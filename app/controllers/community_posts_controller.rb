class CommunityPostsController < ApplicationController
  before_action :set_community_post, only: [ :show, :edit, :update, :destroy ]
  before_action :require_login_for_posting, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :require_owner, only: [ :edit, :update, :destroy ]

  def index
    @community_posts = CommunityPost.order(created_at: :desc)
  end

  def show
    @comment = Comment.new
    @comments = @community_post.comments.order(created_at: :desc)
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


  def edit
  end

  def update
    if @community_post.update(community_post_params)
      redirect_to community_post_path(@community_post), notice: "Post updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @community_post.destroy
    redirect_to community_path, notice: "Post deleted successfully."
  end


  private

  def set_community_post
    @community_post = CommunityPost.find(params[:id])
  end

  def community_post_params
    params.require(:community_post).permit(:title, :content)
  end


  def require_login_for_posting
    unless user_signed_in?
      redirect_to login_path, alert: "Please log in before creating a community post"
    end
  end

  def require_owner
    redirect_to community_path, alert: "You are not allowed to do that." unless @community_post.user == current_user
  end
end
