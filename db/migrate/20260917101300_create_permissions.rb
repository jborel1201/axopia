# frozen_string_literal: true

class CreatePermissions < ActiveRecord::Migration[8.1]
  def change
    create_table :permissions, id: :uuid do |t|
      t.text :resource, null: false
      t.text :action, null: false
      t.text :slug, null: false
      t.text :description

      t.timestamptz :created_at, null: false, default: -> { "now()" }
    end

    add_index :permissions, :slug, unique: true
  end
end
