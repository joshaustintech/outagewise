require "test_helper"

class ProductShellTest < ActionDispatch::IntegrationTest
  test "dashboard renders the seeded account and navigation" do
    get root_path

    assert_response :success
    assert_select "h1", "Dashboard"
    assert_select "a[href=?]", root_path, "Dashboard"
    assert_select "a[href=?]", monitors_path, "Monitors"
    assert_select "a[href=?]", account_status_path, "Status"
    assert_select "body", /Demo Account/
    assert_select "body", /demo@example.com/
  end

  test "monitor list renders an empty state" do
    get monitors_path

    assert_response :success
    assert_select "h1", "Monitors"
    assert_select "body", /No monitors yet/
    assert_select "body", /HTTP endpoints/
  end

  test "account status renders public read only status" do
    get account_status_path

    assert_response :success
    assert_select "h1", "Account Status"
    assert_select "body", /Demo Account/
    assert_select "body", /No monitors are publishing status yet/
  end
end
