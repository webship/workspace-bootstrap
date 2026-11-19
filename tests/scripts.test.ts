import test from 'node:test';
import assert from 'node:assert';
import fs from 'fs';
import os from 'os';
import path from 'path';
import { spawnSync } from 'child_process';

// Compiled, these tests run from dist/tests, so the package root is one folder further up.
const PKG = fs.existsSync(path.join(__dirname, '..', 'package.json')) ? path.join(__dirname, '..') : path.join(__dirname, '..', '..');
const FUNCTIONS = path.join(PKG, 'scripts', 'functions', 'fun-bootstrap.sh');

// The cucumber.js webship-js scaffolds, as far as the testing hook reads it.
const SCAFFOLD = `module.exports = {
  default: {
    requireModule: ['tsx/cjs'],
    require: [
      'node_modules/webship-js/tests/step-definitions/**/*.js',          // Webship-js core step definitions.
      'tests/step-definitions/**/*.js',                                  // Your custom step definitions.
    ],
    paths: ['tests/features/**/*.feature'],
    worldParameters: {
      launchUrl: process.env.LAUNCH_URL || 'http://localhost:8080',
    },
  },
};
`;

/** A project folder with the testing stack scaffolded, and the tooling folder the installer would have filled. */
function project(kind: 'demo' | 'drupal', version = '5.3') {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'bootstrap-plugin-'));
  const dir = path.join(root, 'dev', 'site1');
  fs.mkdirSync(path.join(dir, '.ddev'), { recursive: true });
  fs.writeFileSync(path.join(dir, '.ddev', 'config.yaml'), `name: site1\ntype: ${kind === 'demo' ? 'php' : 'drupal11'}\ndocroot: ${kind === 'demo' ? (version === '4.6' ? 'site/4.6' : 'site') : 'web'}\n`);
  if (kind === 'demo') {
    fs.writeFileSync(path.join(dir, '.ddev', 'config.bootstrap.yaml'), `# The components demo site of the Bootstrap step pack.\n# version: ${version}\n`);
    fs.mkdirSync(path.join(dir, 'site'), { recursive: true });
    fs.writeFileSync(path.join(dir, 'site', 'index.html'), '<!doctype html>\n');
  }
  fs.writeFileSync(path.join(dir, 'cucumber.js'), SCAFFOLD);
  fs.writeFileSync(path.join(dir, 'package.json'), JSON.stringify({ name: 'site1', devDependencies: { 'webship-js': '^2.0.16' } }, null, 2));
  const scripts = path.join(root, 'core', 'scripts');
  fs.mkdirSync(path.join(scripts, 'plugins', 'bootstrap'), { recursive: true });
  fs.copyFileSync(path.join(PKG, 'testing', 'site.feature'), path.join(scripts, 'plugins', 'bootstrap', 'site.feature'));
  return { root, dir, scripts };
}

/** Run bash with the plugin's functions sourced and `ddev` replaced by a recorder. */
function bash(script: string, env: Record<string, string> = {}) {
  const fake = 'ddev() { echo "ddev $*" >> "${DDEV_LOG:-/dev/null}" ; return 0 ; }';
  return spawnSync('bash', ['-c', `${fake}\nsource ${FUNCTIONS}\n${script}`], { encoding: 'utf8', env: { ...process.env, ...env } });
}

test('a static site has no accounts: the list is empty, and adding or removing them says so', () => {
  let r = bash('set_bootstrap_users ; echo "${#users[@]}"');
  assert.strictEqual(r.status, 0, r.stderr);
  assert.strictEqual(r.stdout.trim(), '0');
  r = bash('add_bootstrap_users ; cancel_bootstrap_users');
  assert.strictEqual(r.status, 0, r.stderr);
  assert.match(r.stdout, /no accounts, so there are none to add/);
  assert.match(r.stdout, /no accounts, so there are none to remove/);
});

test('the testing hook adds the step pack, the tags of the version and a first feature to a demo site, once', () => {
  const p = project('demo');
  const run = () => bash(`cd ${p.dir} && testing_configure_bootstrap ${p.dir}`, { WORKSPACE_ROOT: p.root, WORKSPACE_SCRIPTS: p.scripts, doc_name: 'dev', PROJECT_NAME: 'site1' });
  const r = run();
  assert.strictEqual(r.status, 0, r.stderr + r.stdout);
  const pkg = JSON.parse(fs.readFileSync(path.join(p.dir, 'package.json'), 'utf8'));
  assert.strictEqual(pkg.devDependencies['@webship-js/bootstrap-steps'], '^2.0.0');
  assert.strictEqual(pkg.devDependencies['webship-js'], '^2.0.16', 'what was there stays');
  const cucumber = fs.readFileSync(path.join(p.dir, 'cucumber.js'), 'utf8');
  const lines = cucumber.split('\n');
  const core = lines.findIndex((l) => l.includes('node_modules/webship-js/tests/step-definitions'));
  assert.strictEqual(lines[core + 1], "      'node_modules/@webship-js/bootstrap-steps/tests/step-definitions/*.js',", 'the pack is listed right after webship-js');
  assert.match(cucumber, /tags: process\.env\.CUCUMBER_TAGS \|\| 'not @wip and not @v4',/, 'the pages of 5.3 leave out the 4.6 scenarios');
  const loaded = spawnSync(process.execPath, ['-e', `const c = require(${JSON.stringify(path.join(p.dir, 'cucumber.js'))}).default; console.log(JSON.stringify([c.require.length, c.tags]))`], { encoding: 'utf8' });
  assert.strictEqual(loaded.status, 0, loaded.stderr);
  assert.deepStrictEqual(JSON.parse(loaded.stdout), [3, 'not @wip and not @v4']);
  assert.ok(fs.existsSync(path.join(p.dir, 'tests', 'features', 'site.feature')));
  // Again, after a person changed the feature: nothing is doubled, nothing is reset.
  fs.writeFileSync(path.join(p.dir, 'tests', 'features', 'site.feature'), 'Feature: mine\n');
  assert.strictEqual(run().status, 0);
  assert.strictEqual(fs.readFileSync(path.join(p.dir, 'cucumber.js'), 'utf8'), cucumber);
  assert.strictEqual(fs.readFileSync(path.join(p.dir, 'tests', 'features', 'site.feature'), 'utf8'), 'Feature: mine\n');
});

test('a demo site of version 4.6 leaves out the scenarios of version 5', () => {
  const p = project('demo', '4.6');
  const r = bash(`cd ${p.dir} && testing_configure_bootstrap ${p.dir}`, { WORKSPACE_ROOT: p.root, WORKSPACE_SCRIPTS: p.scripts, doc_name: 'dev', PROJECT_NAME: 'site1' });
  assert.strictEqual(r.status, 0, r.stderr + r.stdout);
  assert.match(r.stdout, /for the pages of version 4\.6/);
  assert.match(fs.readFileSync(path.join(p.dir, 'cucumber.js'), 'utf8'), /tags: process\.env\.CUCUMBER_TAGS \|\| 'not @wip and not @v5',/);
});

test('the testing hook leaves any other project alone: the core\'s --add-steps gives it the pack', () => {
  const p = project('drupal');
  const r = bash(`cd ${p.dir} && testing_configure_bootstrap ${p.dir}`, { WORKSPACE_ROOT: p.root, WORKSPACE_SCRIPTS: p.scripts, doc_name: 'dev', PROJECT_NAME: 'site1' });
  assert.strictEqual(r.status, 0);
  assert.strictEqual(r.stdout, '');
  assert.strictEqual(fs.readFileSync(path.join(p.dir, 'cucumber.js'), 'utf8'), SCAFFOLD);
  assert.ok(!fs.existsSync(path.join(p.dir, 'tests')));
});

test('the build takes the demo site from the step pack, serves the pages of the version asked for, and has no database', () => {
  for (const version of ['5.3', '4.6']) {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'bootstrap-build-'));
    fs.mkdirSync(path.join(root, 'dev'), { recursive: true });
    const log = path.join(root, 'ddev.log');
    // The recorder also stands in for the copy of the pages, so the build finds them where they go.
    const script = [
      'trim_project_name() { :; } ; drop_database() { :; } ; ddev_up() { ddev "$@" ; } ; ddev_nodejs_version() { echo 24 ; }',
      `ddev() { echo "ddev $*" >> ${log} ; case "$*" in *"cp -a"*) mkdir -p ${root}/dev/site1/site/4.6 && touch ${root}/dev/site1/site/index.html ${root}/dev/site1/site/4.6/index.html ;; esac ; return 0 ; }`,
      `PROJECT_NAME=site1 ; INSTALL=no ; BOOTSTRAP=${version} ; SOURCE=https://example.com/pack.git ; REF=2.0.x`,
      'bootstrap_build',
    ].join('\n');
    const r = spawnSync('bash', ['-c', `source ${FUNCTIONS}\n${script}`], { encoding: 'utf8', env: { ...process.env, WORKSPACE_ROOT: root, doc_name: 'dev' } });
    assert.strictEqual(r.status, 0, r.stderr + r.stdout);
    const calls = fs.readFileSync(log, 'utf8');
    assert.match(calls, new RegExp(`ddev config --project-type=php --docroot=${version === '4.6' ? 'site/4\\.6' : 'site'} --project-name=site1 --omit-containers=db --nodejs-version=24`));
    assert.match(calls, /git clone --quiet --depth 1 --branch '2\.0\.x' 'https:\/\/example\.com\/pack\.git'/);
    assert.match(calls, /cp -a \/tmp\/components-demo\/demo-site\/\. \/var\/www\/html\/site\//);
    assert.match(calls, /^ddev stop$/m, 'without --install the site is ready and stopped');
    assert.match(fs.readFileSync(path.join(root, 'dev', 'site1', '.ddev', 'config.bootstrap.yaml'), 'utf8'), new RegExp(`^# version: ${version.replace('.', '\\.')}$`, 'm'));
  }
});

test('the first feature names no library or platform in a step, and holds on both versions', () => {
  const feature = fs.readFileSync(path.join(PKG, 'testing', 'site.feature'), 'utf8');
  const steps = feature.split('\n').filter((l) => /^\s*(Given|When|Then|And|But) /.test(l));
  assert.ok(steps.length >= 15);
  for (const s of steps) assert.doesNotMatch(s, /bootstrap|drupal|wordpress/i, s);
  assert.doesNotMatch(feature, /@v5|@v4/, 'no scenario of one version only');
  assert.doesNotMatch(feature, /side panel|offcanvas/i, 'version 4.6 has no side panels');
});
