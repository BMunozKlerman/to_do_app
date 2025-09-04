class ToDoItemsController < ApplicationController
  before_action :set_to_do_item, only: [ :show, :edit, :update, :destroy, :add_follower, :remove_follower, :estimate_duration ]
  before_action :set_users, only: [ :new, :edit, :create, :update ]

  def index
    @to_do_items = ToDoItem.includes(:assigned_to, :created_by)
                          .order(created_at: :desc)
  end

  def show
    @follower_users = @to_do_item.follower_users
  end

  def new
    @to_do_item = ToDoItem.new
  end

  def create
    @to_do_item = ToDoItem.new(to_do_item_params)

    if @to_do_item.save
      redirect_to @to_do_item, notice: "To-do item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @to_do_item.update(to_do_item_params)
      # If this is a status-only update (from checkbox), redirect to index without notice
      if params[:to_do_item].keys == [ "status" ]
        redirect_to to_do_items_path
      else
        redirect_to @to_do_item, notice: "To-do item was successfully updated."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @to_do_item.destroy
    redirect_to to_do_items_url, notice: "To-do item was successfully deleted."
  end

  def add_follower
    user_id = params[:user_id]
    @to_do_item.add_follower(user_id)
    redirect_to @to_do_item, notice: "Follower added successfully."
  end

  def remove_follower
    user_id = params[:user_id]
    @to_do_item.remove_follower(user_id)
    redirect_to @to_do_item, notice: "Follower removed successfully."
  end

  def estimate_duration
    service = DurationEstimationService.new
    estimated_duration = service.estimate_duration(@to_do_item.name, @to_do_item.description)

    if @to_do_item.update(estimated_duration: estimated_duration)
      redirect_to @to_do_item, notice: "Duration estimated: #{estimated_duration}"
    else
      redirect_to @to_do_item, alert: "Failed to save duration estimate"
    end
  end

  private

  def set_to_do_item
    @to_do_item = ToDoItem.find(params[:id])
  end

  def set_users
    @users = User.all.order(:name)
  end

  def to_do_item_params
    params.require(:to_do_item).permit(:name, :status, :due_date, :description, :assigned_to_id, :created_by_id)
  end
end
