class User < ActiveRecord::Base
  before_save :setup_role
  has_and_belongs_to_many :roles

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Default role is "registered"
  def role?(role)
    return !!self.roles.find_by_name(role.to_s.camelize)
  end

  def setup_role
    if self.role_ids.empty?
        self.role_ids = [2]
    end
  end

end
