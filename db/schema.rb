# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_17_102000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.uuid "organization_id", null: false
    t.uuid "role_id", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.uuid "user_id", null: false
    t.index ["organization_id"], name: "index_assignments_on_organization_id"
    t.index ["role_id"], name: "index_assignments_on_role_id"
    t.index ["user_id", "organization_id", "role_id"], name: "index_assignments_on_user_org_role", unique: true
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "action", null: false
    t.uuid "auditable_id", null: false
    t.text "auditable_type", null: false
    t.jsonb "changed_data"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.jsonb "previous_data"
    t.uuid "user_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "certifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "code", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "label", null: false
    t.text "level"
    t.text "registry_type", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["code"], name: "index_certifications_on_code", unique: true
  end

  create_table "funding_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "code", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "label", null: false
    t.index ["code"], name: "index_funding_types_on_code", unique: true
  end

  create_table "learner_fundings", id: false, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.uuid "funding_type_id", null: false
    t.uuid "learner_id", null: false
    t.uuid "opco_id"
    t.index ["funding_type_id"], name: "index_learner_fundings_on_funding_type_id"
    t.index ["opco_id"], name: "index_learner_fundings_on_opco_id"
  end

  create_table "learners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "agreement_sent", default: false, null: false
    t.boolean "attendance_sheet_done", default: false, null: false
    t.boolean "cold_survey_received", default: false, null: false
    t.text "comment"
    t.boolean "completion_certificate_done", default: false, null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.timestamptz "deleted_at"
    t.date "end_date"
    t.text "file_number", null: false
    t.text "first_name", null: false
    t.boolean "hot_survey_received", default: false, null: false
    t.boolean "in_person_agreement_done", default: false, null: false
    t.boolean "initial_assessment_done", default: false, null: false
    t.boolean "is_subcontracted", default: false, null: false
    t.text "last_name", null: false
    t.boolean "needs_analysis_done", default: false, null: false
    t.uuid "organization_id", null: false
    t.boolean "prerequisites_analysis_done", default: false, null: false
    t.boolean "self_assessment_in_person_done", default: false, null: false
    t.date "start_date", null: false
    t.uuid "subcontractor_organization_id"
    t.boolean "trainer_evaluation_done", default: false, null: false
    t.uuid "training_id", null: false
    t.uuid "training_modality_id", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["deleted_at"], name: "index_learners_on_deleted_at"
    t.index ["organization_id", "file_number"], name: "index_learners_on_organization_id_and_file_number", unique: true
    t.index ["organization_id"], name: "index_learners_on_organization_id"
    t.index ["subcontractor_organization_id"], name: "index_learners_on_subcontractor_organization_id"
    t.index ["training_id"], name: "index_learners_on_training_id"
    t.index ["training_modality_id"], name: "index_learners_on_training_modality_id"
    t.check_constraint "end_date IS NULL OR end_date >= start_date", name: "learners_end_date_after_start_date"
  end

  create_table "legal_statuses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "code", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "label", null: false
    t.index ["code"], name: "index_legal_statuses_on_code", unique: true
  end

  create_table "opcos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "code", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "name", null: false
    t.index ["code"], name: "index_opcos_on_code", unique: true
  end

  create_table "organization_qualiopi_actions", id: false, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.uuid "organization_id", null: false
    t.uuid "qualiopi_action_type_id", null: false
    t.index ["qualiopi_action_type_id"], name: "index_organization_qualiopi_actions_on_qualiopi_action_type_id"
  end

  create_table "organization_subcontractors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.boolean "is_active", default: true, null: false
    t.uuid "organization_id", null: false
    t.uuid "subcontractor_id", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["organization_id", "subcontractor_id"], name: "index_org_subcontractors_on_org_and_subcontractor", unique: true
    t.index ["organization_id"], name: "index_organization_subcontractors_on_organization_id"
    t.index ["subcontractor_id"], name: "index_organization_subcontractors_on_subcontractor_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aasm_state", limit: 20, default: "draft", null: false
    t.uuid "admin_user_id"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.timestamptz "deleted_at"
    t.boolean "has_qualiopi", default: false, null: false
    t.boolean "has_subcontractors", default: false, null: false
    t.uuid "legal_status_id"
    t.text "name", null: false
    t.string "nda_number", limit: 14
    t.string "siret", limit: 14
    t.text "slug", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["aasm_state"], name: "index_organizations_on_aasm_state"
    t.index ["admin_user_id"], name: "index_organizations_on_admin_user_id"
    t.index ["deleted_at"], name: "index_organizations_on_deleted_at"
    t.index ["legal_status_id"], name: "index_organizations_on_legal_status_id"
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "permission_overrides", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.boolean "granted", null: false
    t.uuid "organization_id", null: false
    t.uuid "permission_id", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.uuid "user_id", null: false
    t.index ["organization_id"], name: "index_permission_overrides_on_organization_id"
    t.index ["permission_id"], name: "index_permission_overrides_on_permission_id"
    t.index ["user_id", "organization_id", "permission_id"], name: "index_permission_overrides_on_user_org_permission", unique: true
    t.index ["user_id"], name: "index_permission_overrides_on_user_id"
  end

  create_table "permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "action", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "description"
    t.text "resource", null: false
    t.text "slug", null: false
    t.index ["slug"], name: "index_permissions_on_slug", unique: true
  end

  create_table "qualiopi_action_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "code", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "label", null: false
    t.index ["code"], name: "index_qualiopi_action_types_on_code", unique: true
  end

  create_table "role_permissions", id: false, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.uuid "permission_id", null: false
    t.uuid "role_id", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.boolean "is_system", default: false, null: false
    t.text "name", null: false
    t.uuid "organization_id", null: false
    t.text "slug", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["organization_id", "slug"], name: "index_roles_on_organization_id_and_slug", unique: true
    t.index ["organization_id"], name: "index_roles_on_organization_id"
  end

  create_table "training_modalities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "code", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "label", null: false
    t.index ["code"], name: "index_training_modalities_on_code", unique: true
  end

  create_table "trainings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "certification_id"
    t.text "code", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.timestamptz "deleted_at"
    t.text "diploma_code"
    t.uuid "organization_id", null: false
    t.uuid "qualiopi_action_type_id", null: false
    t.text "title", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["certification_id"], name: "index_trainings_on_certification_id"
    t.index ["deleted_at"], name: "index_trainings_on_deleted_at"
    t.index ["organization_id", "code"], name: "index_trainings_on_organization_id_and_code", unique: true
    t.index ["organization_id"], name: "index_trainings_on_organization_id"
    t.index ["qualiopi_action_type_id"], name: "index_trainings_on_qualiopi_action_type_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.timestamptz "deleted_at"
    t.citext "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.text "first_name", null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_super_admin", default: false, null: false, comment: "Super-accès global — volontairement hors profils/permissions, à ne modifier qu'en console (rails console), jamais via un formulaire applicatif"
    t.timestamptz "last_login_at"
    t.text "last_name", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.uuid "organization_id"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unlock_token"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.check_constraint "organization_id IS NOT NULL OR is_super_admin = true", name: "users_organization_id_or_super_admin"
  end

  add_foreign_key "assignments", "organizations", on_delete: :cascade
  add_foreign_key "assignments", "roles", on_delete: :cascade
  add_foreign_key "assignments", "users", on_delete: :cascade
  add_foreign_key "audit_logs", "users", on_delete: :nullify
  add_foreign_key "learner_fundings", "funding_types", on_delete: :restrict
  add_foreign_key "learner_fundings", "learners", on_delete: :cascade
  add_foreign_key "learner_fundings", "opcos", on_delete: :restrict
  add_foreign_key "learners", "organizations", column: "subcontractor_organization_id", on_delete: :restrict
  add_foreign_key "learners", "organizations", on_delete: :cascade
  add_foreign_key "learners", "training_modalities", on_delete: :restrict
  add_foreign_key "learners", "trainings", on_delete: :restrict
  add_foreign_key "organization_qualiopi_actions", "organizations", on_delete: :cascade
  add_foreign_key "organization_qualiopi_actions", "qualiopi_action_types", on_delete: :restrict
  add_foreign_key "organization_subcontractors", "organizations", column: "subcontractor_id", on_delete: :restrict
  add_foreign_key "organization_subcontractors", "organizations", on_delete: :cascade
  add_foreign_key "organizations", "legal_statuses", on_delete: :restrict
  add_foreign_key "organizations", "users", column: "admin_user_id", on_delete: :restrict
  add_foreign_key "permission_overrides", "organizations", on_delete: :cascade
  add_foreign_key "permission_overrides", "permissions", on_delete: :cascade
  add_foreign_key "permission_overrides", "users", on_delete: :cascade
  add_foreign_key "role_permissions", "permissions", on_delete: :cascade
  add_foreign_key "role_permissions", "roles", on_delete: :cascade
  add_foreign_key "roles", "organizations", on_delete: :cascade
  add_foreign_key "trainings", "certifications", on_delete: :restrict
  add_foreign_key "trainings", "organizations", on_delete: :cascade
  add_foreign_key "trainings", "qualiopi_action_types", on_delete: :restrict
  add_foreign_key "users", "organizations", on_delete: :cascade
end
