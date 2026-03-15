{
  config,
  lib,
  ...
}:

{
  # Claude Code configuration managed by Nix

  # Generate Claude Code settings.json dynamically (writable)
  home.activation.claudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/.claude
        chmod 755 $HOME/.claude

        # Generate settings.json
        cat > $HOME/.claude/settings.json <<'EOF'
    {
      "permissions": {
        "allow": [
          "Read(~/.zshrc)"
        ],
        "deny": [
        ]
      },
      "includeCoAuthoredBy": false,
      "env": {
        "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
        "DISABLE_AUTOUPDATER": "1"
      }
    }
    EOF

        chmod 644 $HOME/.claude/settings.json
        echo "Successfully generated Claude Code configuration"
  '';
}
