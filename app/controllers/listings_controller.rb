class ListingsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create ]
  def index
    @listings = Listing.all.order(created_at: :desc)
  end

  def new
    @listing = Listing.new
  end

  def create
    @listing = Listing.new(listing_params)
    @listing.user = current_user



    if @listing.save
      flash[:notice] = "Your item is listed！"
      redirect_to @listing
    else

      flash.now[:alert] = @listing.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @listing = Listing.find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(
      :title, :price, :category, :condition, :location, :description,
      photos: [])
  end
end
