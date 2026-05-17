require "test_helper"
require "yaml"

class GithubActionsTest < ActiveSupport::TestCase
  test "rails test jobs build vite assets before rendering application layout" do
    workflow = YAML.load_file(Rails.root.join(".github/workflows/ci.yml"))

    assert_frontend_build_before_rails_test workflow.fetch("jobs").fetch("test").fetch("steps")
    assert_frontend_build_before_rails_test workflow.fetch("jobs").fetch("system-test").fetch("steps")
  end

  private

  def assert_frontend_build_before_rails_test(steps)
    commands = steps.filter_map { |step| step["run"] }
    test_index = commands.index { |command| command.include?("bin/rails db:test:prepare") }

    assert test_index, "expected job to run Rails tests"
    assert_includes commands.take(test_index), "npm ci"
    assert_includes commands.take(test_index), "npm run build"
  end
end
