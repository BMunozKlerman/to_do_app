class ToDoItem < ApplicationRecord
  belongs_to :assigned_to, class_name: "User"
  belongs_to :created_by, class_name: "User"
  has_many :comments, dependent: :destroy

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending completed] }
  validates :token, presence: true, uniqueness: true
  validates :due_date, presence: true
  validate :due_date_not_in_past, on: :create

  before_validation :generate_token, on: :create

  # JSONB followers field - stores array of user IDs
  # No need for serialize with JSONB in Rails 8

  scope :pending, -> { where(status: "pending") }
  scope :completed, -> { where(status: "completed") }
  scope :overdue, -> { where("due_date < ? AND status != ?", Date.current, "completed") }

  def add_follower(user_id)
    self.followers = (followers || []) | [ user_id.to_i ]
    save!
  end

  def remove_follower(user_id)
    self.followers = (followers || []) - [ user_id.to_i ]
    save!
  end

  def follower_users
    User.where(id: followers || [])
  end

  def overdue?
    due_date < Date.current && status != "completed"
  end

  def completed?
    status == "completed"
  end

  def to_param
    token
  end

  private

  def generate_token
    self.token = UUID.new.generate if token.blank?
  end

  def due_date_not_in_past
    return unless due_date.present?
    return if status == "completed" # Allow past dates for completed items

    errors.add(:due_date, "can't be in the past") if due_date < Date.current
  end
end
