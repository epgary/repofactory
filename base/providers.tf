terraform {
  required_providers {
    github = {
      version = "6.2.1"
      source  = "integrations/github"
    }
  }
}

provider "github" {}
