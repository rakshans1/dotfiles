---
date: 2025-10-20T12:30:00-07:00
researcher: rakshans1
git_commit: 9155bbcdce61e8dfa74135d91a494d8140473645
branch: main
repository: dotfiles
topic: "Creating a Raycast Extension for Caddy Server Management"
tags: [research, raycast, caddy, typescript, extension, admin-api]
status: complete
last_updated: 2025-10-20
last_updated_by: rakshans1
---

# Research: Creating a Raycast Extension for Caddy Server Management

## Research Question

How to create a TypeScript-based Raycast extension in `private/raycast/extensions/` to manage Caddy server based on the Caddy Admin API documentation (`thoughts/caddyport.md`) and inspired by kitze/caddy repository patterns?

## Summary

A Raycast extension for Caddy server management should be built using TypeScript/React with the official Raycast API. The extension will interact with Caddy's Admin API (default: `http://localhost:2019`) to provide server management capabilities directly from Raycast. Key findings:

1. **kitze/caddy repository** - The specific repository doesn't exist publicly at the provided URL, but Kitze has created "Caddy Control for Raycast" (mentioned on kitze.io) which serves as inspiration for this project.

2. **Raycast Extensions vs Script-Commands** - Current setup uses script-commands (bash scripts in `private/raycast/scripts/`), but extensions provide richer UI and deeper integration via TypeScript/React components.

3. **Caddy Admin API** - Provides comprehensive REST endpoints for zero-downtime configuration management, route control, and server monitoring at `localhost:2019`.

4. **Architecture Pattern** - Follow the Docker extension pattern (official Raycast extension) for managing local services with List views, Detail views, and Actions.

5. **Development Workflow** - Use `npm install && npm run dev` for hot-reloading development, with extensions appearing at the top of Raycast search.

## Detailed Findings

### Current Codebase Structure

**Location**: `private/raycast/`

**Current Files**:
- `scripts/` - Contains Raycast script-commands (bash scripts with metadata)
  - `blog.sh` - Build/deploy blog with dropdown argument
  - `brain.sh` - Build/deploy brain-public with dropdown argument
  - `blob.sh`, `clipboard-ocr.sh`, `session-id.sh` - Various utilities
  - `CLAUDE.md` - Documentation for script-commands
  - `CONTRIBUTORS.md` - Detailed script-command guide
- `Snippets.json` - Elixir code snippets for Raycast

**Missing**:
- `extensions/` directory - Needs to be created for TypeScript-based extensions

**Caddy Configuration**: `private/caddy/`
- `Caddyfile` - Main configuration importing multiple project Caddyfiles
- Imports from: iv-pro, htpc, brain-public, music, budget, livebooks, bom-gem-25, rakshanshetty.in
- `build/` directory for static files on localhost

### Caddy Admin API Architecture

**Source**: `thoughts/caddyport.md` and official documentation

**Admin API Endpoint**: `http://localhost:2019` (default)

**Key Capabilities**:

1. **List Listening Ports**
   ```bash
   curl http://localhost:2019/config/apps/http/servers 2>/dev/null | \
     jq -r '.[] | .listen[]? // empty' | sort -u
   ```

2. **List All Proxy Configurations**
   ```bash
   curl http://localhost:2019/config/apps/http/servers 2>/dev/null | \
     jq -r '.srv0.routes[] | select(.match[0].host) | ...'
   ```
   Output: `domain -> backend_port(s)` mapping

3. **Core REST Endpoints**:
   - `/config/` - Full configuration retrieval and updates
   - `/load` - Load complete configuration (POST)
   - `/config/apps/http/servers` - Server configurations
   - `/config/apps/http/servers/srv0/routes` - Route details

4. **Features**:
   - Zero-downtime configuration changes
   - Automatic rollback on failure
   - JSON-native config format
   - Optimistic concurrency control (ETag/If-Match)
   - No authentication required for localhost (can use Unix sockets for security)

### Raycast Extension Development

**Source**: Web research and official documentation

**Project Structure**:
```
private/raycast/extensions/caddy/
├── package.json          # Manifest (superset of npm package.json)
├── tsconfig.json         # TypeScript configuration
├── src/
│   ├── index.tsx        # Main command entry
│   ├── list-servers.tsx # List view for servers
│   ├── view-config.tsx  # Detail view for configuration
│   └── api/
│       └── caddy.ts     # Caddy Admin API client
└── assets/
    └── icon.png         # Extension icon
```

**Core UI Components**:

1. **List Component** - De-facto UI for displaying multiple items
   - Perfect for listing Caddy routes/servers
   - Supports search, filtering, accessories
   - Actions available via ActionPanel

2. **Detail Component** - Detailed information view
   - Markdown support for configuration display
   - Optional metadata panel
   - Ideal for showing Caddyfile content, server status

3. **Form Component** - Data collection
   - Great for adding new reverse proxy rules
   - Type-safe input validation
   - Could support quick templates

4. **Actions & ActionPanel** - User interactions
   - Built-in actions: copy to clipboard, open browser
   - Custom actions: reload config, add route, delete server
   - Keyboard shortcuts for common operations

**HTTP Requests to Caddy API**:

```typescript
// Option 1: Native fetch (Node.js)
const response = await fetch("http://localhost:2019/config/");
const config = await response.json();

// Option 2: @raycast/utils package
import { useFetch } from "@raycast/utils";

const { data, isLoading, error } = useFetch("http://localhost:2019/config/", {
  headers: { "Content-Type": "application/json" }
});
```

**Preferences API** - Configuration storage:
```typescript
// Extension preferences for API endpoint
interface Preferences {
  adminApiUrl: string; // Default: "http://localhost:2019"
  autoRefresh: boolean;
  refreshInterval: number; // seconds
}
```

**Development Commands**:
```bash
# Create extension
# Use Raycast's "Create Extension" command, select location: private/raycast/extensions/

# Install dependencies and start development
cd private/raycast/extensions/caddy
npm install && npm run dev

# Extension appears at top of Raycast search with hot-reloading
```

### Reference: Docker Extension Pattern

**Source**: https://github.com/raycast/extensions/tree/main/extensions/docker

The Docker extension provides an excellent template for server management:

**Features**:
- List containers with status indicators
- Start/stop/restart actions
- View logs in Detail view
- Inspect configuration
- Quick actions for common operations

**Applicable Patterns**:
```typescript
// List View with Status
<List isLoading={isLoading}>
  {servers.map((server) => (
    <List.Item
      key={server.id}
      title={server.domain}
      subtitle={server.backend}
      accessories={[{ text: server.status }]}
      actions={
        <ActionPanel>
          <Action.Push title="View Config" target={<ConfigDetail server={server} />} />
          <Action title="Reload Config" onAction={() => reloadConfig(server.id)} />
        </ActionPanel>
      }
    />
  ))}
</List>
```

### kitze/caddy Research

**Finding**: Repository https://github.com/kitze/caddy not publicly accessible

**Evidence**:
- Kitze's website (kitze.io) lists "Caddy Control for Raycast" as a project
- Repository may be private, unpublished, or located elsewhere
- Similar community projects exist:
  - **caddy-gui** (ArsFy): GUI-based configuration editor
  - **caddyui** (jlbyh2o): Web UI for managing reverse proxies

**Inference**:
The extension concept is validated by Kitze's existing work. Even without access to the source, we have:
- Official Caddy Admin API documentation
- Raycast extension patterns from Docker/MCP examples
- Clear use case for Caddy management via Raycast

### Extensions vs Script-Commands

**Script-Commands** (`private/raycast/scripts/`):
- ✅ Simple, quick automation
- ✅ Any language (bash, Python, Node.js)
- ✅ Minimal setup
- ❌ No custom UI
- ❌ No state management
- ❌ Limited interactivity

**Extensions** (`private/raycast/extensions/`):
- ✅ Rich UI components (List, Detail, Form)
- ✅ Deep API integration
- ✅ State management and navigation
- ✅ TypeScript type safety
- ✅ Full npm ecosystem
- ❌ More complex setup
- ❌ Requires TypeScript/React knowledge

**Recommendation**: Use extension for Caddy management due to:
- Multiple views needed (list servers, view config, edit routes)
- State management (cached configuration, live updates)
- Rich interactions (add/remove/edit routes)
- Real-time status updates

## Code References

- `thoughts/caddyport.md` - Complete Caddy Admin API documentation and query examples
- `private/raycast/scripts/blog.sh:10-11` - Example of dropdown argument metadata
- `private/raycast/scripts/brain.sh:20-43` - Pattern for project-based commands
- `private/caddy/Caddyfile:18-26` - Current Caddy configuration with multiple imports
- `private/raycast/scripts/CLAUDE.md` - Documentation for script-commands architecture

## Architecture Insights

### Recommended Extension Structure

**Extension Name**: `caddy`

**Commands** (defined in package.json manifest):
1. **List Servers** - Default command showing all configured routes
2. **View Configuration** - Display current Caddyfile/JSON config
3. **Add Reverse Proxy** - Form to add new proxy rule
4. **Reload Configuration** - Quick reload action

**API Client Pattern**:
```typescript
// src/api/caddy.ts
export class CaddyAdminClient {
  constructor(private baseUrl: string = "http://localhost:2019") {}

  async getServers() {
    const response = await fetch(`${this.baseUrl}/config/apps/http/servers`);
    if (!response.ok) throw new Error("Caddy not running");
    return response.json();
  }

  async getRoutes() {
    const servers = await this.getServers();
    return servers.srv0.routes.filter(r => r.match?.[0]?.host);
  }

  async reloadConfig(config: CaddyConfig) {
    const response = await fetch(`${this.baseUrl}/load`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(config)
    });
    if (!response.ok) throw new Error("Failed to reload config");
  }

  async addReverseProxy(domain: string, backend: string) {
    // Implementation: PATCH /config/apps/http/servers/srv0/routes
  }
}
```

**State Management**:
- Use `useFetch` hook from `@raycast/utils` for automatic caching
- Implement optimistic updates for config changes
- Show toast notifications for success/error states
- Cache configuration to reduce API calls

**Error Handling**:
```typescript
try {
  await client.reloadConfig(newConfig);
  showToast(Toast.Style.Success, "Configuration reloaded");
} catch (error) {
  showToast(Toast.Style.Failure, "Failed to reload", error.message);
  // Rollback optimistic update
}
```

### Feature Priorities

**Phase 1 - Essential** (MVP):
- ✅ List all configured routes with domain → backend mapping
- ✅ View current configuration in Detail view
- ✅ Reload configuration action
- ✅ Check Caddy server status
- ✅ Preferences for API endpoint URL

**Phase 2 - Enhanced**:
- Add new reverse proxy via Form
- Edit existing route
- Delete route
- Quick templates (reverse proxy, static files, API gateway)
- Search/filter routes

**Phase 3 - Advanced**:
- View TLS certificates
- Certificate expiration warnings
- Multi-server support (different API endpoints)
- Configuration history/snapshots
- Import/export configurations
- Log viewing

### UI Design Patterns

**List View** - Primary interface:
```typescript
<List isLoading={isLoading} searchBarPlaceholder="Search domains...">
  <List.Section title="Active Routes">
    {routes.map((route) => (
      <List.Item
        key={route.domain}
        title={route.domain}
        subtitle={`→ ${route.backend}`}
        accessories={[
          { text: route.listen || ":443" },
          { icon: Icon.Circle, tooltip: "Active" }
        ]}
        actions={
          <ActionPanel>
            <Action.Push
              title="View Details"
              target={<RouteDetail route={route} />}
            />
            <Action
              title="Reload Config"
              icon={Icon.ArrowClockwise}
              onAction={() => reloadConfig()}
            />
            <Action.CopyToClipboard
              title="Copy Domain"
              content={route.domain}
            />
            <Action.OpenInBrowser
              url={`https://${route.domain}`}
            />
          </ActionPanel>
        }
      />
    ))}
  </List.Section>
</List>
```

**Detail View** - Configuration display:
```typescript
<Detail
  markdown={`
# ${route.domain}

## Configuration

\`\`\`json
${JSON.stringify(route.config, null, 2)}
\`\`\`

## Backend

- **Upstream**: ${route.backend}
- **Listen**: ${route.listen}
- **TLS**: ${route.tls ? "Enabled" : "Disabled"}
  `}
  metadata={
    <Detail.Metadata>
      <Detail.Metadata.Label title="Domain" text={route.domain} />
      <Detail.Metadata.Label title="Backend" text={route.backend} />
      <Detail.Metadata.Separator />
      <Detail.Metadata.Link
        title="Open in Browser"
        target={`https://${route.domain}`}
        text={route.domain}
      />
    </Detail.Metadata>
  }
  actions={
    <ActionPanel>
      <Action title="Edit Route" onAction={() => editRoute(route)} />
      <Action title="Delete Route" onAction={() => deleteRoute(route)} />
    </ActionPanel>
  }
/>
```

**Form View** - Add new proxy:
```typescript
<Form
  actions={
    <ActionPanel>
      <Action.SubmitForm
        title="Add Reverse Proxy"
        onSubmit={handleSubmit}
      />
    </ActionPanel>
  }
>
  <Form.TextField
    id="domain"
    title="Domain"
    placeholder="api.example.localhost"
  />
  <Form.TextField
    id="backend"
    title="Backend Port"
    placeholder=":3000"
  />
  <Form.Dropdown id="protocol" title="Protocol" defaultValue="https">
    <Form.Dropdown.Item value="https" title="HTTPS" />
    <Form.Dropdown.Item value="http" title="HTTP" />
  </Form.Dropdown>
  <Form.Checkbox
    id="autoTls"
    label="Enable Automatic TLS"
    defaultValue={true}
  />
</Form>
```

### Integration with Existing Setup

**Current Caddyfile Pattern**:
```caddy
# Main Caddyfile imports project-specific configs
import /Users/rakshan/workspace/iv-pro/Caddyfile
import /Users/rakshan/projects/htpc/Caddyfile
# ... more imports
```

**Extension Integration**:
1. **Read-only mode initially**: Display imported routes from all Caddyfiles
2. **Future**: Support adding routes to specific imported files or main Caddyfile
3. **Respect imports**: Parse imports to show unified view of all routes
4. **Validation**: Check for conflicts before adding new routes

**Security Considerations**:
- Admin API runs on localhost:2019 (no external access by default)
- No authentication required for local access
- Can configure Unix socket for additional security
- Extension preferences can support custom API URLs for remote management (with authentication)

### package.json Manifest Example

```json
{
  "name": "caddy",
  "title": "Caddy",
  "description": "Manage Caddy web server routes and configuration",
  "icon": "icon.png",
  "author": "rakshan",
  "license": "MIT",
  "commands": [
    {
      "name": "list-servers",
      "title": "List Servers",
      "description": "View all configured Caddy routes and servers",
      "mode": "view"
    },
    {
      "name": "view-config",
      "title": "View Configuration",
      "description": "Display current Caddy configuration",
      "mode": "view"
    },
    {
      "name": "add-proxy",
      "title": "Add Reverse Proxy",
      "description": "Add a new reverse proxy rule",
      "mode": "view"
    }
  ],
  "preferences": [
    {
      "name": "adminApiUrl",
      "type": "textfield",
      "required": false,
      "title": "Admin API URL",
      "description": "Caddy Admin API endpoint",
      "default": "http://localhost:2019",
      "placeholder": "http://localhost:2019"
    },
    {
      "name": "autoRefresh",
      "type": "checkbox",
      "required": false,
      "title": "Auto Refresh",
      "description": "Automatically refresh server list",
      "default": true,
      "label": "Enable auto-refresh"
    },
    {
      "name": "refreshInterval",
      "type": "textfield",
      "required": false,
      "title": "Refresh Interval",
      "description": "Auto-refresh interval in seconds",
      "default": "30"
    }
  ],
  "dependencies": {
    "@raycast/api": "^1.83.2",
    "@raycast/utils": "^1.17.0"
  },
  "devDependencies": {
    "@types/node": "^20.8.10",
    "@types/react": "^18.3.3",
    "typescript": "^5.4.5",
    "prettier": "^3.2.5"
  },
  "scripts": {
    "build": "ray build -e dist",
    "dev": "ray develop",
    "fix-lint": "ray lint --fix",
    "lint": "ray lint"
  }
}
```

## Next Steps

1. **Create Extension Directory**:
   ```bash
   cd ~/dotfiles/private/raycast/
   # Use Raycast "Create Extension" command
   # Or: npm create raycast-extension
   ```

2. **Choose Template**: Select "List" template for initial server listing view

3. **Setup Project**:
   ```bash
   cd extensions/caddy
   npm install
   npm run dev
   ```

4. **Implement MVP** (Phase 1):
   - Create Caddy API client (`src/api/caddy.ts`)
   - Build List view for routes (`src/list-servers.tsx`)
   - Add Detail view for configuration (`src/view-config.tsx`)
   - Implement reload action
   - Add preferences for API endpoint

5. **Test Locally**:
   - Ensure Caddy is running (`caddy run --config ~/dotfiles/private/caddy/Caddyfile`)
   - Verify Admin API is accessible (`curl http://localhost:2019/config/`)
   - Test extension commands in Raycast
   - Validate hot-reloading workflow

6. **Iterate** (Phase 2 & 3):
   - Add Form view for adding proxies
   - Implement edit/delete actions
   - Add templates and advanced features

## Additional Resources

**Official Documentation**:
- Raycast Developers: https://developers.raycast.com
- Getting Started: https://developers.raycast.com/basics/getting-started
- API Reference: https://developers.raycast.com/api-reference
- Extensions Repository: https://github.com/raycast/extensions

**Caddy Resources**:
- Admin API Docs: https://caddyserver.com/docs/api
- Admin API Tutorial: https://caddyserver.com/docs/api-tutorial
- JSON Config Structure: https://caddyserver.com/docs/json/

**Example Extensions**:
- Docker Extension: https://github.com/raycast/extensions/tree/main/extensions/docker
- MCP Server Manager: https://github.com/RMNCLDYO/raycast-mcp-server-manager

**Local Files**:
- `thoughts/caddyport.md` - Caddy Admin API documentation
- `private/raycast/scripts/CLAUDE.md` - Script-commands documentation
- `private/caddy/Caddyfile` - Current Caddy configuration

**Community Resources**:
- DEV.to Tutorial: https://dev.to/orliesaurus/build-your-own-raycast-extension-step-by-step-tutorial-5068
- Raycast Developer Program: https://www.raycast.com/developer-program
