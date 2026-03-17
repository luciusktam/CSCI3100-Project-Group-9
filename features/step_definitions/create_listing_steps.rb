Given("I am on the sell page") do
  visit sell_path
end

When("I click on the sell button") do
    click_link "Sell"
end

Then("I should see 'Please log in before listing items for sale'") do
  expect(page).to have_content("Please log in before listing items for sale")
end

Then("I should see the sell page") do
  expect(page).to have_current_path(sell_path)
  expect(page).to have_css("h2", text: "Create a new listing")
  expect(page).to have_field("Image")
  expect(page).to have_field("Category")
  expect(page).to have_field("Listing title")
  expect(page).to have_field("Price")
  expect(page).to have_field("Condition")
  expect(page).to have_field("Description")
  expect(page).to have_button("List it!")
end
