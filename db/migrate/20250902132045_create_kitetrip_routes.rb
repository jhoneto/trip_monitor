class CreateKitetripRoutes < ActiveRecord::Migration[8.0]
  def change
    create_table :kitetrip_routes do |t|
      t.references :kitetrip, null: false, foreign_key: true
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false

      t.timestamps
    end
  end
end
