describe ActiveGraphQL::Model do
  config = { url: 'service_url',
             retriable: { tries: 3 } }

  let(:configured_class) do
    ConfiguredClass ||= Class.new(described_class) do
      configure config
    end
  end

  describe '.build_fetcher' do
    let(:action) { 'some_action' }
    let(:params) { 'some_params' }

    subject { klass.build_fetcher(action, params) }

    context 'with configured class' do
      let(:klass) { configured_class }
      its(:config) { is_expected.to eq config }
      its(:klass) { is_expected.to eq klass }
      its(:action) { is_expected.to eq action }
      its(:params) { is_expected.to eq params }
    end

    context 'with class inheriting the configured one' do
      let(:klass) { Class.new(configured_class) }
      its(:config) { is_expected.to eq config }
      its(:klass) { is_expected.to eq klass }
      its(:action) { is_expected.to eq action }
      its(:params) { is_expected.to eq params }
    end
  end

  shared_context 'with expected fetcher', with_expected_fetcher: true do
    let(:fetcher) { double(:fetcher) }

    before do
      expect(ActiveGraphQL::Fetcher)
        .to receive(:new).with(expected_fetcher_params).and_return(fetcher)
    end
  end

  describe '.all', with_expected_fetcher: true do
    let(:expected_fetcher_params) do
      { config: config,
        klass: configured_class,
        action: :configured_classes,
        params: nil }
    end

    subject { configured_class.all }

    it { is_expected.to be fetcher }
  end

  describe '.where', with_expected_fetcher: true  do
    let(:conditions) { double(:conditions) }

    let(:expected_fetcher_params) do
      { config: config,
        klass: configured_class,
        action: :configured_classes,
        params: conditions }
    end

    subject { configured_class.where(conditions) }

    it { is_expected.to be fetcher }
  end

  describe '.find_by', with_expected_fetcher: true  do
    let(:conditions) { double(:conditions) }

    let(:expected_fetcher_params) do
      { config: config,
        klass: configured_class,
        action: :configured_class,
        params: conditions }
    end

    subject { configured_class.find_by(conditions) }

    it { is_expected.to be fetcher }
  end
end
