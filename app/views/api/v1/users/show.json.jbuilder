json.user do
  json.id current_user.id
  json.email current_user.email
  json.first_name current_user.first_name
  json.last_name current_user.last_name
  json.birthdate current_user.birthdate
  json.phone_number current_user.phone_number
  json.address current_user.address
  json.city current_user.city
  json.country current_user.country
  json.state current_user.state
  json.created_at current_user.created_at
  json.updated_at current_user.updated_at
end