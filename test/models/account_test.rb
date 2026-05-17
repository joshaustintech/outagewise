require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "requires a name and slug" do
    account = Account.new

    assert_not account.valid?
    assert_includes account.errors[:name], "can't be blank"
    assert_includes account.errors[:slug], "can't be blank"
  end

  test "owns demo users and customer database registry metadata" do
    account = accounts(:demo)

    assert_equal [ users(:demo) ], account.users.to_a
    assert_equal customer_databases(:demo), account.customer_database
  end
end
