class CommunityPostsController < ApplicationController
  before_action :require_login_for_posting, only: [ :new, :create ]


  def index
    @community_posts = CommunityPost.order(created_at: :desc)
  end

  def show
    @community_post = CommunityPost.find(params[:id])
  end

  def new
    @community_post = CommunityPost.new
  end

  def create
    @community_post = current_user.community_posts.build(community_post_params)

    if @community_post.save
      redirect_to community_path, notice: "Post created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def community_post_params
    params.require(:community_post).permit(:title, :content)
  end


  def require_login_for_posting
    unless user_signed_in?
      redirect_to login_path, alert: "Please log in before creating a community post"
    end
  end
end
