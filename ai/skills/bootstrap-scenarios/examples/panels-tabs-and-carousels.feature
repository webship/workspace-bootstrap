Feature: Panels, tabs, carousels and the navigation bar
  An accordion closes its open item while it opens another, a tab's panel fades in after the tab's
  event, a carousel slides for half a second: the steps wait for the movement, not for a time.

  Scenario: Opening an accordion item closes the one that was open
    Given I am on "/collapse.html"
    When I expand the "Accordion Item #2" panel
    Then the "Accordion Item #2" panel should be expanded
    And the "Accordion Item #1" panel should be collapsed

  Scenario: Switching tabs shows each tab's panel
    Given I am on "/tabs.html"
    When I switch to the "Profile" tab
    Then the "Profile" tab should be active
    And the "Home" tab should not be active
    And the "Profile" tab should show "the Profile tab's associated content"

  Scenario: The controls of a carousel move to the next slide
    Given I am on "/carousel.html"
    When I go to the next slide of the "Featured" carousel
    Then the "Featured" carousel should show slide 2 of 3
    And the "Featured" carousel should show "Second slide label"

  Scenario: A narrow window hides the links behind the toggle button
    When I set the viewport to the "xs" breakpoint
    And I go to "/navbar.html"
    Then the navigation bar should show its toggle button
    When I expand the navigation bar
    Then the navigation bar should be expanded
