json.extract! kitetrip, :id, :name, :start_date, :end_date, :created_at, :updated_at
json.url kitetrip_url(kitetrip, format: :json)
