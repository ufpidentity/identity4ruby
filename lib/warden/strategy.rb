require 'warden'

module Warden
  module Strategies
    class IdentityStrategy < Warden::Strategies::Base
      def valid?
        params["username"] || session[:identity_username_key]
      end

      def authenticate!
        config = Rails.configuration
        handler = Identity::ConnectionHandler.new config.identity_key, config.identity_key_password, config.identity_certificate, config.identity_truststore
        # create the provider
        @provider = Identity::Provider::IdentityServiceProvider.new handler

        if session[:identity_username_key].nil? && session[:identity_display_items].nil?
          pretext = @provider.pre_authenticate params["username"], request.ip
          if pretext.result['content'] == 'SUCCESS'
            session[:identity_username_key] = pretext.name
            session[:identity_display_items] = pretext.display_items
          else
            fail! pretext.result['message']
          end
        elsif !session[:identity_display_items].nil?
          parameters = {}
          session[:identity_display_items].each do |display_item|
            key = display_item['name']
            Rails.logger.debug "looking for #{key}"
            parameters[key] = params[key]
          end
          context = @provider.authenticate session[:identity_username_key], request.ip, parameters
          case context.result['content']
          when 'CONTINUE'
            session[:identity_display_items] = context.display_items
            flash[:notice] = context.result['message']
          when 'RESET'
            session[:identity_username_key] = nil
            session[:identity_display_items] = nil
          when 'SUCCESS'
            username = context.name
            session[:identity_username_key] = nil
            session[:identity_display_items] = nil
            # this is an ephemeral user that needs to be handled in your custom login controller to associate with a "real" user account
            # password is explicitly nil, keep it that way
            user = User.new(:username => username)
            success! user
          else
            fail! context.result['message']
          end
        end
      end
    end
  end
end
