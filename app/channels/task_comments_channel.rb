class TaskCommentsChannel < ApplicationCable::Channel
  def subscribed
    # Subscribe to comments for a specific task
    task_token = params[:task_token]
    Rails.logger.info "TaskCommentsChannel subscribed to task: #{task_token}"
    stream_from "task_comments_#{task_token}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
