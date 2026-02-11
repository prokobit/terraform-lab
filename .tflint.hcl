plugin "terraform" {
    enabled = true
    preset  = "recommended"
    version = "0.6.0"
    source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

plugin "azurerm" {
    enabled = true
    version = "0.30.0"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}