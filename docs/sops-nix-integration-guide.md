# SOPS-Nix Integration Guide

## Overview

This document provides a comprehensive guide for integrating `sops-nix` into the existing dotfiles repository for secure secrets management. SOPS (Secrets OPerationS) with Nix allows encrypted storage of sensitive configuration data like API keys, passwords, and tokens directly in your private repository while maintaining security through age encryption.

## Why SOPS-Nix?

- **Secure**: Secrets are encrypted with age keys
- **Version Controlled**: Encrypted secrets can be safely committed to your private git repository
- **Declarative**: Integrates seamlessly with Nix configurations
- **Flexible**: Supports multiple encryption backends (age, GPG)
- **Audit Trail**: Changes to secrets are tracked in git history
- **Private Repository Integration**: Leverages your existing private/ directory structure

## Current State Analysis

### Existing Configuration Structure
```
dotfiles/
├── flake.nix                           # Main flake configuration
├── private/                            # Existing private git repository
│   ├── work_functions                  # Existing private content
│   ├── caddy/                          # Existing private content
│   └── raycast/                        # Existing private content
├── nixpkgs/
│   ├── home-manager/
│   │   ├── mac.nix                     # macOS Home Manager config
│   │   ├── linux.nix                   # Linux Home Manager config
│   │   └── modules/                    # Shared modules
│   └── darwin/
│       └── mbp/
│           └── configuration.nix       # Darwin system config
```

### Current Flake Inputs
- nixpkgs (release-25.05)
- nixpkgsUnstable
- home-manager
- darwin
- nix-homebrew
- homebrew-* (bundle, core, cask)
- aiTools

## Proposed File Structure with SOPS-Nix

### Updated Directory Structure
```
dotfiles/
├── flake.nix                          # [MODIFIED] Add sops-nix input
├── flake.lock                         # [AUTO-UPDATED] After flake update
├── private/                           # [EXISTING] Private git repository
│   ├── .sops.yaml                     # [NEW] SOPS configuration (in private repo)
│   ├── .gitignore                     # [MODIFIED] Add SOPS-related ignores
│   ├── secrets/                       # [NEW] Encrypted secrets directory
│   │   ├── common.yaml                # [NEW] Cross-platform secrets
│   │   ├── darwin.yaml                # [NEW] macOS-specific secrets
│   │   ├── linux.yaml                 # [NEW] Linux-specific secrets
│   │   ├── development.yaml           # [NEW] Dev environment secrets
│   │   └── personal.yaml              # [NEW] Personal service secrets
│   ├── keys/                          # [NEW] Public keys storage
│   │   ├── .gitkeep
│   │   ├── README.md                  # [NEW] Key management docs
│   │   └── age-public-keys.txt        # [NEW] Age public keys reference
│   ├── work_functions                 # [EXISTING] Work-related shell functions
│   ├── invideo_ivpro_tmux            # [EXISTING] Project-specific tmux script
│   ├── caddy/                         # [EXISTING] Local server configuration
│   └── raycast/                       # [EXISTING] Raycast configurations
├── nixpkgs/
│   ├── home-manager/
│   │   ├── mac.nix                    # [MODIFIED] Add sops module import
│   │   ├── linux.nix                  # [MODIFIED] Add sops module import
│   │   └── modules/
│   │       ├── common.nix
│   │       ├── home-manager.nix
│   │       ├── tmux.nix
│   │       ├── zsh.nix
│   │       └── sops.nix               # [NEW] SOPS Home Manager module
│   └── darwin/
│       └── mbp/
│           ├── configuration.nix      # [MODIFIED] Add sops integration
│           └── modules/               # [NEW] Darwin modules directory
│               └── sops.nix           # [NEW] SOPS Darwin module
├── config/                            # [EXISTING] Current config dir
└── docs/                              # [EXISTING] Documentation
    └── sops-nix-integration-guide.md  # [NEW] This comprehensive guide
```

### Benefits of Private Repository Structure
- **Double Security**: Private repo access + age encryption
- **Existing Workflow**: Builds on your current private repo usage
- **Clean Separation**: Main dotfiles remain public-ready
- **Unified Location**: All sensitive data in one private repository

## Detailed Configuration Changes

### 1. flake.nix Changes

#### Current Configuration
```nix
{
  description = "Home Manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    aiTools.url = "github:numtide/nix-ai-tools";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nixpkgsUnstable, darwin, ... }: {
    # ... outputs configuration
  };
}
```

#### Required Changes

**Add sops-nix Input:**
```diff
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    aiTools.url = "github:numtide/nix-ai-tools";
+   sops-nix = {
+     url = "github:Mic92/sops-nix";
+     inputs.nixpkgs.follows = "nixpkgs";
+   };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ... rest of inputs
  };
```

**Update Home Manager Configurations:**
```diff
    homeConfigurations = {
      linux = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./nixpkgs/home-manager/linux.nix ];
        extraSpecialArgs = {
          pkgsUnstable = inputs.nixpkgsUnstable.legacyPackages.x86_64-linux;
          aiTools = inputs.aiTools.packages.x86_64-linux;
+         sops-nix = inputs.sops-nix;
        };
      };
      mbp = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./nixpkgs/home-manager/mac.nix ];
        extraSpecialArgs = {
          pkgsUnstable = inputs.nixpkgsUnstable.legacyPackages.aarch64-darwin;
          aiTools = inputs.aiTools.packages.aarch64-darwin;
+         sops-nix = inputs.sops-nix;
        };
      };
    };
```

**Update Darwin Configuration:**
```diff
    darwinConfigurations = {
      mbp = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./nixpkgs/darwin/mbp/configuration.nix
+         inputs.sops-nix.darwinModules.sops
        ];
        inputs = { inherit darwin nixpkgs; };
        specialArgs = {
          inherit inputs;
          nix-homebrew = inputs.nix-homebrew;
          homebrew-core = inputs.homebrew-core;
          homebrew-cask = inputs.homebrew-cask;
+         sops-nix = inputs.sops-nix;
        };
      };
    };
```

### 2. Home Manager Configuration Changes

#### nixpkgs/home-manager/mac.nix

**Current Configuration:**
```nix
{ config, pkgs, home-manager, ... }:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/common.nix
    ./modules/tmux.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.homeDirectory = "/Users/rakshan";
  home.username = "rakshan";

  home.stateVersion = "23.05";

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "vim";
  };
}
```

**Required Changes:**
```diff
-{ config, pkgs, home-manager, ... }:
+{ config, pkgs, home-manager, sops-nix, ... }:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/common.nix
    ./modules/tmux.nix
+   ./modules/sops.nix
+   sops-nix.homeManagerModules.sops
  ];

  nixpkgs.config.allowUnfree = true;

  home.homeDirectory = "/Users/rakshan";
  home.username = "rakshan";

  home.stateVersion = "23.05";

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "vim";
  };
}
```

#### nixpkgs/home-manager/linux.nix

**Current Configuration:**
```nix
{ config, pkgs, home-manager, ... }:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/common.nix
  ];

  home.homeDirectory = "/home/rakshan";
  home.username = "rakshan";

  home.stateVersion = "23.05";

  fonts.fontconfig.enable = true;

  programs.tmux.enable = false;
}
```

**Required Changes:**
```diff
-{ config, pkgs, home-manager, ... }:
+{ config, pkgs, home-manager, sops-nix, ... }:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/common.nix
+   ./modules/sops.nix
+   sops-nix.homeManagerModules.sops
  ];

  home.homeDirectory = "/home/rakshan";
  home.username = "rakshan";

  home.stateVersion = "23.05";

  fonts.fontconfig.enable = true;

  programs.tmux.enable = false;
}
```

### 3. Darwin Configuration Changes

#### nixpkgs/darwin/mbp/configuration.nix

**Current Configuration (key sections):**
```nix
{ pkgs, config, nix-homebrew, homebrew-core, homebrew-cask, ... }:
{
  imports = [
    nix-homebrew.darwinModules.nix-homebrew
  ];

  system.stateVersion = 6;
  system.primaryUser = "rakshan";

  users.users.rakshan = {
    name = "rakshan";
    home = "/Users/rakshan";
    shell = pkgs.zsh;
  };

  # ... rest of configuration
}
```

**Required Changes:**
```diff
-{ pkgs, config, nix-homebrew, homebrew-core, homebrew-cask, ... }:
+{ pkgs, config, nix-homebrew, homebrew-core, homebrew-cask, sops-nix, ... }:
{
  imports = [
    nix-homebrew.darwinModules.nix-homebrew
+   ./modules/sops.nix
  ];

  system.stateVersion = 6;
  system.primaryUser = "rakshan";

  users.users.rakshan = {
    name = "rakshan";
    home = "/Users/rakshan";
    shell = pkgs.zsh;
  };

  # ... rest of configuration
}
```

## New Module Files

### nixpkgs/home-manager/modules/sops.nix

**File**: New file to be created
**Purpose**: Home Manager SOPS integration

```nix
{ config, lib, pkgs, ... }:

{
  # SOPS age key configuration
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  # Default secrets file - common across platforms
  sops.defaultSopsFile = ../../../private/secrets/common.yaml;

  # Platform-specific secrets file based on system
  sops.secrets = {
    # Common secrets available on all platforms
    # Example configuration (uncomment when secrets exist):
    # "github_token" = {
    #   sopsFile = ../../../private/secrets/common.yaml;
    # };
    # "openai_api_key" = {
    #   sopsFile = ../../../private/secrets/common.yaml;
    # };

    # Development secrets
    # "database_password" = {
    #   sopsFile = ../../../private/secrets/development.yaml;
    # };

    # Personal service secrets
    # "backup_encryption_key" = {
    #   sopsFile = ../../../private/secrets/personal.yaml;
    # };
  } // (
    # Platform-specific secrets
    if pkgs.stdenv.isDarwin then {
      # macOS-specific secrets
      # "keychain_password" = {
      #   sopsFile = ../../../private/secrets/darwin.yaml;
      # };
    } else {
      # Linux-specific secrets
      # "sudo_password" = {
      #   sopsFile = ../../../private/secrets/linux.yaml;
      # };
    }
  );

  # Note: age, sops, and ssh-to-age are already installed via common.nix
}
```

### nixpkgs/darwin/modules/sops.nix

**File**: New file to be created (create `modules/` directory first)
**Purpose**: Darwin system-level SOPS integration

```nix
{ config, lib, pkgs, ... }:

{
  # SOPS age key configuration for system user
  sops.age.keyFile = "/Users/${config.system.primaryUser}/.config/sops/age/keys.txt";

  # Darwin-specific secrets
  sops.defaultSopsFile = ../../../../private/secrets/darwin.yaml;

  sops.secrets = {
    # System-level secrets for Darwin
    # Example configuration (uncomment when secrets exist):
    # "admin_password" = {
    #   sopsFile = ../../../../private/secrets/darwin.yaml;
    #   owner = config.system.primaryUser;
    # };

    # Service credentials
    # "service_token" = {
    #   sopsFile = ../../../../private/secrets/darwin.yaml;
    # };
  };

  # Note: age, sops, and ssh-to-age are already installed via Home Manager common.nix
}
```

## Configuration Files in Private Repository

### private/.sops.yaml

**File**: New file in private repository root
**Purpose**: SOPS encryption configuration

```yaml
keys:
  # Personal age key - replace with actual public key after generation
  - &personal_key age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

creation_rules:
  # Common secrets (cross-platform)
  - path_regex: secrets/common\.yaml$
    key_groups:
      - age:
          - *personal_key

  # Platform-specific secrets
  - path_regex: secrets/(darwin|linux)\.yaml$
    key_groups:
      - age:
          - *personal_key

  # Purpose-specific secrets
  - path_regex: secrets/(development|personal)\.yaml$
    key_groups:
      - age:
          - *personal_key

  # Fallback rule for any other encrypted files
  - path_regex: secrets/.*\.(yaml|json|env|ini)$
    key_groups:
      - age:
          - *personal_key
```

### Secrets Files Structure

**private/secrets/common.yaml** (create with sops):
- Cross-platform secrets used by both macOS and Linux
- Examples: GitHub tokens, API keys, shared service credentials
- Encrypted with age, stored in private repository

**private/secrets/darwin.yaml** (create with sops):
- macOS-specific secrets
- Examples: Keychain passwords, macOS service tokens, Touch ID configs
- Used by Darwin system configuration

**private/secrets/linux.yaml** (create with sops):
- Linux-specific secrets
- Examples: sudo passwords, Linux service credentials, display manager configs
- Used by Home Manager on Linux

**private/secrets/development.yaml** (create with sops):
- Development environment secrets
- Examples: Database credentials, development API keys, local service passwords
- Shared across development tools and configurations

**private/secrets/personal.yaml** (create with sops):
- Personal service secrets
- Examples: Personal cloud service tokens, social media API keys, backup encryption keys
- Separated for privacy and easier management

### Key Management Files

#### private/keys/README.md
**Purpose**: Document key management procedures within private repository
**Content**:
- Key generation instructions
- Backup procedures
- Recovery process
- Multi-machine key sharing strategy

#### private/keys/age-public-keys.txt
**Purpose**: Reference file for public keys within private repository
**Usage**: Quick reference for public keys used in `private/.sops.yaml`
**Benefits**: Easy lookup without exposing private keys, kept with secrets

## Implementation Steps

### Step 1: Preparation
1. **Backup Current Configuration**: Ensure git is clean and create backup
2. **Required Tools**: `age`, `sops`, and `ssh-to-age` are already installed via `common.nix`
3. **Generate Age Keys**: Choose between generating new age keys or converting existing SSH Ed25519 keys
4. **Plan Secret Migration**: Identify current secrets to encrypt

### Step 2: Basic Integration
1. **Update flake.nix**: Add sops-nix input
2. **Create private/secrets/ directory**: In existing private repo
3. **Create private/.sops.yaml**: With age key configuration
4. **Update private/.gitignore**: Add secret-related ignores

### Step 3: Module Creation
1. **Create SOPS modules**: Both Home Manager and Darwin
2. **Update configuration imports**: Add sops modules
3. **Test basic setup**: `nix flake check`

### Step 4: Secret Migration
1. **Create initial secret files**: Start with actual secrets using sops
2. **Test encryption/decryption workflow**
3. **Migrate existing secrets**: Move from current locations
4. **Update configurations**: Use sops-managed secrets

### Step 5: Validation
1. **Test on both platforms**: Linux and macOS
2. **Verify secret access**: Ensure services can read secrets
3. **Document usage**: Update CONTRIBUTORS.md

## Security Setup

### Age Key Generation

You have two options for creating age keys:

#### Option 1: Generate New Age Keys
```bash
# Create age key directory
mkdir -p ~/.config/sops/age

# Generate age key pair
age-keygen -o ~/.config/sops/age/keys.txt

# The public key will be displayed - save it for private/.sops.yaml
```

#### Option 2: Convert Existing SSH Ed25519 Keys (Recommended)
If you already have SSH Ed25519 keys, you can convert them to age keys using [ssh-to-age](https://github.com/Mic92/ssh-to-age):

```bash
# ssh-to-age is already installed via common.nix
# Create age key directory
mkdir -p ~/.config/sops/age

# Convert your SSH private key to age format
ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o ~/.config/sops/age/keys.txt

# Get the public key for .sops.yaml
ssh-to-age -i ~/.ssh/id_ed25519.pub
# This will output something like: age1hjm3aujg9e79f5yth8a2cejzdjg5n9vnu96l05p70uvfpeltnpms7yy3pp
```

If your SSH private key is encrypted with a passphrase:
```bash
# Export the passphrase (you'll be prompted to enter it)
read -s SSH_TO_AGE_PASSPHRASE; export SSH_TO_AGE_PASSPHRASE

# Convert the encrypted SSH key
ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o ~/.config/sops/age/keys.txt
```

**Benefits of using ssh-to-age:**
- Leverage existing SSH infrastructure
- No need to manage additional key pairs
- Consistent key management across SSH and age
- Works with existing SSH key backup procedures

### Update .gitignore Files

**Main dotfiles .gitignore** (no changes needed for secrets - they're in private repo):
```gitignore
# Age keys (should be backed up separately, never commit)
.config/sops/age/keys.txt
```

**Private repository .gitignore** (update `private/.gitignore`):
```gitignore
.DS_Store
# SOPS decrypted files and temporary files
*.decrypted.*
.*.yaml.tmp
*.yaml~
.sops.d/

# Never commit private age keys
keys/age-keys.txt
```

### Key Backup Strategy
- **Primary Key**: Store `~/.config/sops/age/keys.txt` in secure password manager
- **SSH-based Keys**: If using ssh-to-age, your existing SSH key backup strategy applies
- **Recovery**: Document key recovery process (either age key recovery or SSH key recovery)
- **Multiple Machines**:
  - For SSH-based approach: Use your existing SSH key distribution method
  - For age-only approach: Consider per-machine keys or shared key strategy

## Creating Secret Files

Create secret files directly with sops:

```bash
# Create and edit common secrets
sops private/secrets/common.yaml

# Example structure for common secrets:
# github_token: "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# openai_api_key: "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# aws_access_key_id: "AKIAXXXXXXXXXXXXXXXX"
# aws_secret_access_key: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Create and edit macOS-specific secrets
sops private/secrets/darwin.yaml

# Example structure for darwin secrets:
# admin_password: "secure_admin_password"
# keychain_password: "keychain_unlock_password"
# touch_id_config: "base64_encoded_config"

# Create and edit Linux-specific secrets
sops private/secrets/linux.yaml

# Example structure for linux secrets:
# sudo_password: "secure_sudo_password"
# display_manager_password: "secure_dm_password"
```

## Usage Examples

### Using Secrets in Home Manager Configurations

```nix
# In any Home Manager module
{ config, pkgs, ... }:
{
  # Use secret in environment variable
  home.sessionVariables = {
    GITHUB_TOKEN = "$(cat ${config.sops.secrets.github_token.path})";
  };

  # Use secret in program configuration
  programs.git.extraConfig = {
    github.token = config.sops.secrets.github_token.path;
  };

  # Use secret in custom script
  home.packages = with pkgs; [
    (writeScriptBin "my-backup-script" ''
      #!/bin/bash
      export RESTIC_PASSWORD="$(cat ${config.sops.secrets.restic_password.path})"
      restic backup ~/Documents
    '')
  ];
}
```

### Using Secrets in Darwin Configuration

```nix
# In Darwin configuration
{ config, pkgs, ... }:
{
  # Use secret for system service
  services.my-daemon = {
    enable = true;
    tokenFile = config.sops.secrets.service_token.path;
  };

  # Use secret in system script
  system.activationScripts.setupService = {
    text = ''
      export SERVICE_PASSWORD="$(cat ${config.sops.secrets.admin_password.path})"
      # ... setup commands
    '';
  };
}
```

## Security Considerations

### Key Management
- **Never commit private keys**: Always keep age private keys out of repo
- **Secure key backup**: Store keys in password manager with recovery info
- **Key rotation**: Plan for periodic key rotation if needed

### Access Control
- **Principle of least privilege**: Only decrypt secrets where needed
- **Platform separation**: Use platform-specific secrets when appropriate
- **Service isolation**: Consider per-service secret files for complex setups

### Operational Security
- **Secret rotation**: Plan for rotating secrets periodically
- **Audit trail**: Review secret changes in git history
- **Cleanup**: Remove old secrets when no longer needed

## Commands Reference

### Development Workflow
```bash
# Edit encrypted secrets (from dotfiles root)
sops private/secrets/common.yaml

# Or from private directory
cd private && sops secrets/common.yaml

# Check sops configuration
sops --version

# Test decryption (don't commit output)
sops -d private/secrets/common.yaml

# Rebuild configurations
nix-switch  # (your existing alias)

# Check flake
nix flake check

# Update flake inputs
nix-update  # (your existing alias)
```

### Key Management
```bash
# Option 1: Generate new age key
age-keygen -o ~/.config/sops/age/keys.txt

# Extract public key from private key (for new age keys)
age-keygen -y ~/.config/sops/age/keys.txt

# Option 2: Convert existing SSH Ed25519 key
ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o ~/.config/sops/age/keys.txt
ssh-to-age -i ~/.ssh/id_ed25519.pub  # Get public key

# Test age encryption/decryption
echo "test" | age -r AGE_PUBLIC_KEY | age -d -i ~/.config/sops/age/keys.txt
```

### Maintenance Procedures

#### Adding New Secrets
1. Edit encrypted file: `sops private/secrets/{category}.yaml`
2. Add secret reference in appropriate module
3. Update consuming configuration
4. Test secret access

#### Rotating Secrets
1. Update secret value: `sops private/secrets/{category}.yaml`
2. Deploy configuration: `nix-switch`
3. Verify service functionality
4. Update documentation if needed

#### Key Rotation
1. Generate new age key pair
2. Re-encrypt all secret files with new key
3. Update `private/.sops.yaml` with new public key
4. Deploy updated configuration
5. Backup new private key securely

## Validation Steps

### Configuration Validation
```bash
# Check flake syntax
nix flake check

# Test Home Manager build (don't switch)
home-manager build --flake .#mbp

# Test Darwin build (don't switch)
nix build .#darwinConfigurations.mbp.system

# Check SOPS configuration
sops --version
```

### Secret Management Validation
```bash
# Test age key generation (choose one method)
age-keygen -o test-key.txt
age-keygen -y test-key.txt  # Extract public key

# Or test SSH-to-age conversion
ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o test-key.txt
ssh-to-age -i ~/.ssh/id_ed25519.pub  # Get public key

# Test SOPS encryption/decryption
echo "test_secret: \"test_value\"" > test.yaml
sops -e test.yaml > test.encrypted.yaml
sops -d test.encrypted.yaml
```

### Integration Testing
```bash
# After implementing changes:
nix-switch  # Your existing alias

# Verify secrets are accessible (example)
cat /run/secrets/github_token  # Should show decrypted content

# Test secret in application
echo $GITHUB_TOKEN  # Should show decrypted token
```

## Integration with Existing Workflow

### With Current Commands
- **nix-switch**: Will automatically handle secret deployment
- **nix-update**: Will update sops-nix along with other inputs
- **Karabiner config**: Can potentially use secrets for sensitive shortcuts

### Documentation Updates
- **CONTRIBUTORS.md**: Add section on secrets management
- **README.md**: Mention sops-nix integration
- **This document**: Keep updated as implementation evolves

## Troubleshooting

### Common Issues
1. **Age key not found**: Ensure `~/.config/sops/age/keys.txt` exists and is readable
2. **Decryption fails**: Check age key matches public key in `private/.sops.yaml`
3. **Permission errors**: Verify sops service has proper permissions
4. **File not encrypted**: Ensure file matches path_regex in `private/.sops.yaml`

### Debugging Commands
```bash
# Check sops-nix service status (on NixOS/Darwin)
systemctl status sops-nix

# Manually test secret decryption
sudo -u sops-nix sops -d /path/to/secret/file

# Check age key
age-keygen -y ~/.config/sops/age/keys.txt
```

## Future Enhancements

### Potential Additions
- **Multiple age keys**: Support for shared secrets across team
- **Git hooks**: Pre-commit hooks to ensure secrets are encrypted
- **Integration**: With other services (password managers, etc.)

### Advanced Usage
- **Per-service secrets**: Separate secret files for different services
- **Environment-specific**: Dev/staging/prod secret separation
- **Automated rotation**: Scripts for secret rotation
- **Monitoring**: Alert on secret access/changes

## Implementation Checklist

- [ ] Add required packages to common.nix: `sops` and `ssh-to-age` ✅ (already added)
- [ ] Generate age key pair (choose method):
  - [ ] Generate new age keys with `age-keygen`, OR
  - [ ] Convert existing SSH Ed25519 keys with `ssh-to-age` (recommended if you have SSH keys)
- [ ] Add sops-nix to flake inputs
- [ ] Create `private/secrets/` directory structure
- [ ] Create `private/keys/` directory
- [ ] Create `private/.sops.yaml` configuration
- [ ] Update `private/.sops.yaml` with actual public key
- [ ] Update all configuration files as specified above
- [ ] Create new module files:
  - [ ] `nixpkgs/home-manager/modules/sops.nix`
  - [ ] `nixpkgs/darwin/modules/sops.nix` (create `modules/` directory first)
- [ ] Update `private/.gitignore`
- [ ] Test flake builds without switching: `nix flake check`
- [ ] Create and encrypt first secret file
- [ ] Test deployment with `nix-switch`
- [ ] Verify secret access in applications
- [ ] Document key backup procedure
- [ ] Test deployment on both macOS and Linux
- [ ] Document usage in CONTRIBUTORS.md
- [ ] Test secret rotation workflow

---

*This comprehensive guide provides everything needed to integrate sops-nix while maintaining your existing dotfiles architecture and leveraging your private repository structure.*
