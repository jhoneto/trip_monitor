class AddCompanyToKitetrips < ActiveRecord::Migration[8.0]
  def change
    add_reference :kitetrips, :company, null: false, foreign_key: true
  end
end
