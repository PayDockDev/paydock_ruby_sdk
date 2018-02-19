require 'net/http'
require 'uri'
require 'json'
require_relative '../paydock'
require_relative "../Tools/create_charges"
require_relative '../Tools/http_request'
require_relative "../Tools/http_method"
require_relative "config"
require_relative "environment"
require_relative "payment_type"

Config.initialise(Environment.Sandbox,Paydock.secretKey,Paydock.publicKey)

module PayDock
	class Charges
		def self.charge_with_token(amount, currency, token)
			body = {
				:amount => amount,
				:currency => currency,
				:token => token
			}
			add_charge(body)
		end

		def self.create_with_credit_card(gateway_id,amount,currency,creditCardNumber,expire_year,expire_month,card_ccv)
			body = {
				:amount => amount,
				:currency => currency,
				:customer => {
					:payment_source => {
						:gateway_id => gateway_id,
						:type => PaymentType.card,
						:card_number => creditCardNumber,
						:expire_month => expire_month,
						:expire_year => expire_year,
						:card_ccv => card_ccv
					}
				}
			}
			add_charge(body)
		end

		def self.create_bank_charge(gateway_id,amount,currency,account_name,account_bsb,account_number)
			body = {
				:amount => amount,
				:currency => currency,
				:customer => {
					:payment_source => {
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

		def self.create_basic_charge_authorisation(gateway_id,amount,currency,creditCardNumber,expire_year,expire_month,card_ccv)
			body = {
				:amount => amount,
				:currency => currency,
				:customer => {
					:payment_source => {
						:gateway_id => gateway_id,
						:card_number => creditCardNumber,
						:expire_month => expire_month,
						:expire_year => expire_year,
						:card_ccv => card_ccv
					}
				}
			}
			authorise(body)
		end

		def self.charge_by_id(amount,currency,customer_id)
			body = {
				:amount => amount,
				:currency => currency,
				:customer_id => customer_id
			}
			add_charge(body)
		end

		def self.charge_with_non_default_payment_source(amount,currency,customer_id,payment_source_id)
			body = {
				:amount => amount,
				:currency => currency,
				:customer_id => customer_id,
				:payment_source_id => payment_source_id
			}
			add_charge(body)
		end

		def self.create_stripe_connection_charge(amount,currency,stripe_transfer_group_id,amount1,stripe_account_id_1,amount2,stripe_account_id_2,token)
			body = {
				:amount => amount,
				:currency => currency,
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
				},
				:token => token
			}
			add_charge(body)
		end

		def self.capture_charge(amount,charge_id)
			body = {
				:amount => amount
			}
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