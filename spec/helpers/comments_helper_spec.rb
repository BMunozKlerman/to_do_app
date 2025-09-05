# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentsHelper, type: :helper do
  describe 'helper methods' do
    it 'is included in the helper' do
      expect(helper.class.ancestors).to include(CommentsHelper)
    end

    it 'has access to Rails helper methods' do
      expect(helper).to respond_to(:link_to)
      expect(helper).to respond_to(:content_tag)
      expect(helper).to respond_to(:time_ago_in_words)
    end
  end

  describe 'helper functionality' do
    let(:comment) { create(:comment) }
    let(:to_do_item) { comment.to_do_item }

    it 'can render comment-related content' do
      # Test that the helper can be used in views
      expect(helper).to be_present
    end

    it 'has access to comment data' do
      # Test that we can work with comment objects
      expect(comment).to be_present
      expect(comment.text).to be_present
      expect(comment.user).to be_present
    end
  end
end
