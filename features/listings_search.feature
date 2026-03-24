Feature: search listings
  As a CUHK student
  So that I can quickly find items I want
  I want to search listings by keyword

  Scenario: search listings by keyword
    Given the following listings exist:
      | title            | price | category    | condition | location   | description            |
      | Study Chair      | 120   | Furniture   | Good      | Sha Tin    | Black wooden chair     |
      | Casio Calculator | 80    | Electronics | Like New  | Ma On Shan | Scientific calculator  |
    When I visit the listings page
    And I fill in "q" with "chair"
    And I press "Search"
    Then I should see listing title "Study Chair"
    And I should not see listing title "Casio Calculator"


  Scenario: filter listings by category
    Given the following listings exist:
      | title            | price | category    | condition | location   | description            |
      | Study Chair      | 120   | Furniture   | Good      | Sha Tin    | Black wooden chair     |
      | Casio Calculator | 80    | Electronics | Like New  | Ma On Shan | Scientific calculator  |
    When I visit the listings page
    And I select "Furniture" from "category"
    And I press "Search"
    Then I should see listing title "Study Chair"
    And I should not see listing title "Casio Calculator"
