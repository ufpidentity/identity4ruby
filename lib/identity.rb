require 'connection_handler.rb'
require 'xmlsimple'
require 'warden/strategy.rb'

module Identity
=begin 
<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<authentication_pretext>
  <name>guest3f4c5a36a65d46e2</name>
  <result xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:type=\"authenticationResult\" confidence=\"0.0\" level=\"0\" code=\"0\" message=\"OK\">SUCCESS</result>
  <display_item name=\"passphrase\"><display_name>Password</display_name><form_element>&lt;input id=&quot;AuthParam0&quot; type=&quot;password&quot; name=&quot;passphrase&quot; class=&quot;field required&quot; /&gt;</form_element><nickname>Guest Password</nickname></display_item>
</authentication_pretext>
=end
  class AuthenticationResult
    attr_accessor :name, :result, :display_items
    
    def initialize(xml) 
      r = XmlSimple.xml_in(xml, { 'ForceArray' => ['display_item'] })
      self.result = r['result']
      self.name = r['name']

      if result['content'] == 'SUCCESS' || result['content'] == 'CONTINUE'
        if r['display_item'] && r['display_item'].length > 0
          self.display_items = Array.new        
          r['display_item'].each_with_index { |di, index| self.display_items[index] = di }
        end
      end
    end
  end

=begin
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<enrollment_pretext>
  <name>test</name>
  <result code="0" message="OK">SUCCESS</result>
  <form_element display_name="Password" name="passphrase">
    <element>&lt;input id=&quot;EnrollParam0&quot; type=&quot;password&quot; name=&quot;passphrase&quot; /&gt;</element>
  </form_element>
</enrollment_pretext>
=end
  class EnrollmentResult 
    attr_accessor :name, :result, :form_elements
    
    def initialize(xml)
      r = XmlSimple.xml_in(xml, { 'ForceArray' => ['form_element'] })
      self.name = r['name']
      self.result = r['result']
      if self.result['content'] == 'SUCCESS'
        if r['form_elements'] && r['form_elements'].length > 0
          self.form_elements = Array.new
          r['form_elements'].each_with_index { |fe, index| self.form_elements[index] = fe }
        end
      end
    end
  end

  module Provider 
    class IdentityServiceProvider 
      def initialize(handler) 
        @handler = handler
      end

      def pre_authenticate(name, remote_host) 
        xml = @handler.make_request 'preauthenticate', { :name => name, :client_ip => remote_host }
        return AuthenticationResult.new(xml)
      end

      def authenticate(name, remote_host, parameters)
        xml = @handler.make_request 'authenticate', { :name => name, :client_ip => remote_host }.merge(parameters)
        return AuthenticationResult.new(xml)
      end

      def pre_enroll(name, remote_host)
        xml = @handler.make_request 'preenroll', { :name => name, :client_ip => remote_host }
        return EnrollmentResult.new(xml)
      end

      def enroll(name, remote_host, parameters)
        xml = @handler.make_request 'enroll', { :name => name, :client_ip => remote_host }.merge(parameters)
        return EnrollmentResult.new(xml)
      end
    end
  end
end
