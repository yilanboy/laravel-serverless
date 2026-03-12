locals {
  app_name = lower(replace(var.app_name, "/[^A-Za-z0-9]/", "-"))
}

resource "random_string" "resource_suffix" {
  length  = 6
  special = false
}
