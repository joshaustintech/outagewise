require "test_helper"

class DatabaseConfigurationTest < ActiveSupport::TestCase
  test "environment has catalog and customer sqlite databases configured" do
    configs = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).index_by(&:name)

    assert_equal "storage/#{Rails.env}_catalog.sqlite3", configs.fetch("primary").database
    assert_equal "storage/#{Rails.env}_customer_demo.sqlite3", configs.fetch("customer").database
  end
end
