require "test/unit"
require "paydock_ruby_sdk"
require_relative "./config/paydock"
require_relative "./support/helpers"

class CustomersTest < Test::Unit::TestCase

  def setup
    PayDock.sandbox = true
    PayDock.secret_key = PayDockTestConf.secretKey
    PayDock.public_key = PayDockTestConf.publicKey
    PayDock.currency   = "USD"
  end

  def test_customer_create
    PayDock.gateway_id = PayDockTestConf.stripe

    cust_response = PayDock::Customer.create({
      first_name: "Cust First",
      last_name: "Cust Last",
      email: "testcust@example.com",
      address_line1: "12345 High Rd.",
      address_line2: "Unit 987",
      address_city: "Lake Town",
      address_country: "Test Country",
      address_postcode: "V2A 2L2",
      token: helper_tokenize_card(),
    })

    assert_equal 201, cust_response[:status]
    assert_kind_of String, cust_response[:customer_id]
  end

  def test_modify_customer
    PayDock.gateway_id = PayDockTestConf.stripe

    customer_id = helper_create_customer()
    cust_update_response = PayDock::Customer.modify(id: customer_id, first_name: "Jacob")
    cust_response = PayDock::Customer.get(id: customer_id)
    assert_equal "Jacob", cust_response.dig(:resource, :data, :first_name)
  end
end