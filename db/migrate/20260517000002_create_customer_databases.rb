class CreateCustomerDatabases < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_databases do |t|
      t.references :account, null: false, foreign_key: true, index: { unique: true }
      t.string :label, null: false
      t.string :database_path, null: false

      t.timestamps
    end

    add_index :customer_databases, :database_path, unique: true
  end
end
