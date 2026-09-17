# frozen_string_literal: true

class CreateCertifications < ActiveRecord::Migration[8.1]
  def change
    create_table :certifications, id: :uuid do |t|
      t.text :code, null: false
      t.text :registry_type, null: false
      t.text :label, null: false
      t.text :level

      t.timestamptz :created_at, null: false, default: -> { "now()" }
      t.timestamptz :updated_at, null: false, default: -> { "now()" }
    end

    add_index :certifications, :code, unique: true
  end
end
