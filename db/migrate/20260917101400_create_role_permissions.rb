# frozen_string_literal: true

class CreateRolePermissions < ActiveRecord::Migration[8.1]
  def change
    create_table :role_permissions, id: false, primary_key: [ :role_id, :permission_id ] do |t|
      t.references :role, type: :uuid, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.references :permission, type: :uuid, null: false, foreign_key: { on_delete: :cascade }

      t.timestamptz :created_at, null: false, default: -> { "now()" }
    end
  end
end
