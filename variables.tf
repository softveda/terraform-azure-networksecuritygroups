variable "location" {
  default = "Australia East"
}

variable "rg_name" {
  description = "The name of the Resource Group where the NSGs will be deployed"
}

variable "file_pattern" {
  default = "*_objects.json"
}
