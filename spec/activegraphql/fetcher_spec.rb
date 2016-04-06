describe ActiveGraphql::Fetcher do
  let(:fetcher) do
    described_class.new(url: url,
                        klass: Class.new(::Hashie::Mash),
                        action: action,
                        params: params)
  end

  let(:url) { 'some-url' }
  let(:klass) { Class.new(::Hashie::Mash) }
  let(:action) { :some_action }
  let(:params) { { some: 'params' } }
  let(:query) { double(:query) }
  let(:graph) { double(:graph) }

  before do
    expect(ActiveGraphql::Query)
      .to receive(:new).with(url: url,
                             action: action,
                             params: params).and_return(query)
  end

  describe '#fetch' do
    before do
      expect(query).to receive(:get).with(graph).and_return(query_response)
    end

    context 'with hash response' do
      let(:query_response) { { field: 'value' } }

      subject { fetcher.fetch(graph) }

      its(:field) { is_expected.to eq 'value' }
    end

    context 'with array response' do
      let(:query_response) { [{ field: 'value1' }, { field: 'value2' }] }

      subject { fetcher.fetch(graph).first }

      its(:field) { is_expected.to eq 'value1' }
    end

    context 'with nil response' do
      let(:query_response) { nil }

      subject { fetcher.fetch(graph) }

      it { is_expected.to be_nil }
    end

    context 'with unexpected response' do
      let(:query_response) { double(:unexpected) }

      subject { fetcher.fetch(graph) }

      it 'fails with unexpected error' do
        expect { subject }.to raise_error(ActiveGraphql::Fetcher::Error)
      end
    end
  end
end
