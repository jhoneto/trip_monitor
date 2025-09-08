json.extract! kitetrip_route, :id, :kitetrip_id, :start_date, :end_date, :created_at, :updated_at
json.url kitetrip_route_url(kitetrip_route, format: :json)
