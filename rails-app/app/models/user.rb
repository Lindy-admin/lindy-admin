class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: {
   member: 0,
   admin: 1,
   superadmin: 10
  }

  validates :tenant, uniqueness: true

  before_create :generate_tenant_hash

  protected

  def generate_tenant_hash
    self.tenant = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(tenant: random_token)
    end
  end
end
