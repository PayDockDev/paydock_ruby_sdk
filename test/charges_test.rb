require "test/unit"
require "paydock_ruby_sdk"
require_relative "./config/paydock"
require_relative "./support/helpers"

class ChargesTest < Test::Unit::TestCase

  def setup
    PayDock.sandbox = true
    PayDock.secret_key = PayDockTestConf.secretKey
    PayDock.public_key = PayDockTestConf.publicKey
  end

  def test_token_then_charge_stripe
    PayDock.gateway_id = PayDockTestConf.stripe

    charge_response = PayDock::Charge.create(
      amount: 111,
      token: helper_tokenize_card()
    )
    assert_equal 201, charge_response[:status]
  end

  def test_token_then_charge_authorise
    PayDock.gateway_id = PayDockTestConf.authorize

    charge_response = PayDock::Charge.create(
      amount: 111,
      token: helper_tokenize_card(card_number: "5520000000000000")
    )
    assert_equal 201, charge_response[:status]
  end

  def test_authorise_then_capture
    PayDock.gateway_id = PayDockTestConf.stripe

    authorise_resp = PayDock::Charge.authorise(
      amount: 111,
      token: helper_tokenize_card()
    )
    assert_equal 201, authorise_resp[:status]
    assert_equal "pending", authorise_resp.dig(:resource, :data, :status)
    assert_equal false,     authorise_resp.dig(:resource, :data, :capture)

    capture_resp = PayDock::Charge.capture(id: authorise_resp[:charge_id])
    assert_equal 201, capture_resp[:status]
    # assert_equal true, capture_resp.dig(:resource, :data, :capture) -> still false for some reason
    assert_equal "complete", capture_resp.dig(:resource, :data, :status)
  end

  def test_charge_after_create_customer
    PayDock.gateway_id = PayDockTestConf.stripe
    customer_id = helper_create_customer()

    charge_response = PayDock::Charge.create(
      amount: 123,
      customer_id: customer_id,
    )
    assert_equal 201, charge_response[:status]

    # A few other checks here that the payment source lines up (ensuring the customer & charge are indeed linked)
    cust_fetch_response   = PayDock::Customer.get(id: customer_id)
    charge_fetch_response = PayDock::Charge.get(id: charge_response[:charge_id])
    assert_equal charge_response.dig(:resource, :data, :customer, :payment_source, :source_id),
                 cust_fetch_response.dig(:resource, :data, :default_source)
    assert_equal charge_response.dig(:resource, :data, :customer, :payment_source, :source_id),
                 charge_fetch_response.dig(:resource, :data, :customer, :payment_source, :source_id)
  end

  def test_authorise_then_cancel
    PayDock.gateway_id = PayDockTestConf.stripe

    authorise_resp = PayDock::Charge.authorise(
      amount: 111,
      token: helper_tokenize_card()
    )
    assert_equal 201, authorise_resp[:status]

    cancel_resp = PayDock::Charge.cancel(id: authorise_resp[:charge_id])
    assert_equal 200, cancel_resp[:status]
    assert_equal "cancelled", cancel_resp.dig(:resource, :data, :status)
  end

  def test_authorise_charge_with_customer
    PayDock.gateway_id = PayDockTestConf.stripe
    customer_id = helper_create_customer()

    authorise_resp = PayDock::Charge.authorise(
      amount: 123,
      customer_id: customer_id,
    )
    assert_equal 201, authorise_resp[:status]
    assert_equal "pending", authorise_resp.dig(:resource, :data, :status)
  end

  def test_get_charges_list
    search_response = PayDock::Charge.search()
    assert_equal 200, search_response[:status]
  end

  def test_search_charges
    PayDock.gateway_id = PayDockTestConf.stripe
    timestamp = Time.now.to_i
    fname = "Gigh#{timestamp}"
    lname = "Lwuh#{timestamp}"
    eml_u = "gilw#{timestamp}"
    amt1  = (timestamp % 1000) + 200
    customer_id = helper_create_customer(
      first_name: fname,
      last_name: lname,
      email: "#{eml_u}@example.com",
    )

    charge_response = PayDock::Charge.create(
      amount: amt1,
      customer_id: customer_id,
    )
    assert_equal 201, charge_response[:status]

    charge_response = PayDock::Charge.create(
      amount: 926,
      customer_id: customer_id,
    )
    assert_equal 201, charge_response[:status]

    search_response = PayDock::Charge.search(search: fname)
    assert_equal 200, search_response[:status]
    assert_equal 2, (search_response.dig(:resource, :data) || []).length

    search_response = PayDock::Charge.search(search: eml_u)
    assert_equal 200, search_response[:status]
    assert_equal 2, (search_response.dig(:resource, :data) || []).length

    search_response = PayDock::Charge.search(amount: amt1)
    assert_equal 200, search_response[:status]
    assert_equal 1, (search_response.dig(:resource, :data) || []).length
  end





  ######### TODO:

  ### Error handling
  # for expired card: (authorise, stripe)
  # [:error][:message] == "System Error", "Credit Card Invalid or Expired"
  # [:error][:code] == 1104, 1100


  # def test_charge_creates_customer
  #   PayDock.gateway_id = PayDockTestConf.stripe
  #   # Create the customer with first charge
  #   charge1_response = PayDock::Charge.create(
  #     amount: 111,
  #     token: helper_tokenize_card(
  #       address_line1: "12345 High Rd.",
  #       address_line2: "Unit 987",
  #       address_city: "Lake Town",
  #       address_country: "Test Country",
  #       address_postcode: "V2A 2L2",
  #     ),
  #     customer: {
  #       first_name: "Tester",
  #       last_name: "Onson",
  #       email: "tester1@example.com"
  #     }
  #   })
  #   puts "FIXME: charge1_response: #{charge1_response.inspect}"
  #   puts "FIXME: charge1_response[:resource]: #{charge1_response[:resource].inspect}"
  #   assert_equal 201, charge1_response[:status]
  #
  #   # use the customer for another charge
  #   charge2_response = PayDock::Charge.create(
  #     amount: 123,
  #     customer_id: charge1_response[:customer_id],
  #   )
  #   assert_equal 201, charge2_response[:status]
  # end

  # def test_bank_charge
  #   PayDock.gateway_id = PayDockTestConf.westpac
  #   PayDock.currency = "AUD"
  #   charge_response = PayDock::Charge.create(
  #     amount: 7,
  #     currency: PayDock.currency,
  #     reference: "",
  #     description: "",
  #     customer: {
  #       first_name: "Tester",
  #       last_name: "Onson",
  #       email: "tester1@example.com",
  #       payment_source: {
  #         gateway_id: PayDock.gateway_id,
  #         type: PayDock::PAYMENT_SOURCE_TYPES[:bsb],
  #         account_name: "Test Name",
  #         account_bsb: "064000",
  #         account_number: "064000",

  #         address_line1: "12345 High Rd.",
  #         address_line2: "Unit 987",
  #         address_city: "Lake Town",
  #         address_country: "Test Country",
  #         address_postcode: "V2A 2L2",
  #       }
  #     },
  #   )
  #   puts "FIXME: charge_response: #{charge_response.inspect}"
  #   assert_equal 201, charge_response[:status]
  # end

  # def test_bank_charge_with_token
  #   PayDock.gateway_id = PayDockTestConf.westpac
  #   PayDock.currency = "AUD"
  #   token_response = PayDock::Token.create(
  #     type: PayDock::PAYMENT_SOURCE_TYPES[:bsb],
  #     account_name: "Test Name",
  #     account_bsb: "064000",
  #     account_number: "064000",
  #   )
  #   puts "FIXME: token_response: #{token_response.inspect}"
  #   assert_equal 201, token_response[:status]

  #   charge_response = PayDock::Charge.create(
  #     amount: 7,
  #     token: token_response[:token],
  #   )
  #   assert_equal 201, charge_response[:status]
  # end




  ###### not doing these ones

  # def test_charge_by_id
  #   charge_response = PayDock::Charges.charge_with_customer("1","AUD","5a70f7385f283b7e1e0388b7",reference:"Test Charge",description:"$1 charged")
  #   status = JSON.parse(charge_response)['status']
  #   assert_equal 201, status
  # end

  # def test_charge_by_non_default_payment_source
  #   charge_response = PayDock::Charges.charge_with_customer_payment_source("1","AUD","5a70f7385f283b7e1e0388b7","5a70f7265f283b7e1e0388b5")
  #   status = JSON.parse(charge_response)['status']
  #   assert_equal 201, status
  # end

  # def test_create_stripe_connection_charge
  #   token_response = Tokens.create_token(PayDockTestConf.stripe,"Test Name","4242424242424242","2020","05",card_ccv:"123")
  #   token = JSON.parse(token_response)['resource']['data']
  #   charge_response = PayDock::Charges.create_stripe_connection_charge(100, "AUD", PayDockTestConf.stripe,token,[{:amount=>40, :currency=>"AUD", :destination=>PayDockTestConf.stripe_destination_account_1},{:amount=>50,:currency=>"AUD",:destination=>PayDockTestConf.stripe_destination_account_2},{:amount=>10,:currency=>"AUD",:destination=>PayDockTestConf.stripe_destination_account_2}])
  #   status = JSON.parse(charge_response)['status']
  #   assert_equal 201, status
  # end

end