class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Tenant scoping for multi-tenancy
  scope :for_tenant, ->(tenant_id) { where(tenant_id: tenant_id) if column_names.include?('tenant_id') }

  # JSONB query helpers
  scope :with_jsonb_contains, ->(column, data) { where("#{column} @> ?", data.to_json) }
  scope :with_jsonb_key, ->(column, key) { where("#{column} ? :key", key: key) }

  # Audit trail
  before_create :set_created_metadata
  before_update :set_updated_metadata

  private

  def set_created_metadata
    if respond_to?(:metadata) && metadata.is_a?(Hash)
      self.metadata = metadata.merge(
        created_at: Time.current,
        created_by: TenantContext.current_user_id
      )
    end
  end

  def set_updated_metadata
    if respond_to?(:metadata) && metadata.is_a?(Hash)
      self.metadata = metadata.merge(
        updated_at: Time.current,
        updated_by: TenantContext.current_user_id
      )
    end
  end
end