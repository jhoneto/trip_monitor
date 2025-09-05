json.kitetrips @kitetrips do |kitetrip|
  json.id kitetrip.id
  json.name kitetrip.name
  json.start_date kitetrip.start_date
  json.end_date kitetrip.end_date

  json.company do
    json.id kitetrip.company.id
    json.name kitetrip.company.name
  end
end
