variable "application" {
  type    = string
  default = "ddb-zero-etl"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "source_table" {
  type    = string
  default = "orders"
}


variable "manage_zero_etl_integration" {
  type = object({
    name     = string
    dist_dir = string
    handler  = string
  })

  default = {
    name     = "manage-zero-etl-integration"
    dist_dir = "../src/dist"
    handler  = "manage-zero-etl-integration.handler"
  }

}
