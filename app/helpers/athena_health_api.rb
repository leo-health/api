#    Copyright 2014 athenahealth, Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License"); you
#   may not use this file except in compliance with the License.  You
#   may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#   implied.  See the License for the specific language governing
#   permissions and limitations under the License.

require 'net/https'
require 'uri'
require 'cgi'
require 'rubygems'
require 'json'

# This module contains utilities for communicating with the More Disruption Please API.
# 
# Classes:
# Connection -- Connects to the API and performs HTTP requests
#
module AthenaHealthAPI
  # This class abstracts away the HTTP connection and basic authentication from API calls.
  #
  # When an object of this class is initialized, it attempts to authenticate to the specified
  # version of the API using the given key and secret.  It stores the access token for later use.
  #
  # Whenever any of the HTTP request methods are called (GET, POST, etc.), the arguments are
  # converted into a request and sent using the connection.  The result is decoded from JSON and
  # returned as a hash.
  #
  # The HTTP request methods take three parameters: a path (string), request parameters (hash), and
  # headers (hash).  These methods automatically prepend the specified API version to the URL.  If
  # the practiceid instance variable is set, it is also added.  Because not all API calls require
  # parameters and custom headers are rare, both of these arguments are optional.
  #
  # If an API response returns 401 Not Authorized, a new access token is obtained and the request is
  # retried.
  #
  # ==== Methods
  # * +GET+ - Perform an HTTP GET request
  # * +POST+ - Perform an HTTP POST request
  # * +PUT+ - Perform an HTTP PUT request
  # * +DELETE+ - Perform an HTTP DELETE request
  class Connection
    class <<self
      attr_accessor :debug
    end

    Connection.debug = false

    @@last_token = nil

    attr_reader :version
    attr_reader :practiceid

    # Connects to the host, and authenticates to the specified API version using key and secret.
    #
    # ==== Positional arguments
    # * +version+ - the API version to access
    # * +key+ - the client key (also known as ID)
    # * +secret+ - the client secret
    #
    # ==== Optional arguments
    # * +practiceid+ - the practice ID to be used in constructing URLs
    #
    def initialize(version, key, secret, practiceid=nil)
      Rails.logger.error("Athena key or secret are empty.  Please set ATHENA_KEY and ATHENA_SECRET env vars.") if key.to_s == '' || secret.to_s == ''

      uri = URI.parse('https://api.athenahealth.com/')
      @connection = Net::HTTP.new(uri.host, uri.port)
      @connection.use_ssl = true
      
      # Monkey patch to make Net::HTTP do proper SSL verification.
      # Background reading: 
      # http://stackoverflow.com/a/9238221
      # http://blog.spiderlabs.com/2013/06/a-friday-afternoon-troubleshooting-ruby-openssl-its-a-trap.html
      def @connection.proper_ssl_context!
        ssl_context = OpenSSL::SSL::SSLContext.new
        ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER
        cert_store = OpenSSL::X509::Store.new
        cert_store.set_default_paths
        ssl_context.cert_store = cert_store
        @ssl_context = ssl_context
      end
      @connection.proper_ssl_context!
      # End monkey patch
      
      @version = version
      @key = key
      @secret = secret
      @practiceid = practiceid

      #try using last token.  If refresh is required, it will be performed on second try
      @token = @@last_token
    end
    
    # Authenticates to the API by following the steps of basic authentication.  The URL to use is
    # determined by the version specified during initialization.
    def authenticate            # :nodoc:
      auth_paths = {
        'v1' => 'oauth',
        'preview1' => 'oauthpreview',
        'openpreview1' => 'oauthopenpreview',
      }
      
      @token = nil

      request = Net::HTTP::Post.new("/#{auth_paths[@version]}/token")
      request.basic_auth(@key, @secret)
      request.set_form_data({'grant_type' => 'client_credentials'})
      
      Rails.logger.info("#{request.method} #{request.path}")

      response = @connection.request(request)

      raise "Athena authentication failed: code #{response.code}" unless response.code == "200"

      authorization = JSON.parse(response.body)
      @@last_token = @token = authorization['authentication_token']
    end
    
    # Joins together URI paths so we can use it in API calls.  Trims extra slashes from arguments,
    # and joins them with slashes (including an initial slash).
    def path_join(*args)        # :nodoc:
      head = '^/+'
      tail = '/+$'
      # add a slash to each slash-trimmed string, grab the non-empty ones, and join them up
      return args.map { |arg| '/' + arg.to_s.gsub(/#{head}|#{tail}/, '') }.select { |x| !x.empty? }.join('')
    end   
    
    # Sets the request body, headers (including auth header) and JSON decodes the response.  If we
    # get a 401 Not Authorized, re-authenticate and try again.
    def call(request, body, headers, secondcall=false)
      authenticate unless @token

      request.set_form_data(body)
      
      headers.each {
        |k, v|
        request[k] = v
      }
      request['authorization'] = "Bearer #{@token}"
      
      Rails.logger.info("#{request.method} #{request.path}")
      Rails.logger.info("request body: #{request.body}") if Connection.debug

      response = @connection.request(request)

      Rails.logger.info("response code: #{response.code}") if Connection.debug
      Rails.logger.info("response body: #{response.body}") if Connection.debug

      if response.code == '401' && !secondcall
        #force re-authentication by nulling out @token
        @token = nil
        return call(request, body, headers, secondcall=true)
      end

      return response
    end
    
    # Perform an HTTP GET request and return a hash of the API response.
    #
    # ==== Positional arguments
    # * +path+ - the path (URI) of the resource, as a string
    # 
    # ==== Optional arguments
    # * +parameters+ - the request parameters, as a hash
    # * +headers+ - the request headers, as a hash
    def GET(path, parameters=nil, headers=nil)
      url = path
      if parameters
        # URI escape each key and value, join them with '=', and join those pairs with '&'.  Add
        # that to the URL with an prepended '?'.
        url += '?' + parameters.map { 
          |k, v|
          [k, v].map {
            |x|
            CGI.escape(x.to_s)
          }.join('=')
        }.join('&')
      end
      
      headers ||= {}
      
      request = Net::HTTP::Get.new(path_join(@version, @practiceid, url))
      return call(request, {}, headers)
    end 
    
    # Perform an HTTP POST request and return a hash of the API response.
    #
    # ==== Positional arguments
    # * +path+ - the path (URI) of the resource, as a string
    # 
    # ==== Optional arguments
    # * +parameters+ - the request parameters, as a hash
    # * +headers+ - the request headers, as a hash
    def POST(path, parameters=nil, headers=nil)
      url = path
      parameters ||= {}
      headers ||= {}
      
      request = Net::HTTP::Post.new(path_join(@version, @practiceid, url))
      return call(request, parameters, headers)
    end
    
    # Perform an HTTP PUT request and return a hash of the API response.
    #
    # ==== Positional arguments
    # * +path+ - the path (URI) of the resource, as a string
    # 
    # ==== Optional arguments
    # * +parameters+ - the request parameters, as a hash
    # * +headers+ - the request headers, as a hash
    def PUT(path, parameters=nil, headers=nil)
      url = path
      parameters ||= {}
      headers ||= {}
      
      request = Net::HTTP::Put.new(path_join(@version, @practiceid, url))
      return call(request, parameters, headers) 
    end
    
    # Perform an HTTP DELETE request and return a hash of the API response.
    #
    # ==== Positional arguments
    # * +path+ - the path (URI) of the resource, as a string
    # 
    # ==== Optional arguments
    # * +parameters+ - the request parameters, as a hash
    # * +headers+ - the request headers, as a hash
    def DELETE(path, parameters=nil, headers=nil)
      url = path
      if parameters
        # URI escape each key and value, join them with '=', and join those pairs with '&'.  Add
        # that to the URL with an prepended '?'.
        url += '?' + parameters.map { 
          |k, v|
          [k, v].map {
            |x|
            CGI.escape(x.to_s)
          }.join('=')
        }.join('&')
      end
      
      headers ||= {}
      
      request = Net::HTTP::Delete.new(path_join(@version, @practiceid, url))
      return call(request, {}, headers)
    end
    
  private :authenticate, :path_join, :call
    
  end
  
end
