require "test/unit"
require_relative "../src/Services/charges"
require_relative "../src/Services/tokens"
require_relative "./config/paydock"

class TestAdd < Test::Unit::TestCase

	def setup
		Config.initialise(Environment.Sandbox,Paydock.secretKey,Paydock.publicKey)
	end

	def test_charge
		charge_response = PayDock::Charges.create_with_credit_card(Paydock.nab,"10","AUD","4242424242424242","2020","05",card_ccv:"123",description:"$10 charged")
		status = JSON.parse(charge_response)['status']
		assert_equal 201, status
	end

	def test_charge_by_token
		token_response = Tokens.create_token(Paydock.authorize,"Test Name","5520000000000000","2020","05",card_ccv:"123")
		token = JSON.parse(token_response)['resource']['data']
		charge_response = PayDock::Charges.charge_with_token(amount:1,currency:"AUD",token:token)
		status = JSON.parse(charge_response)['status']
		assert_equal 201, status
	end

	def test_bank_charge
		charge_response = PayDock::Charges.create_with_bank_account(Paydock.westpac,"1","AUD","Test Name","064000","064000")
		status = JSON.parse(charge_response)['status']
		assert_equal status, 201
	end

	def test_authorise_charge
		charge_response = PayDock::Charges.authorise(Paydock.stripe,"10","AUD","4242424242424242","2020","05",card_ccv:"123")
		status = JSON.parse(charge_response)['status']
		assert_equal 201, status
	end

	def test_charge_by_id
		charge_response = PayDock::Charges.charge_with_customer("1","AUD","5a70f7385f283b7e1e0388b7")
		status = JSON.parse(charge_response)['status']
		assert_equal 201, status
	end

	def test_charge_by_non_default_payment_source
		charge_response = PayDock::Charges.charge_with_customer_payment_source("1","AUD","5a70f7385f283b7e1e0388b7","5a70f7265f283b7e1e0388b5")
		status = JSON.parse(charge_response)['status']
		assert_equal 201, status
	end

	def test_create_stripe_connection_charge
		token_response = Tokens.create_token(Paydock.stripe,"Test Name","4242424242424242","2020","05",card_ccv:"123")
		token = JSON.parse(token_response)['resource']['data']
		charge_response = PayDock::Charges.create_stripe_connection_charge(100, "AUD", Paydock.stripe,token,amount1:40, stripe_account_id_1:Paydock.stripe_destination_account_1,amount2:60,stripe_account_id_2:Paydock.stripe_destination_account_2)
		status = JSON.parse(charge_response)['status']
		assert_equal 201, status
	end

	def test_capture_charge
		basic_charge = PayDock::Charges.authorise(Paydock.stripe,"10","AUD","4242424242424242","2020","05",card_ccv:"123")
		charge_id = JSON.parse(basic_charge)['resource']['data']['_id']
		charge_response = PayDock::Charges.capture_charge(charge_id, amount:"10")
		status = JSON.parse(charge_response)['status']
		assert_equal 201, status
	end

	def test_cancel_authorised_charge
		basic_charge = PayDock::Charges.authorise(Paydock.stripe,"10","AUD","4242424242424242","2020","05",card_ccv:"123")
		charge_id = JSON.parse(basic_charge)['resource']['data']['_id']
		charge_response = PayDock::Charges.cancel_authorised_charge(charge_id)
		status = JSON.parse(charge_response)['status']
		assert_equal 200, status
	end

	def test_get_charges_list
		charge_response = PayDock::Charges.get_charges_list()
		status = JSON.parse(charge_response)['status']
		assert_equal 200, status
	end

end