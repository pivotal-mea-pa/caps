#
# Bootstrap state
#

variable "bootstrap_state_bucket" {
  type = "string"
}

variable "bootstrap_state_prefix" {
  type = "string"
}

# Relative path to the params template file
variable "params_template_file" {
  type = "string"
}
