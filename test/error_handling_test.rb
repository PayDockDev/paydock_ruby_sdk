require "test/unit"
require "paydock_ruby_sdk"
require_relative "./config/paydock"
require_relative "./support/helpers"

class TestAdd < Test::Unit::TestCase
  def setup
    PayDock.sandbox = true
    PayDock.secret_key = PayDockTestConf.secretKey
    PayDock.public_key = PayDockTestConf.publicKey
  end

  def test_api_errors
    PayDock.gateway_id = PayDockTestConf.stripe
    PayDock.currency = "USD"

    charge_response = PayDock::Charge.create(
      foo: 'bar'
    )
    assert_equal "Validation Error", charge_response[:error][:message]
    assert_equal "UnfulfilledCondition", charge_response[:error][:code]

    error_thrown = false

    begin
      charge_response = PayDock::Charge.create(
        amount: 42,
        customer: {
          payment_source: {
            card_name: 'foo'
          }
        }
      )
    rescue
      error_thrown = true
    end

    assert_equal true, error_thrown
  end

  def test_card_errors
    PayDock.gateway_id = PayDockTestConf.stripe
    PayDock.currency = "USD"
    token_response = PayDock::Token.create(
      card_name: "Test Name",
      card_number: "4000000000009995",
      expire_year: "2050",
      expire_month: "05",
    )

    assert_equal "Credit Card Invalid or Expired", token_response[:error][:message]
    assert_equal "1100", token_response[:error][:code]
  end

  def test_network_errors
  end

  def test_token_then_charge_stripe
  end
end