---
name: bootstrap-scenarios
description: The phrases of the Bootstrap step pack (@webship-js/bootstrap-steps) by component, the traps found on real sites, and three example features that pass on the components demo site of the Webship Workspace. Use when writing or fixing webship-js scenarios for dialogs, side panels, drop-down menus, panels and accordions, tabs, the navigation bar, alerts, notifications, carousels, tooltips, popovers or form states on any site that uses Bootstrap.
---

# bootstrap-scenarios

The step pack [`@webship-js/bootstrap-steps`](https://github.com/webship/bootstrap-steps) reads the
components of any site that uses Bootstrap 5.3 (and 4.6 where the same step holds), in a
container-based (DDEV by default) Webship Workspace or anywhere else. Its steps name each component
the way a person reads it and wait on the component's own events and states. Read the installed
definitions before you write a phrase:

```bash
grep -hE "^(Given|When|Then)\(" node_modules/@webship-js/bootstrap-steps/tests/step-definitions/*.steps.js
```

A project gets the pack with `bash cmd-tools-testing.sh <site>` (a demo site of
`cmd-bootstrap-project.sh`) or `bash cmd-tools-testing.sh <site> --add-steps bootstrap` (any other
site, beside its platform's pack).

## The phrases, by component

| Component | Phrases |
| --- | --- |
| Dialog | `When I open the "Modal title" dialog`, `When I open the "..." dialog with the "..." button`, `When I close the "..." dialog`, `When I press Escape in the "..." dialog`, `When I click outside the "..." dialog`, `When I press "Save changes" in the "..." dialog`, `Then the "..." dialog should be shown`, `Then the "..." dialog should show "..."`, `Then no dialog should be shown` |
| Side panel | the same, with `side panel`: `When I open the "Offcanvas" side panel` |
| Drop-down menu | `When I open the "Dropdown button" drop-down menu`, `When I choose "Medium" from the "Choose a size" drop-down menu`, `Then "Disabled link" should be disabled in the "Item states" drop-down menu`, `Then the "..." drop-down menu should not be shown` |
| Panel, accordion | `When I expand the "Accordion Item #2" panel`, `When I collapse the "..." panel`, `Then the "..." panel should be collapsed`, `Then the "..." panel should show "..."` |
| Navigation bar | `When I expand the navigation bar`, `Then the "Main" navigation bar should be collapsed`, `Then the navigation bar should show its toggle button` |
| Tabs | `When I switch to the "Profile" tab`, `Then the "Home" tab should not be active`, `Then the "Profile" tab should show "..."` |
| Alert | `Then I should see a success alert "Well done!"`, `When I dismiss the alert "..."`, `Then the alert "..." should be dismissible` |
| Notification | `Then the "Draft saved" notification should be shown`, `Then the "..." notification should hide by itself`, `When I close the "..." notification` |
| Carousel | `When I go to the next slide of the "Featured" carousel`, `When I go to slide 3 of the carousel`, `Then the "..." carousel should show slide 2 of 3`, `Then the "..." carousel should show "..."`, `Then the "Autoplay" carousel should move to the next slide by itself` |
| Tooltip, popover | `When I hover over the "Tooltip on top" button`, `Then the "Tooltip on top" tooltip should be shown`, `Then the "Popover title" popover should show "..."`, `Then no tooltip should be shown` |
| Form states | `Then the "City" field should be shown as invalid`, `Then the "City" field should show the message "..."`, `Then 5 fields should be shown as invalid` |
| Content | `Then the list item "..." should be active`, `Then the current page of the pagination should be "2"`, `Then the "Previous" link of the pagination should be disabled`, `Then the breadcrumb should read "Home > Library > Data"`, `Then the "Inbox" button should show the badge "99+"` |
| Loading | `Then I should see a loading spinner`, `When I wait for the loading spinners to disappear`, `Then the "Upload" progress bar should reach 100%` |
| The page | `Then the page should use the components script at version "5.3"`, `When I wait for the transitions to finish` |

webship-js's own steps do the rest: `I press "..."`, `I click the "..." button`, `I fill in "..." with
"..."`, `I press the key "ArrowDown"`, `I set the viewport to the "xs" breakpoint`, `the page should
have no serious accessibility violations`.

## Traps found on real sites

- **An event is not the end of the movement.** A tab's `shown` comes before its panel has faded in;
  a notification's `shown` before it has faded in; a dialog gets `.show` 300 milliseconds before its
  `shown`. The pack waits for the movement itself: never add a `wait` after its steps.
- **A short notification can be gone before the next step.** webship-js's own steps let the page
  settle after a click, longer while a timer of the page is pending: a notification that hides in
  less than about two seconds can be gone before `should be shown` looks. Assert that it hides by
  itself instead.
- **Escape needs the focus.** After a click on a backdrop the keyboard focus is on the page's body,
  where Escape does nothing. `When I press Escape in ...` puts the focus in the component first, as
  a keyboard user's is.
- **Two dialogs with one title** are one name for two things: give each its own, or the step takes
  the one that is shown.
- **The theme's own markup wins.** Drupal's theme `bootstrap5` marks a field with an error with its
  own class (`error`), not with `is-invalid`: the form state steps read the framework's classes only.
  Its pager says "Page 1" to a screen reader and shows "1": the steps read both.
- **Version 4.6.** Its notifications hide after half a second unless they say otherwise
  (`data-delay`); its events go through jQuery only; it has no side panels; its default colours of
  navigation links fail the contrast rule.
- **A button that is an input.** webship-js's `I press "Log in"` matches by text and can take a link
  of the same text before an `input type="submit"`: use `I click the "Log in" button`.

## Examples

Three features that pass on the components demo site (`bash cmd-bootstrap-project.sh <site>
--install`), copied into `tests/features/` of the project:

- `examples/dialogs-and-menus.feature`: a dialog, a static backdrop, a menu, a menu that closes by hand.
- `examples/panels-tabs-and-carousels.feature`: an accordion, tabs, a carousel, the navigation bar.
- `examples/forms-and-feedback.feature`: form states, alerts, a notification, a spinner and a progress bar.

## The book

For any automated functional testing in this work (a Gherkin feature, a step definition, choosing a
step, a test run and its failures), read the book *Automated Functional Testing Recipes* first.

- **Where.** Use the first that exists: `.claude/automated-functional-testing-recipes/` in the project,
  `~/.claude/automated-functional-testing-recipes/` (installed by webship/webship-js-ai-agent,
  webship/webship-js-skills or webship/ai-agents), or
  https://github.com/webship/webship-js-ai-agent/tree/2.0.x/automated-functional-testing-recipes
- **How.** Its `README.md` first, then the chapter that matches the task (one file per chapter,
  named by its subject), not the single complete file.
- **Which wins.** The installed webship-js package and the step pack are the source of truth for
  step phrasing. When they differ from the book, follow them and say so.
- **For Bootstrap.** Start with `ch08-modal-dialog-testing.md` (dialogs, drawers, notifications,
  tooltips and popovers), `ch07-waiting-dynamic-content.md` (why a wait names its signal, never a
  time), `ch13-responsive-mobile-testing.md` (the navigation bar on a narrow screen) and
  `ch21-when-tests-go-bad.md` (flaky, brittle and slow scenarios).
