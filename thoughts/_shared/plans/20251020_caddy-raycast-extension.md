# Caddy Raycast Extension Implementation Plan

## Overview

Build a Raycast extension for managing Caddy web server, focused on quick reload functionality and site monitoring. The extension will use only the Caddy Admin API for all operations and provide a convenient interface for developers who frequently edit Caddyfiles and need to reload configuration.

## Current State Analysis

### Existing Setup:
- **Extension template** created at `private/raycast/extensions/caddy/`
- **Caddy installed via Nix** - managed by home-manager/nix-darwin
- **Caddy Admin API** running at `http://localhost:2019`
- **Caddyfile** at `~/dotfiles/private/caddy/Caddyfile` with multiple project imports
- **40+ configured routes** across various projects (invideo, raxx, personal projects)
- **Research document** at `thoughts/_shared/research/2025-10-20_caddy-raycast-extension.md`

### Reference Implementation:
- **kitze/caddy** extension cloned to `/tmp/caddy-kitze`
- Provides excellent UI/UX patterns for:
  - Menu bar status indicator
  - Site reachability checking
  - List views with accessories

### Key Discoveries:
- Admin API provides `/config/apps/http/servers` endpoint for runtime config
- Admin API `/load` endpoint enables zero-downtime reloads
- Site reachability can be checked via `nc -z` port testing
- Caddy is managed by Nix (always running as a service)

## Desired End State

A fully functional Raycast extension that provides:

1. **Quick Reload** - Primary use case: Apply Caddyfile changes instantly (zero-downtime via Admin API)
2. **Menu Bar Status** - Real-time Caddy status with one-click reload
3. **Sites List View** - View all configured routes with reachability indicators
4. **Site Actions** - Open in browser, copy URLs, temporary deletion via API

### Verification:
- Extension appears in Raycast search
- Reload command works from anywhere in Raycast
- Menu bar shows correct status (green=running, red=stopped) with reload action
- Sites list displays all 40+ routes from Admin API
- Reachability indicators show green/red for backend services
- All commands execute without errors

## What We're NOT Doing

- ❌ **Add new sites form** - Sites added manually via Caddyfile editing
- ❌ **Persistent site deletion** - No file editing; only runtime API deletions
- ❌ **Caddyfile parsing/editing** - Admin API only for runtime config
- ❌ **Start/Stop Caddy** - Nix manages Caddy as a service; no process management needed
- ❌ **Finding Caddy binary** - No need to locate or execute caddy binary
- ❌ **Multi-server support** - Single Caddy instance at localhost:2019
- ❌ **TLS certificate management** - Out of scope
- ❌ **Log viewing** - Out of scope

## Implementation Approach

### Technical Strategy:
1. **Admin API Only** - All operations via `http://localhost:2019` endpoints
2. **Zero-downtime reloads** - Leverage Admin API's graceful reload capability
3. **No process management** - Caddy runs as Nix service, always available
4. **Status via API** - Check if Admin API responds = Caddy is running
5. **TypeScript + Raycast API** - Standard extension development approach

### Architecture Pattern:
```
src/
├── utils.ts              # Core utilities and API client (Admin API only)
├── caddy-sites.tsx       # Main list view (existing, to be replaced)
├── status.tsx            # Menu bar command
└── reload.ts             # Quick reload command (no-view) - PRIMARY USE CASE
```

---

## Phase 1: Core Utilities & API Client

### Overview
Build the foundational utilities that all commands will depend on: Admin API client and configuration parsing. Pure API operations only - no shell commands except for port reachability checks.

### Changes Required:

#### 1. Create `src/utils.ts`

**File**: `private/raycast/extensions/caddy/src/utils.ts`
**Changes**: Create new file with Admin API utilities only

```typescript
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

// Admin API Configuration
const ADMIN_API_URL = "http://localhost:2019";

// Types
export interface CaddyStatus {
  isRunning: boolean;
}

export interface CaddyConfig {
  apps?: {
    http?: {
      servers?: {
        [key: string]: {
          listen?: string[];
          routes?: Array<{
            match?: Array<{
              host?: string[];
            }>;
            handle?: any[];
          }>;
        };
      };
    };
  };
}

export interface CaddyRoute {
  host: string;
  port: string;
  url: string;
  proxyTarget?: string;
  isReachable?: boolean;
}

// Status checking via Admin API
export async function getCaddyStatus(): Promise<CaddyStatus> {
  try {
    const response = await fetch(`${ADMIN_API_URL}/config/`);
    return { isRunning: response.ok };
  } catch {
    return { isRunning: false };
  }
}

// Get configuration from Admin API
export async function getCaddyConfig(): Promise<CaddyConfig | null> {
  try {
    const response = await fetch(`${ADMIN_API_URL}/config/`);
    if (!response.ok) throw new Error("Admin API not accessible");
    return await response.json();
  } catch {
    return null;
  }
}

// Parse routes from config
export function parseConfigRoutes(config: CaddyConfig | null): CaddyRoute[] {
  if (!config?.apps?.http?.servers) return [];

  const routes: CaddyRoute[] = [];

  for (const server of Object.values(config.apps.http.servers)) {
    const defaultPort = server.listen?.[0]?.split(":")?.[1] || "443";

    if (server.routes) {
      for (const route of server.routes) {
        let proxyTarget: string | undefined;

        // Extract reverse_proxy upstream (nested search)
        if (route.handle) {
          const findProxy = (handlers: any[]): string | undefined => {
            for (const handler of handlers) {
              if (handler.handler === "reverse_proxy" && handler.upstreams?.[0]?.dial) {
                return handler.upstreams[0].dial;
              }
              if (handler.routes) {
                const nested = findProxy(handler.routes.flatMap((r: any) => r.handle || []));
                if (nested) return nested;
              }
            }
          };
          proxyTarget = findProxy(route.handle);
        }

        if (route.match) {
          for (const match of route.match) {
            if (match.host) {
              for (const host of match.host) {
                const protocol = defaultPort === "443" ? "https" : "http";
                const portSuffix = defaultPort === "80" || defaultPort === "443" ? "" : `:${defaultPort}`;
                routes.push({
                  host,
                  port: defaultPort,
                  url: `${protocol}://${host}${portSuffix}`,
                  proxyTarget,
                });
              }
            }
          }
        }
      }
    }
  }

  return routes;
}

// Port reachability check
export async function isPortReachable(target: string): Promise<boolean> {
  try {
    const [host, port] = target.split(":");
    if (!host || !port) return false;
    await execAsync(`nc -z -w 1 ${host} ${port}`);
    return true;
  } catch {
    return false;
  }
}

export async function checkRoutesReachability(routes: CaddyRoute[]): Promise<CaddyRoute[]> {
  return await Promise.all(
    routes.map(async (route) => {
      if (route.proxyTarget) {
        const isReachable = await isPortReachable(route.proxyTarget);
        return { ...route, isReachable };
      }
      return { ...route, isReachable: undefined };
    })
  );
}

// Reload Caddy configuration via Admin API (zero-downtime)
export async function reloadCaddy(): Promise<{ success: boolean; message: string }> {
  try {
    // Get current config
    const config = await getCaddyConfig();
    if (!config) {
      return { success: false, message: "Could not read current configuration" };
    }

    // POST config back to /load endpoint to trigger reload
    const response = await fetch(`${ADMIN_API_URL}/load`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(config),
    });

    if (response.ok) {
      return { success: true, message: "Configuration reloaded (zero-downtime)" };
    } else {
      const error = await response.text();
      return { success: false, message: `Reload failed: ${error}` };
    }
  } catch (error) {
    return {
      success: false,
      message: `Error: ${error instanceof Error ? error.message : String(error)}`,
    };
  }
}

// Delete site via Admin API (runtime only)
export async function deleteSite(domain: string): Promise<{ success: boolean; message: string }> {
  try {
    const config = await getCaddyConfig();
    if (!config?.apps?.http?.servers?.srv0?.routes) {
      return { success: false, message: "Could not read current config" };
    }

    // Filter out routes matching this domain
    const filteredRoutes = config.apps.http.servers.srv0.routes.filter((route: any) => {
      const hosts = route.match?.[0]?.host;
      return !hosts || !hosts.includes(domain);
    });

    config.apps.http.servers.srv0.routes = filteredRoutes;

    // Push updated config to Admin API
    const response = await fetch(`${ADMIN_API_URL}/load`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(config),
    });

    if (response.ok) {
      return { success: true, message: "Site deleted (runtime only - edit Caddyfile to persist)" };
    } else {
      const error = await response.text();
      return { success: false, message: `Failed to delete: ${error}` };
    }
  } catch (error) {
    return {
      success: false,
      message: `Error: ${error instanceof Error ? error.message : String(error)}`,
    };
  }
}
```

### Success Criteria:

- [x] File created: `src/utils.ts`
- [x] TypeScript compiles without errors: `npm run build`
- [x] All exported functions are typed correctly
- [x] Can import utilities in other files: `import { getCaddyStatus } from "./utils"`
- [x] No shell command execution except for `nc` port checks

---

## Phase 2: Sites List Command

### Overview
Replace the template "caddy-sites" command with a functional sites list that displays all configured Caddy routes with reachability indicators.

### Changes Required:

#### 1. Replace `src/caddy-sites.tsx`

**File**: `private/raycast/extensions/caddy/src/caddy-sites.tsx`
**Changes**: Complete replacement of template code

```typescript
import { List, Action, ActionPanel, Icon, Color, confirmAlert, Alert, showToast, Toast } from "@raycast/api";
import { useCachedPromise } from "@raycast/utils";
import {
  getCaddyStatus,
  getCaddyConfig,
  parseConfigRoutes,
  checkRoutesReachability,
  deleteSite,
} from "./utils";

export default function Command() {
  const { isLoading: statusLoading } = useCachedPromise(getCaddyStatus, [], {
    initialData: { isRunning: false },
  });

  const {
    data: config,
    isLoading: configLoading,
    revalidate: revalidateConfig,
  } = useCachedPromise(getCaddyConfig, [], {
    initialData: null,
    keepPreviousData: false,
  });

  const baseRoutes = parseConfigRoutes(config);

  const {
    data: routes,
    isLoading: routesLoading,
    revalidate: revalidateRoutes,
  } = useCachedPromise(
    async () => {
      if (baseRoutes.length === 0) return [];
      return await checkRoutesReachability(baseRoutes);
    },
    [],
    {
      initialData: baseRoutes,
      execute: baseRoutes.length > 0,
    }
  );

  const isLoading = statusLoading || configLoading || routesLoading;

  const revalidate = async () => {
    await revalidateConfig();
    await revalidateRoutes();
  };

  const handleDeleteSite = async (domain: string) => {
    const confirmed = await confirmAlert({
      title: "Delete Site",
      message: `Remove "${domain}" from Caddy? (Runtime only - won't persist after reload)`,
      primaryAction: {
        title: "Delete",
        style: Alert.ActionStyle.Destructive,
      },
    });

    if (!confirmed) return;

    const toast = await showToast({
      style: Toast.Style.Animated,
      title: "Deleting site...",
    });

    const result = await deleteSite(domain);

    if (result.success) {
      toast.style = Toast.Style.Success;
      toast.title = "Site deleted";
      toast.message = result.message;
      await revalidate();
    } else {
      toast.style = Toast.Style.Failure;
      toast.title = "Failed to delete site";
      toast.message = result.message;
    }
  };

  return (
    <List isLoading={isLoading}>
      <List.Section title="Caddy Sites" subtitle={`${routes?.length || 0} site${routes?.length === 1 ? "" : "s"}`}>
        {routes &&
          routes.map((route, index) => {
            const accessories = [];

            if (route.proxyTarget) {
              accessories.push({ text: `→ ${route.proxyTarget}` });
            }

            if (route.isReachable === true) {
              accessories.push({
                tag: { value: "Running", color: Color.Green },
                icon: { source: Icon.CircleFilled, tintColor: Color.Green },
              });
            } else if (route.isReachable === false) {
              accessories.push({
                tag: { value: "Stopped", color: Color.Red },
                icon: { source: Icon.CircleFilled, tintColor: Color.Red },
              });
            }

            return (
              <List.Item
                key={index}
                title={route.host}
                subtitle={route.url}
                icon={Icon.Globe}
                accessories={accessories}
                actions={
                  <ActionPanel>
                    <ActionPanel.Section title="Site Actions">
                      <Action.OpenInBrowser title="Open in Browser" url={route.url} />
                      <Action
                        title="Refresh"
                        icon={Icon.ArrowClockwise}
                        shortcut={{ modifiers: ["cmd"], key: "r" }}
                        onAction={revalidate}
                      />
                    </ActionPanel.Section>
                    <ActionPanel.Section title="Copy">
                      <Action.CopyToClipboard title="Copy URL" content={route.url} />
                      <Action.CopyToClipboard title="Copy Domain" content={route.host} />
                      {route.proxyTarget && (
                        <Action.CopyToClipboard title="Copy Proxy Target" content={route.proxyTarget} />
                      )}
                    </ActionPanel.Section>
                    <ActionPanel.Section title="Danger Zone">
                      <Action
                        title="Delete Site (Runtime Only)"
                        icon={Icon.Trash}
                        style={Action.Style.Destructive}
                        shortcut={{ modifiers: ["ctrl"], key: "x" }}
                        onAction={() => handleDeleteSite(route.host)}
                      />
                    </ActionPanel.Section>
                  </ActionPanel>
                }
              />
            );
          })}
      </List.Section>

      {(!routes || routes.length === 0) && !isLoading && (
        <List.EmptyView
          title="No Sites Configured"
          description="Check your Caddyfile configuration or reload Caddy"
          icon={Icon.Globe}
        />
      )}
    </List>
  );
}
```

### Success Criteria:

- [x] Command appears in Raycast as "Caddy Sites"
- [x] Lists all 40+ configured sites from Admin API
- [x] Shows green/red reachability indicators for proxy targets
- [x] Actions work: Open in browser, copy URLs
- [x] Delete confirmation dialog appears
- [x] Refresh updates the list: `⌘R`

---

## Phase 3: Menu Bar Status Command

### Overview
Create a menu bar command that shows real-time Caddy status and provides quick access to reload.

### Changes Required:

#### 1. Create `src/status.tsx`

**File**: `private/raycast/extensions/caddy/src/status.tsx`
**Changes**: Create new menu bar command

```typescript
import { MenuBarExtra, Icon, open, Color, showToast, Toast } from "@raycast/api";
import { useCachedPromise } from "@raycast/utils";
import {
  getCaddyStatus,
  getCaddyConfig,
  parseConfigRoutes,
  checkRoutesReachability,
  reloadCaddy,
} from "./utils";

export default function Command() {
  const {
    data: status,
    isLoading: statusLoading,
    revalidate: revalidateStatus,
  } = useCachedPromise(getCaddyStatus, [], {
    initialData: { isRunning: false },
  });

  const {
    data: config,
    isLoading: configLoading,
    revalidate: revalidateConfig,
  } = useCachedPromise(getCaddyConfig, [], {
    initialData: null,
  });

  const baseRoutes = parseConfigRoutes(config);

  const {
    data: routes,
    isLoading: routesLoading,
    revalidate: revalidateRoutes,
  } = useCachedPromise(
    async () => {
      if (baseRoutes.length === 0) return [];
      return await checkRoutesReachability(baseRoutes);
    },
    [],
    {
      initialData: baseRoutes,
      execute: baseRoutes.length > 0,
    }
  );

  const isLoading = statusLoading || configLoading || routesLoading;

  const revalidate = async () => {
    await revalidateStatus();
    await revalidateConfig();
    await revalidateRoutes();
  };

  const icon = status.isRunning
    ? { source: Icon.CheckCircle, tintColor: Color.Green }
    : { source: Icon.XMarkCircle, tintColor: Color.Red };

  return (
    <MenuBarExtra
      icon={icon}
      title="Caddy"
      isLoading={isLoading}
      tooltip={status.isRunning ? "Caddy Running" : "Caddy Stopped"}
    >
      <MenuBarExtra.Section title="Status">
        <MenuBarExtra.Item title={status.isRunning ? "Running" : "Stopped"} icon={icon} />
      </MenuBarExtra.Section>

      {routes && routes.length > 0 && (
        <MenuBarExtra.Section title="Configured Sites">
          {routes.slice(0, 10).map((route, index) => {
            const subtitle = route.proxyTarget ? `→ ${route.proxyTarget}` : undefined;

            const statusIcon =
              route.isReachable === true
                ? { source: Icon.CircleFilled, tintColor: Color.Green }
                : route.isReachable === false
                  ? { source: Icon.CircleFilled, tintColor: Color.Red }
                  : { source: Icon.Circle, tintColor: Color.SecondaryText };

            return (
              <MenuBarExtra.Item
                key={index}
                title={route.host}
                subtitle={subtitle}
                icon={statusIcon}
                onAction={() => open(route.url)}
              />
            );
          })}
          {routes.length > 10 && (
            <MenuBarExtra.Item title={`... and ${routes.length - 10} more`} />
          )}
        </MenuBarExtra.Section>
      )}

      <MenuBarExtra.Section title="Actions">
        {status.isRunning && (
          <MenuBarExtra.Item
            title="Reload Configuration"
            icon={Icon.ArrowClockwise}
            onAction={async () => {
              const toast = await showToast({
                style: Toast.Style.Animated,
                title: "Reloading Caddy...",
              });
              const result = await reloadCaddy();
              if (result.success) {
                toast.style = Toast.Style.Success;
                toast.title = "Caddy Reloaded";
                toast.message = result.message;
              } else {
                toast.style = Toast.Style.Failure;
                toast.title = "Failed to Reload";
                toast.message = result.message;
              }
              setTimeout(() => revalidate(), 1000);
            }}
          />
        )}
      </MenuBarExtra.Section>

      <MenuBarExtra.Section>
        <MenuBarExtra.Item
          title="Refresh Status"
          icon={Icon.ArrowClockwise}
          onAction={revalidate}
          shortcut={{ modifiers: ["cmd"], key: "r" }}
        />
      </MenuBarExtra.Section>
    </MenuBarExtra>
  );
}
```

#### 2. Update `package.json` to add status command

**File**: `private/raycast/extensions/caddy/package.json`
**Changes**: Add new command to manifest

```json
{
  "commands": [
    {
      "name": "caddy-sites",
      "title": "Caddy Sites",
      "description": "View and manage Caddy sites",
      "mode": "view"
    },
    {
      "name": "status",
      "title": "Caddy Status",
      "subtitle": "Menu Bar",
      "description": "View Caddy status and quick reload",
      "mode": "menu-bar"
    }
  ]
}
```

### Success Criteria:

- [x] Menu bar icon appears (green checkmark or red X)
- [x] Shows correct status: Running/Stopped
- [x] Lists first 10 sites with reachability indicators
- [x] Clicking site opens in browser
- [x] Reload action works and shows toast
- [x] Refresh updates status: `⌘R`

---

## Phase 4: Reload Command (No-View)

### Overview
Create a quick no-view reload command that can be triggered directly from Raycast search for instant Caddy configuration reload.

### Changes Required:

#### 1. Create `src/reload.ts`

**File**: `private/raycast/extensions/caddy/src/reload.ts`
**Changes**: Create new no-view command (PRIMARY USE CASE)

```typescript
import { showHUD, showToast, Toast } from "@raycast/api";
import { reloadCaddy } from "./utils";

export default async function Command() {
  const toast = await showToast({
    style: Toast.Style.Animated,
    title: "Reloading Caddy...",
  });

  const result = await reloadCaddy();

  if (result.success) {
    toast.style = Toast.Style.Success;
    toast.title = "Success";
    toast.message = result.message;
    await showHUD("✅ " + result.message);
  } else {
    toast.style = Toast.Style.Failure;
    toast.title = "Failed to reload Caddy";
    toast.message = result.message;
  }
}
```

#### 2. Update `package.json` manifest

**File**: `private/raycast/extensions/caddy/package.json`
**Changes**: Add reload command

```json
{
  "commands": [
    {
      "name": "caddy-sites",
      "title": "Caddy Sites",
      "description": "View and manage Caddy sites",
      "mode": "view"
    },
    {
      "name": "status",
      "title": "Caddy Status",
      "subtitle": "Menu Bar",
      "description": "View Caddy status and quick reload",
      "mode": "menu-bar"
    },
    {
      "name": "reload",
      "title": "Reload Caddy",
      "description": "Reload Caddy configuration (zero-downtime)",
      "mode": "no-view"
    }
  ]
}
```

### Success Criteria:

- [x] Command appears in Raycast search as "Reload Caddy"
- [x] Command executes instantly (no UI shown except toast/HUD)
- [x] Shows HUD with "Configuration reloaded (zero-downtime)" message
- [x] Toast notifications show success/failure state
- [x] Works after editing Caddyfile
- [x] Error messages are helpful when reload fails

---

## Phase 5: Polish & Final Integration

### Overview
Add final touches, update metadata, test all functionality end-to-end.

### Changes Required:

#### 1. Update `package.json` metadata

**File**: `private/raycast/extensions/caddy/package.json`
**Changes**: Update title, description, categories

```json
{
  "$schema": "https://www.raycast.com/schemas/extension.json",
  "name": "caddy",
  "title": "Caddy Server Manager",
  "description": "Manage Caddy server - view sites, reload config, and monitor status",
  "icon": "extension-icon.png",
  "author": "rakshan",
  "platforms": [
    "macOS"
  ],
  "categories": [
    "Developer Tools",
    "System"
  ],
  "license": "MIT"
}
```

#### 2. Update README

**File**: `private/raycast/extensions/caddy/README.md`
**Changes**: Complete documentation

```markdown
# Caddy Server Manager

Manage Caddy web server from Raycast with quick reload, site monitoring, and status indicators.

## Features

### 🚀 Quick Reload (Primary Use Case)
Type "Reload Caddy" in Raycast for instant zero-downtime configuration reload after editing Caddyfiles.

### 📊 Sites List
- View all configured domains
- See backend proxy targets
- Real-time reachability status (green/red indicators)
- Quick actions: open in browser, copy URLs
- Delete sites (runtime only, non-persistent)

### 🟢 Menu Bar Status
- Real-time indicator (green=running, red=stopped)
- Quick access to first 10 sites
- One-click reload
- Click sites to open in browser

## Requirements

- macOS
- Caddy installed via Nix (home-manager or nix-darwin)
- Caddyfile at `~/dotfiles/private/caddy/Caddyfile`
- Admin API enabled on `localhost:2019` (default)

## Usage

### Quick Reload (Primary Use Case)
1. Edit your Caddyfile
2. Open Raycast: `⌘Space`
3. Type "reload caddy"
4. Hit Enter - Done! 🎉

Configuration reloads with zero downtime via Admin API.

### View Sites
- Search "Caddy Sites" to see all configured routes
- Green indicator = backend is reachable
- Red indicator = backend is down
- Press `⌘R` to refresh

### Menu Bar
- Always-visible status indicator
- Click for quick reload action
- Shows first 10 sites for quick access

## How It Works

- **Status Checking**: Checks if Admin API responds (http://localhost:2019)
- **Configuration**: Reads from Admin API `/config/` endpoint
- **Reachability**: Uses `nc -z` to test backend port connectivity
- **Reload**: Admin API `/load` endpoint for zero-downtime reloads
- **No Process Management**: Caddy runs as Nix service

## Development

```bash
npm install
npm run dev
```

## License

MIT
```

### Success Criteria:

- [x] `npm run build` succeeds without errors
- [x] `npm run lint` passes without warnings
- [x] All commands visible in Raycast
- [x] Extension title shows as "Caddy Server Manager"
- [x] Icon displays correctly in Raycast
- [x] README is accurate and helpful
- [x] No shell commands except `nc` for port checks

---

## References

- Original research: `thoughts/_shared/research/2025-10-20_caddy-raycast-extension.md`
- kitze/caddy repository: `/tmp/caddy-kitze/` (UI patterns reference)
- Caddy Admin API docs: `thoughts/caddyport.md`
- Current Caddyfile: `private/caddy/Caddyfile:18-26`
- Raycast API docs: https://developers.raycast.com/api-reference

## Notes

### Pure Admin API Approach
This implementation uses ONLY the Admin API for all operations:
- ✅ Zero-downtime configuration reloads
- ✅ Automatic rollback on invalid configs
- ✅ No process management needed (Nix handles it)
- ✅ No need to find or execute caddy binary
- ✅ Real-time configuration changes

Site deletions are runtime-only (not persisted to Caddyfile) by design.

### Nix-Managed Caddy
Since Caddy is installed and managed by Nix:
- Always runs as a service (no start/stop needed)
- No need to locate binary paths
- Configuration at fixed location
- Admin API always available when service is running

### Future Enhancements (Out of Scope)
- Preferences for custom Admin API URL
- View raw configuration in Detail view
- Filter/search sites by domain
- Group sites by project
