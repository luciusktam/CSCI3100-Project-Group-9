Feature: create listing items
    As a seller 
    I want to edit an item that is listed
    So that I can update my item information

    Background:
    Given I am logged in
    And I have a listing

    Scenario: Owner successfully edits their listing
        When I visit the edit page for my listing
        And I fill in the edit form with updated valid data
        And I update 1 product photo
        And I submit the edit form
        Then I should see an update success message
        And I should be on the updated listing page
        And my listing should show all updated details

    Scenario: Owner tries to edit listing without required fields (Validation)
        When I visit the edit page for my listing
        And I remove the title
        And I submit the edit form
        Then I should see validation error messages on the edit page
        And I should stay on the edit page
        And my listing should still have the original title "iPhone 12"

    Scenario: Non-owner tries to edit someone else's listing (Authorization)
        Given I am logged in as a different user
        When I visit the edit page for the listing "iPhone 12"
        Then I should see an unauthorized message
        And I should be redirected to the listing page

    Scenario: Visitor tries to edit listing without logging in
        Given I am on the home page
        Given I am not logged in
        When I visit the edit page for the listing "iPhone 12"
        Then I should see a message to log in
        And I should see "Please log in before listing items for sale"