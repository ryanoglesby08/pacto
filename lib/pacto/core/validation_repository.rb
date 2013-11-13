module Pacto
  class Validation
    attr_reader :request, :response, :contract, :result

    def initialize(request, response, contract, result)
      @request = request
      @response = response
      @contract = contract
      @result = result
    end

    def to_s
      if @contract.nil?
        contract_name = 'nil'
      else
        contract_name = @contract.file
      end
      """
      Validation:
        Request: #{@request}
        Contract: #{contract_name}
        Result: #{@result.inspect}
      """
    end
  end

  class ValidationRepository
    include Singleton

    attr_reader :validations

    def initialize
      @validations = []
    end

    def logger
      @logger ||= Logger.instance
    end

    def add_validation(request_signature, response, contract)
      logger.debug("Validating #{request_signature}, #{response} against #{contract}")
      if contract.nil?
        result = nil
      else
        result = contract.validate(response) unless contract.nil?
        logger.info("Validation result: #{result}")
      end
      @validations << Validation.new(request_signature, response, contract, result)
    end

    def unmatched_transactions
      @validations.select do |validation|
        validation.contract.nil?
      end
    end

    def invalid_transactions
      @validations.select do |validation|
        validation.contract && !validation.result.empty?
      end
    end
  end
end
