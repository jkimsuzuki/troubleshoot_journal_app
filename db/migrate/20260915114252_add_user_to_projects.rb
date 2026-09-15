class AddUserToProjects < ActiveRecord::Migration[8.1]
  def up
    add_reference :projects, :user, foreign_key: true

    owner_id = User.order(:created_at).first&.id
    Project.where(user_id: nil).update_all(user_id: owner_id) if owner_id

    change_column_null :projects, :user_id, false
  end

  def down
    remove_reference :projects, :user, foreign_key: true
  end
end
