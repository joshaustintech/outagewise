require "test_helper"

class CustomerDatabaseTest < ActiveSupport::TestCase
  test "requires an account, label, and database path" do
    customer_database = CustomerDatabase.new

    assert_not customer_database.valid?
    assert_includes customer_database.errors[:account], "must exist"
    assert_includes customer_database.errors[:label], "can't be blank"
    assert_includes customer_database.errors[:database_path], "can't be blank"
  end
end
