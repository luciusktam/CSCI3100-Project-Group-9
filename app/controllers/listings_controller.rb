class ListingsController < ApplicationController
  before_action :authenticate_user!, only: [ :new ]
  def index
  end

  def new
    @listing = Listing.new
  end

  def show
  end
end
