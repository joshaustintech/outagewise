require "fileutils"

account = Account.find_or_create_by!(slug: "demo") do |record|
  record.name = "Demo Account"
end

account.users.find_or_create_by!(email: "demo@example.com")

customer_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "customer")
customer_database_path = customer_config.database

customer_database = account.customer_database || account.build_customer_database
customer_database.update!(
  label: "Demo Customer",
  database_path: customer_database_path
)

FileUtils.mkdir_p(Rails.root.join(File.dirname(customer_database_path)))
CustomerRecord.connection
