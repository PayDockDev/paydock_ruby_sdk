require "test/unit"
require_relative "../src/Services/tokens"
require_relative "./config/paydock"

class TestAdd < Test::Unit::TestCase
	def setup
		Config.initialise(Environment.Sandbox,Paydock.secretKey,Paydock.publicKey)
	end

	def test_token
		token_response = Tokens.create_token(Paydock.authorize,"Test Name","5520000000000000","2020","05",card_ccv:"123")
		status = JSON.parse(token_response)['status']
		assert_equal status, 201
	end
end

