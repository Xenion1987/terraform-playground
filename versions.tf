# This file contains all provider and their versions
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
      # =  use exact version (e.g. 4.3.2)
      # >  use latest version
      # >= use exact or latest version
      # ~> use latest PATCH version (e.g. 4.3.x)
      # <  use lower version
      # <= use exact or lower version
      # combinations are allowed (e.g. >= 4.0.0 < 5.0.0)
    }
  }
}
