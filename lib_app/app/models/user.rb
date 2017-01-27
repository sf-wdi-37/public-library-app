class User < ApplicationRecord
  has_secure_password

  has_many :library_users
  has_many :libraries, through: :library_users

  def self.confirm(params)
    @user = User.find_by({email: params[:email]})
    @user.try(:authenticate, params[:password])
  end
end
