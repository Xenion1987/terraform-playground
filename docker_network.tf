resource "docker_network" "netdata" {
  name       = "netdata"
  attachable = true
}
