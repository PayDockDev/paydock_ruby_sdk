module PayDock
  PAYMENT_SOURCE_TYPES = {
    card: 'card',
    bsb: 'bsb',
  }

  class << self
    attr_accessor :sandbox, :secret_key, :public_key, :gateway_id, :currency

    def baseUrl
      paydockdomain = self.sandbox ? 'api-sandbox.paydock.com' : 'api.paydock.com'
      "https://#{paydockdomain}/v1"
    end
  end
end
