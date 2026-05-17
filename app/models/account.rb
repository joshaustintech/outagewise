class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_one :customer_database, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
