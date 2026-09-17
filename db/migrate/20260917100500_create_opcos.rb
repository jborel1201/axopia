# frozen_string_literal: true

class CreateOpcos < ActiveRecord::Migration[8.1]
  def change
    create_table :opcos, id: :uuid do |t|
      t.text :code, null: false
      t.text :name, null: false

      t.timestamptz :created_at, null: false, default: -> { "now()" }
    end

    add_index :opcos, :code, unique: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO opcos (id, code, name) VALUES
            (gen_random_uuid(), 'afdas', 'AFDAS'),
            (gen_random_uuid(), 'akto', 'AKTO'),
            (gen_random_uuid(), 'atlas', 'Atlas'),
            (gen_random_uuid(), 'constructys', 'Constructys'),
            (gen_random_uuid(), 'opcommerce', 'L''Opcommerce'),
            (gen_random_uuid(), 'ocapiat', 'OCAPIAT'),
            (gen_random_uuid(), 'opco_2i', 'OPCO 2i'),
            (gen_random_uuid(), 'opco_ep', 'OPCO EP'),
            (gen_random_uuid(), 'opco_mobilites', 'OPCO Mobilités'),
            (gen_random_uuid(), 'opco_sante', 'OPCO Santé'),
            (gen_random_uuid(), 'uniformation', 'Uniformation');
        SQL
      end
    end
  end
end
