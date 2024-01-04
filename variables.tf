##############################
### Docker container variables
variable "container_netdata_hostname" {
  description = "Hostname to be shown on Netdata Metrics site"
  type        = string
  default     = "created-by-terraform"
}
variable "netdata_claim_token" {
  description = "Netdata claim token"
  type        = string
  default     = ""
  sensitive   = true
}
variable "netdata_claim_url" {
  description = "Netdata URL to claim the host to"
  type        = string
  default     = "https://app.netdata.cloud"
}
variable "netdata_claim_rooms" {
  description = "Room-ID to claim the host to"
  type        = string
  default     = ""
}
##############################
### Docker volume variables
variable "volume_netdatacache_id" {
  description = "Docker volume name or id to create/attach to store netdata cache data"
  type        = string
  default     = "netdatacache"
}
variable "volume_netdataconfig_id" {
  description = "Docker volume name or id to create/attach to store netdata config data"
  type        = string
  default     = "netdataconfig"
}
variable "volume_netdatalib_id" {
  description = "Docker volume name or id to create/attach to store netdata lib data"
  type        = string
  default     = "netdatalib"
}
### Docker socket variables
variable "volume_docker_socket_local" {
  description = "Host Docker socket path"
  type        = string
  default     = "/var/run/docker.sock"
}
variable "volume_docker_socket_container" {
  description = "Container Docker socket path"
  type        = string
  default     = "/var/run/docker.sock"
}
