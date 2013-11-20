module Pacto
  module Hooks
    class ERBHook < Pacto::Callback
      def initialize
        @processor = ERBProcessor.new
      end

      def process(contracts, request_signature, response)
        if contracts.empty?
          bound_values = {}
        else
          contract = contracts.first
          bound_values = contract.values.merge(contract.extract_values request_signature)
        end
        bound_values.merge!(:req => { 'HEADERS' => request_signature.headers})
        response.body = @processor.process response.body, bound_values
        response.body
      end

    end
  end
end
