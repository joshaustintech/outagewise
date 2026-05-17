class User < ApplicationRecord
  belongs_to :account

  validates :email, presence: true, uniqueness: true
end
