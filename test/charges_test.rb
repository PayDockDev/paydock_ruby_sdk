require "test/unit"
require_relative "../src/Services/charges"
require_relative "../src/Services/tokens"
require_relative "../src/paydock"

class TestAdd < Test::Unit::TestCase
	def test_charge
		charge_response = PayDock::Charges.create_with_credit_card(gateway_id:Paydock.nab,amount:"10",currency:"AUD",card_number:"4242424242424242",expire_year:"2020",expire_month:"05",card_ccv:"123",description:"$10 charged")
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_charge_by_token
		token_response = Tokens.create_token(gateway_id:Paydock.authorize,card_name:"Test Name",card_number:"5520000000000000",expire_year:"2020",expire_month:"05",card_ccv:"123")
		token = JSON.parse(token_response)['resource']['data']
		charge_response = PayDock::Charges.charge_with_token(amount:1,currency:"AUD",token:token)
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_bank_charge
		charge_response = PayDock::Charges.create_bank_charge(gateway_id:Paydock.westpac,amount:"1",currency:"AUD",account_name:"Test Name",account_bsb:"064000",account_number:"064000")
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_authorise_charge
		charge_response = PayDock::Charges.create_basic_charge_authorisation(gateway_id:Paydock.stripe,amount:"10",currency:"AUD",card_number:"4242424242424242",expire_year:"2020",expire_month:"05",card_ccv:"123")
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_charge_by_id
		charge_response = PayDock::Charges.charge_by_id(amount:"1",currency:"AUD",customer_id:"5a70f7385f283b7e1e0388b7")
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_charge_by_non_default_payment_source
		charge_response = PayDock::Charges.charge_with_non_default_payment_source("1","AUD","5a70f7385f283b7e1e0388b7","5a70f7265f283b7e1e0388b5")
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_create_strip_connection_charge
		token_response = Tokens.create_token(gateway_id:Paydock.authorize,card_name:"Test Name",card_number:"5520000000000000",expire_year:"2020",expire_month:"05",card_ccv:"123")
		token = JSON.parse(token_response)['resource']['data']
		charge_response = PayDock::Charges.create_stripe_connection_charge(100,"AUD",Paydock.stripe,40,Paydock.stripe_destination_account_1,60,Paydock.stripe_destination_account_2,token)
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_capture_charge
		basic_charge = PayDock::Charges.create_basic_charge_authorisation(Paydock.stripe,"10","AUD","4242424242424242","2020","05","123")
		charge_id = JSON.parse(basic_charge)['resource']['data']['_id']
		charge_response = PayDock::Charges.capture_charge("10",charge_id)
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_cancel_authorised_charge
		basic_charge = PayDock::Charges.create_basic_charge_authorisation(Paydock.stripe,"10","AUD","4242424242424242","2020","05","123")
		charge_id = JSON.parse(basic_charge)['resource']['data']['_id']
		charge_response = PayDock::Charges.cancel_authorised_charge(charge_id)
		status = JSON.parse(charge_response)['status']
		assert_equal status, 200
	end

	def test_get_charges_list
		charge_response = PayDock::Charges.get_charges_list()
		status = JSON.parse(charge_response)['status']
		assert_equal status, 200
	end

end