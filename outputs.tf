output "k8s_api_ip" {
  value = "register ${var.k8s_apifqdn} as ${ibm_is_floating_ip.floating_ip.address}"
}
output "kube_config" {
  value = "scp root@${ibm_is_floating_ip.floating_ip.address}:/root/.kube/config ${local.site_name}.config"
}

output "demo_container" {
  value = "http://${ibm_is_floating_ip.floating_ip.address}:30080"
}

output "performance_target" {
  value = "sockperf [test_type] -h ${ibm_is_floating_ip.floating_ip.address} -p 31111"
}