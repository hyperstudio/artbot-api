class RemoveRoles < ActiveRecord::Migration
  def change
    drop_table :roles_users
    drop_table :roles
  end
end
