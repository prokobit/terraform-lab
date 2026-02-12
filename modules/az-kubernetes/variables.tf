variable "prefix" {
  type = string
}

variable "resource_group" {
  type        = any
  description = "Resource Group"
}

variable "data_collection_rule_id" {
  type        = any
  description = "Data Collection Rule Id"
}
