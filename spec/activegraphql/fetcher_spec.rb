describe ActiveGraphQL::Fetcher do
  let(:fetcher) do
    described_class.new(config: config,
                        klass: Class.new(::Hashie::Mash),
                        action: action,
                        params: params)
  end

  let(:config) do
    { url: url }
  end

  let(:url) { 'some-url' }
  let(:klass) { Class.new(::Hashie::Mash) }
  let(:action) { :some_action }
  let(:params) { { some: 'params' } }
  let(:query) { double(:query) }
  let(:graph) { [:some, graph: [:with, :stuff]] }

  describe '#in_locale' do
    context 'with locale' do
      let(:locale) { :some_locale }

      subject { fetcher.in_locale(locale).query }

      its(:locale) { is_expected.to eq locale }
    end
  end

  describe '#fetch' do
    before do
      expect(fetcher)
        .to receive(:query_get).with(*graph).and_return(query_response)
    end

    context 'with hash response' do
      subject { fetcher.fetch(*graph) }

      context 'with data present' do
        let(:query_response) do
          { field: 'value', nested_object: { field: 'value' } }
        end

        its(:field) { is_expected.to eq 'value' }

        it 'also works with nested objects' do
          expect(subject.nested_object.field).to eq 'value'
        end
      end

      context 'with empty data' do
        let(:query_response) { {} }

        it { is_expected.to be_nil }
      end

      context 'with nil response' do
        let(:query_response) { nil }

        it { is_expected.to be_nil }
      end
    end

    context 'with array response' do
      subject { fetcher.fetch(*graph) }

      context 'with data present' do
        let(:query_response) { [{ field: 'value1' }, { field: 'value2' }] }

        it 'resturns the right array' do
          expect(subject.first.field).to eq 'value1'
        end
      end

      context 'with empty data' do
        let(:query_response) { [] }

        it { is_expected.to eq [] }
      end
    end

    context 'with unexpected response' do
      let(:query_response) { double(:unexpected) }

      subject { fetcher.fetch(*graph) }

      it 'fails with unexpected error' do
        expect { subject }.to raise_error(ActiveGraphQL::Fetcher::Error)
      end
    end
  end

  describe '#query_get' do
    let(:response) { double(:response) }

    before do
      expect(ActiveGraphQL::Query)
        .to receive(:new).with(config: config,
                               action: action,
                               params: params).and_return(query)

      expect(query).to receive(:get).with(*graph).and_return(response)

      expect(Retriable).to receive(:retriable).with(expected_retriable_params).and_call_original
    end

    subject { fetcher.query_get(*graph) }

    context 'without retriable config' do
      let(:expected_retriable_params) do
        { tries: 1 }
      end

      it { is_expected.to be response }
    end

    context 'with retriable config' do
      let(:config) do
        { url: url, retriable: retriable_config }
      end

      context 'with hash config' do
        let(:retriable_config) { { tries: 3 } }

        let(:expected_retriable_params) do
          retriable_config
        end

        it { is_expected.to be response }
      end

      context 'with true config' do
        let(:retriable_config) { true }

        # with true config, it uses the default values for Retriable
        let(:expected_retriable_params) { {} }

        it { is_expected.to be response }
      end

      context 'with false config' do
        let(:retriable_config) { false }

        let(:expected_retriable_params) { { tries: 1 } }

        it { is_expected.to be response }
      end

      context 'with nil config' do
        let(:retriable_config) { false }

        let(:expected_retriable_params) { { tries: 1 } }

        it { is_expected.to be response }
      end
    end
  end
end
