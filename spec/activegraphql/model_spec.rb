describe ActiveGraphql::Model do
  describe '.build_fetcher' do
    let(:action) { 'some_action' }
    let(:params) { 'some_params' }

    let(:configured_class) do
      Class.new(described_class) do
        configure url: 'service_url'
      end
    end

    subject { klass.build_fetcher(action, params) }

    context 'with configured class' do
      let(:klass) { configured_class }

      its(:url) { is_expected.to eq 'service_url' }
      its(:klass) { is_expected.to eq klass }
      its(:action) { is_expected.to eq action }
      its(:params) { is_expected.to eq params }
    end

    context 'with class inheriting the configured one' do
      let(:klass) { Class.new(configured_class) }

      its(:url) { is_expected.to eq 'service_url' }
      its(:klass) { is_expected.to eq klass }
      its(:action) { is_expected.to eq action }
      its(:params) { is_expected.to eq params }
    end
  end

  describe '.all' do
    let(:klass) do
      Object.const_set 'MyAllEntity', Class.new(described_class)
    end

    let(:fetcher) { double(:fetcher) }

    before do
      expect(described_class)
        .to receive(:build_fetcher).with(:my_all_entities).and_return(fetcher)
    end

    subject { klass.all }

    it { is_expected.to be fetcher }
  end

  describe '.where' do
    let(:conditions) { double(:conditions) }

    let(:klass) do
      Object.const_set 'MyWhereEntity', Class.new(described_class)
    end

    let(:fetcher) { double(:fetcher) }

    before do
      expect(described_class)
        .to receive(:build_fetcher).with(:my_where_entities, conditions).and_return(fetcher)
    end

    subject { klass.where(conditions) }

    it { is_expected.to be fetcher }
  end

  describe '.find_by' do
    let(:conditions) { double(:conditions) }

    let(:klass) do
      Object.const_set 'MyFindByEntity', Class.new(described_class)
    end

    let(:fetcher) { double(:fetcher) }

    before do
      expect(described_class)
        .to receive(:build_fetcher).with(:my_find_by_entity, conditions).and_return(fetcher)
    end

    subject { klass.find_by(conditions) }

    it { is_expected.to be fetcher }
  end
end
