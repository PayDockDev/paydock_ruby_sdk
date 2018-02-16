module Paydock
	def self.secretKey(); secretKey = "bf05dc59f637a712c900716c868ca7f9f231b3a7";end
	def self.publicKey(); publicKey = "f4a3c72bb6bbccb3f612c30ac9496fbb16d2caec";end


	#Gateway IDs
	def self.authorize(); authorize = "5a272651a527bf12a4c904c9";end
	def self.nab(); nab = "5a27839c6650eb12a817f959";end
	def self.paypal(); paypal = "5a2784836650eb12a817f95a";end
	def self.westpac(); westpac = "5a278586a527bf12a4c90521";end
	def self.paymentexpress(); paymentexpress = "5a2dc8ef5b5b400dc750e643";end
	def self.zipmoney(); zipmoney = "5a3325586a764e0c7124195a";end
	def self.sqid(); sqid = "5a39b93b23441f4f07c045d4";end
	def self.ip_payments(); ip_payments = "5a52b24e24d7922402dffb6a";end
	def self.braintree(); braintree = "5a5445d65e1032728704473a";end
	def self.stripe(); stripe = "5a39b8e723441f4f07c045d3";end

	def self.stripe_destination_account_1(); stripe_destination_account_1 = "";end
	def self.stripe_destination_account_2(); stripe_destination_account_2 = "";end

	def self.content(); content = "application/json";end
	def self.header(); header = {'x-user-secret-key' => Paydock.secretKey, 'Content-type' => Paydock.content}; end

end