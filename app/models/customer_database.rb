class CustomerDatabase < ApplicationRecord
  belongs_to :account

  validates :label, presence: true
  validates :database_path, presence: true, uniqueness: true
end
