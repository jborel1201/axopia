# frozen_string_literal: true

class CreateQualiopiActionTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :qualiopi_action_types, id: :uuid do |t|
      t.text :code, null: false
      t.text :label, null: false

      t.timestamptz :created_at, null: false, default: -> { "now()" }
    end

    add_index :qualiopi_action_types, :code, unique: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO qualiopi_action_types (id, code, label) VALUES
            (gen_random_uuid(), 'training_actions', 'Actions de formation'),
            (gen_random_uuid(), 'skills_assessment', 'Bilan de compétences'),
            (gen_random_uuid(), 'vae', 'VAE (Validation des Acquis de l''Expérience)'),
            (gen_random_uuid(), 'apprenticeship', 'Apprentissage (CFA)');
        SQL
      end
    end
  end
end
