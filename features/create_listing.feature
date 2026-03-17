Feature: create listing items
    As a seller 
    I want to list an item for sale
    So that buyers can find it

    Background:
        Given I am on the home page

    Scenario: A visitor tries to sell item
        Given I am not logged in
        When I click on the sell button
        Then I should see the login page
        And I should see "Please log in before listing items for sale"

    Scenario: logged in user can navigate to create listing page
        Given I am logged in
        When I click on the sell button
        Then I should see the sell page

