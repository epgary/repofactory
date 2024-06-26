variable "repositories_file" {
  description = "Path to the YAML file containing repository configurations"
  default     = "repositories.yaml"
}

locals {
  repositories = yamldecode(file(var.repositories_file))["repositories"]
}

resource "github_repository" "repos" {
  for_each = { for repo in local.repositories : keys(repo)[0] => values(repo)[0] }

  name       = each.key
  visibility = try(each.value.repository_options.visibility, "private")

  # Shared configuration
  allow_auto_merge            = false
  allow_merge_commit          = false
  allow_rebase_merge          = false
  allow_squash_merge          = true
  allow_update_branch         = true
  auto_init                   = true
  delete_branch_on_merge      = true
  has_discussions             = false
  has_downloads               = true
  has_issues                  = true
  has_projects                = true
  has_wiki                    = true
  merge_commit_message        = "PR_TITLE"
  merge_commit_title          = "MERGE_MESSAGE"
  squash_merge_commit_message = "COMMIT_MESSAGES"
  squash_merge_commit_title   = "PR_TITLE"
  vulnerability_alerts        = true
}

resource "github_branch_protection" "main" {
  for_each = { for repo in local.repositories : keys(repo)[0] => values(repo)[0] }

  pattern                = "main"
  repository_id          = github_repository.repos[each.key].node_id
  require_signed_commits = try(each.value.main_branch_options.require_signed_commits, false)

  # Shared configuration
  allows_deletions                = false
  allows_force_pushes             = false
  enforce_admins                  = true
  require_conversation_resolution = true
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 1
  }
  required_status_checks {
    strict = true
  }
}

resource "github_repository_environment" "test" {
  for_each    = github_repository.repos
  repository  = each.value.name
  environment = "environment/test"
  wait_timer  = 10000
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "test" {
  for_each       = github_repository.repos
  repository     = each.value.name
  environment    = github_repository_environment.test[each.key].environment
  branch_pattern = "releases/*"
}
