module Identity
  module Resolver
    class StaticIdentityResolver
      def get_host
        'https://staging.ufp.com:8443/identity-services/services'
      end
    end
  end
end
