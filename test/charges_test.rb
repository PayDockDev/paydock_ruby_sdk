require "test/unit"
require_relative "../src/Services/charges"
require_relative "../src/Services/tokens"
require_relative "../src/paydock"

class TestAdd < Test::Unit::TestCase
	def test_charge
		charge_response = PayDock::Charges.create_with_credit_card(Paydock.nab,"10","AUD","4242424242424242","2020","05","123")
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_charge_by_token
		token_response = Tokens.create_token(Paydock.authorize,"Test Name","5520000000000000","2020","05","123")
		token = JSON.parse(token_response)['resource']['data']
		charge_response = PayDock::Charges.charge_with_token(1,"AUD",token)
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_bank_charge
		charge_response = PayDock::Charges.create_bank_charge(Paydock.westpac,"1","AUD","Test Name","064000","064000")
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_authorise_charge
		charge_response = PayDock::Charges.create_basic_charge_authorisation(Paydock.stripe,"10","AUD","4242424242424242","2020","05","123")
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_charge_by_id
		charge_response = PayDock::Charges.charge_by_id("1","AUD","5a70f7385f283b7e1e0388b7")
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_charge_by_non_default_payment_source
		charge_response = PayDock::Charges.charge_with_non_default_payment_source("1","AUD","5a70f7385f283b7e1e0388b7","5a70f7265f283b7e1e0388b5")
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

end