# How to List Caddy Ports and Proxies

This document explains how to query the Caddy Admin API to list all listening ports and proxy configurations.

## Prerequisites

- Caddy server running with Admin API enabled (default: `localhost:2019`)
- `curl` and `jq` installed

## List All Listening Ports

To see which ports Caddy is listening on:

```bash
curl http://localhost:2019/config/apps/http/servers 2>/dev/null | jq -r '.[] | .listen[]? // empty' | sort -u
```

**Output example:**
```
:443
```

The Admin API itself runs on `localhost:2019` by default (not shown in the servers config).

## List All Proxy Configurations

To get a complete list of all domains and their backend proxies:

```bash
curl http://localhost:2019/config/apps/http/servers 2>/dev/null | jq -r '
  .srv0.routes[] |
  select(.match[0].host) |
  {
    domain: .match[0].host[0],
    backend: (.handle[0].routes[0].handle[0].upstreams // .handle[0].routes[].handle[0].upstreams // empty)
  } |
  if .backend then
    "\(.domain) -> \(.backend | if type == "array" then map(.dial) | join(", ") else .dial end)"
  else
    empty
  end
' | sort
```

**Output example:**
```
ai.invideo.localhost -> :3000
autobrr.raxx.localhost -> :9012
llb-pro-api.invideo.localhost -> :4000, :4001
raxx.localhost -> :9000
```

## Understanding the Output

### Listening Ports
- These are the ports Caddy **listens on** for incoming connections
- Typically `:443` for HTTPS and `:80` for HTTP (auto-redirects to HTTPS)
- Admin API runs on `localhost:2019` by default

### Proxy Backends
- Shows the mapping: `domain -> backend_port(s)`
- Multiple ports indicate load balancing (e.g., `:4000, :4001`)
- All domains are accessed via the listening port (usually :443)

## How It Works

### The jq Query Breakdown

1. **Extract server config:** `.srv0.routes[]` - Iterates through all routes in the main server
2. **Filter routes with hosts:** `select(.match[0].host)` - Only routes that match specific hostnames
3. **Extract domain and backend:**
   - `domain: .match[0].host[0]` - Gets the first hostname from the match
   - `backend: (.handle[0].routes[0].handle[0].upstreams // ...)` - Extracts upstream dial addresses
4. **Format output:** Combines domain and backend(s) with arrow notation
5. **Sort:** Alphabetically sorts the results

### Admin API Endpoints

- `/config/` - Full Caddy configuration
- `/config/apps/http/servers` - HTTP servers and their configurations
- `/config/apps/http/servers/srv0/routes` - Individual routes and handlers

## Alternative: View Full Server Config

To see the complete server configuration with all details:

```bash
curl http://localhost:2019/config/apps/http/servers | jq
```

This shows everything including:
- Listen addresses
- Routes and matchers
- Handler configurations
- TLS settings
- Load balancing policies

## OS-Level Verification

To verify what Caddy is actually listening on at the OS level:

```bash
# macOS/Linux
lsof -i -P | grep caddy

# Or with netstat
netstat -an | grep LISTEN | grep caddy

# Linux with ss
ss -tlnp | grep caddy
```

This shows the actual network sockets Caddy has opened, which should match the Admin API configuration.

## Common Use Cases

### Check if a domain is configured
```bash
curl http://localhost:2019/config/apps/http/servers 2>/dev/null | jq -r '.srv0.routes[].match[0].host[]?' | grep "example.localhost"
```

### Find backend for specific domain
```bash
curl http://localhost:2019/config/apps/http/servers 2>/dev/null | jq -r '
  .srv0.routes[] |
  select(.match[0].host[0] == "ai.invideo.localhost") |
  .handle[0].routes[0].handle[0].upstreams[].dial
'
```

### Count total proxies
```bash
curl http://localhost:2019/config/apps/http/servers 2>/dev/null | jq -r '
  .srv0.routes[] |
  select(.match[0].host) |
  .match[0].host[0]
' | wc -l
```

## Notes

- The Admin API must be accessible (default: `localhost:2019`)
- Server name may vary (e.g., `srv0`, `srv1`); adjust the query accordingly
- For multiple servers, iterate through all server objects
- The API returns JSON, making it perfect for programmatic access
