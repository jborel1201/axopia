# frozen_string_literal: true

class CreateTrainings < ActiveRecord::Migration[8.1]
  def change
    create_table :trainings, id: :uuid do |t|
      t.references :organization, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :qualiopi_action_type, type: :uuid, null: false, foreign_key: { on_delete: :restrict }
      t.references :certification, type: :uuid, foreign_key: { on_delete: :restrict }
      t.text :title, null: false
      t.text :code, null: false
      t.text :diploma_code

      t.timestamptz :created_at, null: false, default: -> { "now()" }
      t.timestamptz :updated_at, null: false, default: -> { "now()" }
      t.timestamptz :deleted_at
    end

    add_index :trainings, [ :organization_id, :code ], unique: true
    add_index :trainings, :deleted_at
  end
end
