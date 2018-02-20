require "net/http"
require 'uri'
require 'json'
require_relative "../Services/tokens"
require_relative 'http_request'
require_relative "http_method"
require_relative "service_helper"
require_relative "../Services/config"
require_relative "../Services/environment"

def tokens(body)
	url = Config.baseURL
	uri = url+"payment_sources/tokens?public_key="+Paydock.publicKey
	ServiceHelper.callPaydock(uri,HTTP_method.POST, body)
end