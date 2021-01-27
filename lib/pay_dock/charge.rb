module PayDock
  class Charge
    class << self
      def call_pay_dock(action, args = {})
        response = PayDock::ServiceHelper.call_pay_dock(action, {
          service_path: '/charges'
        }.merge(args))
        response_data = response.dig(:data, :resource, :data)
        response_data.kind_of?(Hash) ? response.merge({charge_id: response_data[:_id]}) : response
      end

      def create(body)
        call_pay_dock(:create, {body: body})
      end

      def get(body)
        call_pay_dock(:get, {id: body.delete(:id), body: body})
      end

      def search(query_params = {})
        call_pay_dock(:search, {query_params: query_params})
      end

      def authorise(body)
        call_pay_dock(:create, {body: body, query_params: {capture: 'false'}})
      end

      def capture(body)
        call_pay_dock(:capture, {id: body.delete(:id), body: body})
      end

      def cancel(body)
        call_pay_dock(:capture, {id: body.delete(:id), http_method: 'DELETE', body: body})
      end
    end
  end
end
