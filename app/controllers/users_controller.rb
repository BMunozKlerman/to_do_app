class UsersController < ApplicationController
  def index
    @users = User.all.order(:name)
  end

  def show
    @user = User.find(params[:id])
    @assigned_todos = @user.assigned_todos.includes(:created_by).order(created_at: :desc)
    @created_todos = @user.created_todos.includes(:assigned_to).order(created_at: :desc)
    @followed_todos = @user.followed_todos.includes(:assigned_to, :created_by).order(created_at: :desc)
  end
end
