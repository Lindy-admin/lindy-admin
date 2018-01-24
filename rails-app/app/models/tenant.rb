class Tenant < ApplicationRecord

  validates :token, uniqueness: true

  before_create :generate_token
  after_create :create_schema

  protected

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Tenant.exists?(token: random_token)
    end
  end

  def create_schema
    Apartment::Tenant.create(self.token)
  end

end
