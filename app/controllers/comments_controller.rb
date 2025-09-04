class CommentsController < ApplicationController
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper

  before_action :set_to_do_item
  before_action :set_comment, only: [ :destroy ]

  def create
    @comment = @to_do_item.comments.build(comment_params)
    @comment.user_id = params[:comment][:user_id]

    if @comment.save
      # Broadcast the new comment to all users viewing this task
      broadcast_comment_created(@comment)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @to_do_item, notice: "Comment added successfully!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("comment-form", partial: "comments/form", locals: { to_do_item: @to_do_item, comment: @comment }) }
        format.html { redirect_to @to_do_item, alert: "Error adding comment: #{@comment.errors.full_messages.join(', ')}" }
      end
    end
  end

  def destroy
    @comment.destroy
    # Broadcast the comment deletion to all users viewing this task
    broadcast_comment_deleted(@comment)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @to_do_item, notice: "Comment deleted successfully!" }
    end
  end

  private

  def set_to_do_item
    @to_do_item = ToDoItem.find_by!(token: params[:to_do_item_token])
  end

  def set_comment
    @comment = @to_do_item.comments.find_by!(token: params[:token])
  end

  def comment_params
    params.require(:comment).permit(:text, :user_id)
  end

  def broadcast_comment_created(comment)
    ActionCable.server.broadcast(
      "task_comments_#{@to_do_item.token}",
      {
        action: "comment_created",
        comment: {
          id: comment.id,
          token: comment.token,
          text: comment.text,
          user_name: comment.user.name,
          created_at: comment.created_at,
          time_ago: format_time_ago(comment.created_at)
        }
      }
    )
  end

  def broadcast_comment_deleted(comment)
    ActionCable.server.broadcast(
      "task_comments_#{@to_do_item.token}",
      {
        action: "comment_deleted",
        comment_token: comment.token
      }
    )
  end

  def format_time_ago(time)
    seconds = Time.current - time
    case seconds
    when 0..59
      "#{seconds.to_i} seconds ago"
    when 60..3599
      "#{(seconds / 60).to_i} minutes ago"
    when 3600..86399
      "#{(seconds / 3600).to_i} hours ago"
    when 86400..2591999
      "#{(seconds / 86400).to_i} days ago"
    else
      time.strftime("%B %d, %Y at %I:%M %p")
    end
  end
end
