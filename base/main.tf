terraform {
  required_providers {
    github = {
      version = "6.2.1"
      source  = "integrations/github"
    }
  }
}

provider "github" {}

resource "github_repository" "SampleRepo" {
  name                        = "todelete_sample"
  visibility                  = "publicc"
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

resource "github_branch_protection" "MainBranchProtection" {
  repository_id                   = github_repository.SampleRepo.node_id
  pattern                         = "main"
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
