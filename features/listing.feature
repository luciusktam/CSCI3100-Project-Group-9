Feature: listing items pages
    As a user 
    I want to see the listing items
    So that I can buy it

        
    
    Scenario: I see an item I want buy at home page
        Given I create 30 test listings
        Given I am on the home page
        Then I should see the 8 most recent listings
        And I should see listing titles, prices, and images
        
    
    Scenario: I see an item on listing page
        Given I create 30 test listings
        Given I am on the home page
        When I click 'view all'
        Then I should be on the listings index page
        And I should see pagination if there are more than 20 listings

    Scenario: no listing posted yet
        Given I am on the home page
        Then I should see No listings yet
        When I click 'view all'
        Then I should be on the listings index page
        Then I should see No listings yet