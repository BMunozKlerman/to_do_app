# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:assigned_user) { create(:user) }
  let(:created_user) { create(:user) }

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns all users as @users" do
      user1 = create(:user, name: "Z User")
      user2 = create(:user, name: "A User")
      get :index
      expect(assigns(:users)).to eq([ user2, user1 ])
    end

    it "orders users by name" do
      user1 = create(:user, name: "Charlie")
      user2 = create(:user, name: "Alice")
      user3 = create(:user, name: "Bob")

      get :index
      expect(assigns(:users)).to eq([ user2, user3, user1 ])
    end
  end

  describe "GET #show" do
    let(:to_do_item1) { create(:to_do_item, assigned_to: user, created_by: created_user) }
    let(:to_do_item2) { create(:to_do_item, created_by: user, assigned_to: assigned_user) }
    let(:followed_item) { create(:to_do_item) }

    before do
      # Add user as follower to followed_item
      followed_item.add_follower(user.id)
    end

    it "returns a successful response" do
      get :show, params: { id: user.id }
      expect(response).to be_successful
    end

    it "assigns the requested user as @user" do
      get :show, params: { id: user.id }
      expect(assigns(:user)).to eq(user)
    end

    it "assigns assigned_todos as @assigned_todos" do
      to_do_item1
      get :show, params: { id: user.id }
      expect(assigns(:assigned_todos)).to include(to_do_item1)
    end

    it "assigns created_todos as @created_todos" do
      to_do_item2
      get :show, params: { id: user.id }
      expect(assigns(:created_todos)).to include(to_do_item2)
    end

    it "assigns followed_todos as @followed_todos" do
      followed_item
      get :show, params: { id: user.id }
      expect(assigns(:followed_todos)).to include(followed_item)
    end

    it "includes associated users in assigned_todos" do
      to_do_item1
      get :show, params: { id: user.id }
      expect(assigns(:assigned_todos).first.created_by).to be_present
    end

    it "includes associated users in created_todos" do
      to_do_item2
      get :show, params: { id: user.id }
      expect(assigns(:created_todos).first.assigned_to).to be_present
    end

    it "includes associated users in followed_todos" do
      followed_item
      get :show, params: { id: user.id }
      expect(assigns(:followed_todos).first.assigned_to).to be_present
    end

    it "orders assigned_todos by created_at desc" do
      old_item = create(:to_do_item, assigned_to: user, created_at: 1.day.ago)
      new_item = create(:to_do_item, assigned_to: user, created_at: 1.hour.ago)

      get :show, params: { id: user.id }
      expect(assigns(:assigned_todos)).to eq([ new_item, old_item ])
    end

    it "orders created_todos by created_at desc" do
      old_item = create(:to_do_item, created_by: user, created_at: 1.day.ago)
      new_item = create(:to_do_item, created_by: user, created_at: 1.hour.ago)

      get :show, params: { id: user.id }
      expect(assigns(:created_todos)).to eq([ new_item, old_item ])
    end

    it "orders followed_todos by created_at desc" do
      # Create items with specific timestamps
      old_item = create(:to_do_item, created_at: 1.day.ago)
      new_item = create(:to_do_item, created_at: 1.hour.ago)
      old_item.add_follower(user.id)
      new_item.add_follower(user.id)

      get :show, params: { id: user.id }
      # Check that the items are ordered correctly by created_at desc
      followed_todos = assigns(:followed_todos)
      expect(followed_todos.first.created_at).to be > followed_todos.last.created_at
    end

    it "raises error for invalid user id" do
      expect {
        get :show, params: { id: 99999 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
