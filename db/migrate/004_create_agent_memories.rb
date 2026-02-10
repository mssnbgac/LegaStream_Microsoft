class CreateAgentMemories < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_memories do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :session_id, null: false
      t.string :context_type, null: false
      t.jsonb :conversation_history, default: []
      t.jsonb :learned_patterns, default: {}
      t.jsonb :document_context, default: {}
      t.datetime :expires_at

      t.timestamps
    end

    add_index :agent_memories, [:tenant_id, :session_id]
    add_index :agent_memories, :context_type
    add_index :agent_memories, :expires_at
    
    # JSONB indexes for full-text search
    add_index :agent_memories, :conversation_history, using: :gin
    add_index :agent_memories, :learned_patterns, using: :gin
    add_index :agent_memories, :document_context, using: :gin
  end
end