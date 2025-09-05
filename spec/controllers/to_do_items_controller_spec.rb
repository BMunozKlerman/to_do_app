# frozen_string_literal: true

require "rails_helper"

RSpec.describe ToDoItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:assigned_user) { create(:user) }
  let(:to_do_item) { create(:to_do_item, created_by: user, assigned_to: assigned_user) }
  let(:valid_attributes) do
    {
      name: "Test Task",
      status: "pending",
      due_date: 1.week.from_now,
      description: "Test description",
      assigned_to_id: assigned_user.id,
      created_by_id: user.id
    }
  end
  let(:invalid_attributes) { { name: "" } }

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns all to_do_items as @to_do_items" do
      to_do_item
      get :index
      expect(assigns(:to_do_items)).to eq([ to_do_item ])
    end

    it "includes associated users" do
      to_do_item
      get :index
      # Check that the association is accessible (this would trigger a query if not loaded)
      expect(assigns(:to_do_items).first.assigned_to).to be_present
    end

    it "orders by created_at desc" do
      old_item = create(:to_do_item, created_at: 1.day.ago)
      new_item = create(:to_do_item, created_at: 1.hour.ago)

      get :index
      expect(assigns(:to_do_items)).to eq([ new_item, old_item ])
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: { token: to_do_item.token }
      expect(response).to be_successful
    end

    it "assigns the requested to_do_item as @to_do_item" do
      get :show, params: { token: to_do_item.token }
      expect(assigns(:to_do_item)).to eq(to_do_item)
    end

    it "assigns follower_users as @follower_users" do
      get :show, params: { token: to_do_item.token }
      expect(assigns(:follower_users)).to eq(to_do_item.follower_users)
    end

    it "raises error for invalid token" do
      expect {
        get :show, params: { token: "invalid_token" }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end

    it "assigns a new to_do_item as @to_do_item" do
      get :new
      expect(assigns(:to_do_item)).to be_a_new(ToDoItem)
    end

    it "assigns all users as @users" do
      user
      get :new
      expect(assigns(:users)).to include(user)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new ToDoItem" do
        expect {
          post :create, params: { to_do_item: valid_attributes }
        }.to change(ToDoItem, :count).by(1)
      end

      it "assigns a newly created to_do_item as @to_do_item" do
        post :create, params: { to_do_item: valid_attributes }
        expect(assigns(:to_do_item)).to be_a(ToDoItem)
        expect(assigns(:to_do_item)).to be_persisted
      end

      it "redirects to the created to_do_item" do
        post :create, params: { to_do_item: valid_attributes }
        expect(response).to redirect_to(ToDoItem.last)
      end

      it "sets a success notice" do
        post :create, params: { to_do_item: valid_attributes }
        expect(flash[:notice]).to eq("To-do item was successfully created.")
      end
    end

    context "with invalid parameters" do
      it "does not create a new ToDoItem" do
        expect {
          post :create, params: { to_do_item: invalid_attributes }
        }.not_to change(ToDoItem, :count)
      end

      it "assigns a newly created but unsaved to_do_item as @to_do_item" do
        post :create, params: { to_do_item: invalid_attributes }
        expect(assigns(:to_do_item)).to be_a_new(ToDoItem)
      end

      it "renders the 'new' template" do
        post :create, params: { to_do_item: invalid_attributes }
        expect(response).to render_template(:new)
      end

      it "returns unprocessable_content status" do
        post :create, params: { to_do_item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET #edit" do
    it "returns a successful response" do
      get :edit, params: { token: to_do_item.token }
      expect(response).to be_successful
    end

    it "assigns the requested to_do_item as @to_do_item" do
      get :edit, params: { token: to_do_item.token }
      expect(assigns(:to_do_item)).to eq(to_do_item)
    end

    it "assigns all users as @users" do
      get :edit, params: { token: to_do_item.token }
      expect(assigns(:users)).to include(user)
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      let(:new_attributes) { { name: "Updated Task" } }

      it "updates the requested to_do_item" do
        patch :update, params: { token: to_do_item.token, to_do_item: new_attributes }
        to_do_item.reload
        expect(to_do_item.name).to eq("Updated Task")
      end

      it "assigns the requested to_do_item as @to_do_item" do
        patch :update, params: { token: to_do_item.token, to_do_item: new_attributes }
        expect(assigns(:to_do_item)).to eq(to_do_item)
      end

      it "redirects to the to_do_item" do
        patch :update, params: { token: to_do_item.token, to_do_item: new_attributes }
        expect(response).to redirect_to(to_do_item)
      end

      it "sets a success notice" do
        patch :update, params: { token: to_do_item.token, to_do_item: new_attributes }
        expect(flash[:notice]).to eq("To-do item was successfully updated.")
      end
    end

    context "with status-only update" do
      it "redirects to index with status notice" do
        patch :update, params: { token: to_do_item.token, to_do_item: { status: "completed" } }
        expect(response).to redirect_to(to_do_items_path)
        expect(flash[:notice]).to eq("Task marked as completed!")
      end
    end

    context "with invalid parameters" do
      it "assigns the to_do_item as @to_do_item" do
        patch :update, params: { token: to_do_item.token, to_do_item: invalid_attributes }
        expect(assigns(:to_do_item)).to eq(to_do_item)
      end

      it "renders the 'edit' template" do
        patch :update, params: { token: to_do_item.token, to_do_item: invalid_attributes }
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable_content status" do
        patch :update, params: { token: to_do_item.token, to_do_item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested to_do_item" do
      to_do_item
      expect {
        delete :destroy, params: { token: to_do_item.token }
      }.to change(ToDoItem, :count).by(-1)
    end

    it "redirects to the to_do_items list" do
      delete :destroy, params: { token: to_do_item.token }
      expect(response).to redirect_to(to_do_items_url)
    end

    it "sets a success notice" do
      delete :destroy, params: { token: to_do_item.token }
      expect(flash[:notice]).to eq("To-do item was successfully deleted.")
    end
  end

  describe "POST #add_follower" do
    let(:follower) { create(:user) }

    context "with valid user_id" do
      it "adds the follower" do
        expect {
          post :add_follower, params: { token: to_do_item.token, user_id: follower.id }
        }.to change { to_do_item.reload.followers.count }.by(1)
      end

      it "redirects to the to_do_item" do
        post :add_follower, params: { token: to_do_item.token, user_id: follower.id }
        expect(response).to redirect_to(to_do_item)
      end

      it "sets a success notice" do
        post :add_follower, params: { token: to_do_item.token, user_id: follower.id }
        expect(flash[:notice]).to eq("Follower added successfully.")
      end
    end

    context "with blank user_id" do
      it "does not add a follower" do
        expect {
          post :add_follower, params: { token: to_do_item.token, user_id: "" }
        }.not_to change { to_do_item.reload.followers.count }
      end

      it "redirects to the to_do_item with alert" do
        post :add_follower, params: { token: to_do_item.token, user_id: "" }
        expect(response).to redirect_to(to_do_item)
        expect(flash[:alert]).to eq("Please select a user to follow.")
      end
    end

    context "when an error occurs" do
      before do
        allow_any_instance_of(ToDoItem).to receive(:add_follower).and_raise(StandardError.new("Test error"))
      end

      it "redirects with error message" do
        post :add_follower, params: { token: to_do_item.token, user_id: follower.id }
        expect(response).to redirect_to(to_do_item)
        expect(flash[:alert]).to eq("Error adding follower: Test error")
      end
    end
  end

  describe "DELETE #remove_follower" do
    let(:follower) { create(:user) }

    before do
      to_do_item.add_follower(follower.id)
    end

    it "removes the follower" do
      expect {
        delete :remove_follower, params: { token: to_do_item.token, user_id: follower.id }
      }.to change { to_do_item.reload.followers.count }.by(-1)
    end

    it "redirects to the to_do_item" do
      delete :remove_follower, params: { token: to_do_item.token, user_id: follower.id }
      expect(response).to redirect_to(to_do_item)
    end

    it "sets a success notice" do
      delete :remove_follower, params: { token: to_do_item.token, user_id: follower.id }
      expect(flash[:notice]).to eq("Follower removed successfully.")
    end
  end

  describe "POST #estimate_duration" do
    let(:duration_service) { instance_double(DurationEstimationService) }

    before do
      allow(DurationEstimationService).to receive(:new).and_return(duration_service)
      allow(duration_service).to receive(:estimate_duration).and_return("2 hours")
    end

    it "calls the duration estimation service" do
      post :estimate_duration, params: { token: to_do_item.token }
      expect(duration_service).to have_received(:estimate_duration).with(to_do_item.name, to_do_item.description)
    end

    it "updates the to_do_item with estimated duration" do
      post :estimate_duration, params: { token: to_do_item.token }
      to_do_item.reload
      expect(to_do_item.estimated_duration).to eq("2 hours")
    end

    it "redirects to the to_do_item with success notice" do
      post :estimate_duration, params: { token: to_do_item.token }
      expect(response).to redirect_to(to_do_item)
      expect(flash[:notice]).to eq("Duration estimated: 2 hours")
    end

    context "when update fails" do
      before do
        allow_any_instance_of(ToDoItem).to receive(:update).and_return(false)
      end

      it "redirects with error message" do
        post :estimate_duration, params: { token: to_do_item.token }
        expect(response).to redirect_to(to_do_item)
        expect(flash[:alert]).to eq("Failed to save duration estimate")
      end
    end
  end

  describe "private methods" do
    describe "#set_to_do_item" do
      it "finds to_do_item by token" do
        controller.params[:token] = to_do_item.token
        controller.send(:set_to_do_item)
        expect(assigns(:to_do_item)).to eq(to_do_item)
      end
    end

    describe "#set_users" do
      it "assigns all users ordered by name" do
        user1 = create(:user, name: "Z User")
        user2 = create(:user, name: "A User")
        controller.send(:set_users)
        expect(assigns(:users)).to eq([ user2, user1 ])
      end
    end

    describe "#to_do_item_params" do
      it "permits the correct parameters" do
        params = ActionController::Parameters.new({
          to_do_item: {
            name: "Test",
            status: "pending",
            due_date: "2024-01-01",
            description: "Test description",
            assigned_to_id: "1",
            created_by_id: "2"
          }
        })
        controller.params = params
        permitted = controller.send(:to_do_item_params)
        expect(permitted).to include(:name, :status, :due_date, :description, :assigned_to_id, :created_by_id)
      end
    end
  end
end
