class CreateKitetripParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :kitetrip_participants do |t|
      t.references :kitetrip, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: 'participant'

      t.timestamps
    end
  end
end
