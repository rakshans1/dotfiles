{ config, lib, pkgs, private, ... }:

{
  # Kubernetes configuration managed by Nix
  # EKS cluster config with SOPS-encrypted secrets

  # Generate kubeconfig with SOPS secrets
  home.activation.kubernetesConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.kube
    chmod 700 $HOME/.kube

        if [[ -f "${config.sops.secrets.k8s_certificate_authority_data.path}" && -f "${config.sops.secrets.k8s_server_endpoint.path}" && -f "${config.sops.secrets.k8s_cluster_name.path}" && -f "${config.sops.secrets.k8s_region.path}" && -f "${config.sops.secrets.k8s_namespace.path}" ]]; then
      CLUSTER_NAME=$(cat ${config.sops.secrets.k8s_cluster_name.path})
      SERVER_ENDPOINT=$(cat ${config.sops.secrets.k8s_server_endpoint.path})
      CERT_DATA=$(cat ${config.sops.secrets.k8s_certificate_authority_data.path})
      REGION=$(cat ${config.sops.secrets.k8s_region.path})
      NAMESPACE=$(cat ${config.sops.secrets.k8s_namespace.path})
      CLUSTER_ARN="arn:aws:eks:$REGION:583463116790:cluster/$CLUSTER_NAME"

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
      chmod 600 $HOME/.kube/config
    fi
  '';
}