# frozen_string_literal: true

class CreateOrganizationQualiopiActions < ActiveRecord::Migration[8.1]
  def change
    create_table :organization_qualiopi_actions,
      id: false, primary_key: [ :organization_id, :qualiopi_action_type_id ] do |t|
      t.references :organization, type: :uuid, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.references :qualiopi_action_type, type: :uuid, null: false, foreign_key: { on_delete: :restrict }

      t.timestamptz :created_at, null: false, default: -> { "now()" }
    end
  end
end
