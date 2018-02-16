require "net/http"
require "uri"
require "json"

module HttpMethod
	def self.GET(uri,header); Net::HTTP::Get.new(uri.request_uri, header); end
	def self.POST(uri,header); Net::HTTP::Post.new(uri.request_uri, header); end
	def self.PUT(uri,header); Net::HTTP::Put.new(uri.request_uri, header); end
	def self.DELETE(uri,header); Net::HTTP::Delete.new(uri.request_uri, header); end
end

module HTTP_method
	def self.GET(); return "GET"; end
	def self.POST(); return "POST"; end
	def self.PUT(); return "PUT"; end
	def self.DELETE(); return "DELETE"; end
end
