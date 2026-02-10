class CreateTenants < ActiveRecord::Migration[8.0]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.string :subscription_tier, default: 'basic'
      t.string :encryption_key_id
      t.jsonb :configuration, default: {}
      t.jsonb :billing_settings, default: {}
      t.jsonb :compliance_requirements, default: {}
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :tenants, :subdomain, unique: true
    add_index :tenants, :name
    add_index :tenants, :active
  end
end