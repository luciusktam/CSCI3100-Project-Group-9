Feature: Notification
  As a user
  I want the messages are notified
  So that I can ask or answer questions immediately

  Background:
    Given the following users exist:
      | username | email                    | password | password_confirmation |
      | buyer    | buyer@link.cuhk.edu.hk   | password | password              |
      | seller   | seller@link.cuhk.edu.hk  | password | password              |
      And I am logged in as a buyer

      Scenario: Notification on Chat button when receiving a new message
        Given I am on the homepage page
        And I have a conversation with "seller"
        When seller sends me a new message
        Then I should see a notification badge on the chat button at the header

      Scenario: Notification on the user who sent message
        Given I am on the chat page
        And I have a conversation with "seller"
        When seller sends me a new message
        Then I should see a notification badge on the chat sidebar for Bob
        And the unread count should be displayed as "1"

      Scenario: Notification disappear when clicked
        Given I am on the chat page
        And I have a conversation with "seller"
        When seller sends me a new message
        And I click the chat button
        Then I should not see a notification badge on the chat button at the header
        And I should be redirected to the chat page
        When I click seller on the chat sidebar
        And I should not see a toast notification appear