class User < ApplicationRecord
  belongs_to :tenant
  has_many :documents, dependent: :destroy
  has_many :agent_memories, dependent: :destroy
  has_many :usage_records, dependent: :destroy

  has_secure_password

  validates :email, presence: true, uniqueness: { scope: :tenant_id }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, inclusion: { in: %w[admin user viewer] }

  before_create :generate_confirmation_token
  before_create :set_default_tenant

  scope :confirmed, -> { where(email_confirmed: true) }
  scope :active, -> { where(active: true) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def admin?
    role == 'admin'
  end

  def confirmed?
    email_confirmed?
  end

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(32)
    self.confirmation_sent_at = Time.current
  end

  def generate_reset_password_token
    self.reset_password_token = SecureRandom.urlsafe_base64(32)
    self.reset_password_sent_at = Time.current
    save!
  end

  def confirm_email!
    update!(
      email_confirmed: true,
      confirmed_at: Time.current,
      confirmation_token: nil
    )
  end

  def reset_password!(new_password)
    update!(
      password: new_password,
      reset_password_token: nil,
      reset_password_sent_at: nil
    )
  end

  def confirmation_token_valid?
    confirmation_sent_at && confirmation_sent_at > 24.hours.ago
  end

  def reset_password_token_valid?
    reset_password_sent_at && reset_password_sent_at > 2.hours.ago
  end

  def update_last_login!
    update!(last_login_at: Time.current)
  end

  def lock_account!
    update!(locked_at: Time.current, active: false)
  end

  def unlock_account!
    update!(locked_at: nil, active: true)
  end

  def locked?
    locked_at.present?
  end

  def can_login?
    active? && confirmed? && !locked?
  end

  private

  def set_default_tenant
    self.tenant ||= Tenant.find_or_create_by(name: 'Default', subdomain: 'default') do |t|
      t.subscription_tier = 'basic'
      t.active = true
    end
  end
end