require 'rails_helper'

RSpec.describe "Chats", type: :request do
  describe "GET /chat" do
    it "returns http success" do
      get "/chat"
      expect(response).to have_http_status(:success)
    end
  end

end
