module PayDock
  class Customer
    class << self
      def call_pay_dock(action, args = {})
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

      def index(body)
        call_pay_dock(:index, {body: body})
      end
    end
  end
end
