Feature: Buyer-Seller Chat
  As a buyer
  I want to communicate with sellers
  So that I can ask questions about the items

  Background:
    Given the following users exist:
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
      When I click the "Chat" page button
      Then I should see the login page
      And I should see "Please log in before listing items for sale"

    Scenario: Buyer sees empty chat page when no conversations exist
      When I click the "Chat" page button
      Then I should see "Find a seller to chat with!"
      And I should see "No conversation selected"
      And I should see "Choose a user to start messaging."

    Scenario: Buyer starts a new conversation by searching for a product
      When I am on the home page
      And I fill in "q" with "camera"
      And I press "Search"
      Then I should see listing title "Vintage Camera"
      When I click on "Vintage Camera" in the item list
      And I click the "Chat with seller" button
      Then I should see the chat window with "seller1"
      And I should see a message input field
      And the messages area should be empty
      When I type "Hi, is the camera still available?" in the message input
      And I click the send button
      Then I should see my message "Hi, is the camera still available?" in the chat
      And the message should be marked as sent

    Scenario: Cannot send empty message
      When I click the "Chat" page button
      And I click on "seller1" in the user list
      And I click the send button without typing a message
      Then I should not see any new message in the chat

    Scenario: Messages appear instantly in the chat
      When I click the "Chat" page button
      And I click on "seller1" in the user list
      And I type "Hello!" in the message input
      And I click the send button
      Then I should see "Hello!" appear in the chat immediately
      And the message input should be cleared

    Scenario: Messages persist after page reload
      When I click the "Chat" page button
      And I click on "seller1" in the user list
      And I type "Persistent message" in the message input
      And I click the send button
      Then I should see "Persistent message" in the chat
      When I refresh the page
      Then I should still see "Persistent message" in the chat with "seller1"

    Scenario: Search filters users by username
      When I click the "Chat" page button
      And I search for "seller1" in the chat search
      Then I should see "seller1" in the user list
      And I should not see "seller2" in the user list
      When I clear the search
      Then I should see both "seller1" and "seller2" in the user list

    Scenario: Seller sees messages from buyer
      Given I have a conversation with "seller1" about "Vintage Camera"
      And I send a message "Is it available?"
      When I logout
      And I login as "seller1@link.cuhk.edu.hk" with password "password"
      And I click the "Chat" page button
      Then I should see "buyer" in the user list
      And I should see an unread indicator
      When I click on "buyer" in the user list
      Then I should see the message "Is it available?"
      And the message should be from "buyer"