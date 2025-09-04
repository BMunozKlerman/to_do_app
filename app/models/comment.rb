class Comment < ApplicationRecord
  belongs_to :to_do_item
  belongs_to :user

  validates :text, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  def to_param
    token
  end

  private

  def generate_token
    self.token = SecureRandom.uuid if token.blank?
  end
end
