# frozen_string_literal: true

class Comments::CommentComponent < ViewComponent::Base
  include ActionView::Helpers::DateHelper # Required for time_ago_in_words

  def initialize(comment:, to_do_item:)
    @comment = comment
    @to_do_item = to_do_item
  end

  private

  attr_reader :comment, :to_do_item

  def time_ago
    time_ago_in_words(comment.created_at) + " ago"
  end
end
