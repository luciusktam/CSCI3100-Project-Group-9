Feature: Managing community posts
  As a logged-in user
  So that I can share with the community
  I want to create, edit, and delete my posts

  Background:
    Given the following users exist:
      | username | email                  | password    |
      | testuser | test1@link.cuhk.edu.hk | password123 |
      | alice    | alice@link.cuhk.edu.hk | password123 |
    And I am logged in as "testuser"

  Scenario: Create a new post successfully
    When I visit the new community post page
    And I fill in the community field "Title" with "Laptop for CSCI project"
    And I fill in the community field "Content" with "Selling a laptop that is good for coding projects."
    And I press the community button "Create Post"
    Then I should see "Laptop for CSCI project"
    And I should see "Selling a laptop that is good for coding projects."

  Scenario: Fail to create a post with blank fields
    When I visit the new community post page
    And I press the community button "Create Post"
    Then I should see a community form error

  Scenario: Edit my own post
    Given the following community posts exist:
      | title     | content       | username |
      | Old title | Old post body | testuser |
    When I visit the community post page for "Old title"
    And I follow "Edit"
    And I fill in the community field "Title" with "Updated title"
    And I fill in the community field "Content" with "Updated post body"
    And I press the community button "Update Post"
    Then I should see "Updated title"
    And I should see "Updated post body"
    And I should not see "Old title"

  Scenario: Delete my own post from show page
    Given the following community posts exist:
      | title     | content     | username |
      | Delete me | Remove this | testuser |
    When I visit the community post page for "Delete me"
    And I press the community button "Delete"
    Then I should be on the community page
    And I should not see "Delete me"

  Scenario: Owner can see edit and delete buttons
    Given the following community posts exist:
      | title       | content        | username |
      | My own post | My own content | testuser |
    When I visit the community post page for "My own post"
    Then I should see "Edit"
    And I should see "Delete"

  Scenario: Non-owner cannot see edit and delete buttons
    Given the following community posts exist:
      | title      | content       | username |
      | Alice post | Post by alice | alice    |
    When I visit the community post page for "Alice post"
    Then I should not see "Edit"
    And I should not see "Delete"