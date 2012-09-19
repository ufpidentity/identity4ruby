require 'rest-client'
require 'resolver.rb'

module Identity
  class ConnectionHandler
    @@resolver = Identity::Resolver::StaticIdentityResolver.new
    
    def initialize(key_file, key_pass, cert_file, ca_certs='truststore.pem')
      @resource = RestClient::Resource.new(
        @@resolver.get_host,
        :ssl_client_key   => OpenSSL::PKey::RSA.new(File.read(key_file), key_pass),
        :ssl_client_cert  => OpenSSL::X509::Certificate.new(File.read(cert_file)),
        :ssl_ca_file      => ca_certs,
        :verify_ssl       => OpenSSL::SSL::VERIFY_PEER)
    end

    def make_request(path, parameters)
      @resource = @resource.class.new(@@resolver.get_host, @resource.options)
      response = @resource[path].get :params => parameters

      if response.code != 200
        result = "<context><name>%s</name><result xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:type=\"defaultResult\" message=\"Identity Service Failure : %d\">FAILURE</result></context>" %  (parameters[:name].nil? || parameters[:name].empty?) ? 'Unknown' : parameters[:name], response.code
      else
        result = response.to_s
      end
      return result
    end
  end
end
