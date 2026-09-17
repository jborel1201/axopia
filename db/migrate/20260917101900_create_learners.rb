# frozen_string_literal: true

class CreateLearners < ActiveRecord::Migration[8.1]
  def change
    create_table :learners, id: :uuid do |t|
      t.references :organization, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :training, type: :uuid, null: false, foreign_key: { on_delete: :restrict }
      t.references :training_modality, type: :uuid, null: false, foreign_key: { on_delete: :restrict }
      t.text :file_number, null: false
      t.text :first_name, null: false
      t.text :last_name, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.boolean :is_subcontracted, null: false, default: false
      t.references :subcontractor_organization, type: :uuid,
        foreign_key: { to_table: :organizations, on_delete: :restrict }
      t.text :comment

      t.boolean :prerequisites_analysis_done, null: false, default: false
      t.boolean :needs_analysis_done, null: false, default: false
      t.boolean :agreement_sent, null: false, default: false
      t.boolean :in_person_agreement_done, null: false, default: false
      t.boolean :initial_assessment_done, null: false, default: false
      t.boolean :self_assessment_in_person_done, null: false, default: false
      t.boolean :hot_survey_received, null: false, default: false
      t.boolean :attendance_sheet_done, null: false, default: false
      t.boolean :trainer_evaluation_done, null: false, default: false
      t.boolean :completion_certificate_done, null: false, default: false
      t.boolean :cold_survey_received, null: false, default: false

      t.timestamptz :created_at, null: false, default: -> { "now()" }
      t.timestamptz :updated_at, null: false, default: -> { "now()" }
      t.timestamptz :deleted_at

      t.check_constraint "end_date IS NULL OR end_date >= start_date",
        name: "learners_end_date_after_start_date"
    end

    add_index :learners, [ :organization_id, :file_number ], unique: true
    add_index :learners, :deleted_at
  end
end
