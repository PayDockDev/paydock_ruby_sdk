require "test/unit"
require_relative "../src/Services/tokens"
require_relative "../src/paydock"

class TestAdd < Test::Unit::TestCase
	def test_token
		token_response = Tokens.create_token(gateway_id:Paydock.authorize,card_name:"Test Name",card_number:"5520000000000000",expire_year:"2020",expire_month:"05",card_ccv:"123")
		status = JSON.parse(token_response)['status']
		assert_equal status, 201
	end
end

