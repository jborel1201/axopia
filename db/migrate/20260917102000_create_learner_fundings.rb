# frozen_string_literal: true

class CreateLearnerFundings < ActiveRecord::Migration[8.1]
  def change
    create_table :learner_fundings, id: false, primary_key: [ :learner_id, :funding_type_id ] do |t|
      t.references :learner, type: :uuid, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.references :funding_type, type: :uuid, null: false, foreign_key: { on_delete: :restrict }
      t.references :opco, type: :uuid, foreign_key: { on_delete: :restrict }

      t.timestamptz :created_at, null: false, default: -> { "now()" }
    end
  end
end
