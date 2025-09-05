# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToDoItem, type: :model do
  let(:user) { create(:user) }
  let(:to_do_item) { build(:to_do_item, created_by: user, assigned_to: user) }

  subject { to_do_item }

  describe 'associations' do
    it { should belong_to(:assigned_to).class_name('User') }
    it { should belong_to(:created_by).class_name('User') }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:due_date) }
    it { should validate_inclusion_of(:status).in_array(%w[pending completed]) }
    
    # Token presence is handled by the before_validation callback
    it 'validates token presence after callback' do
      todo = build(:to_do_item, token: nil, created_by: user, assigned_to: user)
      todo.valid?
      expect(todo.token).to be_present
    end
    
    context 'uniqueness validation' do
      subject { create(:to_do_item, created_by: user, assigned_to: user) }
      it { should validate_uniqueness_of(:token) }
    end

    describe 'due_date validation' do
      context 'when creating a new item' do
        it 'validates due_date is not in the past' do
          todo = build(:to_do_item, due_date: 1.day.ago, created_by: user, assigned_to: user)
          expect(todo).not_to be_valid
          expect(todo.errors[:due_date]).to include("can't be in the past")
        end

        it 'allows due_date in the past for completed items' do
          todo = build(:to_do_item, due_date: 1.day.ago, status: 'completed', created_by: user, assigned_to: user)
          expect(todo).to be_valid
        end

        it 'allows due_date in the future' do
          todo = build(:to_do_item, due_date: 1.day.from_now, created_by: user, assigned_to: user)
          expect(todo).to be_valid
        end

        it 'allows due_date today' do
          todo = build(:to_do_item, due_date: Date.current, created_by: user, assigned_to: user)
          expect(todo).to be_valid
        end
      end

      context 'when updating an existing item' do
        let(:todo) { create(:to_do_item, due_date: 1.day.from_now, created_by: user, assigned_to: user) }

        it 'allows updating due_date to past for completed items' do
          todo.update!(status: 'completed', due_date: 1.day.ago)
          expect(todo).to be_valid
        end
      end
    end
  end

  describe 'scopes' do
    let!(:pending_todo) { create(:to_do_item, status: 'pending', created_by: user, assigned_to: user) }
    let!(:completed_todo) { create(:to_do_item, status: 'completed', created_by: user, assigned_to: user) }
    let!(:overdue_todo) do
      # Create a completed todo first, then update to pending with past due date
      todo = create(:to_do_item, status: 'completed', created_by: user, assigned_to: user)
      todo.update!(status: 'pending', due_date: 1.day.ago)
      todo
    end

    describe '.pending' do
      it 'returns only pending todos' do
        expect(ToDoItem.pending).to include(pending_todo)
        expect(ToDoItem.pending).not_to include(completed_todo)
      end
    end

    describe '.completed' do
      it 'returns only completed todos' do
        expect(ToDoItem.completed).to include(completed_todo)
        expect(ToDoItem.completed).not_to include(pending_todo)
      end
    end

    describe '.overdue' do
      it 'returns only overdue todos' do
        expect(ToDoItem.overdue).to include(overdue_todo)
        expect(ToDoItem.overdue).not_to include(completed_todo)
        expect(ToDoItem.overdue).not_to include(pending_todo)
      end
    end
  end

  describe 'followers functionality' do
    let(:todo) { create(:to_do_item, created_by: user, assigned_to: user) }
    let(:follower1) { create(:user) }
    let(:follower2) { create(:user) }

    describe '#add_follower' do
      it 'adds a follower to the todo' do
        todo.add_follower(follower1.id)
        expect(todo.followers).to include(follower1.id)
      end

      it 'does not add duplicate followers' do
        todo.add_follower(follower1.id)
        todo.add_follower(follower1.id)
        expect(todo.followers.count(follower1.id)).to eq(1)
      end

      it 'saves the todo after adding follower' do
        expect { todo.add_follower(follower1.id) }.to change { todo.reload.followers }
      end
    end

    describe '#remove_follower' do
      before do
        todo.add_follower(follower1.id)
        todo.add_follower(follower2.id)
      end

      it 'removes a follower from the todo' do
        todo.remove_follower(follower1.id)
        expect(todo.followers).not_to include(follower1.id)
        expect(todo.followers).to include(follower2.id)
      end

      it 'saves the todo after removing follower' do
        expect { todo.remove_follower(follower1.id) }.to change { todo.reload.followers }
      end
    end

    describe '#follower_users' do
      before do
        todo.add_follower(follower1.id)
        todo.add_follower(follower2.id)
      end

      it 'returns User objects for followers' do
        follower_users = todo.follower_users
        expect(follower_users).to include(follower1, follower2)
      end

      it 'returns an ActiveRecord relation' do
        expect(todo.follower_users).to be_a(ActiveRecord::Relation)
      end
    end
  end

  describe 'status methods' do
    let(:todo) { create(:to_do_item, created_by: user, assigned_to: user) }

    describe '#overdue?' do
      it 'returns true for overdue pending todos' do
        todo.update!(due_date: 1.day.ago, status: 'pending')
        expect(todo.overdue?).to be true
      end

      it 'returns false for completed todos even if overdue' do
        todo.update!(due_date: 1.day.ago, status: 'completed')
        expect(todo.overdue?).to be false
      end

      it 'returns false for future todos' do
        todo.update!(due_date: 1.day.from_now, status: 'pending')
        expect(todo.overdue?).to be false
      end
    end

    describe '#completed?' do
      it 'returns true for completed todos' do
        todo.update!(status: 'completed')
        expect(todo.completed?).to be true
      end

      it 'returns false for pending todos' do
        todo.update!(status: 'pending')
        expect(todo.completed?).to be false
      end
    end
  end

  describe '#to_param' do
    it 'returns the token' do
      expect(to_do_item.to_param).to eq(to_do_item.token)
    end
  end

  describe 'callbacks' do
    it 'generates token before validation on create' do
      todo = build(:to_do_item, token: nil, created_by: user, assigned_to: user)
      expect(todo).to receive(:generate_token)
      todo.valid?
    end

    it 'sets token if blank' do
      todo = build(:to_do_item, token: nil, created_by: user, assigned_to: user)
      todo.valid?
      expect(todo.token).to be_present
    end

    it 'does not override existing token' do
      existing_token = SecureRandom.uuid
      todo = build(:to_do_item, token: existing_token, created_by: user, assigned_to: user)
      todo.valid?
      expect(todo.token).to eq(existing_token)
    end
  end

  describe 'factory' do
    it 'creates a valid to_do_item' do
      expect(to_do_item).to be_valid
    end

    it 'creates a to_do_item with name' do
      expect(to_do_item.name).to be_present
    end

    it 'creates a to_do_item with description' do
      expect(to_do_item.description).to be_present
    end

    it 'creates a to_do_item with token' do
      expect(to_do_item.token).to be_present
    end

    it 'creates a to_do_item with due_date' do
      expect(to_do_item.due_date).to be_present
    end
  end

  describe 'with traits' do
    it 'creates a completed todo' do
      completed_todo = create(:to_do_item, :completed, created_by: user, assigned_to: user)
      expect(completed_todo.status).to eq('completed')
    end

    it 'creates an overdue todo' do
      # Create completed todo first, then make it pending with past due date
      overdue_todo = create(:to_do_item, :completed, created_by: user, assigned_to: user)
      overdue_todo.update!(status: 'pending', due_date: 1.day.ago)
      expect(overdue_todo.overdue?).to be true
    end

    it 'creates a todo due today' do
      due_today_todo = create(:to_do_item, :due_today, created_by: user, assigned_to: user)
      expect(due_today_todo.due_date).to eq(Date.current)
    end

    it 'creates a todo due tomorrow' do
      due_tomorrow_todo = create(:to_do_item, :due_tomorrow, created_by: user, assigned_to: user)
      expect(due_tomorrow_todo.due_date).to eq(1.day.from_now.to_date)
    end

    it 'creates a todo due next week' do
      due_next_week_todo = create(:to_do_item, :due_next_week, created_by: user, assigned_to: user)
      expect(due_next_week_todo.due_date).to be > Date.current
    end

    it 'creates a todo with estimated duration' do
      todo_with_duration = create(:to_do_item, :with_estimated_duration, created_by: user, assigned_to: user)
      expect(todo_with_duration.estimated_duration).to be_present
    end

    it 'creates a todo with followers' do
      todo_with_followers = create(:to_do_item, :with_followers, created_by: user, assigned_to: user)
      expect(todo_with_followers.followers).to be_present
      expect(todo_with_followers.followers.length).to be >= 1
    end

    it 'creates a todo with comments' do
      todo_with_comments = create(:to_do_item, :with_comments, created_by: user, assigned_to: user)
      expect(todo_with_comments.comments.count).to be >= 1
    end

    it 'creates an urgent todo' do
      urgent_todo = create(:to_do_item, :urgent, created_by: user, assigned_to: user)
      expect(urgent_todo.name).to start_with('URGENT:')
      expect(urgent_todo.due_date).to be <= 1.day.from_now
    end

    it 'creates a low priority todo' do
      low_priority_todo = create(:to_do_item, :low_priority, created_by: user, assigned_to: user)
      expect(low_priority_todo.name).to end_with('(low priority)')
      expect(low_priority_todo.due_date).to be > 1.week.from_now
    end
  end

  describe 'token generation' do
    it 'generates a UUID token' do
      todo = build(:to_do_item, token: nil, created_by: user, assigned_to: user)
      todo.valid?
      expect(todo.token).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end
end
