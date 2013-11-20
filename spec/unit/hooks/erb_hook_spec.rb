describe Pacto::Hooks::ERBHook do
  describe '#process' do
    let(:req) do
      OpenStruct.new(:headers => {'User-Agent' => 'abcd'})
    end
    let(:converted_req) do
      {'HEADERS' => {'User-Agent' => 'abcd'}}
    end
    let(:res) do
      OpenStruct.new(:body => 'before')
    end

    before do
    end

    context 'no matching contracts' do
      it 'binds the request' do
        contracts = Set.new
        mock_erb(:req => converted_req)
        described_class.new.process contracts, req, res
        expect(res.body).to eq('after')
      end
    end

    context 'one matching contract' do
      it 'binds the request and the contract\'s values' do
        contract = double(:values => {:max => 'test'}, :extract_values => {:a => 'b'})
        contracts = Set.new([contract])
        mock_erb(:req => converted_req, :max => 'test', :a => 'b')
        described_class.new.process contracts, req, res
        expect(res.body).to eq('after')
      end
    end

    context 'multiple matching contracts' do
      it 'binds the request and the first contract\'s values' do
        # FIXME: Bad mocking
        contract1 = double(:values => {:max => 'test'}, :extract_values => {:a => 'b'})
        contract2 = double(:values => {:mob => 'team'}, :extract_values => {:c => 'd'})
        res = OpenStruct.new(:body => 'before')
        mock_erb(:req => converted_req, :max => 'test', :a => 'b')
        contracts = Set.new([contract1, contract2])
        described_class.new.process contracts, req, res
        expect(res.body).to eq('after')
      end
    end
  end

  def mock_erb(hash)
    Pacto::ERBProcessor.any_instance.should_receive(:process).with('before', hash).and_return('after')
  end
end
