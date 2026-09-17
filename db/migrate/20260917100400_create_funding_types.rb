# frozen_string_literal: true

class CreateFundingTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :funding_types, id: :uuid do |t|
      t.text :code, null: false
      t.text :label, null: false

      t.timestamptz :created_at, null: false, default: -> { "now()" }
    end

    add_index :funding_types, :code, unique: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO funding_types (id, code, label) VALUES
            (gen_random_uuid(), 'opco', 'OPCO'),
            (gen_random_uuid(), 'cpf', 'CPF'),
            (gen_random_uuid(), 'pole_emploi', 'France Travail (ex-Pôle Emploi)'),
            (gen_random_uuid(), 'company', 'Entreprise (plan de développement des compétences)'),
            (gen_random_uuid(), 'region', 'Région'),
            (gen_random_uuid(), 'self_funded', 'Financement personnel'),
            (gen_random_uuid(), 'other', 'Autre');
        SQL
      end
    end
  end
end
