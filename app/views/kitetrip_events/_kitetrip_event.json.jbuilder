json.extract! kitetrip_event, :id, :kitetrip_id, :event_date, :title, :description, :created_at, :updated_at
json.url kitetrip_event_url(kitetrip_event, format: :json)
