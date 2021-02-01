require "test/unit"
require "paydock_ruby_sdk"
require_relative "./config/paydock"
require_relative "./support/helpers"

class ErrorHandlingTest < Test::Unit::TestCase
  def setup
    PayDock.sandbox = true
    PayDock.expect_error = true
    PayDock.secret_key = PayDockTestConf.secretKey
    PayDock.public_key = PayDockTestConf.publicKey
  end

  def test_api_error
    PayDock.gateway_id = PayDockTestConf.stripe
    PayDock.currency = "USD"

    charge_response = PayDock::Charge.create(
      foo: 'bar'
    )
    assert_equal "Validation Error", charge_response[:error][:message]
    assert_equal "UnfulfilledCondition", charge_response[:error][:code]
  end

  def test_api_error_disallow_card_details
    PayDock.gateway_id = PayDockTestConf.stripe
    PayDock.currency = "USD"

    begin
      error_thrown = false
      charge_response = PayDock::Charge.create(
        amount: 42,
        customer: {payment_source: {card_name: 'disallow'}}
      )
    rescue ArgumentError
      error_thrown = true
    end
    assert_equal true, error_thrown, "throw error for charge with card details"

    begin
      error_thrown = false
      customer_id = helper_create_customer({
        token: nil,
        payment_source: {card_name: 'disallow'}
      })
    rescue ArgumentError
      error_thrown = true
    end
    assert_equal true, error_thrown, "throw error for customer with card details"

    begin
      error_thrown = false
      PayDock::Subscription.create(
        amount: 42,
        schedule: {interval: 'month', frequency: 1},
        customer: {payment_source: {card_name: 'disallow'}}
      )
    rescue ArgumentError
      error_thrown = true
    end
    assert_equal true, error_thrown, "throw error for subscription with card details"
  end

  def test_error_no_secret_key_set
    PayDock.secret_key = nil

    begin
      error_thrown = false
      charge_response = PayDock::Charge.create(
        amount: 42,
        token: 'asdfasdf',
      )
    rescue ArgumentError
      error_thrown = true
    end

    assert_equal true, error_thrown
  end

  def test_network_errors
    PayDock.custom_base_url = "https://intentional-error.paydock.com/v1"
    PayDock.gateway_id = PayDockTestConf.stripe
    PayDock.currency = "USD"
    PayDock::ServiceHelper.close_connection

    token_response = PayDock::Token.create(
      card_name: "Test Name",
      card_number: "4000000000009995",
      expire_year: "2050",
      expire_month: "05",
    )

    PayDock.custom_base_url = nil
    PayDock::ServiceHelper.close_connection # to reset the domain
    assert_equal "network_error", token_response[:error][:code]
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
end
