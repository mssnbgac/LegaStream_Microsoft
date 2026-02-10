class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :filename, null: false
      t.string :file_path, null: false
      t.string :content_type
      t.bigint :file_size
      t.string :status, default: 'pending'
      t.jsonb :metadata, default: {}
      t.jsonb :extracted_entities, default: {}
      t.jsonb :analysis_results, default: {}
      t.jsonb :processing_log, default: []

      t.timestamps
    end

    add_index :documents, [:tenant_id, :status]
    add_index :documents, :user_id
    add_index :documents, :filename
    add_index :documents, :status
    add_index :documents, :created_at
    
    # JSONB indexes for better query performance
    add_index :documents, :extracted_entities, using: :gin
    add_index :documents, :analysis_results, using: :gin
    add_index :documents, :metadata, using: :gin
  end
end