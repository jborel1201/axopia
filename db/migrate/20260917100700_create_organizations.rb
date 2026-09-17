# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations, id: :uuid do |t|
      t.text :name, null: false
      t.text :slug, null: false
      t.string :siret, limit: 14
      t.string :nda_number, limit: 14
      t.references :legal_status, type: :uuid, foreign_key: { on_delete: :restrict }
      t.boolean :has_qualiopi, null: false, default: false
      t.boolean :has_subcontractors, null: false, default: false
      t.string :aasm_state, limit: 20, null: false, default: "draft"

      t.timestamptz :created_at, null: false, default: -> { "now()" }
      t.timestamptz :updated_at, null: false, default: -> { "now()" }
      t.timestamptz :deleted_at
    end

    add_index :organizations, :slug, unique: true
    add_index :organizations, :aasm_state
    add_index :organizations, :deleted_at
  end
end
