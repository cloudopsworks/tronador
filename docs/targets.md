## Makefile Targets
```
Available targets:

  bash/lint                           Lint all bash scripts
  docs/copyright-add                  Add copyright headers to source code
  git/aliases-update                  Update git aliases
  git/export                          Export git vars
  git/submodules-update               Update submodules
  gitflow/feature/finish              Git-Flow feature finish (automatic via PR), this receives the following call pattern: make gitflow/feature/finish must be on a feature branch
  gitflow/feature/finish/%            Git-Flow feature finish (manual), this receives the following call pattern: make gitflow/feature/manual/finish:<feature_name>
  gitflow/feature/publish             Git-Flow feature publish
  gitflow/feature/publish/%           Git-Flow feature publish, this receives the following call pattern: make gitflow/feature/publish:<feature_name>
  gitflow/feature/purge/%             Git-Flow feature purge, this receives the following call pattern: make gitflow/feature/purge:<feature_name>
  gitflow/feature/start/%             Git-Flow feature start, this receives the following call pattern: make gitflow/feature/start:<feature_name>
  gitflow/hotfix/finish               Git-Flow Hotfix finish (automatic via PR)
  gitflow/hotfix/finish/%             Git-Flow Hotfix finish (manual)
  gitflow/hotfix/publish              GIt-Flow Hotfix publishing
  gitflow/hotfix/purge                Git-Flow hotfix purge
  gitflow/hotfix/purge/%              Git-Flow hotfix purge with hotfix-version
  gitflow/hotfix/start                GIt-Flow Hotfix start
  gitflow/init                        Git-Flow Initialize develop branch
  gitflow/release/finish              Git-Flow release publish Pull-Request against MAIN and DEVELOP branches
  gitflow/release/finish/%            Git-Flow release finish (manual), this receives the following call pattern: make gitflow/release/manual/finish:<version>
  gitflow/release/finish/comment      Git-Flow release finish (automatic via pr)
  gitflow/release/publish             Git-Flow release publish
  gitflow/release/publish/%           Git-Flow release publish (manual), this receives the following call pattern: make gitflow/release/manual/publish:<version>
  gitflow/release/purge               Git-Flow release purge on current tag
  gitflow/release/purge/%             Git-Flow release purge on specific version
  gitflow/release/start               Git-Flow release start - this process uses the GitVersion tool to infer the next version
  gitflow/release/start/%             Git-Flow release start next version, for forced version the call is gitflow/release/start:<version>
  gitflow/release/start/major         Git-Flow release start next  major version.
  gitflow/release/start/minor         Git-Flow release start next  minor version.
  gitflow/release/start/patch         Git-Flow release start next  patch version.
  gitflow/support/publish             Git-Flow support publish
  gitflow/support/publish/%           Git-Flow support publish, this receives the following call pattern: make gitflow/support/publish:<version>
  gitflow/support/start/%             Git-Flow support start, this receives the following call pattern: make gitflow/support/start:<version>
  gitflow/version/publish             Git-Flow version publish to remote (push tags
  gitflow/version/semver              Retrieve the SemVer version with GitVersion tool
  gitflow/version/semver/full         Retrieve the Full SemVer version (commits count) with GitVersion tool translate + to - for compatibility with Helm/Docker
  gitflow/version/tag                 Git-Flow version tagging
  gitflow/version/tag/%               Git-Flow version tagging with meta tagging for release&pre-release, meta tag is in form of <meta_tag>(. or -)<meta_tag_value>
  github/download-private-release     Download release from github
  github/download-public-release      Download release from github
  github/latest-release               Fetch the latest release tag from the GitHub API
  github/push-artifacts               Push all release artifacts to GitHub (Required: `GITHUB_TOKEN`)
  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  make/lint                           Lint all makefiles
  packages/delete                     Delete packages
  packages/install                    Install packages 
  packages/install/%                  Install package (e.g. helm, helmfile, kubectl)
  packages/reinstall                  Reinstall packages
  packages/reinstall/%                Reinstall package (e.g. helm, helmfile, kubectl)
  packages/uninstall/%                Uninstall package (e.g. helm, helmfile, kubectl)
  readme                              Alias for readme/build
  readme/build                        Create README.md by building it from README.yaml
  readme/init                         Create basic minimalistic .README.md template file
  readme/lint                         Verify the `README.md` is up to date
  semver/export                       Export semver vars
  template/build                      Create $OUT file by building it from $IN template file
  template/deps                       Install dependencies
  terraform/get-modules               Ensure all modules can be fetched
  terraform/get-plugins               Ensure all plugins can be fetched
  terraform/install                   Install terraform
  terraform/lint                      Lint check Terraform
  terraform/upgrade-modules           Upgrade all terraform module sources
  terraform/validate                  Basic terraform sanity check

```
