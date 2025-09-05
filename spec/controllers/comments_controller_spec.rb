# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:to_do_item) { create(:to_do_item) }
  let(:comment) { create(:comment, to_do_item: to_do_item, user: user) }
  let(:valid_attributes) do
    {
      text: "Test comment",
      user_id: user.id
    }
  end
  let(:invalid_attributes) { { text: "" } }

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Comment" do
        expect {
          post :create, params: { to_do_item_token: to_do_item.token, comment: valid_attributes }
        }.to change(Comment, :count).by(1)
      end

      it "assigns a newly created comment as @comment" do
        post :create, params: { to_do_item_token: to_do_item.token, comment: valid_attributes }
        expect(assigns(:comment)).to be_a(Comment)
        expect(assigns(:comment)).to be_persisted
      end

      it "sets the user_id from params" do
        post :create, params: { to_do_item_token: to_do_item.token, comment: valid_attributes }
        expect(assigns(:comment).user_id).to eq(user.id)
      end

      it "broadcasts the comment creation" do
        expect(ActionCable.server).to receive(:broadcast).with(
          "task_comments_#{to_do_item.token}",
          hash_including(action: "comment_created")
        )
        post :create, params: { to_do_item_token: to_do_item.token, comment: valid_attributes }
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          post :create, params: { to_do_item_token: to_do_item.token, comment: valid_attributes }, format: :turbo_stream
          expect(response).to be_successful
        end
      end

      context "with html format" do
        it "redirects to the to_do_item with success notice" do
          post :create, params: { to_do_item_token: to_do_item.token, comment: valid_attributes }, format: :html
          expect(response).to redirect_to(to_do_item)
          expect(flash[:notice]).to eq("Comment added successfully!")
        end
      end
    end

    context "with invalid parameters" do
      it "does not create a new Comment" do
        expect {
          post :create, params: { to_do_item_token: to_do_item.token, comment: invalid_attributes }
        }.not_to change(Comment, :count)
      end

      it "assigns a newly created but unsaved comment as @comment" do
        post :create, params: { to_do_item_token: to_do_item.token, comment: invalid_attributes }
        expect(assigns(:comment)).to be_a_new(Comment)
      end

      context "with turbo_stream format" do
        it "renders the form with errors" do
          post :create, params: { to_do_item_token: to_do_item.token, comment: invalid_attributes }, format: :turbo_stream
          expect(response).to be_successful
        end
      end

      context "with html format" do
        it "redirects with error message" do
          post :create, params: { to_do_item_token: to_do_item.token, comment: invalid_attributes }, format: :html
          expect(response).to redirect_to(to_do_item)
          expect(flash[:alert]).to include("Error adding comment")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested comment" do
      comment
      expect {
        delete :destroy, params: { to_do_item_token: to_do_item.token, token: comment.token }
      }.to change(Comment, :count).by(-1)
    end

    it "assigns the requested comment as @comment" do
      delete :destroy, params: { to_do_item_token: to_do_item.token, token: comment.token }
      expect(assigns(:comment)).to eq(comment)
    end

    it "broadcasts the comment deletion" do
      expect(ActionCable.server).to receive(:broadcast).with(
        "task_comments_#{to_do_item.token}",
        hash_including(action: "comment_deleted")
      )
      delete :destroy, params: { to_do_item_token: to_do_item.token, token: comment.token }
    end

    context "with turbo_stream format" do
      it "responds with turbo_stream" do
        delete :destroy, params: { to_do_item_token: to_do_item.token, token: comment.token }, format: :turbo_stream
        expect(response).to be_successful
      end
    end

    context "with html format" do
      it "redirects to the to_do_item with success notice" do
        delete :destroy, params: { to_do_item_token: to_do_item.token, token: comment.token }, format: :html
        expect(response).to redirect_to(to_do_item)
        expect(flash[:notice]).to eq("Comment deleted successfully!")
      end
    end
  end

  describe "private methods" do
    describe "#set_to_do_item" do
      it "finds to_do_item by token" do
        controller.params[:to_do_item_token] = to_do_item.token
        controller.send(:set_to_do_item)
        expect(assigns(:to_do_item)).to eq(to_do_item)
      end

      it "raises error for invalid token" do
        controller.params[:to_do_item_token] = "invalid_token"
        expect {
          controller.send(:set_to_do_item)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "#set_comment" do
      it "finds comment by token within the to_do_item" do
        controller.params[:token] = comment.token
        controller.instance_variable_set(:@to_do_item, to_do_item)
        controller.send(:set_comment)
        expect(assigns(:comment)).to eq(comment)
      end

      it "raises error for invalid comment token" do
        controller.params[:token] = "invalid_token"
        controller.instance_variable_set(:@to_do_item, to_do_item)
        expect {
          controller.send(:set_comment)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "#comment_params" do
      it "permits the correct parameters" do
        params = ActionController::Parameters.new({
          comment: {
            text: "Test comment",
            user_id: "1"
          }
        })
        controller.params = params
        permitted = controller.send(:comment_params)
        expect(permitted).to include(:text, :user_id)
      end
    end

    describe "#broadcast_comment_created" do
      it "broadcasts with correct data structure" do
        comment = create(:comment, to_do_item: to_do_item, user: user)
        controller.instance_variable_set(:@to_do_item, to_do_item)

        expect(ActionCable.server).to receive(:broadcast).with(
          "task_comments_#{to_do_item.token}",
          {
            action: "comment_created",
            comment: {
              id: comment.id,
              token: comment.token,
              text: comment.text,
              user_name: comment.user.name,
              created_at: comment.created_at,
              time_ago: anything
            }
          }
        )

        controller.send(:broadcast_comment_created, comment)
      end
    end

    describe "#broadcast_comment_deleted" do
      it "broadcasts with correct data structure" do
        comment = create(:comment, to_do_item: to_do_item, user: user)
        controller.instance_variable_set(:@to_do_item, to_do_item)

        expect(ActionCable.server).to receive(:broadcast).with(
          "task_comments_#{to_do_item.token}",
          {
            action: "comment_deleted",
            comment_token: comment.token
          }
        )

        controller.send(:broadcast_comment_deleted, comment)
      end
    end

    describe "#format_time_ago" do
      it "formats seconds correctly" do
        time = 30.seconds.ago
        result = controller.send(:format_time_ago, time)
        expect(result).to match(/\d+ seconds ago/)
      end

      it "formats minutes correctly" do
        time = 30.minutes.ago
        result = controller.send(:format_time_ago, time)
        expect(result).to match(/\d+ minutes ago/)
      end

      it "formats hours correctly" do
        time = 2.hours.ago
        result = controller.send(:format_time_ago, time)
        expect(result).to match(/\d+ hours ago/)
      end

      it "formats days correctly" do
        time = 3.days.ago
        result = controller.send(:format_time_ago, time)
        expect(result).to match(/\d+ days ago/)
      end

      it "formats old dates with full format" do
        time = 1.month.ago
        result = controller.send(:format_time_ago, time)
        expect(result).to match(/\w+ \d+, \d+ at \d+:\d+ [AP]M/)
      end
    end
  end
end
