require_relative "../paydock"
require_relative "http_method"
require_relative "http_request"
require_relative "../Services/config"

class ServiceHelper
	def self.callPaydock(uri, http_request, body)
		uri = URI.parse(uri)
		case http_request
		when "GET"
			request = HttpMethod.GET(uri,Paydock.header)
		when "POST"
			request = HttpMethod.POST(uri,Paydock.header)
		when "PUT"
			request = HttpMethod.PUT(uri,Paydock.header)
		when "DELETE"
			request = HttpMethod.GET(uri,Paydock.header)
		end
		HTTPmethod.httpmethod(uri,Paydock.header,body, request)
	end
end