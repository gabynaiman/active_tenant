class Global < ActiveRecord::Base
  belongs_to_tenant_global
end

class Tenant < ActiveRecord::Base
end

class OtherTenant < ActiveRecord::Base
end

class Custom < ActiveRecord::Base
end