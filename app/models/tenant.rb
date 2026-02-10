class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :documents, through: :users
  has_many :usage_records, through: :users

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true
  validates :subscription_tier, inclusion: { in: %w[basic premium enterprise] }

  scope :active, -> { where(active: true) }

  def admin_users
    users.where(role: 'admin')
  end

  def total_documents
    documents.count
  end

  def total_usage_this_month
    usage_records.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month)
                 .sum(:tokens_used)
  end

  def subscription_limits
    case subscription_tier
    when 'basic'
      { documents_per_month: 100, tokens_per_month: 1_000_000, users: 5 }
    when 'premium'
      { documents_per_month: 500, tokens_per_month: 5_000_000, users: 25 }
    when 'enterprise'
      { documents_per_month: -1, tokens_per_month: -1, users: -1 } # Unlimited
    end
  end

  def within_limits?
    limits = subscription_limits
    return true if limits[:documents_per_month] == -1 # Unlimited

    documents_this_month = documents.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month).count
    usage_this_month = total_usage_this_month

    documents_this_month <= limits[:documents_per_month] &&
      usage_this_month <= limits[:tokens_per_month] &&
      users.count <= limits[:users]
  end
end