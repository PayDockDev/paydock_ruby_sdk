require "net/http"
require "uri"
require "json"
require_relative "http_method"


module HTTPmethod
	def self.httpmethod(uri,header,body,request)
		http = Net::HTTP.new(uri.host,uri.port)
		http.use_ssl = true
		request.body = body.to_json
		# Send the request
		response = http.request(request)
		response.body
	end
end