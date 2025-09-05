# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { create(:user) }
  let(:to_do_item) { create(:to_do_item) }
  let(:comment) { build(:comment, user: user, to_do_item: to_do_item) }

  subject { comment }

  describe 'associations' do
    it { should belong_to(:to_do_item) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:text) }

    # Token presence is handled by the before_validation callback
    # so we test it manually
    it 'validates token presence after callback' do
      comment = build(:comment, token: nil, user: user, to_do_item: to_do_item)
      comment.valid?
      expect(comment.token).to be_present
    end

    context 'uniqueness validation' do
      subject { create(:comment, user: user, to_do_item: to_do_item) }
      it { should validate_uniqueness_of(:token) }
    end
  end

  describe 'callbacks' do
    it 'generates token before validation on create' do
      comment = build(:comment, token: nil)
      expect(comment).to receive(:generate_token)
      comment.valid?
    end

    it 'sets token if blank' do
      comment = build(:comment, token: nil)
      comment.valid?
      expect(comment.token).to be_present
    end

    it 'does not override existing token' do
      existing_token = SecureRandom.uuid
      comment = build(:comment, token: existing_token)
      comment.valid?
      expect(comment.token).to eq(existing_token)
    end
  end

  describe '#to_param' do
    it 'returns the token' do
      expect(comment.to_param).to eq(comment.token)
    end
  end

  describe 'factory' do
    it 'creates a valid comment' do
      expect(comment).to be_valid
    end

    it 'creates a comment with text' do
      expect(comment.text).to be_present
    end

    it 'creates a comment with token' do
      expect(comment.token).to be_present
    end
  end

  describe 'with traits' do
    it 'creates a short comment' do
      short_comment = create(:comment, :short)
      expect(short_comment.text.split.length).to be <= 5
    end

    it 'creates a long comment' do
      long_comment = create(:comment, :long)
      expect(long_comment.text.split.length).to be > 10
    end

    it 'creates a question comment' do
      question_comment = create(:comment, :question)
      expect(question_comment.text).to end_with('?')
    end

    it 'creates a suggestion comment' do
      suggestion_comment = create(:comment, :suggestion)
      expect(suggestion_comment.text).to start_with('Suggestion:')
    end
  end
end
