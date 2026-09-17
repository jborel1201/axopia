# frozen_string_literal: true

class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.text :auditable_type, null: false
      t.uuid :auditable_id, null: false
      t.text :action, null: false
      t.references :user, type: :uuid, foreign_key: { on_delete: :nullify }
      t.jsonb :previous_data
      t.jsonb :changed_data

      t.timestamptz :created_at, null: false, default: -> { "now()" }
    end

    add_index :audit_logs, [ :auditable_type, :auditable_id ]
  end
end
