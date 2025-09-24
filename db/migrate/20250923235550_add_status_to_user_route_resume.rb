class AddStatusToUserRouteResume < ActiveRecord::Migration[8.0]
  def change
    add_column :user_route_resumes, :status, :string, null: false, default: 'pending'
  end
end
