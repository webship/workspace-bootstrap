Feature: Dialogs and drop-down menus
  A dialog moves for about half a second when it opens and when it closes, and a menu closes in
  the ways it was made to: the steps wait for each.

  Scenario: A dialog opens with its button and closes with Escape
    Given I am on "/modal.html"
    When I open the "Modal title" dialog
    Then the "Modal title" dialog should be shown
    And the "Modal title" dialog should show "you're reading this text in a modal"
    When I press Escape in the "Modal title" dialog
    Then no dialog should be shown

  Scenario: A dialog with a static backdrop stays when the page is clicked
    Given I am on "/modal.html"
    When I open the "Static backdrop" dialog
    And I click outside the "Static backdrop" dialog
    Then the "Static backdrop" dialog should be shown
    When I press "Close" in the "Static backdrop" dialog
    Then the "Static backdrop" dialog should not be shown

  Scenario: A choice from a menu closes it and changes the page
    Given I am on "/dropdowns.html"
    When I choose "Medium" from the "Choose a size" drop-down menu
    Then the "Choose a size" drop-down menu should not be shown
    And I should see "Size: Medium."

  Scenario: The items of a menu, active and disabled
    Given I am on "/dropdowns.html"
    When I open the "Item states" drop-down menu
    Then "Active link" should be active in the "Item states" drop-down menu
    And "Disabled link" should be disabled in the "Item states" drop-down menu
    When I close the "Item states" drop-down menu
    Then no drop-down menu should be shown
