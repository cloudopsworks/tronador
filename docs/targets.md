## Makefile Targets
```
Available targets:

  bash/lint                           Lint all bash scripts
  docs/copyright-add                  Add copyright headers to source code
  git/aliases-update                  Update git aliases
  git/export                          Export git vars
  git/submodules-update               Update submodules
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
