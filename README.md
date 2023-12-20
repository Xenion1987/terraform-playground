# Terraform Playground

- [Requirements](#requirements)
  - [Docker](#docker)
  - [Microsoft Visual Studio Code](#microsoft-visual-studio-code)
  - [vscode extensions](#vscode-extensions)
- [Start contributing](#start-contributing)
- [Getting started with **terraform**](#getting-started-with-terraform)
- [Example: Create a docker container `netdata`](#example-create-a-docker-container-netdata)
  - [Setup your **terraform** environment](#setup-your-terraform-environment)
  - [Let **terraform** create a docker `netdata` container](#let-terraform-create-a-docker-netdata-container)
    - [Check what **terraform** ***would*** do (`terraform plan`)](#check-what-terraform-would-do-terraform-plan)
    - [Create **terraform** resources (`terraform apply`)](#create-terraform-resources-terraform-apply)
    - [Check created resources](#check-created-resources)
    - [Visit `netdata` metrics app](#visit-netdata-metrics-app)
  - [Set custom variables](#set-custom-variables)
- [Modules](#modules)

This repository can be used as a template for developing with `terraform`. This repository sets up a complete terraform development environment including:

- terraform
- terraform-docs
- terraform-grunt
- terraform-lint
- vscode terraform plugins
- pre-commit

## Requirements

### Docker

[Install Docker (Desktop)](https://docs.docker.com/get-docker/)

### Microsoft Visual Studio Code

Download and install [vscode](https://code.visualstudio.com/)

### vscode extensions

In **vscode**, install extension **[ms-vscode-remote.remote-containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)**

## Start contributing

1. Start **docker** engine
1. Clone this repository
1. Open the local repository in **vscode**
1. If you want to mount your local workspace directory into the **devcontainer**, modify [.devcontainer.json](./.devcontainer/devcontainer.json) Section `"mounts": [ "source=${localEnv:HOME}${localEnv:USERPROFILE}/workspace,target=/home/vscode/workspace,type=bind,consistency=cached"]` to fit your workspace path.
1. In the popup at the lower right corner, click on "Reopen in Container"
1. Initialize **terraform** via `terraform init`
1. Start infrastructure as code

## Getting started with **terraform**

| Description                                              | Link                                                                |
| -------------------------------------------------------- | ------------------------------------------------------------------- |
| Terraform official tutorials                             | [terraform.io](https://developer.hashicorp.com/terraform/tutorials) |
| HashiCorp Terraform Associate Certification Course (003) | [YouTube](https://www.youtube.com/watch?v=SPcwo0Gq9T8)              |

Most of the cloud providers cost money for each created or running instance. Some providerso do offer free tiers (e.g. [AWS](https://aws.amazon.com/free), [MS-Azure](https://azure.microsoft.com/en-in/pricing/free-services/) or [Google Cloud](https://cloud.google.com/free)). Those may be okay for getting started with terraform, but they all require knowledge related to the provider.

As a starting point, you could also use the [**docker** provider](https://developer.hashicorp.com/terraform/tutorials/docker-get-started) to getting started with **terraform** locally and for free.

## Example: Create a docker container `netdata`

### Setup your **terraform** environment

Please follow the steps described above: [Start contributing](#start-contributing)  

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

Feel free to add your own variables like `container_netdata_hostname` or your own `netdata_claim_*` variables. You only need to modify the commented out variables in [main.tf](./main.tf).

<!-- BEGIN_TERRAFORM_DOCS -->


## Modules

| Name                                                  | Source                   | Version |
| ----------------------------------------------------- | ------------------------ | ------- |
| [docker\_netdata](./modules/docker_netdata/README.md) | ./modules/docker_netdata | n/a     |
<!-- END_TERRAFORM_DOCS -->
