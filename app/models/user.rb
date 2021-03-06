class User < ActiveRecord::Base
  extend Enumerize
  ROLES = %w[organizer voter]
  INDUSTRIES = ['Non-profit',  'Government',  'Media',  'Sports',  'Consumer Goods', 'Education',  'Other']

  TEMP_EMAIL_PREFIX = 'temp.email'
  TEMP_EMAIL_REGEX = /\Atemp.email/

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :twitter, :linkedin, :google_oauth2]

  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update
  validates_acceptance_of :terms

  has_many :identities, :dependent => :destroy
  has_many :votes
  has_many :questions, through: :votes
  has_many :organizations, :dependent => :destroy
  has_many :following_organizations, class: OrganizationFollower, foreign_key: :follower_id

  enumerize :gender, in: [:male, :female]

  def name
    "#{ first_name } #{ last_name }".strip
  end

  def follow(organization) 
    organization_follower = OrganizationFollower.find_or_initialize_by(organization: organization, follower: self) 
    return true if organization_follower.persisted?
    organization_follower.receive_app_notifications = true
    organization_follower.receive_email = true
    organization_follower.save
  end

  def age 
    dob = Date.new(birth_year.to_i)
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end
  
  def formatted_location
    location ? location.gsub(',', ' -') : 'n/a'
  end
  
  def main_organization
    organizations.last
  end

  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      email = auth.info.email if email_is_verified
      user = User.where(:email => email).first if email

      # Create the user if it's a new registration
      if user.nil?
        case auth.provider
        when 'facebook'
          name = auth.info.name
          firstname = auth.info.first_name if auth.info.first_name.present?
          last_name = auth.info.last_name if auth.info.last_name.present?
          gender = auth.info.gender if auth.info.gender.present?
          age = auth.info.age_range if auth.info.age_range.present?

        when 'twitter'
          name = auth.info.name
          location = auth.info.location if auth.info.location.present?

        when 'google_oauth2'
          name = auth.info.name
          firstname = auth.info.given_name if auth.info.given_name.present?
          last_name = auth.info.family_name if auth.info.family_name.present?
          gender = auth.info.gender if auth.info.gender.present?

        when 'linkedin'
          name = auth.info.name
          first_name = auth.info.first_name if auth.info.first_name.present?
          last_name = auth.info.last_name if auth.info.last_name.present?
          location = auth.info.location.name if auth.info.location.name.present?
          country = auth.info.location.country.code if auth.info.location.country.code.present?
        end

        user = User.new(
          # name: auth.extra.raw_info.name,
          name: name,
          first_name: first_name.present? ? first_name : '',
          last_name: last_name.present? ? last_name : '',
          email: email.present? ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}@townhallsocial.com",
          gender: gender.present? ? gender : '',
          location: location.present? ? location : '',
          password: Devise.friendly_token[0,20]
        )

        user.skip_confirmation!
        user.save!
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end

    identity.user

  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end

  def generate_password(attr={})
   require 'securerandom'
   generated_password = SecureRandom.urlsafe_base64(6)
   self.password = generated_password
   self.password_confirmation = generated_password
  end

end