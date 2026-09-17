# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: { on_delete: :cascade }

      ## Database authenticatable
      t.citext :email, null: false
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Trackable
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      ## Lockable
      t.integer :failed_attempts, default: 0, null: false
      t.string :unlock_token
      t.datetime :locked_at

      ## Profile
      t.text :first_name, null: false
      t.text :last_name, null: false
      t.boolean :is_active, null: false, default: true
      t.timestamptz :last_login_at
      t.boolean :is_super_admin, null: false, default: false,
        comment: "Super-accès global — volontairement hors profils/permissions, à ne modifier qu'en console (rails console), jamais via un formulaire applicatif"

      t.timestamptz :created_at, null: false, default: -> { "now()" }
      t.timestamptz :updated_at, null: false, default: -> { "now()" }
      t.timestamptz :deleted_at

      t.check_constraint "organization_id IS NOT NULL OR is_super_admin = true",
        name: "users_organization_id_or_super_admin"
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :unlock_token, unique: true
    add_index :users, :deleted_at
  end
end
