class JwtService
  SECRET_KEY = ENV.fetch("JWT_SECRET_KEY") # { Rails.application.secret_key_base }
  ALGORITHM = "HS256"
  EXPIRY_TIME = 365.days

  def self.encode(payload, expires_in = EXPIRY_TIME)
    payload[:exp] = expires_in.from_now.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    decoded_token = JWT.decode(token, SECRET_KEY, true, algorithm: ALGORITHM)
    decoded_token.first
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def self.generate_token_for_user(user, device_id)
    # Remove tokens existentes para este device (opcional - permite apenas 1 token por device)
    user.api_tokens.where(device_id: device_id).destroy_all

    # Gera um identificador único para o token
    jti = SecureRandom.uuid

    # Cria o payload
    payload = {
      user_id: user.id,
      device_id: device_id,
      jti: jti
    }

    # Gera o token JWT
    token = encode(payload)

    # Salva no banco para controle
    api_token = user.api_tokens.create!(
      token: jti, # Salvamos apenas o jti no banco, não o token completo
      device_id: device_id,
      expires_at: EXPIRY_TIME.from_now
    )

    { token: token, api_token: api_token }
  end

  def self.find_user_by_token(token)
    decoded_payload = decode(token)
    return nil unless decoded_payload

    user = User.find_by(id: decoded_payload["user_id"])
    return nil unless user

    # Verifica se o token ainda existe no banco e não expirou
    api_token = user.api_tokens.active.find_by(
      token: decoded_payload["jti"],
      device_id: decoded_payload["device_id"]
    )

    return nil unless api_token

    user
  end

  def self.revoke_token(token)
    decoded_payload = decode(token)
    return false unless decoded_payload

    ApiToken.find_by(
      token: decoded_payload["jti"],
      device_id: decoded_payload["device_id"]
    )&.destroy

    true
  end

  def self.revoke_all_user_tokens(user)
    user.api_tokens.destroy_all
  end

  def self.cleanup_expired_tokens
    ApiToken.cleanup_expired
  end
end
