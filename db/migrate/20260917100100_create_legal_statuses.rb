# frozen_string_literal: true

class CreateLegalStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :legal_statuses, id: :uuid do |t|
      t.text :code, null: false
      t.text :label, null: false

      t.timestamptz :created_at, null: false, default: -> { "now()" }
    end

    add_index :legal_statuses, :code, unique: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO legal_statuses (id, code, label) VALUES
            (gen_random_uuid(), 'ei', 'Entreprise Individuelle (EI)'),
            (gen_random_uuid(), 'micro_entreprise', 'Micro-entreprise'),
            (gen_random_uuid(), 'eurl', 'EURL'),
            (gen_random_uuid(), 'sarl', 'SARL'),
            (gen_random_uuid(), 'sasu', 'SASU'),
            (gen_random_uuid(), 'sas', 'SAS'),
            (gen_random_uuid(), 'sa', 'SA'),
            (gen_random_uuid(), 'snc', 'SNC (Société en Nom Collectif)'),
            (gen_random_uuid(), 'sci', 'SCI (Société Civile Immobilière)'),
            (gen_random_uuid(), 'scop', 'SCOP (Société Coopérative de Production)'),
            (gen_random_uuid(), 'scic', 'SCIC (Société Coopérative d''Intérêt Collectif)'),
            (gen_random_uuid(), 'selarl', 'SELARL'),
            (gen_random_uuid(), 'selas', 'SELAS'),
            (gen_random_uuid(), 'gie', 'GIE (Groupement d''Intérêt Économique)'),
            (gen_random_uuid(), 'association_loi_1901', 'Association loi 1901'),
            (gen_random_uuid(), 'fondation', 'Fondation'),
            (gen_random_uuid(), 'etablissement_public', 'Établissement public'),
            (gen_random_uuid(), 'autre', 'Autre');
        SQL
      end
    end
  end
end
