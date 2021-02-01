module PayDock
  class Token
    class << self
      def call_pay_dock(action, args = {})
        PayDock::ServiceHelper.call_pay_dock(action, {
          service_path: '/payment_sources/tokens',
          query_params: {public_key: PayDock.public_key},
        }.merge(args))
      end

      def create(body = {})
        default_attrs = {
          type: PayDock::PAYMENT_SOURCE_TYPES[:card],
        }
        response = call_pay_dock(:create, {body: default_attrs.merge(body)})
        response.merge({
          token: response.dig(:resource, :data)
        })
      end
    end
  end
end
