{
  config,
  lib,
  ...
}:

{
  # Raycast AI providers configuration managed by Nix with SOPS secrets

  # Generate providers.yaml with SOPS secrets
  home.activation.raycastConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            mkdir -p $HOME/.config/raycast/ai
            chmod 755 $HOME/.config/raycast/ai

            if [[ -f "${config.sops.secrets.llm_endpoint.path}" && -f "${config.sops.secrets.llm_api_key.path}" ]]; then
              # Read secrets at runtime
              API_ENDPOINT=$(cat ${config.sops.secrets.llm_endpoint.path})
              API_KEY=$(cat ${config.sops.secrets.llm_api_key.path})

              # Generate providers.yaml
              cat > $HOME/.config/raycast/ai/providers.yaml <<EOF
    providers:
      - id: litellm
        name: LiteLLM
        base_url: $API_ENDPOINT
        api_keys:
          litellm: $API_KEY
        models:
          - id: claude-sonnet-4-5-20250929
            name: "Claude Sonnet 4.5"
            provider: litellm
            context: 200000
            abilities:
              temperature:
                supported: true
              vision:
                supported: true
              system_message:
                supported: true
              tools:
                supported: true
          - id: xai/grok-4-fast-reasoning
            name: "Grok 4 Fast Reasoning"
            provider: litellm
            context: 200000
            abilities:
              temperature:
                supported: false
              vision:
                supported: true
              system_message:
                supported: true
              tools:
                supported: true
          - id: gpt-5
            name: "GPT 5"
            provider: litellm
            context: 200000
            abilities:
              temperature:
                supported: false
              vision:
                supported: true
              system_message:
                supported: true
              tools:
                supported: true
          - id: gpt-5-mini
            name: "GPT 5 mini"
            provider: litellm
            context: 200000
            abilities:
              temperature:
                supported: false
              vision:
                supported: true
              system_message:
                supported: true
              tools:
                supported: true
          - id: gpt-5-nano
            name: "GPT 5 nano"
            provider: litellm
            context: 200000
            abilities:
              temperature:
                supported: false
              vision:
                supported: true
              system_message:
                supported: true
              tools:
                supported: true
    EOF

              chmod 600 $HOME/.config/raycast/ai/providers.yaml
              echo "Successfully generated Raycast AI providers configuration"
            fi
  '';
}
