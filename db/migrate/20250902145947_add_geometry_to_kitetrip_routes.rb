class AddGeometryToKitetripRoutes < ActiveRecord::Migration[8.0]
  def change
    # Add a geometry column to store route points (LineString)
    add_column :kitetrip_routes, :route_path, :geometry, limit: { type: "linestring", srid: 4326 }
    
    # Add individual geometry columns for start and end points
    add_column :kitetrip_routes, :start_point, :geometry, limit: { type: "point", srid: 4326 }
    add_column :kitetrip_routes, :end_point, :geometry, limit: { type: "point", srid: 4326 }
    
    # Add spatial indexes for better performance
    add_index :kitetrip_routes, :route_path, using: :gist
    add_index :kitetrip_routes, :start_point, using: :gist
    add_index :kitetrip_routes, :end_point, using: :gist
    
    # Add columns to store route name and description
    add_column :kitetrip_routes, :name, :string
    add_column :kitetrip_routes, :description, :text
  end
end
