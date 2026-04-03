require "rails_helper"

RSpec.describe Comment, type: :model do
  it "is invalid without body" do
    comment = Comment.new(body: nil)
    expect(comment).not_to be_valid
  end
end
