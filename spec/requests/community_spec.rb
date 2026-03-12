require 'rails_helper'

RSpec.describe "Communities", type: :request do
  describe "GET /community" do
    it "returns http success" do
      get "/community"
      expect(response).to have_http_status(:success)
    end
  end

end
