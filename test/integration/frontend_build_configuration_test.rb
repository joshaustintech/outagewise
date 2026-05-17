require "test_helper"

class FrontendBuildConfigurationTest < ActiveSupport::TestCase
  test "package scripts build and watch the milestone zero frontend assets" do
    package_json = JSON.parse(Rails.root.join("package.json").read)

    assert_equal "vite build", package_json.dig("scripts", "build")
    assert_includes package_json.dig("scripts", "watch"), "app/views/**/*.erb"
    assert_includes package_json.dig("scripts", "watch"), "app/frontend/**/*.elm"
    assert_includes package_json.dig("scripts", "watch"), "app/frontend/**/*.css"
  end

  test "vite entrypoint mounts elm and imports tailwind css" do
    entrypoint = Rails.root.join("app/frontend/entrypoints/application.js").read

    assert_includes entrypoint, "../styles/application.css"
    assert_includes entrypoint, "Elm.StatusPulse.init"
  end
end
