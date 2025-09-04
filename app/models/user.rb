class User < ApplicationRecord
  validates :name, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  # Relationships
  has_many :assigned_todos, class_name: "ToDoItem", foreign_key: "assigned_to_id", dependent: :destroy
  has_many :created_todos, class_name: "ToDoItem", foreign_key: "created_by_id", dependent: :destroy

  # Followed todos (through followers JSONB field)
  def followed_todos
    ToDoItem.where("followers @> ?", [ id ].to_json)
  end

  private

  def generate_token
    self.token = UUID.new.generate if token.blank?
  end
end
