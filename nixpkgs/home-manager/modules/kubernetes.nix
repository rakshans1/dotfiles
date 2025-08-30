{ config, lib, pkgs, private, ... }:

let
  # Define secrets paths for clean access
  inherit (config.sops.secrets)
    k8s_cluster_name
    k8s_server_endpoint
    k8s_certificate_authority_data
    k8s_region
    k8s_namespace
    k8s_aws_account_id;

in
{
  # Create ~/.kube directory with correct permissions
  home.file.".kube".source = null;

  # Activation script to generate kubeconfig at runtime
  home.activation.kubernetesConfig = lib.hm.dag.entryAfter ["writeBoundary"] (
    let
      # Check if all secrets exist and are non-empty
      secretsExist = lib.all (secret: builtins.pathExists secret.path && (builtins.readFile secret.path) != "") [
        k8s_cluster_name
        k8s_server_endpoint
        k8s_certificate_authority_data
        k8s_region
        k8s_namespace
        k8s_aws_account_id
      ];
    in
    lib.optionalString secretsExist ''
      # Ensure ~/.kube directory exists
      mkdir -p $HOME/.kube
      chmod 700 $HOME/.kube

      # Read secrets at runtime
      CLUSTER_NAME=$(cat ${k8s_cluster_name.path})
      SERVER_ENDPOINT=$(cat ${k8s_server_endpoint.path})
      CERT_DATA=$(cat ${k8s_certificate_authority_data.path})
      REGION=$(cat ${k8s_region.path})
      NAMESPACE=$(cat ${k8s_namespace.path})
      AWS_ACCOUNT_ID=$(cat ${k8s_aws_account_id.path})
      CLUSTER_ARN="arn:aws:eks:$REGION:$AWS_ACCOUNT_ID:cluster/$CLUSTER_NAME"

      # Generate kubeconfig with runtime-substituted values
      cat > $HOME/.kube/config << EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $CERT_DATA
    server: $SERVER_ENDPOINT
  name: $CLUSTER_ARN
contexts:
- context:
    cluster: $CLUSTER_ARN
    namespace: $NAMESPACE
    user: $CLUSTER_ARN
  name: $CLUSTER_ARN
current-context: $CLUSTER_ARN
kind: Config
preferences: {}
users:
- name: $CLUSTER_ARN
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - --region
      - $REGION
      - eks
      - get-token
      - --cluster-name
      - $CLUSTER_NAME
      command: aws
      env: null
      interactiveMode: IfAvailable
      provideClusterInfo: false
EOF

      # Set kubeconfig permissions
      chmod 600 $HOME/.kube/config

      # Verify kubeconfig was created
      if [[ ! -f $HOME/.kube/config ]]; then
        echo "ERROR: Failed to create kubeconfig file" >&2
        exit 1
      fi

      echo "Successfully generated kubeconfig for cluster: $CLUSTER_NAME"
    '' + lib.optionalString (!secretsExist) ''
      echo "WARNING: Some SOPS secrets are missing or empty; skipping kubeconfig generation" >&2
    ''
  );
}