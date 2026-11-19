Feature: The components demo site answers and its components work
  As the owner of the demo site
  I want its pages to load the components script and its components to open and close
  So that a build that came out broken is caught before anything else is tested

  # Placed by the workspace's testing setup as a starting point: it is yours to change. It holds on
  # the pages of version 5.3 and on those of 4.6 (cmd-bootstrap-project.sh --bootstrap 4.6).

  @critical
  Scenario: The home page is served with the components script
    Given I am on the homepage
    Then the response status code should be 200
    And the page should use the components script
    And I should see "Collapse and accordion"

  @critical
  Scenario: A dialog opens and closes
    Given I am on "/modal.html"
    When I open the "Modal title" dialog
    Then the "Modal title" dialog should show "you're reading this text in a modal"
    When I close the "Modal title" dialog
    Then no dialog should be shown

  Scenario: Opening an accordion item closes the one that was open
    Given I am on "/collapse.html"
    When I expand the "Accordion Item #2" panel
    Then the "Accordion Item #2" panel should be expanded
    And the "Accordion Item #1" panel should be collapsed

  Scenario: A choice from a drop-down menu changes the page
    Given I am on "/dropdowns.html"
    When I choose "Medium" from the "Choose a size" drop-down menu
    Then the "Choose a size" drop-down menu should not be shown
    And I should see "Size: Medium."

  Scenario: A narrow window hides the links behind the toggle button
    When I set the viewport to the "xs" breakpoint
    And I go to "/navbar.html"
    Then the navigation bar should be collapsed
    When I expand the navigation bar
    Then the navigation bar should be expanded
