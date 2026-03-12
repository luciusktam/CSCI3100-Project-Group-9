require 'rails_helper'

RSpec.describe "Communities", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/community/index"
      expect(response).to have_http_status(:success)
    end
  end

end
