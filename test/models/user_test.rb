require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires an account and email" do
    user = User.new

    assert_not user.valid?
    assert_includes user.errors[:account], "must exist"
    assert_includes user.errors[:email], "can't be blank"
  end
end
