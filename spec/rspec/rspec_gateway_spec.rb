require 'rspec/rspec_gateway'
require 'stringio'

describe RSpecGateway do
  describe '#context_sizes' do
    shared_examples :context_sizes do |behavior, expected_sizes, source_lines|
      let(:io) { make_io source_lines }
      it "#{behavior}" do
        #puts "\n#{source_lines}"
        expect(context_sizes io).to eql(expected_sizes)
      end
    end

    context 'given no lines' do
      include_examples :context_sizes, 'returns []', [], ""
    end

    context 'given blank lines' do
      include_examples :context_sizes, 'returns []', [], "\n \n\t\n"
    end

    context 'when looking for a new context' do
      shared_examples :finishes do |expected_sizes, source_lines|
        include_examples(:context_sizes,
          'returns the size of each context containing 1 or more tests', 
          expected_sizes,
          source_lines
        )
      end

      shared_examples :context_doppelganger do |doppelganger_name|
        include_examples :context_sizes, "ignores evil #{doppelganger_name} doppelgangers", [], <<END
#{doppelganger_name} 'not a context' do
  it { should_not fool_you_into_thinking_this_is_a_test }
end
END
      end

      context 'given no further context or description blocks' do
        it_behaves_like :finishes, [], "require 'awesome_production_code'"
        it_behaves_like :finishes, [], "it 'has behavior with no context'"
        it_behaves_like :finishes, [], "its 'behavior hath no context'"
        it_behaves_like :context_doppelganger, 'not_a_context'
        it_behaves_like :context_doppelganger, 'not_a_describe'
        it_behaves_like :context_doppelganger, 'context_you_must_be_joking?'
        it_behaves_like :context_doppelganger, 'describe_you_must_be_joking?'
      end
    end

    context 'given a context block without any tests' do
      shared_examples :skips_a_context do |what_context, source_lines|
        include_examples :context_sizes, "skips a #{what_context}", [], source_lines 
      end

      it_behaves_like :skips_a_context, 'empty one liner context', "context 'empty one liner' {}"
      it_behaves_like :skips_a_context, 'empty context block', [], <<END
context 'empty block' do
end
END

      it_behaves_like :skips_a_context, 'context that has no tests in it', [], <<END
context 'with doppelgangers' do
  not_an_it
  it_is_not_a_test
end
END
    end

    context 'given a context with 1 or more tests' do
      shared_examples :recognizes_context_named do |context_name|
        include_examples(:context_sizes,
          "returns the number of lines between `#{context_name}' and the start of the test", [1], <<END
#{context_name} 'with tests' do
  let(:expected_answer) { 42 }
  it { should do_something_cool }
end
END
        )
      end

      shared_examples :ignores_setup do |ignores_what, setup_lines|
        include_examples(:context_sizes, "ignores #{ignores_what}", [0], <<END
context 'bafflegab' do
#{setup_lines}
it { should behave }
end
END
        )
      end

      it_behaves_like :recognizes_context_named, 'context'
      it_behaves_like :recognizes_context_named, '  context'
      it_behaves_like :recognizes_context_named, 'describe'
      it_behaves_like :recognizes_context_named, '  describe'
      it_behaves_like :ignores_setup, 'empty setup lines', ""
      it_behaves_like :ignores_setup, 'empty setup lines', "context 'another context' do"
      it_behaves_like :ignores_setup, 'empty setup lines', "describe 'another describe' do"

      it_behaves_like :context_sizes, 'recognizes RSpec3 its clauses', [0], <<END
context 'RSpec3 its clause' do
  its(:field) { should be_awesome }
end
END

      it_behaves_like :context_sizes, 'does not count setup for a second test in the same context', [0], <<END
context 'multiple tests' do
  its(:field) { should be_awesome }
  its(:other_field) { should_not be_as_awesome }
end
END
    end

    def make_io(*lines)
      joined = lines.join "\n"
      StringIO.new joined
    end

    def context_sizes(io)
      gateway = RSpecGateway.new io
      gateway.context_sizes
    end
  end
end
