# frozen_string_literal: true

class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    change_table :users, bulk: true do |t|
      t.text :first_name, null: false
      t.text :last_name, null: false
      t.boolean :is_active, null: false, default: true
      t.boolean :is_super_admin, null: false, default: false,
        comment: "Super-accès global — volontairement hors profils/permissions, à ne modifier qu'en console (rails console), jamais via un formulaire applicatif"
      t.timestamptz :last_login_at
      t.timestamptz :deleted_at

      ## Trackable (Devise)
      t.integer :sign_in_count, null: false, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
    end

    add_index :users, :deleted_at
  end
end
