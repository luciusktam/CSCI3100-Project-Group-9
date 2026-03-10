Feature: Homepage
  As a user of the CUSHMS marketplace app
  I want to view and interact with the homepage
  So that I can browse listings and navigate the application

  Background:
    Given the user is on the homepage

  Scenario: View homepage layout and navigation elements
    Then the user should see the app logo "CUSHMS"
    And the user should see navigation links for:
      | Community |
      | Chat      |
      | Sell      |
      | Profile   |
    And the user should see a login button in the top right corner

  Scenario: Search for items using the search bar
    When the user enters "textbook" in the search input
    And clicks the search button
    Then the search should be performed with the query "textbook"
    And the user should be redirected to the search results page

  Scenario: Apply filters to search
    Given the search section is visible
    When the user clicks on the "Category" filter tag
    Then a category selection dropdown should appear
    When the user selects a category
    Then the selected category should appear as an active filter chip

    When the user clicks on the "Price" filter tag
    Then a price range input should appear
    When the user enters a price range
    Then the price filter should appear as an active filter chip

    When the user clicks on the "Location" filter tag
    Then a location selection dropdown should appear
    When the user selects a location
    Then the location filter should appear as an active filter chip

  Scenario: Clear all active filters
    Given the user has applied multiple filters
    When the user clicks the "clear all" button
    Then all active filter chips should be removed
    And the search results should update to show unfiltered listings

  Scenario: View fresh listings grid
    Then the user should see a "Fresh listings" section header
    And a "view all" link to see all listings
    And the user should see a grid of product cards

  Scenario: Interact with product cards
    Given the product grid displays multiple items
    When the user clicks on a product card
    Then the user should be redirected to that product's detail page

  Scenario: Navigate to other pages via page buttons
    When the user clicks the "Community" page button
    Then the user should be redirected to the community page

    When the user clicks the "Chat" page button
    Then the user should be redirected to the chat page

    When the user clicks the "Sell" page button
    Then the user should be redirected to the sell page

    When the user clicks the "Profile" page button
    Then the user should be redirected to the profile page

  Scenario: Login from homepage
    When the user clicks the login button
    Then the user should be redirected to the login page

  Scenario Outline: Product card displays correct information
    Given a product listing exists with:
      | category | <category> |
      | title    | <title>    |
      | price    | <price>    |
      | location | <location> |
    Then the product card should display:
      | element  | value      |
      | category | <category> |
      | title    | <title>    |
      | price    | <price>    |
      | location | <location> |

    Examples:
      | category    | title           | price  | location    |
      | Electronics | Film Camera     | $299   | CUHK        |
      | Furniture   | Leather Sofa    | $450   | Sha Tin     |
      | Fashion     | Jacket          | $89    | Kowloon Bay |

  Scenario: Search input field behavior
    Given the search input field is empty
    When the user clicks on the search input
    Then the input field should have focus
    And the search box border should highlight in blue
    When the user types in the search field
    Then the text should appear in the input
    When the user clears the search field
    Then the placeholder text should reappear