# @webship.co/workspace-bootstrap

Bootstrap for the [Webship Workspace](https://github.com/webship/workspace) dashboard: a builder
that serves the components demo site of the
[Bootstrap step pack](https://github.com/webship/bootstrap-steps) in a container (a page for every
component, with the markup of Bootstrap's documentation and examples, on version 5.3 or 4.6), the
step pack wired into the testing setup of such a site, and its AI items — two agents, a skill, a
command and two prompts for testing and building UIs made of the components — each listed in the
workspace folder of its kind.

The components are not a platform: any site may use them, whatever its CMS. So the plugin gives a
site with every component on it, and the step pack goes into any other project with the core's own
command: `bash cmd-tools-testing.sh <project> --add-steps bootstrap` (Webship Workspace 1.0.22 or
later), beside the platform's pack of a Drupal, WordPress or Joomla site whose theme is built on the
components.

The workspace is container-based (DDEV by default): a demo site is a row like any other, so the row
menus the core draws (start, stop, launch, backup, clone, remove, tests) work on it; what does not
apply to a static site is listed under
[What is different from a platform](#what-is-different-from-a-platform).

The plugin is made from the reference platform plugin,
[`@webship.co/workspace-wordpress`](https://github.com/webship/workspace-wordpress), and serves its
site the way the static-site plugins do
([`@webship.co/workspace-gatsby`](https://github.com/webship/workspace-gatsby),
[`@webship.co/workspace-astro`](https://github.com/webship/workspace-astro)).

## Use it

```bash
cd ~/workspace
bash core/scripts/plugins.sh --require bootstrap --with-needs     # npm install into the dashboard
bash core/scripts/plugins.sh --activate bootstrap --with-needs    # plugins.bootstrap in settings.yml
bash core/scripts/plugins.sh --install bootstrap                  # the builder, functions, args, AI items
bash core/scripts/plugins.sh --configure bootstrap                # nothing to configure: it has no settings file
```

The same four steps are buttons on the dashboard's **Settings → Plugins** page. `--install` is
idempotent. `--uninstall` removes what it placed; an AI item you edited stays.

Everything the plugin carries lands in the folder it belongs to, when that folder is an active
workspace folder:

| What | Lands in |
| --- | --- |
| `cmd-bootstrap-project.sh` | every active sites folder: `dev/`, `test/`, `sandboxes/`, `demos/` |
| The agents `bootstrap-ui-builder`, `bootstrap-tester` | `ai-agents/` |
| The skill `bootstrap-scenarios` | `ai-skills/` |
| The command `/bootstrap-test` | `ai-commands/` |
| The prompts `bootstrap-build-and-test`, `bootstrap-scenarios-for-a-site` | `ai-prompts/` |

There they are listed like any other item of the folder, and installed into Claude Code from there.

## What it needs

A workspace starts empty, so the manifest says what else this plugin needs (`needs`):

- one sites folder, for the builder: `dev`, `test`, `sandboxes`, `demos` (`dev` is the one added when none is there). The folder also carries `cmd-tools-testing.sh` and the Users tools this plugin's hooks answer to.
- `ai-agents`, `ai-skills`, `ai-commands` and `ai-prompts`: the AI folders its agents, its skill, its command and its prompts are placed in.

`--require` says so, `--activate` and `--install` stop until the workspace has them, and `--with-needs` adds what is missing first:

```bash
bash core/scripts/plugins.sh --activate bootstrap --with-needs   # dev and the four AI folders are required, activated and installed first
bash core/scripts/plugins.sh --install bootstrap
```

Everything the builder runs for a site runs in the site's own container, through the container
tool the workspace already needs; the plugin asks for no command of its own on the machine.

## What the package holds

| Path | What it is |
| --- | --- |
| `commands/cmd-bootstrap-project.sh` | The builder, in the Build list as **Bootstrap (components demo site)**, installed into every sites folder |
| `scripts/functions/fun-bootstrap.sh` | The bash functions behind it, sourced by bootstrap once installed; the names the core's tools look for (`set_bootstrap_users`, `add_bootstrap_users`, `cancel_bootstrap_users`, `testing_configure_bootstrap`) |
| `scripts/args/arg-bootstrap.sh` | Its argparse; the Build form draws the builder's flags from it |
| `testing/site.feature` | The first feature a demo site gets when testing is set up (it holds on both versions) |
| `ai/agents/bootstrap-ui-builder.md` | The agent that builds and checks UIs made of the components, with the demo site as its reference |
| `ai/agents/bootstrap-tester.md` | The agent that writes and runs scenarios with the step pack, on a demo site or on any other site |
| `ai/skills/bootstrap-scenarios/` | The skill: the step pack's phrases by component, the traps found on real sites, three example features |
| `ai/commands/bootstrap-test.md` | The slash command `/bootstrap-test <site>`: add the pack when missing, match every step, run, report |
| `ai/prompts/bootstrap-build-and-test.md`, `bootstrap-scenarios-for-a-site.md` | Two prompts: whole launch commands for a new session |
| `src/index.ts` | `register(api)`: what the assistant is told about the components here |
| `features/bootstrap.feature` | Scenarios for the dashboard's own browser suite |

The `workspacePlugin` block in `package.json` is the manifest the installer reads.

## What is different from a platform

| | WordPress (the reference) | Bootstrap |
| --- | --- | --- |
| What is built | A WordPress site | The components demo site: the `demo-site/` folder of the step pack's repository |
| Project | `--project-type=wordpress` | `--project-type=php --docroot=site` (`site/4.6` for `--bootstrap 4.6`), no database: the web server serves static pages |
| Recognised by | The DDEV project type | A file the builder writes: `.ddev/config.bootstrap.yaml` (it also records the version served) |
| Getting the code | `wp core download` | `git clone` of the step pack's repository, in the web container |
| Accounts | WP-CLI | None: a static site. `--add-users` is taken and adds nothing |
| Testing | The WordPress pack | The Bootstrap pack, and the tags of the version served; any other site gets it with `--add-steps bootstrap` |

## The commands

Run it from a sites folder. `--help` is safe.

### Serve the demo site

```bash
cd ~/workspace/dev
bash cmd-bootstrap-project.sh bssite --install                   # the pages of version 5.3
bash cmd-bootstrap-project.sh bssite46 --install --bootstrap 4.6  # the same pages on version 4.6
bash cmd-bootstrap-project.sh bssite --install --ref 2.0.x       # a branch or a tag of the step pack
```

| Flag | What it does |
| --- | --- |
| `--install` | Start the site and check that it answers at `https://<name>.ddev.site` |
| `--bootstrap 5.3\|4.6` | The version of the components to serve (default 5.3) |
| `--source <git url>` | The repository the demo site is taken from (default: the step pack's) |
| `--ref <branch or tag>` | A branch or a tag of that repository (default `2.0.x`) |
| `--add-users` | Taken so that every builder accepts the same flags; a static site has no accounts |
| `--launch` | Open the site in a browser when it is ready |

The builder deletes a project of the same name first, then makes a container with a web server and
no database, takes the demo site's pages from the step pack's repository and, with `--install`,
starts it and checks that it answers: about half a minute.

### Test a site

On a demo site:

```bash
bash cmd-tools-testing.sh bssite                                  # webship-js, the step pack, a first feature
bash cmd-tools-testing.sh bssite --run --path tests/features/site.feature
```

The testing setup adds `@webship-js/bootstrap-steps` to the project, lists its step definitions in
`cucumber.js`, leaves the scenarios of the other version out (`not @v4` on 5.3, `not @v5` on 4.6),
and writes `tests/features/site.feature` (the components script, a dialog, an accordion, a menu, the
navigation bar on a narrow screen). It changes nothing in a project that is not a demo site.

On any other site whose theme uses the components (Webship Workspace 1.0.22 or later):

```bash
bash cmd-tools-testing.sh mysite                          # webship-js and the platform's own pack
bash cmd-tools-testing.sh mysite --add-steps bootstrap    # the component steps, beside it
bash cmd-tools-testing.sh mysite --run
```

The component steps share no phrase with a platform's pack, so the core puts them in the same
profile; `--remove-steps bootstrap` takes out exactly what `--add-steps` put in.

### Users

A static site has no accounts. `cmd-tools-add-users.sh <name> bootstrap` and
`cmd-tools-cancel-users.sh <name> bootstrap` say so and change nothing.

## The AI items

| Item | Kind | What it is for |
| --- | --- | --- |
| `bootstrap-ui-builder` | agent | Builds and checks UIs made of the components: names a person and the steps can read, the two versions, the components a page must set up, the demo site as a reference |
| `bootstrap-tester` | agent | Writes and runs scenarios with the step pack on any site: explores in the browser first, never sleeps, never names a library or platform in a step |
| `bootstrap-scenarios` | skill | The step pack's phrases by component, the traps found on real sites, three example features that pass on the demo site |
| `/bootstrap-test <site>` | command | Adds the pack when missing, matches every step, runs, reports |
| `bootstrap-build-and-test` | prompt | Serves a demo site and proves it with its first feature |
| `bootstrap-scenarios-for-a-site` | prompt | Writes and runs the component scenarios of one site of the workspace |

Every item says the workspace is container-based (DDEV by default), and the agents and the skill
send the reader to the book *Automated Functional Testing Recipes* first.

## Develop it

```bash
npm install
npm test        # builds, then the unit tests: the manifest, the scripts, the AI items, the needs
npm run lint    # the TypeScript compiler, no output
```

CI runs the same on Node.js 24 and 26, checks that every shell script parses, and runs the plugin's
webship-js features against a dashboard with the plugin installed (the reusable workflow
`webship/workspace/.github/workflows/plugin-browser-suite.yml`). `tests/fixtures/step-definitions.txt`
holds the step definitions of the step pack at the version the testing hook pins and of webship-js,
read from their packages: every phrase an AI item shows must match one of them.
