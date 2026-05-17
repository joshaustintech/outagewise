class CustomerRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :customer, reading: :customer }
end
