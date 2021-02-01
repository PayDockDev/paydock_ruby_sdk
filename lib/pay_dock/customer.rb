module PayDock
  class Customer
    class << self
      def call_pay_dock(action, args = {})
        if PayDock.sandbox && !(args.dig(:body, :payment_source) || {}).keys.index {|k| k.to_s.match(/^card_/)}.nil?
          throw "You should avoid handling any card details, use paydock.js to generate a single use token"
        end

        response = PayDock::ServiceHelper.call_pay_dock(action, {
          service_path: '/customers',
        }.merge(args))
        response.merge({customer_id: response.dig(:resource, :data, :_id)})
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
    end
  end
end
