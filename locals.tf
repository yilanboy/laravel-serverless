locals {
  app_name = lower(replace(var.app_name, "/[^A-Za-z0-9]/", "-"))

  bref_v3_environment_variables = {
    BREF_RUNTIME         = "Bref\\FunctionRuntime\\Main"
    LOG_CHANNEL          = "stderr"
    LOG_STDERR_FORMATTER = "Bref\\Monolog\\CloudWatchFormatter"
  }
}
