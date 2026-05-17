require "test_helper"

class CiWorkflowTest < ActiveSupport::TestCase
  test "system test workflow runs database preparation before the system test task" do
    workflow = Rails.root.join(".github/workflows/ci.yml").read

    assert_includes workflow, "bin/rails db:test:prepare && bin/rails test:system"
    refute_includes workflow, "bin/rails db:test:prepare test:system"
  end

  test "system test directory is present for the Rails system test task" do
    assert_path_exists Rails.root.join("test/system")
  end
end
