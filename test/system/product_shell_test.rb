require "application_system_test_case"

class ProductShellSystemTest < ApplicationSystemTestCase
  test "developer can navigate the product shell" do
    visit root_path

    assert_text "Dashboard"
    assert_text "Demo Account"

    click_link "Monitors"
    assert_text "No monitors yet"

    click_link "Status"
    assert_text "Account Status"
    assert_text "No monitors are publishing status yet"
  end
end
