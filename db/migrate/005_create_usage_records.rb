class CreateUsageRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :usage_records do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :operation_type, null: false
      t.integer :token_count, null: false
      t.decimal :cost, precision: 10, scale: 4
      t.jsonb :operation_details, default: {}
      t.jsonb :billing_metadata, default: {}

      t.timestamps
    end

    add_index :usage_records, [:tenant_id, :created_at]
    add_index :usage_records, [:user_id, :created_at]
    add_index :usage_records, :operation_type
    add_index :usage_records, :created_at
    
    # JSONB indexes
    add_index :usage_records, :operation_details, using: :gin
    add_index :usage_records, :billing_metadata, using: :gin
  end
end