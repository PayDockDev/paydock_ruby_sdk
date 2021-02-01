def helper_tokenize_card(args = {})
  PayDock.currency = "AUD"
  token_response = PayDock::Token.create({
    card_name: "Test Name",
    card_number: "4242424242424242",
    expire_year: "2050",
    expire_month: "05",
    card_ccv: "123"
  }.merge(args))

  assert_equal 201, token_response[:status]
  assert_equal token_response.dig(:resource, :data), token_response[:token]

  token_response[:token]
end

def helper_create_customer(args = {})
  cust_response = PayDock::Customer.create({
    token: helper_tokenize_card(),
    address_line1: "12345 High Rd.",
    address_line2: "Unit 987",
    address_city: "Lake Town",
    address_country: "Test Country",
    address_postcode: "V2A 2L2",
  }.merge(args))
  assert_equal 201, cust_response[:status]
  cust_response[:customer_id]
end
