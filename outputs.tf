output "k8s_api_ip" {
  value = ibm_is_floating_ip.floating_ip.address
}

output "kube_config" {
  value = "scp root@${ibm_is_floating_ip.floating_ip.address}:/root/.kube/config"
}