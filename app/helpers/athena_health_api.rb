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
  class Configuration
    attr_accessor :min_request_interval, :num_workers, :logger

    def initialize
      @min_request_interval = (0.2).seconds
      @num_workers = 4
      @logger = Rails.logger
    end

    def effective_min_request_interval
      @min_request_interval * @num_workers
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

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
    @@last_token = nil
    @@last_request = Time.now

    attr_reader :version, :practiceid

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
      AthenaHealthAPI.configuration.logger.error("Athena key or secret are empty.  Please set ATHENA_KEY and ATHENA_SECRET env vars.") if key.to_s == '' || secret.to_s == ''

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
      @rate_limiter = RateLimiter.new
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
      AthenaHealthAPI.configuration.logger.info("#{request.method} #{request.path}")
      response = @connection.request(request)
      AthenaHealthAPI.configuration.logger.info("#{response.code}\n#{response.body[0..2048]}")
      raise "Athena authentication failed: code #{response.code}" unless response.code == "200"
      authorization = JSON.parse(response.body)
      @@last_token = @token = authorization['access_token']
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
    def call(request, body, headers, secondcall=false, ignore_throttle=false)
      authenticate unless @token
      request.set_form_data(body)
      headers.each {
        |k, v|
        request[k] = v
      }

      request['authorization'] = "Bearer #{@token}"
      AthenaHealthAPI.configuration.logger.info("#{request.method} #{request.path}\n#{request.body}")
      sleep_time = @rate_limiter.sleep_time_after_incrementing_call_count
      AthenaHealthAPI.configuration.logger.info("TEMPORARY INFO: SHOULD SLEEP FOR #{sleep_time} SECONDS")
      sleep(sleep_time) unless ignore_throttle
      response = @connection.request(request)
      @@last_request = Time.now
      AthenaHealthAPI.configuration.logger.info("#{response.code}\n#{response.body[0..2048]}")
      if response.code == '401' && !secondcall
        #force re-authentication by nulling out @token
        @token = nil
        return call(request, body, headers, secondcall=true)
      end

      response
    end

    # Perform an HTTP GET request and return a hash of the API response.
    #
    # ==== Positional arguments
    # * +path+ - the path (URI) of the resource, as a string
    #
    # ==== Optional arguments
    # * +parameters+ - the request parameters, as a hash
    # * +headers+ - the request headers, as a hash
    def GET(path, parameters=nil, headers=nil, ignore_throttle=false, version_and_practice_prepended=false)
      url = path
      url += '?' + parameters.to_query if parameters && parameters.size > 0
      url = path_join(@version, @practiceid, url) unless version_and_practice_prepended
      headers ||= {}
      request = Net::HTTP::Get.new(url)
      return call(request, {}, headers, false, ignore_throttle)
    end

    # Perform an HTTP POST request and return a hash of the API response.
    #
    # ==== Positional arguments
    # * +path+ - the path (URI) of the resource, as a string
    #
    # ==== Optional arguments
    # * +parameters+ - the request parameters, as a hash
    # * +headers+ - the request headers, as a hash
    def POST(path, parameters=nil, headers=nil, ignore_throttle=false)
      url = path
      parameters ||= {}
      headers ||= {}
      request = Net::HTTP::Post.new(path_join(@version, @practiceid, url))
      call(request, parameters, headers, false, ignore_throttle)
    end

    # Perform an HTTP PUT request and return a hash of the API response.
    #
    # ==== Positional arguments
    # * +path+ - the path (URI) of the resource, as a string
    #
    # ==== Optional arguments
    # * +parameters+ - the request parameters, as a hash
    # * +headers+ - the request headers, as a hash
    def PUT(path, parameters=nil, headers=nil, ignore_throttle=false)
      url = path
      parameters ||= {}
      headers ||= {}
      request = Net::HTTP::Put.new(path_join(@version, @practiceid, url))
      call(request, parameters, headers, false, ignore_throttle)
    end

    # Perform an HTTP DELETE request and return a hash of the API response.
    #
    # ==== Positional arguments
    # * +path+ - the path (URI) of the resource, as a string
    #
    # ==== Optional arguments
    # * +parameters+ - the request parameters, as a hash
    # * +headers+ - the request headers, as a hash
    def DELETE(path, parameters=nil, headers=nil, ignore_throttle=false)
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
      call(request, {}, headers, false, ignore_throttle)
    end
  end

  class RateLimiter
    attr_reader :athena_api_key, :per_second_rate_limit, :per_day_rate_limit, :next_day

    def initialize
      @per_day_rate_limit = ENV['ATHENA_DAY_RATE'].to_i
      @per_second_rate_limit = ENV['ATHENA_SECOND_RATE'].to_i
      @athena_api_key = ENV['ATHENA_KEY']
      @next_day = Date.tomorrow.to_datetime.to_i
    end

    def reset_counts
      $redis.del(day_key)
      $redis.del(second_key)
    end

    def sleep_time_after_incrementing_call_count
      [sleep_time_day_rate_limit_after_incrementing_call_count, sleep_time_second_rate_limit_after_incrementing_call_count].max
    end

    def sleep_time_day_rate_limit_after_incrementing_call_count
      key = day_key
      count, _ = $redis.multi do
        $redis.incr(key)
        $redis.expireat(key, @next_day)
      end
      count < @per_day_rate_limit ? 0 : @next_day - Time.now.to_i
    end

    def sleep_time_second_rate_limit_after_incrementing_call_count
      count, _ = $redis.multi do
        $redis.incr(second_key)
        $redis.expire(second_key, 1)
      end
      count < @per_second_rate_limit ? 0 : 1
    end

    def day_key
      if Time.now.to_i <=  $redis.get('expire_at').to_i
        "day_rate_limit:#{athena_api_key}:#{$redis.get('expire_at')}"
      else
        @next_day = Date.tomorrow.to_datetime.to_i
        $redis.set('expire_at', @next_day)
        "day_rate_limit:#{athena_api_key}:#{@next_day.to_s}"
      end
    end

    def second_key
      time_pattern = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
      "second_rate_limit:#{athena_api_key}:#{time_pattern}"
    end
  end
end
