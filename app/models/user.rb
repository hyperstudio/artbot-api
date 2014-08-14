class User < ActiveRecord::Base
  before_save :setup_role
  before_validation(:create_authentication_token, on: :create)

  has_and_belongs_to_many :roles
  has_many :favorites, dependent: :destroy
  has_many :events, through: :favorites
  has_many :interests, dependent: :destroy

  validates :authentication_token, uniqueness: true, presence: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Default role is "registered"
  def role?(role)
    return self.roles.find_by_name(role.to_s.camelize)
  end

  private

  def setup_role
    if self.role_ids.empty?
      self.role_ids = [ Role.find_or_create_by(name: 'Registered').id ]
    end
  end

  def create_authentication_token
    self.authentication_token = loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

end
