variable "region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "us-east-1"
}

variable "ses_email" {
  description = "The verified email address for SES."
  type        = string
}

variable "open_ai_api_key" {
  description = "The OpenAi API key."
  type        = string
}
