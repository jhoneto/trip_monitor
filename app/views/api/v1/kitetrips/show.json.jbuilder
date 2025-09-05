json.kitetrip do
  json.id @kitetrip.id
  json.name @kitetrip.name
  json.start_date @kitetrip.start_date
  json.end_date @kitetrip.end_date

  json.company do
    json.id @kitetrip.company.id
    json.name @kitetrip.company.name
  end

  json.routes @kitetrip.kitetrip_routes do |route|
    json.id route.id
    json.name route.name
    json.description route.description
    json.start_point route.start_point
    json.end_point route.end_point
    json.route_path route.route_path
  end
end
