class User < ActiveRecord::Base
  before_validation(:create_authentication_token, on: :create)

  has_many :favorites, dependent: :destroy
  has_many :events, through: :favorites
  has_many :interests, dependent: :destroy

  validates :authentication_token, uniqueness: true, presence: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  private

  def create_authentication_token
    self.authentication_token = loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

end
