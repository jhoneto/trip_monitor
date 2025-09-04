class CreateKitetripUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :kitetrip_users do |t|
      t.references :kitetrip, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, default: "traveler", null: false

      t.timestamps
    end

    add_index :kitetrip_users, [:kitetrip_id, :user_id], unique: true
  end
end
