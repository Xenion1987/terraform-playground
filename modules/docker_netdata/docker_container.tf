resource "docker_container" "netdata" {
  capabilities {
    add = [
      "SYS_PTRACE",
      "SYS_ADMIN"
    ]
  }
  env = [
    "NETDATA_CLAIM_TOKEN=${try(var.netdata_claim_token, "")}",
    "NETDATA_CLAIM_URL=${try(var.netdata_claim_url, "")}",
    "NETDATA_CLAIM_ROOMS=${try(var.netdata_claim_rooms, "")}"
  ]
  hostname = var.container_netdata_hostname
  image    = docker_image.netdata.image_id
  name     = "netdata"
  ports {
    ip       = "127.0.0.1"
    internal = 19999
    external = 19999
  }
  restart       = "unless-stopped"
  security_opts = ["apparmor:unconfined"]
  volumes {
    volume_name    = "netdataconfig"
    container_path = "/etc/netdata"
  }
  volumes {
    volume_name    = "netdatalib"
    container_path = "/var/lib/netdata"
  }
  volumes {
    volume_name    = "netdatacache"
    container_path = "/var/cache/netdata"
  }
  volumes {
    host_path      = "/etc/passwd"
    container_path = "/host/etc/passwd"
    read_only      = true
  }
  volumes {
    host_path      = "/etc/group"
    container_path = "/host/etc/group"
    read_only      = true
  }
  volumes {
    host_path      = "/proc"
    container_path = "/host/proc"
    read_only      = true
  }
  volumes {
    host_path      = "/sys"
    container_path = "/host/sys"
    read_only      = true
  }
  volumes {
    host_path      = "/etc/os-release"
    container_path = "/host/etc/os-release"
    read_only      = true
  }
  volumes {
    host_path      = var.volume_docker_socket_local
    container_path = var.volume_docker_socket_container
    read_only      = true
  }
}
