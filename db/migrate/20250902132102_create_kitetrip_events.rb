class CreateKitetripEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :kitetrip_events do |t|
      t.references :kitetrip, null: false, foreign_key: true
      t.datetime :event_date, null: false
      t.string :title, null: false
      t.string :description

      t.timestamps
    end
  end
end
