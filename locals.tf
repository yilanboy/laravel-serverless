locals {
  app_name = lower(replace(var.app_name, "/[^A-Za-z0-9]/", "-"))
}
