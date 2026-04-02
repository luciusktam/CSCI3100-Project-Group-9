Feature: Community comments
  As a user
  So that I can join discussions
  I want to add and manage comments

  Background:
    Given the following users exist:
      | username | email                  | password    |
      | testuser | test1@link.cuhk.edu.hk | password123 |
      | alice    | alice@link.cuhk.edu.hk | password123 |
    And the following community posts exist:
      | title             | content                 | username |
      | CSCI3100 question | How do we do milestone? | alice    |

  Scenario: Guest sees login prompt for comments
    When I visit the community post page for "CSCI3100 question"
    Then I should see "Please log in to comment."
    And I should see "Login"

  Scenario: Logged-in user adds a comment
    Given I am logged in as "testuser"
    When I visit the community post page for "CSCI3100 question"
    And I fill in the community field "Your comment" with "You should check the project brief."
    And I press the community button "Post Comment"
    Then I should see "You should check the project brief."
    And I should see "testuser"

  Scenario: Fail to add a blank comment
    Given I am logged in as "testuser"
    When I visit the community post page for "CSCI3100 question"
    And I press the community button "Post Comment"
    Then I should see a community form error

  Scenario: Comment owner can delete own comment
    Given I am logged in as "testuser"
    And the following comments exist:
      | post_title        | body              | username |
      | CSCI3100 question | Temporary comment | testuser |
    When I visit the community post page for "CSCI3100 question"
    And I press the community button "Delete Comment"
    Then I should not see "Temporary comment"

  Scenario: Non-owner cannot see delete comment button
    Given I am logged in as "testuser"
    And the following comments exist:
      | post_title        | body            | username |
      | CSCI3100 question | Alice owns this | alice    |
    When I visit the community post page for "CSCI3100 question"
    Then I should not see "Delete Comment"