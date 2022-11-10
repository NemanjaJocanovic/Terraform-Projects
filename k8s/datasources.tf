data "terraform_remote_state" "kubeconfig" {
  backend = "remote"

  config = {
    organization = "nemanja-terraform"
    workspaces = {
      name = "nemanja"
    }
  }
}