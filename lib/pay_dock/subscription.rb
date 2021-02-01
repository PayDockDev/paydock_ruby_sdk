module PayDock
  class Subscription
    class << self
      def call_pay_dock(action, args = {})
        if PayDock.sandbox && !(args.dig(:body, :customer, :payment_source) || {}).keys.index {|k| k.to_s.match(/^card_/)}.nil?
          throw "You should avoid handling any card details, use paydock.js to generate a single use token"
        end

        response = PayDock::ServiceHelper.call_pay_dock(action, {service_path: '/subscriptions'}.merge(args))
        response_data = response.dig(:resource, :data)
        response.merge!({subscription_id: response_data[:_id], subscription_status: response_data[:status]}) if response_data.kind_of?(Hash)
        response
      end

      def create(body)
        call_pay_dock(:create, {body: body})
      end

      def get(body)
        call_pay_dock(:get, {id: body.delete(:id), body: body})
      end

      def modify(body)
        call_pay_dock(:update, {id: body.delete(:id), body: body})
      end

      def search(query_params = {})
        call_pay_dock(:search, {query_params: query_params})
      end

      def cancel(body)
        call_pay_dock(:delete, {id: body.delete(:id), body: body})
      end
    end
  end
end
