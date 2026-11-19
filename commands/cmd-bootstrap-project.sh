#!/usr/bin/env bash

# workspace-name: Bootstrap (components demo site)

# Installed by the Bootstrap plugin (plugins.sh --install bootstrap); __WORKSPACE__ is the workspace it was installed into.
#
# Serve the components demo site of the Bootstrap step pack in a container, at
# https://<name>.ddev.site: a page for every component, with the markup of Bootstrap's
# documentation and examples. With --install the site is started and checked. A static site:
# it has no database and no accounts.

# Bootstrap.
# Find the workspace tooling from this script, so a fresh clone needs no setup.
WORKSPACE_SCRIPTS="${WORKSPACE_SCRIPTS:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../core/scripts" && pwd)}";
source ${WORKSPACE_SCRIPTS}/bootstrap.sh || exit 1 ;

# Load workspace settings.
eval $(parse_yaml ${WORKSPACE_CONFIG}/workspace.__WORKSPACE__.settings.yml);

# Where the demo site comes from: the step pack's repository, its branch, and the version of the
# components to serve (5.3, or 4.6 for the pages of version 4.6).
site_source="https://github.com/webship/bootstrap-steps.git";
site_source_ref="2.0.x";
site_bootstrap_version="5.3";

# Distribution.
distribution_name="bootstrap";
distribution_title="Bootstrap";
distribution_webroot="site";

ARGPARSE_DESCRIPTION="Build a ${distribution_title} project in __WORKSPACE__"
# The args file comes with the plugin: core/scripts/plugins/bootstrap/ is where plugins.sh --install puts it.
source ${WORKSPACE_SCRIPTS}/plugins/bootstrap/args/arg-bootstrap.sh || exit 1 ;

shift $#;

bootstrap_build ;
