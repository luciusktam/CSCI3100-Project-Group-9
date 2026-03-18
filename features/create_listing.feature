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

    Scenario: logged in user succesfully creates a listing
        Given I am logged in
        When I click on the sell button
        Then I should see the sell page
        And I fill in all required fields with valid data
        And I upload 2 product photos
        And I submit the form
        Then I should see a success message
        And I should be on the new listing page
        And my listing should be visible with all details

    Scenario: Seller tries to create listing without required fields (Validation)
        Given I am logged in
        When I click on the sell button
        Then I should see the sell page
        And I do not fill in all required fields
        And I submit the form
        Then I should see validation error messages
        And I should stay on the sell page


    