module PayDock
  class ServiceHelper
    class << self
      @@connection = nil

      def headers
        {
          'x-user-secret-key' => PayDock.secret_key,
          'Content-type' => "application/json",
        }
      end

      def new_connection
        uri = URI.parse(PayDock.baseUrl)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http
      end

      def validate_and_prepare!(action, args = {})
        raise ArgumentError, "PayDock.secret_key is required" if !PayDock.secret_key
        return args if action.to_sym == :search

        raise ArgumentError, "PayDock.gateway_id is required" if !PayDock.gateway_id
        raise ArgumentError, "PayDock.currency is required"   if !PayDock.currency

        args.merge({
          body: {
            gateway_id: PayDock.gateway_id,
            currency: PayDock.currency,
          }.merge(args[:body])
        })
      end

      def hash_to_params(h)
        h.to_a.map {|kv| "#{kv[0]}=#{kv[1]}"}.join('&')
      end

      def http_meta_for(action, args = {})
        result = {
          http_method: args[:http_method] || 'POST',
          path: args[:service_path]
        }

        result[:path] += "/#{args[:id]}" if args[:id]

        case action.to_sym
        when :get, :search
          result[:http_method] = 'GET'
        when :create, :update
          result[:http_method] = 'POST'
        when :delete
          result[:http_method] = 'DELETE'
        else
          result[:path] += "/#{action}"
        end

        result[:path] += "?#{hash_to_params(args[:query_params])}" if args[:query_params] && args[:query_params].keys.length > 0
        result
      end

      def call_pay_dock(action, args)
        args = validate_and_prepare!(action, args)
        http_meta = http_meta_for(action, args)
        uri = URI.parse(PayDock.baseUrl + http_meta[:path])
        @@connection ||= new_connection()
        # puts "DEBUG send_request() #{http_meta[:http_method].to_s.upcase} #{uri.request_uri}"
        # puts "DEBUG send_request() body = #{args[:body].to_json}"
        http_resp = @@connection.send_request(http_meta[:http_method].to_s.upcase, uri.request_uri, args[:body] ? args[:body].to_json : nil, self.headers.merge(args[:headers] || {}))
        JSON.parse(http_resp.body, symbolize_names: true)
      end
    end
  end
end