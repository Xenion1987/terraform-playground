# This file contains all outputs
output "variable_netdata_claim_token" {
  description = "Variable value for 'netdata_claim_token'"
  value       = var.netdata_claim_token
}
output "volume_netdatacache_id" {
  description = "ID for created docker volume 'netdatacache'"
  value       = docker_volume.netdatacache.id
}
output "volume_netdataconfig_id" {
  description = "ID for created docker volume 'netdataconfig'"
  value       = docker_volume.netdataconfig.id
}
output "volume_netdatalib_id" {
  description = "ID for created docker volume 'netdatalib'"
  value       = docker_volume.netdatalib.id
}
output "network_id_netdata" {
  description = "Long ID for created docker network 'netdata'"
  value       = docker_network.netdata.id
}
