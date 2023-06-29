data "scaleway_k8s_version" "latest" {
  name = "latest"
}

resource "scaleway_vpc_private_network" "kapsule" {
  name        = "pn_kapsule"
  is_regional = true
  tags        = ["kapsule"]
}

resource "scaleway_k8s_cluster" "k8s_cluster" {
  name                        = "metalb-cluster"
  cni                         = "cilium"
  version                     = data.scaleway_k8s_version.latest.name
  private_network_id          = scaleway_vpc_private_network.kapsule.id
  delete_additional_resources = true

  autoscaler_config {
    disable_scale_down               = false
    scale_down_unneeded_time         = "2m"
    scale_down_delay_after_add       = "2m"
    scale_down_utilization_threshold = 0.5
    estimator                        = "binpacking"
    expander                         = "random"
    ignore_daemonsets_utilization    = true
  }

  depends_on = [scaleway_vpc_private_network.kapsule]
}

resource "scaleway_instance_placement_group" "availability_group" {
  policy_type = "max_availability"
  policy_mode = "enforced"
}

resource "scaleway_k8s_pool" "k8s_pool" {
  name               = "demo-pool"
  cluster_id         = scaleway_k8s_cluster.k8s_cluster.id
  node_type          = "DEV1-M"
  size               = 1
  min_size           = 1
  max_size           = 10
  autoscaling        = true
  autohealing        = true
  container_runtime  = "containerd"
  placement_group_id = scaleway_instance_placement_group.availability_group.id
}

variable "hide" { # Workaround to hide local-exec output
  default   = "yes"
  sensitive = true
}

resource "null_resource" "kubeconfig" {
  depends_on = [scaleway_k8s_pool.k8s_pool]
  triggers = {
    host                   = scaleway_k8s_cluster.k8s_cluster.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.k8s_cluster.kubeconfig[0].token
    cluster_ca_certificate = scaleway_k8s_cluster.k8s_cluster.kubeconfig[0].cluster_ca_certificate
  }

  provisioner "local-exec" {
    environment = {
      HIDE_OUTPUT = var.hide # Workaround to hide local-exec output
    }
    command = <<-EOT
    cat<<EOF>kubeconfig.yaml
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: ${self.triggers.cluster_ca_certificate}
        server: ${self.triggers.host}
      name: ${scaleway_k8s_cluster.k8s_cluster.name}
    contexts:
    - context:
        cluster: ${scaleway_k8s_cluster.k8s_cluster.name}
        user: admin
      name: admin@${scaleway_k8s_cluster.k8s_cluster.name}
    current-context: admin@${scaleway_k8s_cluster.k8s_cluster.name}
    kind: Config
    preferences: {}
    users:
    - name: admin
      user:
        token: ${self.triggers.token}
    EOF
    chmod 600 kubeconfig.yaml
    EOT
  }
}

