# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  subject { user }

  describe 'associations' do
    it { should have_many(:assigned_todos).class_name('ToDoItem').with_foreign_key('assigned_to_id').dependent(:destroy) }
    it { should have_many(:created_todos).class_name('ToDoItem').with_foreign_key('created_by_id').dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    
    # Token presence is handled by the before_validation callback
    it 'validates token presence after callback' do
      user = build(:user, token: nil)
      user.valid?
      expect(user.token).to be_present
    end
    
    context 'uniqueness validation' do
      subject { create(:user) }
      it { should validate_uniqueness_of(:token) }
    end
  end

  describe 'callbacks' do
    it 'generates token before validation on create' do
      user = build(:user, token: nil)
      expect(user).to receive(:generate_token)
      user.valid?
    end

    it 'sets token if blank' do
      user = build(:user, token: nil)
      user.valid?
      expect(user.token).to be_present
    end

    it 'does not override existing token' do
      existing_token = SecureRandom.uuid
      user = build(:user, token: existing_token)
      user.valid?
      expect(user.token).to eq(existing_token)
    end
  end

  describe '#followed_todos' do
    let(:user) { create(:user) }
    let(:todo1) { create(:to_do_item) }
    let(:todo2) { create(:to_do_item) }
    let(:todo3) { create(:to_do_item) }

    before do
      todo1.add_follower(user.id)
      todo2.add_follower(user.id)
      # todo3 is not followed by user
    end

    it 'returns todos that the user follows' do
      expect(user.followed_todos).to include(todo1, todo2)
      expect(user.followed_todos).not_to include(todo3)
    end

    it 'returns an ActiveRecord relation' do
      expect(user.followed_todos).to be_a(ActiveRecord::Relation)
    end
  end

  describe 'count methods' do
    let(:user) { create(:user) }
    let!(:assigned_todo1) { create(:to_do_item, assigned_to: user) }
    let!(:assigned_todo2) { create(:to_do_item, assigned_to: user) }
    let!(:created_todo1) { create(:to_do_item, created_by: user) }
    let!(:created_todo2) { create(:to_do_item, created_by: user) }
    let!(:created_todo3) { create(:to_do_item, created_by: user) }
    let!(:followed_todo) { create(:to_do_item) }

    before do
      followed_todo.add_follower(user.id)
    end

    describe '#assigned_todos_count' do
      it 'returns the count of assigned todos' do
        expect(user.assigned_todos_count).to eq(2)
      end
    end

    describe '#created_todos_count' do
      it 'returns the count of created todos' do
        expect(user.created_todos_count).to eq(3)
      end
    end

    describe '#followed_todos_count' do
      it 'returns the count of followed todos' do
        expect(user.followed_todos_count).to eq(1)
      end
    end
  end

  describe 'factory' do
    it 'creates a valid user' do
      expect(user).to be_valid
    end

    it 'creates a user with name' do
      expect(user.name).to be_present
    end

    it 'creates a user with token' do
      expect(user.token).to be_present
    end
  end

  describe 'with traits' do
    it 'creates a user with todos' do
      user_with_todos = create(:user, :with_todos)
      expect(user_with_todos.created_todos.count).to eq(3)
      expect(user_with_todos.assigned_todos.count).to eq(2)
    end

    it 'creates a user with completed todos' do
      user_with_completed = create(:user, :with_completed_todos)
      expect(user_with_completed.created_todos.completed.count).to eq(2)
    end

    it 'creates a user with overdue todos' do
      user_with_overdue = create(:user, :with_overdue_todos)
      expect(user_with_overdue.created_todos.overdue.count).to eq(2)
    end
  end

  describe 'token generation' do
    it 'generates a UUID token' do
      user = build(:user, token: nil)
      user.valid?
      expect(user.token).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end
end
