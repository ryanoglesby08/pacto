require 'pacto/stubs/webmock_helper'

module Pacto
  module Stubs
    class BuiltIn

      def initialize
        register_callbacks
        @logger = Logger.instance
      end

      def stub_request! request, response, stubbing = true
        strict = Pacto.configuration.strict_matchers
        uri_pattern = Addressable::Template.new("#{request.host}#{request.path}")
        if stubbing
          stub = WebMock.stub_request(request.method, uri_pattern)
          stub.to_return(
            :status => response.status,
            :headers => response.headers,
            :body => format_body(response.body)
          )
          request_pattern = stub.request_pattern
        else
          request_pattern = WebMock::RequestPattern.new(request.method, uri_pattern)
        end
        request_pattern.with(request_details(request)) if strict
        request_pattern
      end

      def reset!
        WebMock.reset!
        WebMock.reset_callbacks
      end

      def process_callbacks(request_signature, response)
        WebMockHelper.generate(request_signature, response) if Pacto.generating?

        contracts = Pacto.contracts_for request_signature
        Pacto.configuration.callback.process contracts, request_signature, response

        WebMockHelper.validate(request_signature, response) if Pacto.validating?
      end

      private

      def register_callbacks
        WebMock.after_request do |request_signature, response|
          process_callbacks request_signature, response
        end
      end

      def format_body(body)
        if body.is_a?(Hash) || body.is_a?(Array)
          body.to_json
        else
          body
        end
      end

      def request_details request
        details = {}
        unless request.params.empty?
          details[webmock_params_key(request)] = request.params
        end
        unless request.headers.empty?
          details[:headers] = request.headers
        end
        details
      end

      def webmock_params_key request
        request.method == :get ? :query : :body
      end
    end
  end
end
