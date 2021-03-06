require 'securerandom'
require 'pacto/erb_processor'

describe 'Templating' do
  let(:contract_path) { 'spec/integration/data/templating_contract.json' }

  let(:key) { SecureRandom.hex }
  let(:auth_token) { SecureRandom.hex }
  let :response do
    contract = Pacto.build_from_file(contract_path, 'http://dummyprovider.com')
    Pacto.register_contract(contract, 'my_contract')
    Pacto.use('my_contract', {:key => key, :auth_token => auth_token})

    raw_response = HTTParty.get('http://dummyprovider.com/echo', headers: {
      'Accept' => 'application/json',
      'Custom-Auth-Token' => "#{auth_token}",
      'X-Message' => "#{key}"
      }
    )
    MultiJson.load(raw_response.body)
  end

  before :each do
    Pacto.unregister_all!
  end

  context 'No processing' do
    it 'does not proccess erb tag' do
      Pacto.configure do |c|
        c.preprocessor = nil
        c.postprocessor = nil
        c.strict_matchers = false
        c.register_callback do |contracts, req, res|
          res
        end
      end

      expect(response.keys).to eq ['message']
      expect(response['message']).to eq("<%= req['HEADERS']['X-Message'].reverse %>")
    end
  end

  context 'Post processing' do
    it 'processes erb on each request' do
      Pacto.configure do |c|
        c.preprocessor = nil
        c.strict_matchers = false
        c.postprocessor = Pacto::ERBProcessor.new
      end

      expect(response.keys).to eq ['message']
      expect(response['message']).to eq(key.reverse)
    end
  end
end
