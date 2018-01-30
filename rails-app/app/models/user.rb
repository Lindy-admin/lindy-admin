class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :tenant
  before_create :add_tenant

  enum role: {
   member: 0,
   admin: 1,
   superadmin: 10
  }

  def add_tenant
    if role != "superadmin" and tenant == nil
      self.tenant = Tenant.create!
    end
  end

end
