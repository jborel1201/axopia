# frozen_string_literal: true

class CreateAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :assignments, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :organization, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :role, type: :uuid, null: false, foreign_key: { on_delete: :cascade }

      t.timestamptz :created_at, null: false, default: -> { "now()" }
      t.timestamptz :updated_at, null: false, default: -> { "now()" }
    end

    add_index :assignments, [ :user_id, :organization_id, :role_id ],
      unique: true, name: "index_assignments_on_user_org_role"
  end
end
