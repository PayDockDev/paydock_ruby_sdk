# Welcome to the Paydock Ruby SDK

This SDK provides a wrapper around the PayDock REST API.

## Installation

Gemfile:

```ruby
gem 'paydock_ruby_sdk', git: 'https://github.com/PayDock/paydock_ruby_sdk.git'
```

## Basic Usage

### Note about 'token' variable

The token variable below is assuming you are using [PayDock.js](https://docs.paydock.com/#paydock-js)
to create you a single use token in place of a payment source

```ruby
  require 'paydock_ruby_sdk'

  # All/any of these can live in config/initialisers
  # gateway_id and currency are just here for convenience, override for individual requests if needed
  PayDock.secret_key = '...'
  PayDock.public_key = '...'
  PayDock.gateway_id = '...'
  PayDock.currency = "AUD"

  # use a single-use token from paydock.js to process a charge
  charge_resp = PayDock::Charge.create(amount: 10.50, token: token)
  if !charge_resp[:error_code]
    # Maybe save the charge_resp[:charge_id] to your db
  end

  # create a customer with a default payment source (from the token)
  cust_resp = PayDock::Customer.create(first_name: "...", last_name: "...", token: token)
  if !cust_resp[:error_code]
    # Maybe save the cust_resp[:customer_id] to your db
  end

  # Use the default payment source from an existing customer
  charge_resp = PayDock::Charge.create(amount: 10.50, customer_id: cust_resp[:customer_id])

  # Retrieve a customer
  cust_resp = PayDock::Customer.get(id: '...')

  # Search for charges by email address
  charges = PayDock::Charge.search(search: 'hello@example.com')
```

## Full Documentation

See the [PayDock API Reference](https://docs.paydock.com/#api-reference).

## Usage

### Authorise, then capture (or cancel)

```ruby
  authorise_resp = PayDock::Charge.authorise(amount: 111, token: token)
  capture_resp = PayDock::Charge.capture(id: authorise_resp[:charge_id])

  ## or cancel the authorisation
  PayDock::Charge.cancel(id: authorise_resp[:charge_id])
```

### Search for charges

```ruby
  # by customer
  charges = PayDock::Charge.search(customer_id: '...')

  # by subscription
  charges = PayDock::Charge.search(subscription_id: '...')

  # with filters
  charges = PayDock::Charge.search('created_at.from' => 3.days.ago)
```

## Testing

Run a testcase file with

```sh
bundle exec ruby test/charges_test.rb
```
