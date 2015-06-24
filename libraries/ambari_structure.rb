require 'json'
require 'ostruct'
require 'uri'

# Hack to deal with Chef's screwed up way of loading libraries at compile time
class RecursiveOpenStruct < OpenStruct
end unless defined? RecursiveOpenStruct

module Ambari
  # Represents configuration
  class Structure < RecursiveOpenStruct
    def delete_from_server
      issue request: :delete
    end

    def follow
      self.class.new Hash.new, remote: true, href: href
    end

    def post_to_server &block
      issue request: :post, &block
    end

    private

    def arguments_for request:
      json = escaped_json if request == :post
      parameters = {
        content_type: :json, 'X-Requested-By' => 'ambari-cookbook'
      }

      [json, parameters].compact
    end

    def authenticated_url
      uri = URI.parse @href

      uri.user = @@user
      uri.password = @@password

      uri.to_s
    end

    def escaped_json
      to_h.to_json.inspect
    end

    def fields_from hash:, arguments:
      memoize arguments: arguments

      arguments[:remote] ? remote_fields : hash
    end

    def initialize hash = {}, arguments = {}
      fields = fields_from hash: hash, arguments: arguments

      super fields, recurse_over_arrays: true
    end

    def issue request:, &block
      arguments = arguments_for request: request
      block ||= proc {}

      rest_client.send request, authenticated_url, *arguments do |response|
        body = response.return!.body

        block.call JSON.parse body unless body.empty?
      end
    rescue RestClient::Exception => exception
      raise "Issuing #{ request } to #{ @href } failed:\n#{ exception.inspect }"
    end

    def memoize arguments:
      @href = arguments[:href]
      @@user ||= arguments[:user]
      @@password ||= arguments[:password]
    end

    def remote_fields
      issue request: :get do |body| return body end
    end

    def rest_client
      require 'restclient'

      RestClient
    end
  end
end
