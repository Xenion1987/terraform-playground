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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_netdata_hostname"></a> [container\_netdata\_hostname](#input\_container\_netdata\_hostname) | Hostname to be shown on Netdata Metrics site | `string` | `"created-by-terraform"` | no |
| <a name="input_netdata_claim_rooms"></a> [netdata\_claim\_rooms](#input\_netdata\_claim\_rooms) | Room-ID to claim the host to | `string` | `""` | no |
| <a name="input_netdata_claim_token"></a> [netdata\_claim\_token](#input\_netdata\_claim\_token) | Netdata claim token | `string` | `""` | no |
| <a name="input_netdata_claim_url"></a> [netdata\_claim\_url](#input\_netdata\_claim\_url) | Netdata URL to claim the host to | `string` | `"https://app.netdata.cloud"` | no |
| <a name="input_volume_docker_socket_container"></a> [volume\_docker\_socket\_container](#input\_volume\_docker\_socket\_container) | Container Docker socket path | `string` | `"/var/run/docker.sock"` | no |
| <a name="input_volume_docker_socket_local"></a> [volume\_docker\_socket\_local](#input\_volume\_docker\_socket\_local) | Host Docker socket path | `string` | `"/var/run/docker.sock"` | no |
| <a name="input_volume_netdatacache_id"></a> [volume\_netdatacache\_id](#input\_volume\_netdatacache\_id) | Docker volume name or id to create/attach to store netdata cache data | `string` | `"netdatacache"` | no |
| <a name="input_volume_netdataconfig_id"></a> [volume\_netdataconfig\_id](#input\_volume\_netdataconfig\_id) | Docker volume name or id to create/attach to store netdata config data | `string` | `"netdataconfig"` | no |
| <a name="input_volume_netdatalib_id"></a> [volume\_netdatalib\_id](#input\_volume\_netdatalib\_id) | Docker volume name or id to create/attach to store netdata lib data | `string` | `"netdatalib"` | no |
<!-- END_TERRAFORM_DOCS -->