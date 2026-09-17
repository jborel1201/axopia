# frozen_string_literal: true

class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles, id: :uuid do |t|
      t.references :organization, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.text :name, null: false
      t.text :slug, null: false
      t.boolean :is_system, null: false, default: false

      t.timestamptz :created_at, null: false, default: -> { "now()" }
      t.timestamptz :updated_at, null: false, default: -> { "now()" }
    end

    add_index :roles, [ :organization_id, :slug ], unique: true
  end
end
