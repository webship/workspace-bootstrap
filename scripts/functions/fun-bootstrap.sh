#!/usr/bin/env bash

# Bootstrap for the Webship Workspace: serve the components demo site of the Bootstrap step pack in
# a container, and wire the step pack into the testing setup of such a site.
#
# Placed by `plugins.sh --install bootstrap` in core/scripts/plugins/bootstrap/functions/, where
# bootstrap sources it after the core's own functions. Everything runs in the project's container
# (DDEV by default), never on the host: the demo site is a folder of static pages (site/, taken
# from the demo-site/ folder of the step pack's repository), served by the container's web server.
# There is no database.
#
# The demo site is static: it has no accounts. The components are not a platform and the container
# tool has no project type for them, so a project of this builder is recognised by a file
# (.ddev/config.bootstrap.yaml, written by the builder), and four names are the ones the core's
# tools look for:
#   set_bootstrap_users          an empty list: there are no accounts  (cmd-tools-add-users.sh <project> bootstrap)
#   add_bootstrap_users          says so, and adds nothing             (the same tool)
#   cancel_bootstrap_users       says so, and removes nothing          (cmd-tools-cancel-users.sh <project> bootstrap)
#   testing_configure_bootstrap  the step pack in the testing stack    (cmd-tools-testing.sh <project>)
#
# Any other project whose theme uses the components gets the step pack from the core:
#   cmd-tools-testing.sh <project> --add-steps bootstrap

# The step pack a demo site is tested with, and the release line it is required at.
readonly BOOTSTRAP_STEPS_PACKAGE='@webship-js/bootstrap-steps';
readonly BOOTSTRAP_STEPS_VERSION='^2.0.0';

# Where the demo site lives in the web container.
readonly BOOTSTRAP_SITE='/var/www/html/site';

# A static site has no accounts: the list is empty.
function set_bootstrap_users() {
  users=();
}

# Is this folder a project of the Bootstrap builder? The builder leaves .ddev/config.bootstrap.yaml in it.
function bootstrap_is_project() {
  local project_path="$1";
  [ -f "${project_path}/.ddev/config.bootstrap.yaml" ] ;
}

# The version of the components a demo site serves (5.3 or 4.6), as the builder wrote it.
function bootstrap_served_version() {
  local project_path="$1";
  sed -n 's/^# version: //p' "${project_path}/.ddev/config.bootstrap.yaml" 2>/dev/null | head -n 1 ;
}

# What the container tool is told about the site: the web server serves the pages of the version
# asked for (site/ for 5.3, site/4.6 for 4.6) as they are. The file also marks the project as one
# of this builder.
function bootstrap_write_ddev_config() {
  local project_path="$1" version="$2" source="$3" ref="$4";
  mkdir -p "${project_path}/.ddev" || return 1 ;
  cat > "${project_path}/.ddev/config.bootstrap.yaml" <<YAMLEOF
# The components demo site of the Bootstrap step pack. Written by the Bootstrap builder of the
# workspace; build again rather than editing by hand.
# version: ${version}
# source: ${source}${ref:+ (${ref})}
# The web server serves the static pages of site/ (site/4.6 for version 4.6): there is no database.
YAMLEOF
}

# Wait until the web server answers with the demo site's home page.
function bootstrap_wait() {
  local attempt ;
  for attempt in $(seq 1 30) ; do
    if ddev exec "curl -fsS -o /dev/null http://127.0.0.1/index.html" > /dev/null 2>&1 ; then
      return 0 ;
    fi
    sleep 2 ;
  done
  echo "The web server of the project does not answer with the demo site." ;
  return 1 ;
}

# Build a demo site from nothing: the container, the pages of the step pack, and with --install the
# site started and checked.
function bootstrap_build() {
  trim_project_name ;
  local base_url="https://${PROJECT_NAME}.ddev.site" ;
  local version="${BOOTSTRAP:-${site_bootstrap_version:-5.3}}" ;
  local source="${SOURCE:-${site_source}}" ;
  local ref="${REF:-${site_source_ref:-}}" ;
  local project_path="${WORKSPACE_ROOT}/${doc_name}/${PROJECT_NAME}" ;
  local docroot="site" ;
  [ "${version}" == "4.6" ] && docroot="site/4.6" ;

  cd ${WORKSPACE_ROOT}/${doc_name} || exit 1 ;

  drop_database ;
  rm -rf "${PROJECT_NAME}" ;
  mkdir -p "${PROJECT_NAME}/site" ;
  cd "${project_path}" || exit 1 ;

  # A web server and no database: the site is static pages, served as they are.
  ddev config --project-type=php --docroot="${docroot}" --project-name=${PROJECT_NAME} \
    --omit-containers=db --nodejs-version=$(ddev_nodejs_version) || exit 1 ;
  bootstrap_write_ddev_config "${project_path}" "${version}" "${source}" "${ref}" || exit 1 ;
  ddev_up start -y || exit 1 ;

  echo "Getting the demo site: ${source}${ref:+ at ${ref}}" ;
  ddev exec "rm -rf /tmp/components-demo && git clone --quiet --depth 1 ${ref:+--branch '${ref}'} '${source}' /tmp/components-demo" \
    || { echo "The demo site could not be cloned from ${source}${ref:+ at ${ref}}." ; exit 1 ; } ;
  ddev exec "test -f /tmp/components-demo/demo-site/index.html && cp -a /tmp/components-demo/demo-site/. ${BOOTSTRAP_SITE}/ && rm -rf /tmp/components-demo" \
    || { echo "${source} has no demo-site/ folder with an index.html." ; exit 1 ; } ;
  if [ ! -f "${project_path}/${docroot}/index.html" ] ; then
    echo "The demo site has no pages for version ${version} (${docroot}/index.html)." ;
    exit 1 ;
  fi

  [ "${ADD_USERS}" == 'yes' ] && echo "--add-users: the demo site is static and has no accounts; nothing is added." ;

  if [ "${INSTALL}" == 'yes' ] ; then
    bootstrap_wait || exit 1 ;
    echo "${doc_name} ${PROJECT_NAME} is served: the components of version ${version}, $(find "${project_path}/${docroot}" -maxdepth 1 -name '*.html' | wc -l) pages.";
    echo "Go to ${base_url}";
  else
    ddev stop ;
    echo "${doc_name} ${PROJECT_NAME} is ready: the components of version ${version}.";
    echo "Serve it with: cd ${PROJECT_NAME} && ddev start   (or build with --install)";
  fi

  if [ "${LAUNCH}" == 'yes' ] ; then
    ddev launch ;
  fi

  cd ${WORKSPACE_ROOT}/${doc_name};
}

# A static site has no accounts: there is nothing to add, and nothing to remove.
function add_bootstrap_users() {
  echo "The components demo site is static: it has no accounts, so there are none to add." ;
}

function cancel_bootstrap_users() {
  echo "The components demo site is static: it has no accounts, so there are none to remove." ;
}

# The step pack in the testing stack of a demo site. The core's testing_configure calls this in the
# project folder once webship-js is scaffolded and before the dependencies are installed; for a
# project that is not a demo site of this builder it changes nothing (any other project gets the
# pack with the core's --add-steps).
#
# It adds the pack to package.json, lists its step definitions in cucumber.js after webship-js's
# own, sets the tags of the version served (the 4.6 pages leave out what only version 5 has), and
# writes a first feature when the project has none of its own. There is no users registry: the
# site has no accounts. Every part is skipped when it is already there, so a second run adds what
# the first missed and never resets a suite. The suite is the project's (its package.json,
# cucumber.js and tests/ are next to site/, not in it).
function testing_configure_bootstrap() {
  local project_path="$1";
  bootstrap_is_project "${project_path}" || return 0 ;
  if [ ! -f "${project_path}/cucumber.js" ] || [ ! -f "${project_path}/package.json" ] ; then
    echo "  Bootstrap: cucumber.js is not here yet — run the testing setup again once webship-js is scaffolded." ;
    return 1 ;
  fi

  local version ;
  version="$(bootstrap_served_version "${project_path}")" ;
  echo "Adding the Bootstrap step pack (${BOOTSTRAP_STEPS_PACKAGE} ${BOOTSTRAP_STEPS_VERSION}) for the pages of version ${version:-5.3}.";

  python3 - "${project_path}" "${BOOTSTRAP_STEPS_PACKAGE}" "${BOOTSTRAP_STEPS_VERSION}" "${version:-5.3}" <<'PYEOF' || return 1
import json, re, sys

project, pack, version, served = sys.argv[1:5]

# package.json: the pack as a dev dependency, at the release line this plugin was proven on.
pkg_file = project + '/package.json'
pkg = json.load(open(pkg_file))
if pack not in pkg.get('dependencies', {}) and pack not in pkg.get('devDependencies', {}):
    pkg.setdefault('devDependencies', {})[pack] = version
    open(pkg_file, 'w').write(json.dumps(pkg, indent=2) + '\n')
    print('  package.json: %s %s' % (pack, version))

# cucumber.js: the pack's step definitions after webship-js's own.
cucumber_file = project + '/cucumber.js'
src = open(cucumber_file).read()
before = src

if ('node_modules/%s/' % pack) not in src:
    line = "'node_modules/%s/tests/step-definitions/*.js'," % pack
    core = re.search(r"^([ \t]*)'node_modules/webship-js/tests/step-definitions/[^']*',.*$", src, re.M)
    opening = re.search(r"^([ \t]*)require:[ \t]*\[[ \t]*$", src, re.M)
    if core:
        src = src[:core.end()] + '\n' + core.group(1) + line + src[core.end():]
    elif opening:
        src = src[:opening.end()] + '\n' + opening.group(1) + '  ' + line + src[opening.end():]
    else:
        sys.exit("  cucumber.js has no require list this can add to. Add this line to it:\n    " + line)
    print('  cucumber.js: the step definitions of %s' % pack)

# The tags of the version served: the scenarios the pack tags for one version stay out of a run
# against the other (@v5: what only version 5 has; @v4: the 4.6 pages only).
skip = '@v5' if served == '4.6' else '@v4'
if 'tags:' not in src:
    opening = re.search(r"^([ \t]*)paths:.*$", src, re.M)
    if opening:
        src = src[:opening.end()] + '\n' + opening.group(1) + "tags: process.env.CUCUMBER_TAGS || 'not @wip and not %s'," % skip + src[opening.end():]
        print('  cucumber.js: the tags of the pages of version %s (not %s)' % (served, skip))

if src != before:
    open(cucumber_file, 'w').write(src)
PYEOF

  # A first feature, when the project has none for the site yet: the components script, a dialog, a
  # panel, a menu and the navigation bar on a narrow screen, on the pages of either version.
  local feature="${WORKSPACE_SCRIPTS}/plugins/bootstrap/site.feature" ;
  if [ -f "${feature}" ] && [ ! -f "${project_path}/tests/features/site.feature" ] ; then
    mkdir -p "${project_path}/tests/features" && cp "${feature}" "${project_path}/tests/features/site.feature" \
      && echo "  tests/features/site.feature: a first feature for the site" ;
  fi
}
