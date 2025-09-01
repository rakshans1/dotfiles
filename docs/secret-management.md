# Secret Management

SOPS-Nix integrated with **modular architecture** and **private repository as flake input**.

## Implementation Summary

- **Encryption**: Age keys (converted from SSH Ed25519)
- **Architecture**: Modular SOPS configs for Home Manager + Darwin
- **Private Repo**: Flake input (`git+file:///Users/rakshan/dotfiles/private`)
- **Secrets**: `private/secrets/common.yaml` (encrypted)
- **Integration**: Environment variables + configuration files
- **AWS**: Managed via Nix (config + credentials from SOPS secrets)

## Architecture

### Flake Integration
```nix
# flake.nix inputs
sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
private = { url = "git+file:///Users/rakshan/dotfiles/private"; flake = false; };
```

### Module Structure
- `nixpkgs/home-manager/modules/sops.nix` - User secrets definitions
- `nixpkgs/home-manager/modules/aws.nix` - AWS configuration files
- `nixpkgs/darwin/mbp/modules/sops.nix` - System secrets
- `private/secrets/common.yaml` - Encrypted storage
- `private/.sops.yaml` - SOPS config

### Integration Points
- Home Manager: `sops-nix.homeManagerModules.sops` + `./modules/sops.nix`
- Darwin: `inputs.sops-nix.darwinModules.sops` + `./modules/sops.nix`
- Environment Variables: Auto-export via `config.sops.secrets.*.path` in zsh.nix
- Configuration Files: Generated via activation scripts (AWS, etc.)

## Key Files

### SOPS Module (nixpkgs/home-manager/modules/sops.nix)
```nix
{ config, lib, pkgs, private, ... }:
{
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.secrets = {
    ...
  };
}
```

### AWS Module (nixpkgs/home-manager/modules/aws.nix)
```nix
{ config, lib, pkgs, private, ... }:
{
  # Static config file managed by Home Manager
  home.file.".aws/config".text = ''
    [default]
    region = ap-south-1
    output = json
  '';

  # Dynamic credentials file from SOPS secrets
  home.activation.awsCredentials = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.aws && chmod 700 $HOME/.aws
    if [[ -f "${config.sops.secrets.aws_access_key_id.path}" ]]; then
      echo "[default]" > $HOME/.aws/credentials
      echo "aws_access_key_id = $(cat ${config.sops.secrets.aws_access_key_id.path})" >> $HOME/.aws/credentials
      echo "aws_secret_access_key = $(cat ${config.sops.secrets.aws_secret_access_key.path})" >> $HOME/.aws/credentials
      chmod 600 $HOME/.aws/credentials
    fi
  '';
}
```

### SOPS Config (private/.sops.yaml)
```yaml
keys:
  - &personal_key age1gkngy4sh65rgknr25cf3cman2fzdmlmhjfy2nw7ak463vxucmqcq5jttgm
creation_rules:
  - path_regex: secrets/.*\.(yaml|json|env|ini)$
    key_groups:
      - age: [*personal_key]
```

### Environment Export (zsh.nix)
```bash
```

## Daily Usage

```bash
# Edit secrets
cd private && sops secrets/common.yaml

# Apply changes
nix-switch
```

## Key Management

```bash
# One-time setup: Convert SSH to age key
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o ~/.config/sops/age/keys.txt
ssh-to-age -i ~/.ssh/id_ed25519.pub  # Get public key for .sops.yaml
```

## Adding New Secrets

1. **Edit encrypted file**: `cd private && sops secrets/common.yaml`
2. **Add to SOPS module**: `"new_secret" = { sopsFile = "${private}/secrets/common.yaml"; };`
3. **Choose integration method**:
   - **Environment variable**: `export NEW_SECRET=$(cat ${config.sops.secrets.new_secret.path})` in zsh.nix
   - **Configuration file**: Create activation script in dedicated module (like aws.nix)
4. **Apply**: `nix-switch && exec zsh` (if using env vars)

## Technical Notes

### Architecture Decision
**Problem**: Private repo (separate git) wasn't accessible to Nix flakes
**Solution**: Added as flake input enables clean `"${private}/secrets/common.yaml"` references

### Key Details
- **Age Keys**: Converted from existing SSH Ed25519 via `ssh-to-age`
- **Module Structure**: Separate user-level (Home Manager) + system-level (Darwin) modules
- **Shell Restart**: Required after first setup (`exec zsh`) for environment variables
- **Packages**: Added `sops` + `ssh-to-age` to `common.nix` (`age` was pre-existing)

### Troubleshooting
- **Empty env vars**: Run `exec zsh` after first setup
- **Decryption fails**: Check `SOPS_AGE_KEY_FILE` environment variable
- **Build errors**: Verify flake inputs + module paths

## Usage Examples

### Environment Variables (API Keys)
- **Anthropic API**: Exported as `$ANTHROPIC_API_KEY` in zsh
- **Good for**: CLI tools, development environments
- **Integration**: Direct export in zsh.nix

### Configuration Files (Credentials)
- **AWS**: Managed as `~/.aws/config` and `~/.aws/credentials` files
- **Good for**: Applications expecting standard config files
- **Integration**: Home Manager activation scripts + file management

## Future Usage

### Platform-Specific Secrets
Create additional encrypted files:
- `secrets/darwin.yaml` - macOS-specific
- `secrets/linux.yaml` - Linux-specific
- `secrets/development.yaml` - Dev environment

### Key Security
- **Location**: `~/.config/sops/age/keys.txt` (never commit)
- **Backup**: Use existing SSH key backup procedures
- **Multi-machine**: Leverage SSH key distribution