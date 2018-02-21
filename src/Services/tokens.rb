require 'net/http'
require 'uri'
require 'json'
require_relative "../Tools/create_charges"
require_relative "../Tools/create_tokens"
require_relative '../Tools/http_request'
require_relative "../Tools/http_method"
require_relative "config"
require_relative "environment"

class Tokens
	def self.create_token(gateway_id,card_name,card_number,expire_year,expire_month,card_ccv:"")
		body = {
			:gateway_id => gateway_id,
			:card_name => card_name,
			:card_number => card_number,
			:expire_month => expire_month,
			:expire_year => expire_year,
			:card_ccv => card_ccv
		}
		tokens(body)
	end
end