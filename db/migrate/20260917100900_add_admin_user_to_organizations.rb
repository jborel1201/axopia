# frozen_string_literal: true

class AddAdminUserToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_reference :organizations, :admin_user, type: :uuid,
      foreign_key: { to_table: :users, on_delete: :restrict }
  end
end
