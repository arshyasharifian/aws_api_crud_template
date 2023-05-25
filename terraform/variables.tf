variable "service_name" {
    description = "Name of the Service"
    type = string
    default = "<enter_name_of_service>"
}

variable "domain_name" {
  description = "Name of domain"
  type = string
  # NOTE: must purchase this domain name before proceeding 
  default = "<enter_name_of_custom_domain>"
}