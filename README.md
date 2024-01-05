# Terraform Playground

- [Terraform Playground](#terraform-playground)
  - [Requirements](#requirements)
    - [Docker](#docker)
    - [Microsoft Visual Studio Code](#microsoft-visual-studio-code)
    - [vscode extensions](#vscode-extensions)
  - [Example: Create a docker container `netdata`](#example-create-a-docker-container-netdata)
    - [Setup your **terraform** environment](#setup-your-terraform-environment)
    - [Let **terraform** create a docker `netdata` container](#let-terraform-create-a-docker-netdata-container)
      - [Check what **terraform** ***would*** do (`terraform plan`)](#check-what-terraform-would-do-terraform-plan)
      - [Create **terraform** resources (`terraform apply`)](#create-terraform-resources-terraform-apply)
      - [Check created resources](#check-created-resources)
      - [Visit `netdata` metrics app](#visit-netdata-metrics-app)
    - [Set custom variables](#set-custom-variables)
  - [Requirements](#requirements-1)
  - [Providers](#providers)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

This repository can be used as a template for developing with `terraform`. This repository sets up a complete terraform development environment including:

- terraform
- terraform-docs
- terraform-lint
- terraform-trivy
- vscode terraform plugins
- pre-commit

## Requirements

### Docker

[Install Docker (Desktop)](https://docs.docker.com/get-docker/)

### Microsoft Visual Studio Code

Download and install [vscode](https://code.visualstudio.com/)

### vscode extensions

In **vscode**, install extension **[ms-vscode-remote.remote-containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)**


## Example: Create a docker container `netdata`

### Setup your **terraform** environment

1. Start **docker** engine
2. Clone this repository
3. Open the local repository in **vscode**
4. If you want to mount your local workspace directory into the **devcontainer**, modify [.devcontainer.json](./.devcontainer/devcontainer.json) Section `"mounts": [ "source=${localEnv:HOME}${localEnv:USERPROFILE}/workspace,target=/home/vscode/workspace,type=bind,consistency=cached"]` to fit your workspace path.
5. In the popup at the lower right corner, click on "Reopen in Container"
6. Initialize **terraform** via `terraform init`
7. Start infrastructure as code

### Let **terraform** create a docker `netdata` container

#### Check what **terraform** ***would*** do (`terraform plan`)

As soon as you have successfully initialized **terraform** via `terraform init`, you can check what the example **terraform** module would do:

```sh
terraform plan
```

You should see something similar like this:
<details>
  <summary><code>terraform plan</code> output</summary>

```go
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
+ create

Terraform will perform the following actions:

# module.docker_netdata.docker_container.netdata will be created
+ resource "docker_container" "netdata" {
    + attach                                      = false
    + bridge                                      = (known after apply)
    + command                                     = (known after apply)
    + container_logs                              = (known after apply)
    + container_read_refresh_timeout_milliseconds = 15000
    + entrypoint                                  = (known after apply)
    + env                                         = (sensitive value)
    + exit_code                                   = (known after apply)
    + hostname                                    = "created-by-terraform"
    + id                                          = (known after apply)
    + image                                       = (known after apply)
    + init                                        = (known after apply)
    + ipc_mode                                    = (known after apply)
    + log_driver                                  = (known after apply)
    + logs                                        = false
    + must_run                                    = true
    + name                                        = "netdata"
    + network_data                                = (known after apply)
    + read_only                                   = false
    + remove_volumes                              = true
    + restart                                     = "unless-stopped"
    + rm                                          = false
    + runtime                                     = (known after apply)
    + security_opts                               = [
        + "apparmor:unconfined",
        ]
    + shm_size                                    = (known after apply)
    + start                                       = true
    + stdin_open                                  = false
    + stop_signal                                 = (known after apply)
    + stop_timeout                                = (known after apply)
    + tty                                         = false
    + wait                                        = false
    + wait_timeout                                = 60

    + capabilities {
        + add  = [
            + "SYS_ADMIN",
            + "SYS_PTRACE",
            ]
        + drop = []
        }

    + ports {
        + external = 19999
        + internal = 19999
        + ip       = "127.0.0.1"
        + protocol = "tcp"
        }

    + volumes {
        + container_path = "/etc/netdata"
        + volume_name    = "netdataconfig"
        }
    + volumes {
        + container_path = "/host/etc/group"
        + host_path      = "/etc/group"
        + read_only      = true
        }
    + volumes {
        + container_path = "/host/etc/os-release"
        + host_path      = "/etc/os-release"
        + read_only      = true
        }
    + volumes {
        + container_path = "/host/etc/passwd"
        + host_path      = "/etc/passwd"
        + read_only      = true
        }
    + volumes {
        + container_path = "/host/proc"
        + host_path      = "/proc"
        + read_only      = true
        }
    + volumes {
        + container_path = "/host/sys"
        + host_path      = "/sys"
        + read_only      = true
        }
    + volumes {
        + container_path = "/var/cache/netdata"
        + volume_name    = "netdatacache"
        }
    + volumes {
        + container_path = "/var/lib/netdata"
        + volume_name    = "netdatalib"
        }
    + volumes {
        + container_path = "/var/run/docker.sock"
        + host_path      = "/var/run/docker.sock"
        + read_only      = true
        }
    }

# module.docker_netdata.docker_image.netdata will be created
+ resource "docker_image" "netdata" {
    + id           = (known after apply)
    + image_id     = (known after apply)
    + keep_locally = false
    + name         = "netdata/netdata:stable"
    + repo_digest  = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

</details>

As you can see, **terraform** would create two resources as mentioned at the end of the output:

```go
# module.docker_netdata.docker_container.netdata will be created
(...)

# module.docker_netdata.docker_image.netdata will be created
(...)

Plan: 2 to add, 0 to change, 0 to destroy.
```

Don't be afraid and take a look at the detailed resources to get an idea of what happens.

#### Create **terraform** resources (`terraform apply`)

If you agree with the output of `terraform plan`, you can create the resources:

```sh
terraform apply
```

You should see something similar to this:

```txt
(...)
Plan: 2 to add, 0 to change, 0 to destroy.
module.docker_netdata.docker_image.netdata: Creating...
module.docker_netdata.docker_image.netdata: Still creating... [10s elapsed]
module.docker_netdata.docker_image.netdata: Creation complete after 13s [id=sha256:97829c5803169cfee85770935ccf537012776e091a3e157db3ae9e045e6982a5netdata/netdata:stable]
module.docker_netdata.docker_container.netdata: Creating...
module.docker_netdata.docker_container.netdata: Creation complete after 1s [id=6cb2d6ab44ba39d8ee983dc0e1cb8aca485927067be2938d27cf10ff83fe4a24]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

#### Check created resources

Now, you should see the created container and volumes:

```sh
$ docker ps | grep netdata
6cb2d6ab44ba   97829c580316   "/usr/sbin/run.sh"   2 minutes ago   Up 2 minutes (healthy)   127.0.0.1:19999->19999/tcp   netdata
```

```sh
$ docker volume ls | grep netdata
local     netdatacache
local     netdataconfig
local     netdatalib
```

#### Visit `netdata` metrics app

As defined in [docker_container.tf](./modules/docker_netdata/docker_container.tf), we have exposed the container to `127.0.0.1:19999`. So open a browser and check your host's metrics: [http://127.0.0.1:19999](http://127.0.0.1:19999)

### Set custom variables

Feel free to add your own variables like `container_netdata_hostname` or your own `netdata_claim_*` variables by copying the `main.tf` to `main_override.tf` and edit the commented out variables.  
Or create a file `terraform.tfvars` and add the variables and your values to that file.

<!-- BEGIN_TERRAFORM_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | ~> 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_docker"></a> [docker](#provider\_docker) | ~> 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [docker_container.netdata](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container) | resource |
| [docker_image.netdata](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [docker_network.netdata](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/network) | resource |
| [docker_volume.netdatacache](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume) | resource |
| [docker_volume.netdataconfig](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume) | resource |
| [docker_volume.netdatalib](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_netdata_hostname"></a> [container\_netdata\_hostname](#input\_container\_netdata\_hostname) | Hostname to be shown on Netdata Metrics site | `string` | `"created-by-terraform"` | no |
| <a name="input_netdata_claim_rooms"></a> [netdata\_claim\_rooms](#input\_netdata\_claim\_rooms) | Room-ID to claim the host to | `string` | `null` | no |
| <a name="input_netdata_claim_token"></a> [netdata\_claim\_token](#input\_netdata\_claim\_token) | Netdata claim token | `string` | `null` | no |
| <a name="input_netdata_claim_url"></a> [netdata\_claim\_url](#input\_netdata\_claim\_url) | Netdata URL to claim the host to | `string` | `"https://app.netdata.cloud"` | no |
| <a name="input_volume_docker_socket_container"></a> [volume\_docker\_socket\_container](#input\_volume\_docker\_socket\_container) | Container Docker socket path | `string` | `"/var/run/docker.sock"` | no |
| <a name="input_volume_docker_socket_local"></a> [volume\_docker\_socket\_local](#input\_volume\_docker\_socket\_local) | Host Docker socket path | `string` | `"/var/run/docker.sock"` | no |
| <a name="input_volume_netdatacache_id"></a> [volume\_netdatacache\_id](#input\_volume\_netdatacache\_id) | Docker volume name or id to create/attach to store netdata cache data | `string` | `"netdatacache"` | no |
| <a name="input_volume_netdataconfig_id"></a> [volume\_netdataconfig\_id](#input\_volume\_netdataconfig\_id) | Docker volume name or id to create/attach to store netdata config data | `string` | `"netdataconfig"` | no |
| <a name="input_volume_netdatalib_id"></a> [volume\_netdatalib\_id](#input\_volume\_netdatalib\_id) | Docker volume name or id to create/attach to store netdata lib data | `string` | `"netdatalib"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_id_netdata"></a> [network\_id\_netdata](#output\_network\_id\_netdata) | Long ID for created docker network 'netdata' |
| <a name="output_variable_netdata_claim_token"></a> [variable\_netdata\_claim\_token](#output\_variable\_netdata\_claim\_token) | Variable value for 'netdata\_claim\_token' |
| <a name="output_volume_netdatacache_id"></a> [volume\_netdatacache\_id](#output\_volume\_netdatacache\_id) | ID for created docker volume 'netdatacache' |
| <a name="output_volume_netdataconfig_id"></a> [volume\_netdataconfig\_id](#output\_volume\_netdataconfig\_id) | ID for created docker volume 'netdataconfig' |
| <a name="output_volume_netdatalib_id"></a> [volume\_netdatalib\_id](#output\_volume\_netdatalib\_id) | ID for created docker volume 'netdatalib' |
<!-- END_TERRAFORM_DOCS -->
