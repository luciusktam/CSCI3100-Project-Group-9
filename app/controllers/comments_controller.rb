# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_community_post, only: [ :create ]
  before_action :set_comment, only: [ :destroy ]
  before_action :require_comment_owner, only: [ :destroy ]

  def create
    @comment = @community_post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to community_post_path(@community_post), notice: "Comment added."
    else
      @comments = @community_post.comments.reorder(created_at: :asc, id: :asc)
      render "community_posts/show", status: :unprocessable_entity
    end
  end

  def destroy
    community_post = @comment.community_post
    @comment.destroy
    redirect_to community_post_path(community_post), notice: "Comment deleted."
  end

  private

  def set_community_post
    @community_post = CommunityPost.find(params[:community_post_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def require_login
    redirect_to login_path, alert: "Please log in first." unless user_signed_in?
  end

  def require_comment_owner
    redirect_to community_path, alert: "You are not allowed to do that." unless @comment.user == current_user
  end
end
