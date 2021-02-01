require "test/unit"
require "paydock_ruby_sdk"
require_relative "./config/paydock"
require_relative "./support/helpers"

class SubscriptionsTest < Test::Unit::TestCase

  def setup
    PayDock.sandbox = true
    PayDock.secret_key = PayDockTestConf.secretKey
    PayDock.public_key = PayDockTestConf.publicKey
  end

  def test_basic_subscription
    PayDock.gateway_id = PayDockTestConf.stripe

    subscription_response = PayDock::Subscription.create(
      amount: 111,
      customer_id: helper_create_customer(),
      schedule: {
        interval: 'month',
        frequency: 1,
      }
    )
    assert_equal 201, subscription_response[:status]
    assert_kind_of String, subscription_response[:subscription_id]
  end

  def test_basic_pledge
    PayDock.gateway_id = PayDockTestConf.stripe

    subscription_response = PayDock::Subscription.create(
      amount: 111,
      customer_id: helper_create_customer(),
      schedule: {
        interval: 'month',
        frequency: 2,
        end_transactions: 10,
      }
    )
    assert_equal 201, subscription_response[:status]
    assert_equal "inprogress", subscription_response.dig(:resource, :data, :schedule, :status)
    assert_equal 10, subscription_response.dig(:resource, :data, :schedule, :end_transactions)

    subscription_response = PayDock::Subscription.create(
      amount: 11,
      customer_id: helper_create_customer(),
      schedule: {
        interval: 'month',
        frequency: 2,
        end_date: Time.now + (3*365*24*60*60), # 3 years
      }
    )
    assert_equal 201, subscription_response[:status]
    assert_equal "inprogress", subscription_response.dig(:resource, :data, :schedule, :status)
    assert_kind_of String, subscription_response.dig(:resource, :data, :schedule, :end_date)
  end

  def test_get_and_update_subscription
    PayDock.gateway_id = PayDockTestConf.stripe

    subscription_response = PayDock::Subscription.create(
      amount: 181,
      customer_id: helper_create_customer(),
      schedule: {
        interval: 'month',
        frequency: 3,
      }
    )

    subscription_fetch_response  = PayDock::Subscription.get(id: subscription_response[:subscription_id])
    assert_equal 181, subscription_fetch_response.dig(:resource, :data, :amount)
    subscription_update_response = PayDock::Subscription.modify(id: subscription_response[:subscription_id], amount: 191)
    assert_equal 191, subscription_update_response.dig(:resource, :data, :amount)

    subscription_fetch_response  = PayDock::Subscription.get(id: subscription_response[:subscription_id])
    assert_equal 3, subscription_fetch_response.dig(:resource, :data, :schedule, :frequency)
    subscription_update_response = PayDock::Subscription.modify(id: subscription_response[:subscription_id], schedule: {frequency: 1, interval: 'month', start_date: Time.now})
    assert_equal 1, subscription_update_response.dig(:resource, :data, :schedule, :frequency)
  end

  def test_cancel_subscription
    PayDock.gateway_id = PayDockTestConf.stripe

    subscription_response = PayDock::Subscription.create(
      amount: 111,
      customer_id: helper_create_customer(),
      schedule: {
        interval: 'month',
      }
    )

    subscription_fetch_response  = PayDock::Subscription.cancel(id: subscription_response[:subscription_id])
    assert_equal 'deleted', subscription_fetch_response[:subscription_status]
  end

  def test_search_subscriptions
    PayDock.gateway_id = PayDockTestConf.stripe

    customer_id = helper_create_customer(
      first_name: "search for",
      last_name: "subscription",
      email: "searchforsubs@example.com",
    )

    subscription_response = PayDock::Subscription.create(amount: 111, customer_id: customer_id, schedule: {interval: 'month'})
    assert_equal 201, subscription_response[:status]
    subscription_response = PayDock::Subscription.create(amount: 141, customer_id: customer_id, schedule: {interval: 'month'})
    assert_equal 201, subscription_response[:status]

    search_response = PayDock::Subscription.search(customer_id: customer_id)
    assert_equal 200, search_response[:status]
    assert_equal 2, (search_response.dig(:resource, :data) || []).length
  end
end