require 'digest'
class User < ActiveRecord::Base
  attr_accessor :password
  validates_uniqueness_of :email  
  validates_length_of :email, :within => 5..50
  # validates_format_of :email, :with =>  /^[^@][\w.-]+@[\w.-]+[.][a-z]{2.4}$/i
  validates_format_of :email, :with =>  /\A[^@][\w.-]+@[\w.-]+[.][a-z]{2.4}\z/i

  validates_confirmation_of :password
  validates_length_of :password, :within => 4..20
  validates_presence_of :password, :if => :password_required?

  has_one :profile
  has_many :articles, -> { order('published_at DESC, title ASC')},
                        :dependent => :nullify
  has_many :replies, :through => :articles, :source => :comments

  before_save :encrypt_new_password

  def self.authenticate(email, password)
    user = find_by_email(email)
    return user if user && user.authenticated?(password)
  end

  def authenticated?(password)
    self.hashed_password == encrypt(password)
  end

  protected
    def encrypt_new_password
      return if password.blank?
      self.hashed_password = encrypt(password)
    end

    def password_required?
      hashed_password.blank? || password.present?
    end

    def encrypt(string)
      Digest::SHA1.hexdigest(string)
    end
end
