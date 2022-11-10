terraform {
  cloud {
    organization = "nemanja-terraform"

    workspaces {
      name = "k8s"
    }
  }
}