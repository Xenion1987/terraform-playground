resource "docker_image" "netdata" {
  name         = "netdata/netdata:stable"
  keep_locally = false
}
