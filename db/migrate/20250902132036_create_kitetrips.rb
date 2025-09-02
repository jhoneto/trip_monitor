class CreateKitetrips < ActiveRecord::Migration[8.0]
  def change
    create_table :kitetrips do |t|
      t.string :name, null: false
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
