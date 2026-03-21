Feature: Homepage
  As a user of the CUSHMS marketplace app
  I want to view and interact with the homepage
  So that I can browse listings and navigate the application

  Background:
    Given I am on the homepage

  @navigation
  Scenario: View homepage layout and navigation elements
    Then I should see the app logo "CUSHMS"
    And I should see navigation links for:
      | Community |
      | Chat      |
      | Sell      |
      | Profile   |
    And I should see a login button in the top right corner

  @navigation
  Scenario: Navigate to community page from homepage
    When I click the "Community" button
    Then I should be redirected to the community page

  @navigation
  Scenario: Navigate to chat page from homepage
    When I click the "Chat" button
    Then I should be redirected to the chat page

  @navigation
  Scenario: Navigate to sell page from homepage
    When I click the "Sell" button
    Then I should be redirected to the sell page

  # @navigation
  # Scenario: Navigate to profile page from homepage
  #   Given a verified user exists with email "testuser@cuhk.edu.hk" and password "password123"
  #   And the user is logged in as "testuser@cuhk.edu.hk" with password "password123"
  #   When the user clicks the "Profile" page button
  #   Then the user should be redirected to the profile page

  @navigation
  Scenario: Login from homepage
    When I click the login button
    Then I should be redirected to the login page

  @search
  Scenario: Search input field behavior
    Given the search input field is empty
    When I click on the search input
    Then the input field should have focus
    And the search box border should highlight in blue
    When I types in the search field
    Then the text should appear in the input
    When I clears the search field
    Then the placeholder text should reappear

  @search
  Scenario: Search for items using the search bar
    Given there are listings matching "textbook"
    When I enters "textbook" in the search input
    And click the search button
    Then the search should be performed with the query "textbook"
    And I should be redirected to the search results page
    And they should see listings matching "textbook"

  @filter
  Scenario: Apply category filter to search
    Given the search section is visible
    And there are listings in different categories
    When I click on the "Category" filter tag
    Then a category selection dropdown should appear
    When I selects the "Electronics" category
    Then the "Electronics" category should appear as an active filter chip
    And the search results should show only electronics listings

  @filter
  Scenario: Apply price range filter to search
    Given the search section is visible
    And there are listings with different prices
    When I click on the "Price" filter tag
    Then a price range input should appear
    When I enters minimum price "100" and maximum price "500"
    Then the price filter should appear as an active filter chip
    And the search results should show listings between $100 and $500

  @filter
  Scenario: Apply location filter to search
    Given the search section is visible
    And there are listings in different locations
    When I click on the "Location" filter tag
    Then a location selection dropdown should appear
    When I selects "CUHK" as the location
    Then the "CUHK" location should appear as an active filter chip
    And the search results should show only CUHK listings

  @filter
  Scenario: Apply multiple filters
    Given the search section is visible
    And there are listings with various categories, prices, and locations
    When I applies "Electronics" category filter
    And I applies price range from "$100" to "$500"
    And I applies "CUHK" location filter
    Then all three filters should appear as active filter chips
    And the search results should show electronics listings between $100-$500 at CUHK

  @filter
  Scenario: Clear all active filters
    Given I has applied multiple filters
    When I click the "clear all" button
    Then all active filter chips should be removed
    And the search results should update to show all listings

  @listings
  Scenario: View fresh listings grid
    Given there are 8 active listings in the database
    Then I should see a "Fresh listings" section header
    And a "view all" link to see all listings
    And I should see a grid of 8 product cards

  @listings
  Scenario: View all listings from homepage
    Given there are more than 16 active listings
    When I click the "view all" link
    Then I should be redirected to the all listings page
    And they should see all available listings

  @listings
  Scenario Outline: Product card displays correct information
    Given a product listing exists with:
      | category | <category> |
      | title    | <title>    |
      | price    | <price>    |
      | location | <location> |
    When I is on the homepage
    Then the product card should display:
      | element  | value      |
      | category | <category> |
      | title    | <title>    |
      | price    | <price>    |
      | location | <location> |

    Examples:
      | category    | title           | price  | location     |
      | Electronics | Film Camera     | $299   | CUHK         |
      | Furniture   | Leather Sofa    | $450   | Sha Tin      |
      | Fashion     | Jacket          | $89    | Kowloon Tong |

  # @listings
  # Scenario: Interact with product cards
  #   Given the product grid displays multiple items
  #   Given there are listings in the product grid
  #   When the user clicks on the product card for "Film Camera"
  #   Then the user should be redirected to that product's detail page
  #   And they should see the full details of "Film Camera"
