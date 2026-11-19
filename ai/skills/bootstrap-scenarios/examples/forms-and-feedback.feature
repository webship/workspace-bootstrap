Feature: Form states, alerts, notifications and loading
  What a page tells a person: the state of each field after a form is sent, an alert, a
  notification that hides by itself, a spinner while a list loads, a bar that fills.

  Scenario: A form sent empty shows its invalid fields with their messages
    Given I am on "/validation.html"
    When I press "Submit form"
    Then 5 fields should be shown as invalid
    And the "City" field should show the message "Please provide a valid city."
    And the "First name" field should be shown as valid

  Scenario: A dismissible alert goes away with its close button
    Given I am on "/alerts.html"
    When I dismiss the alert "Holy guacamole!"
    Then I should not see the alert "Holy guacamole!"

  Scenario: A notification appears and hides by itself
    Given I am on "/toasts.html"
    When I press "Save draft"
    Then the "Draft saved" notification should be shown
    And the "Draft saved" notification should hide by itself

  Scenario: A spinner turns while a list loads, and a bar fills during an upload
    Given I am on "/loading.html"
    When I press "Load results"
    And I wait for the loading spinner to disappear
    Then I should see "3 results found."
    When I go to "/progress.html"
    And I press "Start upload"
    Then the "Upload" progress bar should reach 100%
