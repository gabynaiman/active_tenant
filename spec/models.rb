class Global < ActiveRecord::Base
  belongs_to_global_tenant
end

class Tenant < ActiveRecord::Base
end

class OtherTenant < ActiveRecord::Base
end

class Custom < ActiveRecord::Base
end