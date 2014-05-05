class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new #guest user
    if user.role? :admin
        can :manage, :all
    elsif user.role? :registered
        can :read, :all
    end
  end
end