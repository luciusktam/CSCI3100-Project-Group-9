Feature: Homepage
  As a user of the CUSHMS marketplace app
  I want to view and interact with the homepage
  So that I can browse listings and navigate the application

  Background:
    Given I am on the home page

  Scenario: View homepage layout and navigation elements
    Then I should see the app logo "CUMarket"
    And I should see navigation links for:
      | Community |
      | Chat      |
      | Sell      |
      | Profile   |
    And I should see a login button in the top right corner

  Scenario: Navigate to community page from homepage
    Given I am logged in
    When I click the "Community" page button
    Then I should be redirected to the community page

  Scenario: Navigate to chat page from homepage
    Given I am logged in
    When I click the "Chat" page button
    Then I should be redirected to the chat page

  Scenario: Navigate to sell page from homepage
    Given I am logged in
    When I click the "Sell" page button
    Then I should be redirected to the sell page

  Scenario: Navigate to profile page from homepage
    Given I am logged in
    When I click the "Profile" page button
    Then I should be redirected to the profile page

  Scenario: Login from homepage
    When I click on the login button in the top right corner
    Then I should be redirected to the login page