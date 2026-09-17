# frozen_string_literal: true

class CreateOrganizationSubcontractors < ActiveRecord::Migration[8.1]
  def change
    create_table :organization_subcontractors, id: :uuid do |t|
      t.references :organization, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :subcontractor, type: :uuid, null: false,
        foreign_key: { to_table: :organizations, on_delete: :restrict }
      t.boolean :is_active, null: false, default: true

      t.timestamptz :created_at, null: false, default: -> { "now()" }
      t.timestamptz :updated_at, null: false, default: -> { "now()" }
    end

    add_index :organization_subcontractors, [ :organization_id, :subcontractor_id ],
      unique: true, name: "index_org_subcontractors_on_org_and_subcontractor"
  end
end
