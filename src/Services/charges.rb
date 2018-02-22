require 'net/http'
require 'uri'
require 'json'
require_relative "../Tools/create_charges"
require_relative '../Tools/http_request'
require_relative "../Tools/http_method"
require_relative "config"
require_relative "environment"
require_relative "payment_type"

module PayDock
	class Charges
		def self.charge_with_token(amount:0, currency:"", token:"")
			body = {
				:amount => amount,
				:currency => currency,
				:token => token
			}
			add_charge(body)
		end

		def self.create_with_credit_card(gateway_id, amount, currency, card_number, expire_year, expire_month, card_ccv:"",description:"",reference:"",first_name:"",last_name:"",email:"",address_line1:"",address_line2:"",address_city:"",address_country:"",address_postcode:"")
			body = {
				:amount => amount,
				:currency => currency,
				:reference => reference,
				:description => description,
				:customer => {
					:first_name => first_name,
					:last_name => last_name,
					:email => email,
					:payment_source => {
						:address_line1 => address_line1,
						:address_line2 => address_line2,
						:address_city => address_city,
						:address_country => address_country,
						:address_postcode => address_postcode,
						:gateway_id => gateway_id,
						:type => PaymentType.card,
						:card_number => card_number,
						:expire_month => expire_month,
						:expire_year => expire_year,
						:card_ccv => card_ccv
					}
				}
			}
			add_charge(body)
		end

		def self.create_with_bank_account(gateway_id,amount,currency,account_name,account_bsb,account_number,description:"",reference:"",first_name:"",last_name:"",email:"",address_line1:"",address_line2:"",address_city:"",address_country:"",address_postcode:"")
			body = {
				:amount => amount,
				:currency => currency,
				:reference => reference,
				:description => description,
				:customer => {
					:first_name => first_name,
					:last_name => last_name,
					:email => email,
					:payment_source => {
						:address_line1 => address_line1,
						:address_line2 => address_line2,
						:address_city => address_city,
						:address_country => address_country,
						:address_postcode => address_postcode,
						:gateway_id => gateway_id,
						:type => PaymentType.bsb,
						:account_name => account_name,
						:account_bsb => account_bsb,
						:account_number => account_number
					}
				}
			}
			add_charge(body)
		end

		# TODO: work out what to do with this, to see whether we need to support by token and by customer
		def self.authorise(amount,currency,customer_id:"",token:"",gateway_id:"",card_number:"",expire_year:"",expire_month:"",card_ccv:"",description:"",reference:"",first_name:"",last_name:"",email:"",address_line1:"",address_line2:"",address_city:"",address_country:"",address_postcode:"")
			body = {
				:amount => amount,
				:currency => currency,
				:customer_id => customer_id,
				:token => token,
				:description => description,
				:reference => reference,
				:customer => {
					:first_name => first_name,
					:last_name => last_name,
					:email => email,
					:payment_source => {
						:address_line1 => address_line1,
						:address_line2 => address_line2,
						:address_city => address_city,
						:address_country => address_country,
						:address_postcode => address_postcode,
						:gateway_id => gateway_id,
						:card_number => card_number,
						:expire_month => expire_month,
						:expire_year => expire_year,
						:card_ccv => card_ccv
					}
				}
			}
			authorise_charge(body)
		end

		# TODO: check whether we need extra fields for this
		def self.charge_with_customer(amount,currency,customer_id,description:"",reference:"")
			body = {
				:amount => amount,
				:currency => currency,
				:customer_id => customer_id,
				:description => description,
				:reference => reference
			}
			add_charge(body)
		end

		# TODO: check whether we need extra fields for this
		def self.charge_with_customer_payment_source(amount,currency,customer_id, payment_source_id,description:"",reference:"")
			body = {
				:amount => amount,
				:currency => currency,
				:customer_id => customer_id,
				:payment_source_id => payment_source_id,
				:description => description,
				:reference => reference
			}
			add_charge(body)
		end

		# TODO: this isn't right. We need to support each of the different transfer options for stripe connect, not just 2. We also need to support more than just using a token
		def self.create_stripe_connection_charge(amount,currency,stripe_transfer_group_id, token, amount1:0,stripe_account_id_1:"",amount2:0,stripe_account_id_2:"",stripe_direct_account_id:nil,stripe_application_fee:nil,stripe_destination_account_id:nil,stripe_destination_amount:nil,securepay_fraud_guard:nil,ip_address:nil)
			body = {
				:amount => amount,
				:currency => currency,
				:token => token,
				:metadata => {
					:stripe_direct_account_id => stripe_direct_account_id,
					:stripe_application_fee => stripe_application_fee,
					:stripe_destination_account_id	=> stripe_destination_account_id,
					:stripe_destination_amount => stripe_destination_amount,
					:securepay_fraud_guard => securepay_fraud_guard,
					:ip_address => ip_address
				},
				:transfers => {
					:stripe_transfer_group => stripe_transfer_group_id,
					:items => [{
							:amount1 => amount1,
							:currency => currency,
							:destination => stripe_account_id_1
						},
						{
							:amount2 => amount2,
							:currency => currency,
							:destination => stripe_account_id_2
						}]
				}				
			}
			add_charge(body)
		end

		def self.capture_charge(charge_id)
			# TODO: check what happens if the amount isn't sent through. We shouldn't send through a body if the amount isn't provided
			body = {}
			capture(body,charge_id)
		end

		def self.cancel_authorised_charge(charge_id)
			body = {}
			cancel_authorised(body,charge_id)
		end

		def self.get_charges_list()
			body = {}
			get_charges(body)
		end
	end
end