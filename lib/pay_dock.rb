module PayDock
  PAYMENT_SOURCE_TYPES = {
    card: 'card',
    bsb: 'bsb',
    bank_account: 'bank_account',
  }

  class << self
    attr_accessor :sandbox, :secret_key, :public_key, :gateway_id, :currency, :expect_error, :custom_base_url

    def baseUrl
      paydockdomain = self.sandbox ? 'api-sandbox.paydock.com' : 'api.paydock.com'
      self.custom_base_url || "https://#{paydockdomain}/v1"
    end
  end
end
