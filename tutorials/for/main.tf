terraform {
  backend "local" {} # Using local backend, no remote state
}

locals {
  # A map of instances
  instances = {
    "web1" = {
      cpu = 4
      ram = 8
    }
    "web2" = {
      cpu = 4
      ram = 8
    }
    "web3" = {
      cpu = 4
      ram = 8
    }
  }
}

##########################################################
### Print all instances as declared in 'locals'
output "instances" {
  value = local.instances
}
# Output:
# instances = {
#   "web1" = {
#     "cpu" = 4
#     "ram" = 8
#   }
#   "web2" = {
#     "cpu" = 4
#     "ram" = 8
#   }
#   "web3" = {
#     "cpu" = 4
#     "ram" = 8
#   }
# }
##########################################################
### Print a list of each instance's key
output "for_list_keys" {
  value = [ # lists are surrounded by '[]'
    for instance in keys(local.instances) : instance
  ]
}
# Output:
# for_list_keys = [
#   "web1",
#   "web2",
#   "web3",
# ]

##########################################################
### Print a list of each instance's values
output "for_list_values" {
  value = [ # lists are surrounded by '[]'
    for instance in local.instances : instance
  ]
}
# Output:
# for_list_values = [
#   {
#     "cpu" = 4
#     "ram" = 8
#   },
#   {
#     "cpu" = 4
#     "ram" = 8
#   },
#   {
#     "cpu" = 4
#     "ram" = 8
#   },
# ]

##########################################################
### Print a map of each instance and it's values
output "for_map" {
  value = { # maps and dictionaries are surrounded by '{}'
    for instance_key, instance_values in local.instances : instance_key => instance_values
    #   |--- ^ ----|  |----- ^ -----|    |----- ^ -----|   |---- ^ ---| ^  |----- ^ -----|
    #        |               |                  |                |      |         |
    #        |               |                  |                |      |   ... those values.
    #        |               |                  |                | ... containing ...
    #        |               |                  |     The value of this variable
    #        |               |                  |     should be set as the map
    #        |               |                  |     key name ...
    #        |               |            input variable
    #        |  variable name for the values
    # variable name for the key
  }
}
# Output:
# for_dict = {
#   "web1" = {
#     "cpu" = 4
#     "ram" = 8
#   }
#   "web2" = {
#     "cpu" = 4
#     "ram" = 8
#   }
#   "web3" = {
#     "cpu" = 4
#     "ram" = 8
#   }
# }
