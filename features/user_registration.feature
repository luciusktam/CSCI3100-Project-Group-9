Feature: Single-page Login/Registration
  As a visitor
  I want to login or register

  Background:
    Given I am on the home page

  Scenario: New user registration with valid CUHK email
    When I click on the login button in the top right corner
    Then I should see a login/registration form
    When I enter email "newstudent@link.cuhk.edu.hk" in the form
    Then the system should detect this is a new email
    And I should see new fields for username and password appear
    When I fill in username "cuhkstudent"
    And I fill in password "Password123"
    And I fill in password confirmation "Password123"
    And I click "Register"
    Then I should receive a confirmation email

  Scenario: Existing user login with correct password
    Given a confirmed user exists with email "existing@link.cuhk.edu.hk" and password "Password123"
    When I click on the login button in the top right corner
    Then I should see a login/registration form
    When I enter email "existing@link.cuhk.edu.hk" in the form
    Then the system should detect this is an existing email
    And I should see only the password field appear
    When I fill in password "Password123"
    And I click "Login"
    Then I should be redirected to the home page
    And I should see "Logged in successfully"

  Scenario: Existing user with wrong password
    Given a confirmed user exists with email "existing@link.cuhk.edu.hk" and password "Password123"
    When I click on the login button in the top right corner
    Then I should see a login/registration form
    When I enter email "existing@link.cuhk.edu.hk" in the form
    Then I should see only the password field appear
    When I fill in password "WrongPassword123"
    And I click "Login"
    Then I should stay on the same page
    And I should see "Invalid email or password"
    And the password field should be cleared for retry

  Scenario: New user with non-CUHK email
    When I click on the login button in the top right corner
    Then I should see a login/registration form
    When I enter email "student@gmail.com" in the form
    Then I should see an error message "Only @link.cuhk.edu.hk email addresses are allowed"
    And no additional fields should appear

  Scenario: New user registration with weak password
    When I click on the login button in the top right corner
    Then I should see a login/registration form
    When I enter email "newstudent@link.cuhk.edu.hk" in the form
    Then the system should detect this is a new email
    And I should see new fields for username and password appear
    When I fill in username "cuhkstudent"
    And I fill in password "weak"
    And I fill in password confirmation "weak"
    Then I should see password error messages:
      | error |
      | Password must be at least 8 characters |
      | Password must contain at least one uppercase letter |

  Scenario: New user registration with mismatched passwords
    When I click on the login button in the top right corner
    Then I should see a login/registration form
    When I enter email "newstudent@link.cuhk.edu.hk" in the form
    Then the system should detect this is a new email
    And I should see new fields for username and password appear
    When I fill in username "cuhkstudent"
    And I fill in password "Password123"
    And I fill in password confirmation "Password456"
    And I click "Register"
    Then I should see "Password confirmation doesn't match"

  Scenario: New user registration with missing username
    When I click on the login button in the top right corner
    Then I should see a login/registration form
    When I enter email "newstudent@link.cuhk.edu.hk" in the form
    Then the system should detect this is a new email
    And I should see new fields for username and password appear
    When I leave username empty
    And I fill in password "Password123"
    And I fill in password confirmation "Password123"
    And I click "Register"
    Then I should see "Username can't be blank"

  Scenario: New user registration with existing username
    Given a user exists with username "cuhkstudent" and email "other@link.cuhk.edu.hk"
    When I click on the login button in the top right corner
    Then I should see a login/registration form
    When I enter email "newstudent@link.cuhk.edu.hk" in the form
    Then the system should detect this is a new email
    And I should see new fields for username and password appear
    When I fill in username "cuhkstudent"
    And I fill in password "Password123"
    And I fill in password confirmation "Password123"
    And I click "Register"
    Then I should see "Username has already been taken"

  Scenario: Switching between login and register modes
    When I click on the login button in the top right corner
    Then I should see a login/registration form
    When I enter email "newstudent@link.cuhk.edu.hk" in the form
    Then I should see registration fields (username, password, confirm)
    When I clear the email field
    And I enter email "existing@link.cuhk.edu.hk" in the form
    Then the registration fields should disappear
    And I should see only the password field
    When I clear the email field again
    And I enter email "anothernew@link.cuhk.edu.hk" in the form
    Then I should see registration fields appear again

  Scenario: Forgot password link for existing user
    Given a confirmed user exists with email "existing@link.cuhk.edu.hk" and password "Password123"
    When I click on the login button in the top right corner
    Then I should see a login/registration form
    When I enter email "existing@link.cuhk.edu.hk" in the form
    Then I should see only the password field appear
    And I should see a "Forgot password?" link
    When I click "Forgot password?"
    Then I should be redirected to the password reset page