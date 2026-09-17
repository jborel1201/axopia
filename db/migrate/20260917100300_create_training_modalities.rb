# frozen_string_literal: true

class CreateTrainingModalities < ActiveRecord::Migration[8.1]
  def change
    create_table :training_modalities, id: :uuid do |t|
      t.text :code, null: false
      t.text :label, null: false

      t.timestamptz :created_at, null: false, default: -> { "now()" }
    end

    add_index :training_modalities, :code, unique: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO training_modalities (id, code, label) VALUES
            (gen_random_uuid(), 'in_person', 'Présentiel'),
            (gen_random_uuid(), 'remote', 'Visio'),
            (gen_random_uuid(), 'blended', 'Mixte');
        SQL
      end
    end
  end
end
