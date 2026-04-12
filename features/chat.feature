Feature: Buyer-Seller Chat
  As a buyer
  I want to communicate with sellers
  So that I can ask questions about the items

  Background:
    Given the following users exist to chat:
      | username | email                    | password | password_confirmation |
      | buyer    | buyer@link.cuhk.edu.hk   | password | password              |
      | seller1  | seller1@link.cuhk.edu.hk | password | password              |
      | seller2  | seller2@link.cuhk.edu.hk | password | password              |
    And the following listings exist chat:
      | title          | price | category    | condition | location   | seller  |
      | Vintage Camera | 299   | Electronics | New       | CUHK       | seller1 |
      | Leather Sofa   | 450   | Furniture   | New       | Sha Tin    | seller1 |
      | Mountain Bike  | 199   | Sports      | New       | Ma On Shan | seller2 |
    And I am logged in as a buyer

  Scenario: A visitor tries to chat
    Given I am not logged in
    When I visit the chat page directly
    Then I should see a message to log in
    And I should see "Please log in before accessing the chat"

  Scenario: Buyer sees empty chat page when no conversations exist
    When I click the "Chat" page button
    Then I should see "Find a seller to chat with!"
    And I should see "No conversation selected"
    And I should see "Choose a user to start messaging."
