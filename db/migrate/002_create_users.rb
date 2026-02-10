class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name
      t.string :last_name
      t.string :role, default: 'user'
      t.jsonb :preferences, default: {}
      t.boolean :active, default: true
      t.datetime :last_login_at
      
      # Email confirmation
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      
      # Password reset
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      
      # Account status
      t.boolean :email_confirmed, default: false
      t.datetime :locked_at

      t.timestamps
    end

    add_index :users, [:tenant_id, :email], unique: true
    add_index :users, :email
    add_index :users, :role
    add_index :users, :active
    add_index :users, :confirmation_token, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :email_confirmed
  end
end