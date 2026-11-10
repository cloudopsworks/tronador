# REMOVED: the repos/* module (repository template lifecycle) has been migrated
# to Tronador CLI (`tronador repos ...`). Every repos target now prints a
# migration notice and fails hard, so CI and local workflows cannot silently
# keep relying on the removed make implementation.

# Map a removed make target to its Tronador CLI equivalent.
# Default rule: repos/a/b -> tronador repos a b. Exceptions are listed first.
define repos-cli-equivalent
$(strip \
  $(if $(filter repos,$(1)),tronador repos --help,\
  $(if $(filter repos/avail repos/available,$(1)),tronador repos available,\
  $(if $(filter repos/upgrade/dev,$(1)),tronador repos upgrade develop,\
  $(if $(filter repos/upgrade/stack repos/upgrade/fetch repos/upgrade/eval repos/upgrade/issue-templates repos/upgrade/pull-request-template repos/migrate/%,$(1)),tronador repos upgrade,\
  $(if $(filter repos/template/init,$(1)),tronador repos template init,\
  $(if $(filter repos/clean/template,$(1)),tronador repos template clean,\
  tronador repos $(subst /, ,$(patsubst repos/%,%,$(1))))))))))
endef

.PHONY: repos
repos repos/%:
	@printf '\n%s\n%s\n\n  %-15s %s\n\n%s\n\n  %-15s %s\n  %-15s %s\n  %-15s %s\n\n' \
	  'ERROR: make target "$@" has been removed.' \
	  'The repos/* module was migrated to Tronador CLI. Use instead:' \
	  'Equivalent:'     '$(call repos-cli-equivalent,$@)' \
	  'Install Tronador CLI and see the docs:' \
	  'Install guide:'  'https://cloudopsworks.co/resources/tronador-cli-installation/' \
	  'Resources:'      'https://cloudopsworks.co/resources/' \
	  'GitHub project:' 'https://github.com/cloudopsworks/tronador-cli' >&2
	@exit 1
