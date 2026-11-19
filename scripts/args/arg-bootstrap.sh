#!/usr/bin/env bash

argparse "$@" <<ARGEOF || exit 1
parser.add_argument('PROJECT_NAME',
                    help='The name of the project: its folder, its DDEV project and its host name.')
parser.add_argument('-b', '--bootstrap',
                    default="${site_bootstrap_version}",
                    choices=['5.3', '4.6'],
                    help='The version of the components to serve: the pages of 5.3, or the same pages on 4.6. [default %(default)s]')
parser.add_argument('-s', '--source',
                    default="${site_source}",
                    help='The git repository the demo site is taken from (its demo-site/ folder). [default %(default)s]')
parser.add_argument('-r', '--ref',
                    default="${site_source_ref}",
                    help='A branch or a tag of that repository; empty means its default branch. Example: --ref 2.0.x [default %(default)s]')
parser.add_argument('-i', '--install',
                    action='store_true',
                    default=False,
                    help='Start the site and check that it answers at the address of the project.')
parser.add_argument('-a', '--add-users',
                    action='store_true',
                    default=False,
                    help='Taken so that every builder accepts the same flags: a static site has no accounts, and nothing is added.')
parser.add_argument('-l', '--launch',
                    action='store_true',
                    default=False,
                    help='Open the site in a browser when it is ready.')
ARGEOF
