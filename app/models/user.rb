class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :companies, dependent: :destroy
  has_many :kitetrip_participants, dependent: :destroy
  has_many :kitetrips, through: :kitetrip_participants
  has_many :kitetrip_users, dependent: :destroy
  has_many :assigned_kitetrips, through: :kitetrip_users, source: :kitetrip
  has_many :api_tokens, dependent: :destroy
  has_many :user_route_traces, dependent: :destroy
end
