# Variables for GitHub OIDC module
# Currently no variables needed, but good practice to have the file

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
