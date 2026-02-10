class TenantContext
  class << self
    def current
      Thread.current[:tenant_id]
    end

    def current=(tenant_id)
      Thread.current[:tenant_id] = tenant_id
    end

    def current_user_id
      Thread.current[:current_user_id]
    end

    def current_user_id=(user_id)
      Thread.current[:current_user_id] = user_id
    end

    def with_tenant(tenant_id)
      old_tenant = current
      self.current = tenant_id
      yield
    ensure
      self.current = old_tenant
    end

    def with_user(user_id)
      old_user = current_user_id
      self.current_user_id = user_id
      yield
    ensure
      self.current_user_id = old_user
    end

    def reset!
      Thread.current[:tenant_id] = nil
      Thread.current[:current_user_id] = nil
    end
  end
end