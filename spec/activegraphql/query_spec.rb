describe ActiveGraphQL::Query do
  let(:query) do
    described_class.new(config: config,
                        action: action,
                        params: params)
  end

  let(:config) do
    { url: url }
  end

  let(:url) { 'some-url' }
  let(:action) { :some_long_action_name }
  let(:params) do
    { some_long_param_name1: 'value1',
      some_long_param_name2: 'value2' }
  end

  let(:graph) do
    [:attr1,
     { object: [:nested_attr, nested_object: [:super_nested_attr]] },
     :attr2]
  end

  let(:expected_query_with_params) do
    '{ someLongActionName'\
    '(someLongParamName1: "value1", someLongParamName2: "value2") { ' \
    'attr1, object { nestedAttr, nestedObject { superNestedAttr } }, attr2 }' \
    ' }'
  end

  let(:expected_query_without_params) do
    '{ someLongActionName { ' \
    'attr1, object { nestedAttr, nestedObject { superNestedAttr } }, attr2 }' \
    ' }'
  end
  let(:variables_hash) { { skip: 20, limit: 10 } }

  describe '#get' do
    let(:response) do
      { 'data' => { 'someLongActionName' => { 'someExpected' => 'data' } } }
    end

    before do
      expect(HTTParty)
        .to receive(:get).with(url, expected_request_options).and_return(response)
    end

    subject { query.get(*graph) }

    context 'with timeout configured' do
      let(:expected_request_options) do
        { query: { query: expected_query_with_params }, timeout: 0.1 }
      end

      let(:config) do
        { url: url,
          http: { timeout: 0.1 } }
      end

      it { is_expected.to eq(some_expected: 'data') }
    end

    context 'without timeout configured' do
      let(:expected_request_options) do
        { query: { query: expected_query_with_params } }
      end

      context 'with no errors in the response' do
        it { is_expected.to eq(some_expected: 'data') }

        context 'with locale' do
          let(:locale) { :en }

          let(:expected_request_options) do
            { headers: { 'Accept-Language' => locale.to_s },
              query: { query: expected_query_with_params } }
          end

          before { query.locale = locale }

          it { is_expected.to eq(some_expected: 'data') }
        end

        context 'with variables' do
          let(:expected_request_options) do
            {
              query: {
                query: expected_query_with_params,
                variables: variables_hash
              }
            }
          end

          before { query.variables = variables_hash }

          it { is_expected.to eq(some_expected: 'data') }
        end
      end

      context 'with errors in the response' do
        let(:response) do
          {
            'errors' => [
              { 'message' => 'message1' },
              { 'message' => 'message2' }
            ]
          }
        end

        it 'fails with an error' do
          expect { subject }.to raise_error(ActiveGraphQL::Query::ServerError,
                                            /"message1", "message2"/)
        end
      end
    end

    context 'with bearer auth strategy configured' do
      let(:token) { 'some.token' }

      let(:expected_request_options) do
        { query: { query: expected_query_with_params },
          headers: { 'Authorization' => "Bearer #{token}" } }
      end

      let(:config) do
        { url: url,
          auth: { strategy: :bearer, class: Object } }
      end

      before do
        expect(Object).to receive(:encode).and_return(token)
      end

      it { is_expected.to eq(some_expected: 'data') }
    end
  end

  describe '#to_s' do
    subject do
      query.tap { |q| q.graph = graph }.to_s
    end

    context 'without params' do
      let(:params) { nil }

      it { is_expected.to eq expected_query_without_params }
    end

    context 'with params' do
      it { is_expected.to eq expected_query_with_params }
    end
  end

  describe '#qaction' do
    subject { query.qaction }

    it { is_expected.to eq 'someLongActionName' }
  end

  describe 'qparams' do
    subject { query.qparams }

    context 'without params' do
      let(:params) { nil }

      it { is_expected.to be_nil }
    end

    context 'with string params' do
      it { is_expected.to eq "someLongParamName1: \"value1\", someLongParamName2: \"value2\"" }
    end

    context 'with array param' do
      let(:params) { { array_param: ['foo', 'bar'] } }

      it { is_expected.to eq 'arrayParam: ["foo", "bar"]' }
    end

    context 'with boolean params' do
      let(:params) { { true_param: true, false_param: false } }

      it { is_expected.to eq 'trueParam: true, falseParam: false' }
    end

    context 'with integer param' do
      let(:params) { { int_param: 42 } }

      it { is_expected.to eq 'intParam: 42' }
    end
  end

  describe '#qgraph' do
    subject { query.qgraph(graph) }

    it { is_expected.to eq 'attr1, object { nestedAttr, nestedObject { superNestedAttr } }, attr2' }
  end

  describe '#merge_variables' do
    subject { query.merge_variables(variables_hash) }

    context 'when there are no variables before' do
      it do
        subject
        expect(query.variables).to eq(variables_hash)
      end
    end

    context 'when there are some variables' do
      let(:other_variables) { { withFriends: true } }

      before do
        query.variables = other_variables
      end

      it do
        subject
        expect(query.variables).to include(variables_hash, other_variables)
      end
    end
  end
end
