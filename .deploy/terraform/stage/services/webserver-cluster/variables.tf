variable "stripe_secret_key" {
  description = "The Stripe secret key"
  type = string
}

variable "web_app_url" {
  description = "Web app url to redirect user after payment"
  type = string
}

variable "web_hook_secret" {
  description = "The Stripe webhook secret"
  type = string
}

variable "service_account" {
  description = "The service account file name used for auth"
  type = string
  default = "./service-account.json"
}