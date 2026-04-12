Feature: Browsing community posts
  As a CUtrade user
  So that I can read and search discussions
  I want to browse the community board

  Background:
  Given the following users exist:
    | username | email                  | password    |
    | testuser | test1@link.cuhk.edu.hk | password123 |
    | alice    | alice@link.cuhk.edu.hk | password123 |
  Scenario: View empty community state (logged in)
    Given I am logged in as "testuser"
    And there are no community posts
    When I visit the community page
    Then I should see "Post"
    And I should see "New Post"
    And I should see "No posts yet"
    And I should see "Create First Post"

  Scenario: View empty community state (not logged in)
    Given there are no community posts
    When I visit the community page
    Then I should see "Post"
    Then I should see "No posts yet"
    And I should see "Create First Post"

  Scenario: View community index with posts
    Given the following community posts exist:
      | title                 | content                         | username |
      | CSCI3100 project help | Need teammates for milestone 2 | testuser |
      | Looking for textbook  | Need a used database textbook  | alice    |
    When I visit the community page
    Then I should see "CSCI3100 project help"
    And I should see "Looking for textbook"
    And I should see "testuser"
    And I should see "alice"

  Scenario: View a community post
    Given the following community posts exist:
      | title                | content                           | username |
      | Used iPad discussion | Is this iPad good for note taking | testuser |
    When I visit the community post page for "Used iPad discussion"
    Then I should see "Used iPad discussion"
    And I should see "Is this iPad good for note taking"
    And I should see "Comments"

  Scenario: Search by exact keyword
    Given the following community posts exist:
      | title            | content                          | username |
      | Selling textbook | Great database textbook for sale | testuser |
      | Gaming monitor   | 144hz monitor in good condition  | alice    |
    When I visit the community page
    And I fill in the community search with "textbook"
    And I press the community search button
    Then I should see "Selling textbook"

  @fuzzy
  Scenario: Search by typo with fuzzy search
    Given the following community posts exist:
      | title                  | content                                 | username |
      | Laptop for the project | Laptop for the CSCI project, good cond. | testuser |
      | Bicycle for sale       | Cheap bicycle in good condition         | alice    |
    When I visit the community page
    And I fill in the community search with "laptp"
    And I press the community search button
    Then I should see "Laptop for the project"
