---
date: 2025-10-24 21:25:48 +0530
researcher: Rakshan Shetty
git_commit: d8a4b4cd50c4e5d9f0c4b43444f4740c5b3a9749
branch: main
repository: dotfiles
topic: "Open-source alternatives to custom background job manager with FzF integration"
tags: [research, background-jobs, process-management, fzf, cli-tools]
status: complete
last_updated: 2025-10-24
last_updated_by: Rakshan Shetty
---

# Research: Open-source alternatives to custom background job manager with FzF integration

## Research Question

**Question**: What open-source tools or libraries exist that can replace a custom bash script for managing background processes with features like logging, FzF search, job control, and status tracking?

**Context**: User has developed a custom bash script (`bgrun`) with the following capabilities:
- Run commands in background with automatic logging
- Persistent job database tracking (PID, command, status, timestamps)
- List jobs with status checking
- View logs (with follow mode)
- FzF-based search with preview
- Job control (kill processes)
- Cleanup old job records
- Color-coded status output

## Summary

After comprehensive research across process managers, FzF-integrated tools, and modern CLI job runners, I found **several mature alternatives** that can replace the custom script:

**Best Matches for Direct Replacement**:
1. **Overmind** (Go) - Modern process manager with tmux integration, excellent logging and control
2. **sysz** (bash/systemd) - Perfect FzF integration with systemd for Linux users
3. **tmux-fzf** - Comprehensive tmux session and process manager with FzF
4. **PM2** (Node.js) - Full-featured process manager with monitoring and logging
5. **Supervisor** (Python) - Mature, battle-tested process control system

**Key Finding**: No single tool exactly replicates all custom script features (especially the simple "run any command in background + FzF search" pattern), but several combinations or individual tools can provide superior functionality:
- **For multi-process development**: Overmind + Procfile
- **For Linux with FzF**: sysz + systemd user services
- **For tmux workflows**: tmux-fzf
- **For production-grade management**: Supervisor or PM2

## Detailed Findings

### 1. Process Managers (Procfile-based)

#### Overmind ⭐ Top Recommendation
**Link**: https://github.com/DarthSim/overmind
**Language**: Go
**Installation**: `brew install overmind` or `go install github.com/DarthSim/overmind/v2@latest`

**Key Features**:
- Starts processes defined in Procfile in tmux sessions
- Individual process control (restart without restarting entire stack)
- Automatic process restart on failure
- No output buffering/clipping
- Colored output preserved
- Interactive debugging (attach to any process)
- Port management and process dependencies

**Quick Start**:
```bash
# Create Procfile
echo "web: python -m http.server 8000" > Procfile
echo "worker: python worker.py" >> Procfile

# Start all processes
overmind start

# Connect to specific process
overmind connect web

# Restart specific process
overmind restart worker
```

**Comparison to Custom Script**:
- ✅ Better: Multi-process management, tmux integration, no buffering
- ✅ Better: Interactive debugging capabilities
- ⚠️ Different: Requires Procfile definition (not ad-hoc commands)
- ❌ Missing: No built-in FzF search (but can use tmux-fzf)
- ❌ Missing: No job history database

**Resources**:
- GitHub: https://github.com/DarthSim/overmind
- Official site: https://evilmartians.com/opensource/overmind
- Tutorial: https://pragmaticpineapple.com/control-your-dev-processes-with-overmind/

---

#### Foreman / Honcho / Goreman
**Foreman**: https://github.com/ddollar/foreman (Ruby)
**Honcho**: https://github.com/nickstenning/honcho (Python)
**Goreman**: https://github.com/mattn/goreman (Go)

**Key Features**:
- Original Procfile-based process manager (Heroku standard)
- Environment variable management (.env files)
- Export to systemd/upstart/launchd
- Colored output per process

**Comparison to Custom Script**:
- ⚠️ Similar: Multi-process management with logs
- ❌ Missing: Output buffering issues (Overmind fixes this)
- ❌ Missing: Less granular process control
- ❌ Missing: No FzF integration

---

### 2. FzF-Integrated Process Management

#### sysz ⭐ Perfect for Linux + FzF
**Link**: https://github.com/joehillen/sysz
**Platform**: Linux (systemd)
**Installation**: Download script or install from package manager

**Key Features**:
- Interactive systemctl management via FzF
- User and system units support
- Commands: start, stop, restart, status, edit, enable, disable
- Fast fuzzy searching
- Native systemd integration (journald logging, restart policies)

**Quick Start**:
```bash
# Interactive menu
sysz

# User units only
sysz --user

# Filter specific units
sysz '*docker*'
```

**Comparison to Custom Script**:
- ✅ Better: Perfect FzF integration
- ✅ Better: Native systemd features (logging, restart policies, resource limits)
- ✅ Better: Survives reboots
- ⚠️ Different: Requires creating systemd service files
- ❌ Limitation: Linux-only

**Creating User Service for Ad-hoc Commands**:
```bash
# ~/.config/systemd/user/myapp.service
[Unit]
Description=My Background App

[Service]
ExecStart=/path/to/command
Restart=always

[Install]
WantedBy=default.target

# Enable and start
systemctl --user enable myapp.service
systemctl --user start myapp.service

# View logs with FzF via sysz
sysz --user
```

---

#### tmux-fzf ⭐ For tmux Users
**Link**: https://github.com/sainnhe/tmux-fzf
**Stars**: 1,200+
**Installation**: Via TPM or manual

**Key Features**:
- Session, window, pane management with FzF
- Process management: view with top/pstree, send signals (kill, term, stop, cont)
- Multiple selection support (TAB/Shift-TAB)
- Preview support
- Custom user menu

**Installation**:
```bash
# Using TPM - add to ~/.tmux.conf:
set -g @plugin 'sainnhe/tmux-fzf'

# Press prefix + I to install

# Usage: prefix + F (Shift+F)
```

**Comparison to Custom Script**:
- ✅ Better: Comprehensive tmux integration
- ✅ Better: Process control with signal sending
- ⚠️ Different: Designed for tmux sessions, not standalone background jobs
- ❌ Missing: No persistent job database across reboots

---

#### FzF Native Process Management
**Link**: https://github.com/junegunn/fzf
**Installation**: `brew install fzf`

**Built-in Features**:
- Tab completion for kill: `kill -9 **<TAB>`
- Process filtering: `ps aux | fzf | awk '{print $2}' | xargs kill`
- Log viewing: `tail -f *.log | fzf --tail 100000 --exact --wrap`

**Custom Integration Example**:
```bash
# Add to .bashrc/.zshrc
fkill() {
    local pid
    pid=$(ps aux | sed 1d | fzf -m | awk '{print $2}')
    if [ -n "$pid" ]; then
        echo "$pid" | xargs kill -9
    fi
}
```

**Log Viewing Patterns**:
```bash
# Real-time log filtering
tail -f app.log | fzf --exact --wrap

# With preview window that follows
tail -f *.log | fzf --preview-window follow

# Docker logs
docker logs --follow $container | fzf --exact
```

**Comparison to Custom Script**:
- ✅ Similar: FzF-based process selection
- ⚠️ Different: Requires custom shell functions
- ❌ Missing: No job tracking, no persistent logging, no status database

**Resources**:
- FzF log viewing guide: https://junegunn.github.io/fzf/tips/browsing-log-streams/
- Advanced docs: https://github.com/junegunn/fzf/blob/master/ADVANCED.md

---

#### Additional FzF Tools
- **fzf-kill**: https://github.com/Zeioth/fzf-kill - Dedicated process killer
- **tmux-session**: https://github.com/BartSte/tmux-session - Session manager

---

### 3. Traditional Process Supervisors

#### Supervisor
**Link**: http://supervisord.org/
**Language**: Python
**Installation**: `pip install supervisor` or `brew install supervisor`

**Key Features**:
- Process monitoring and control
- Automatic restart on failure
- Web interface and XML-RPC API
- Event notifications
- Log rotation
- Process groups

**Configuration Example**:
```ini
# /etc/supervisor/conf.d/myapp.conf
[program:myapp]
command=/path/to/command
autostart=true
autorestart=true
stderr_logfile=/var/log/myapp.err.log
stdout_logfile=/var/log/myapp.out.log
```

**Control Commands**:
```bash
supervisorctl start myapp
supervisorctl stop myapp
supervisorctl status
supervisorctl restart myapp
```

**Comparison to Custom Script**:
- ✅ Better: Production-grade reliability
- ✅ Better: Automatic restart policies
- ✅ Better: Web UI and API
- ⚠️ Different: Configuration-based (not ad-hoc commands)
- ❌ Missing: No FzF integration

---

#### PM2
**Link**: https://pm2.keymetrics.io/
**Language**: Node.js
**Installation**: `npm install -g pm2`

**Key Features**:
- Process monitoring and management
- Load balancing and cluster mode
- Log management
- Auto-restart on file changes
- Startup scripts
- Monitoring dashboard

**Quick Start**:
```bash
# Start process
pm2 start app.js --name myapp

# List processes
pm2 list

# Logs
pm2 logs myapp

# Monitoring TUI
pm2 monit

# Save process list
pm2 save
pm2 startup
```

**Comparison to Custom Script**:
- ✅ Better: Feature-rich, built-in monitoring
- ✅ Better: Log aggregation across processes
- ⚠️ Different: Node.js optimized (but works for any app)
- ⚠️ Heavier: Node.js dependency
- ❌ Missing: No FzF integration

---

#### supervisord-go (Modern Alternative)
**Link**: https://github.com/ochinchina/supervisord
**Language**: Go
**Installation**: Build from source (single binary)

**Key Features**:
- Go reimplementation of supervisord
- Single binary, no Python dependency
- Ideal for containers and minimal environments
- Configuration-compatible with Python supervisord

**Comparison to Custom Script**:
- ✅ Better: No runtime dependencies
- ✅ Better: Single binary deployment
- ⚠️ Similar: Configuration-based management
- ❌ Missing: No FzF integration

---

### 4. Modern CLI Task Runners

#### cargo-make
**Link**: https://github.com/sagiegurari/cargo-make
**Language**: Rust
**Installation**: `cargo install cargo-make` or `brew install cargo-make`

**Key Features**:
- Task flow definitions with dependencies
- Parallel task execution
- Cross-platform (macOS/Linux/Windows)
- Plugin system

**Quick Start**:
```toml
# Makefile.toml
[tasks.dev]
command = "python"
args = ["app.py"]

[tasks.worker]
command = "celery"
args = ["worker"]
```

```bash
cargo make dev
```

**Comparison to Custom Script**:
- ⚠️ Different: Task runner, not process manager
- ❌ Missing: No background process supervision
- ❌ Missing: No persistent job tracking

---

#### Dkron (Distributed Scheduler)
**Link**: https://dkron.io/
**Language**: Go
**Installation**: Single binary or Docker

**Key Features**:
- Distributed cron alternative
- Web UI + REST API
- Lightweight daemon
- Multi-platform
- No single point of failure

**Use Case**: Scheduled jobs across multiple machines

**Comparison to Custom Script**:
- ⚠️ Different: Focused on scheduling, not ad-hoc background jobs
- ❌ Missing: No FzF integration

---

### 5. systemd User Services (Linux)

**Documentation**: https://wiki.archlinux.org/title/Systemd/User

**Key Features**:
- Native Linux integration
- User-level services in `~/.config/systemd/user/`
- Automatic restart policies
- Resource limits and controls
- Journald logging integration
- Can combine with sysz for FzF interface

**Service Template for Ad-hoc Commands**:
```bash
# Helper function to create user service
bg_service() {
    local name="$1"
    shift
    local cmd="$@"

    cat > ~/.config/systemd/user/${name}.service <<EOF
[Unit]
Description=${name}

[Service]
ExecStart=${cmd}
Restart=on-failure

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    systemctl --user start ${name}.service
    echo "Started ${name}.service"
}

# Usage
bg_service myapp python app.py

# View logs
journalctl --user -u myapp.service -f

# Manage with sysz
sysz --user
```

**Comparison to Custom Script**:
- ✅ Better: Native OS integration, survives reboots
- ✅ Better: Excellent logging via journald
- ✅ Better: Can combine with sysz for FzF
- ⚠️ Different: Requires service file creation
- ❌ Limitation: Linux-only

---

## Feature Comparison Matrix

| Tool | Background Jobs | Logging | FzF Integration | Job Database | Ad-hoc Commands | Cross-Platform | Single Binary |
|------|----------------|---------|-----------------|--------------|-----------------|----------------|---------------|
| **Custom Script** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Overmind** | ✅ | ✅ | ⚠️ (via tmux-fzf) | ❌ | ⚠️ (Procfile) | ✅ | ✅ |
| **sysz + systemd** | ✅ | ✅ | ✅ | ⚠️ (journald) | ⚠️ (wrapper) | ❌ (Linux) | ✅ |
| **tmux-fzf** | ⚠️ (sessions) | ✅ | ✅ | ❌ | ⚠️ | ✅ | ❌ |
| **Supervisor** | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| **PM2** | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ❌ |
| **FzF native** | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ | ✅ |

**Legend**: ✅ Full support | ⚠️ Partial/requires workaround | ❌ Not available

---

## Recommendations

### For Your Use Case (dotfiles with FzF + cross-platform)

#### Option 1: Enhanced Custom Script + FzF ⭐ Simplest
**Recommendation**: Keep your custom script but enhance it

**Why**:
- Already does exactly what you need
- No dependencies beyond bash + FzF
- Cross-platform (macOS/Linux)
- Single file deployment

**Enhancements to Consider**:
1. Use SQLite instead of pipe-delimited flat file for robust querying
2. Add `bgrun attach <job_id>` using `tail -f` in less/vim
3. Add `bgrun export` to export to systemd/launchd for persistence
4. Add `bgrun daemon` mode for server-like processes
5. Integrate with `tmux-fzf` if you use tmux

**Example SQLite Enhancement**:
```bash
# Replace DB_FILE with SQLite
DB_FILE="${BG_DIR}/jobs.db"

# Initialize
sqlite3 "${DB_FILE}" "CREATE TABLE IF NOT EXISTS jobs (
    job_id TEXT PRIMARY KEY,
    pid INTEGER,
    command TEXT,
    start_time TEXT,
    status TEXT,
    end_time TEXT
)"

# Insert
sqlite3 "${DB_FILE}" "INSERT INTO jobs VALUES (
    '${job_id}', ${pid}, '${cmd}', '${start_time}', 'running', NULL
)"

# Query with FzF
sqlite3 -separator $'\t' "${DB_FILE}" \
    "SELECT job_id, pid, status, start_time, command FROM jobs" | \
    fzf --preview="cat ${LOGS_DIR}/{1}.log"
```

---

#### Option 2: sysz + systemd User Services (Linux Only) ⭐ Best for Linux
**Recommendation**: Use sysz for FzF + systemd for persistence

**Setup**:
1. Install sysz: https://github.com/joehillen/sysz
2. Create wrapper function to generate user services on-the-fly
3. Use sysz for interactive management

**Wrapper Script**:
```bash
# Add to shell config
bgrun() {
    if [[ "$1" == "list" ]]; then
        sysz --user
    elif [[ "$1" == "logs" ]]; then
        journalctl --user -u "$2" -f
    else
        # Generate service name
        local service_name="bgrun-$(date +%s)"

        # Create user service
        cat > ~/.config/systemd/user/${service_name}.service <<EOF
[Unit]
Description=bgrun: $@

[Service]
ExecStart=$@
Restart=on-failure

[Install]
WantedBy=default.target
EOF

        systemctl --user daemon-reload
        systemctl --user start ${service_name}.service
        echo "Started ${service_name}"
    fi
}
```

**Pros**:
- Native OS integration
- Perfect FzF integration via sysz
- Survives reboots
- Excellent logging

**Cons**:
- Linux-only
- More complex setup

---

#### Option 3: Overmind + tmux-fzf (For Multi-Process Dev)
**Recommendation**: Use Overmind for defined workflows, tmux-fzf for interactive control

**Setup**:
```bash
# Install
brew install overmind
# Install tmux-fzf via TPM

# Create Procfile for common workflows
# ~/projects/myapp/Procfile
web: python manage.py runserver
worker: celery worker
logs: tail -f logs/app.log

# Start
cd ~/projects/myapp
overmind start

# Interactive control
# Press tmux prefix + F
```

**Pros**:
- Best multi-process management
- No output buffering
- Individual process control
- tmux-fzf provides FzF interface

**Cons**:
- Requires Procfile definitions
- Not for truly ad-hoc commands

---

#### Option 4: PM2 (For Node.js Workflows)
**Recommendation**: Use PM2 if you work primarily with Node.js

```bash
npm install -g pm2

# Start any command
pm2 start "python app.py" --name myapp
pm2 start "npm run dev" --name frontend

# Interactive monitoring
pm2 monit

# Logs
pm2 logs

# List
pm2 list
```

**Pros**:
- Feature-rich
- Built-in monitoring
- Cross-platform
- Startup scripts

**Cons**:
- Node.js dependency
- No FzF integration

---

### Decision Matrix

| Your Priority | Recommended Solution |
|---------------|---------------------|
| **Simplicity + cross-platform** | Enhanced custom script |
| **Linux + FzF + persistence** | sysz + systemd |
| **Multi-process development** | Overmind + tmux-fzf |
| **Production reliability** | Supervisor or PM2 |
| **Tmux workflows** | tmux-fzf |
| **No dependencies** | Enhanced custom script |

---

## Architecture Insights

### Patterns Discovered

#### 1. Process Management Approaches
- **Procfile-based**: Define processes in manifest (Overmind, Foreman)
- **Service-based**: Register services with daemon (systemd, Supervisor)
- **Ad-hoc**: Start commands directly (custom script, PM2)
- **Session-based**: Manage via terminal multiplexer (tmux-fzf)

#### 2. Logging Strategies
- **File-based**: Each job logs to separate file (custom script, Overmind)
- **Journald**: Centralized logging with metadata (systemd)
- **Database**: Structured logging with queries (PM2)
- **Stream**: Real-time log streaming (Supervisor)

#### 3. FzF Integration Patterns
- **Native integration**: Tool built with FzF (sysz, fzf-kill)
- **Preview hooks**: FzF preview window shows logs (custom script)
- **Post-processing**: FzF selects, pipe to action (native FzF patterns)
- **TUI embedding**: FzF as part of larger TUI (tmux-fzf)

#### 4. Job Tracking Approaches
- **Flat file database**: Pipe-delimited or similar (custom script)
- **SQLite**: Relational database (enhancement suggestion)
- **System registry**: systemd units, PM2 process list
- **No persistence**: Session-based only (pure tmux)

---

## Code References

### Your Custom Script Features
- Job database: Pipe-delimited flat file at `~/.bgrun/jobs.db`
- Log files: Per-job at `~/.bgrun/logs/{job_id}.log`
- FzF search: Lines 103-136 with preview window
- Status checking: Lines 80-85 using `kill -0`

### Similar Patterns in Wild
- Overmind logging: https://github.com/DarthSim/overmind/blob/master/start.go
- sysz FzF integration: https://github.com/joehillen/sysz/blob/master/sysz
- tmux-fzf process script: https://github.com/sainnhe/tmux-fzf/blob/master/scripts/process.sh
- FzF kill completion: https://github.com/junegunn/fzf/blob/master/shell/completion.bash

---

## Additional Resources

### Documentation
- **Overmind**: https://github.com/DarthSim/overmind
- **sysz**: https://github.com/joehillen/sysz
- **tmux-fzf**: https://github.com/sainnhe/tmux-fzf
- **FzF log viewing**: https://junegunn.github.io/fzf/tips/browsing-log-streams/
- **systemd user services**: https://wiki.archlinux.org/title/Systemd/User
- **Supervisor**: http://supervisord.org/
- **PM2**: https://pm2.keymetrics.io/

### Tutorials
- **Overmind guide**: https://pragmaticpineapple.com/control-your-dev-processes-with-overmind/
- **FzF tricks**: https://pragmaticpineapple.com/four-useful-fzf-tricks-for-your-terminal/
- **systemd timers**: https://wiki.archlinux.org/title/Systemd/Timers

### Related Tools
- **Process Supervisors**: Supervisor, PM2, supervisord-go
- **Task Runners**: just, Task, cargo-make
- **Job Schedulers**: Dkron, Cronicle
- **Job Queues**: Faktory, Beanstalkd
- **TUI Tools**: htop, glances, bottom

---

## Conclusion

**Direct Answer**: Yes, there are multiple open-source alternatives to your custom script, but **none perfectly replicate your simple "run any command in background + FzF search" pattern**.

**Best Path Forward**:
1. **Keep your custom script** - it's well-designed and does exactly what you need
2. **Enhance with SQLite** for robust querying
3. **On Linux, consider migrating to systemd + sysz** for persistence and native integration
4. **For multi-process projects, use Overmind** with Procfile
5. **Add tmux-fzf** if you're a tmux user for comprehensive process control

Your custom script fills a genuine gap in the ecosystem - most tools are either too heavy (PM2, Supervisor), too structured (Overmind/Procfile), platform-specific (systemd), or lack job tracking (pure FzF). The simplicity of "bgrun command" with automatic logging and FzF search is valuable.

**Next Steps**:
1. Decide if you want to keep custom script or migrate
2. If keeping: enhance with SQLite, add export feature, integrate with tmux-fzf
3. If migrating: choose sysz+systemd (Linux) or Overmind (cross-platform multi-process)
4. Consider publishing your script to GitHub - it could help others with similar needs
