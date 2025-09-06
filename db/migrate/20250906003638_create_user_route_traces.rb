class CreateUserRouteTraces < ActiveRecord::Migration[8.0]
  def change
    create_table :user_route_traces do |t|
      t.references :user, null: false, foreign_key: true
      t.references :kitetrip_route, null: false, foreign_key: true
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.json :metadata

      t.timestamps
    end
  end
end
