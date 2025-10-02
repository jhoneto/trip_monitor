class AddMetricDateToTrace < ActiveRecord::Migration[8.0]
  def change
    add_column :user_route_traces, :metric_date, :datetime
  end
end
