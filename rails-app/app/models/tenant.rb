class Tenant < ApplicationRecord

  validates :token, uniqueness: true

  before_create :generate_token
  before_destroy :destroy_schema
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
  def destroy_schema
    Apartment::Tenant.drop(self.token)
  end

end
