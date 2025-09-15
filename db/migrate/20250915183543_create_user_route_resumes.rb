class CreateUserRouteResumes < ActiveRecord::Migration[8.0]
  def change
    create_table :user_route_resumes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :kitetrip_route, null: false, foreign_key: true
      t.decimal :average_speed, precision: 8, scale: 2, null: false
      t.decimal :max_speed, precision: 8, scale: 2, null: false
      t.decimal :total_distance, precision: 10, scale: 3, null: false
      t.integer :total_time, null: false

      t.timestamps
    end

    # Add PostGIS geometry columns
    add_column :user_route_resumes, :executed_route, :line_string, null: true

    # Add indexes for better performance
    add_index :user_route_resumes, [:user_id, :kitetrip_route_id]
    add_index :user_route_resumes, :created_at
    add_index :user_route_resumes, :average_speed
    add_index :user_route_resumes, :max_speed
    add_index :user_route_resumes, :total_distance
    add_index :user_route_resumes, :total_time

    # Add spatial index for the geometry column
    add_index :user_route_resumes, :executed_route, using: :gist
  end
end
