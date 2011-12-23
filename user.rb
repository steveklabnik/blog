require 'bcrypt'

DataMapper.setup(:default, ENV['DATABASE_URL'] || {:adapter => 'sqlite3', :database => 'db/development.sqlite3'})

class User
  include DataMapper::Resource

  property :id, Serial
  property :email, String
  property :encrypted_password, String

  attr_accessor :password

  before :create do |user|
    user.encrypted_password = BCrypt::Password.create(user.password, :cost => 5)
  end

  def self.authenticate(email, password)
    u = first(:email => email)
    return nil if u.nil? 
    return nil unless u.encrypted_password = BCrypt::Password.create(password, :cost => 5)
    u
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!

