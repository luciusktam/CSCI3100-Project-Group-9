Feature: User authentication
  As a CUHK student
  I want to register and log in with my CUHK email
  So that only verified campus users can access the marketplace

  Background:
    Given I am on the home page

  Scenario: Navigate from login page to register page
    When I click on the login button in the top right corner
    Then I should see the login page
    When I click the register link on the login page
    Then I should see the register page

  Scenario: Register with a valid CUHK email
    Given I am on the register page
    When I register with email "newstudent@link.cuhk.edu.hk", username "cuhkstudent", password "Password123", and confirmation "Password123"
    Then I should be redirected to the login page
    And I should see "Account created. Verification is still required before login."

  Scenario: Reject registration with a non-CUHK email
    Given I am on the register page
    When I register with email "student@gmail.com", username "outsider", password "Password123", and confirmation "Password123"
    Then I should stay on the register page
    And I should see "Email is invalid"

  Scenario: Login with a verified user
    Given a verified user exists with email "existing@link.cuhk.edu.hk" and password "Password123"
    When I log in with email "existing@link.cuhk.edu.hk" and password "Password123"
    Then I should be redirected to the home page
    And I should see "Logged in successfully."

  Scenario: Block login for an unverified user
    Given an unverified user exists with email "pending@link.cuhk.edu.hk" and password "Password123"
    When I log in with email "pending@link.cuhk.edu.hk" and password "Password123"
    Then I should stay on the login page
    And I should see "Your CUHK email has not been verified yet. Please check your email."

  Scenario: Reject login with a wrong password
    Given a verified user exists with email "existing@link.cuhk.edu.hk" and password "Password123"
    When I log in with email "existing@link.cuhk.edu.hk" and password "WrongPassword123"
    Then I should stay on the login page
    And I should see "Invalid email or password."

  Scenario: Logout after login
    Given a verified user exists with email "existing@link.cuhk.edu.hk" and password "Password123"
    And I am logged in as "existing@link.cuhk.edu.hk" with password "Password123"
    When I click the logout button
    Then I should be redirected to the home page
    And I should see "Logged out successfully."

  Scenario: Verify email address via the link in the verification email
    Given I am on the register page
    When I register with email "newverify@link.cuhk.edu.hk", username "verifyuser", password "Password123", and confirmation "Password123"
    Then a verification email should be sent to "newverify@link.cuhk.edu.hk"
    When I follow the verification link in the email
    Then I should be redirected to the login page
    And I should see "Email verified! You can now log in."
    When I log in with email "newverify@link.cuhk.edu.hk" and password "Password123"
    Then I should be redirected to the home page
    And I should see "Logged in successfully."

  Scenario: Using an invalid verification token
    When I visit the verification link with token "totally_invalid_token"
    Then I should be redirected to the home page
    And I should see "Invalid or expired verification link."