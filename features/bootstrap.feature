Feature: The Bootstrap plugin on the dashboard
  Once the plugin is activated and installed, the sites folders offer the Bootstrap builder, each
  AI folder lists the items of its kind the plugin ships, and the Plugins page lists the plugin
  with what it ships.

  # Settings lists every plugin that was added; the package and what the plugin ships are on its own page.
  Scenario: Settings lists the plugin, and its own page names its package and what it ships
    Given I am on "/settings"
     Then I should see "Bootstrap"
     When I go to "/settings/plugin/bootstrap"
     Then I should see "@webship.co/workspace-bootstrap"
      And I should see "cmd-bootstrap-project.sh"
      And I should see "bootstrap-ui-builder"

  Scenario: A sites folder offers the Bootstrap builder
    Given I am on "/dev"
     Then "option[value='cmd-bootstrap-project.sh']" should be attached

  # The AI folders are searched by name: with every plugin on, a folder lists more than one page of items.
  Scenario: The AI Agents folder lists the agents the plugin ships
    Given I am on "/ai-agents?q=bootstrap-"
     Then I should see "bootstrap-ui-builder"
      And I should see "bootstrap-tester"

  Scenario: The AI Skills folder lists the skill the plugin ships
    Given I am on "/ai-skills?q=bootstrap-scenarios"
     Then I should see "bootstrap-scenarios"

  Scenario: The AI Commands folder lists the command the plugin ships
    Given I am on "/ai-commands?q=bootstrap-test"
     Then I should see "bootstrap-test"

  Scenario: The AI Prompts folder lists the prompts the plugin ships
    Given I am on "/ai-prompts?q=bootstrap-"
     Then I should see "bootstrap-build-and-test"
      And I should see "bootstrap-scenarios-for-a-site"
