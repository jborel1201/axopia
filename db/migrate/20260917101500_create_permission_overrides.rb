# frozen_string_literal: true

class CreatePermissionOverrides < ActiveRecord::Migration[8.1]
  def change
    create_table :permission_overrides, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :organization, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :permission, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.boolean :granted, null: false

      t.timestamptz :created_at, null: false, default: -> { "now()" }
      t.timestamptz :updated_at, null: false, default: -> { "now()" }
    end

    add_index :permission_overrides, [ :user_id, :organization_id, :permission_id ],
      unique: true, name: "index_permission_overrides_on_user_org_permission"
  end
end
