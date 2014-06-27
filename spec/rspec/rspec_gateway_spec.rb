require 'rspec/rspec_gateway'
require 'stringio'

describe RSpecGateway do
  describe '#context_sizes' do
    shared_examples :context_sizes do |behavior, expected_sizes, *source_lines|
      let(:io) { make_io source_lines }
      it "#{behavior}" do
        puts "source_lines: #{source_lines}"
        expect(context_sizes io).to eql(expected_sizes)
      end
    end

    shared_examples :finishes do |expected_sizes, *source_lines|
      let(:io) { make_io source_lines }
      it 'returns the size of each context containing 1 or more tests' do
        expect(context_sizes io).to eql(expected_sizes)
      end
    end

    shared_examples :context_doppelganger do |doppelganger_name|
      include_examples :context_sizes, "ignores evil #{doppelganger_name} doppelgangers", [], <<END
#{doppelganger_name} 'not a valid context' do
  it { should_not fool_you_into_thinking_this_is_a_test }
end
END
    end

    context 'given no lines' do
      include_examples :context_sizes, 'returns []', []
    end

    context 'given blank lines' do
      include_examples :context_sizes, 'returns []', [], "", " ", "\t"
    end

    context 'when looking for a new context' do
      context 'given no further context or description blocks' do
        include_examples :finishes, [], "require 'prod'"
        include_examples :finishes, [], "it 'has behavior with no context'"
        include_examples :finishes, [], "its 'behavior hath no context'"
      end

      include_examples :context_doppelganger, 'not_a_context'
    end

    context 'given a context block without any tests' do
      include_examples :context_sizes, 'skips the context', [], "context 'empty one liner' {}"
      include_examples :context_sizes, 'skips the context', [],<<END
context 'empty' do
end
END

      include_examples :context_sizes, 'skips the context', [],<<END
context 'empty' do
  not_an_it something: 'else'
end
END
    end

    context 'given a context with 1 or more tests' do
      include_examples :context_sizes, 'returns the number of lines between the start of the context and the start of the test', [0], <<END
context 'one test' do
  it { should be_empty }
end
END

      include_examples :context_sizes, 'recognizes RSpec3 its clauses', [0], <<END
context 'RSpec3 its clause' do
  its(:field) { should be_awesome }
end
END
    end

#    context 'given a context without any tests' do
#      let(:empty) { make_io("context 'empty' do",
#                            "end")}
#      let(:no_tests) { make_io("context 'no tests' do",
#                               "  let(:unused) { 42 }",
#                               "end")}
#      let(:it_prefix) { make_io("context 'deceptive it' do",
#                                "  it_is_not_a_test",
#                                "end")}
#      let(:it_suffix) { make_io("context 'deceptive it' do",
#                                "  do_it",
#                                "end")}
#      it 'does not return an entry for the context' do
#        expect(context_sizes empty).to eql []
#        expect(context_sizes no_tests).to eql []
#        expect(context_sizes it_prefix).to eql []
#        expect(context_sizes it_suffix).to eql []
#      end
#    end
#
#    context 'given no setup code' do
#      let(:empty_setup) { make_io("context 'no setup' do",
#                                  "  it { should be_empty }",
#                                  "end")}
#      let(:blank_setup) { make_io("context 'blank setup' do",
#                                  "",
#                                  "    ",
#                                  "\t\t",
#                                  "  it { should be_empty }",
#                                  "end")}
#      it 'returns 0' do
#        expect(context_sizes empty_setup).to eql [0]
#        expect(context_sizes blank_setup).to eql [0]
#      end
#    end
#
#    context 'given a context or describe block with 1 or more tests' do
#      let(:context_block) { make_io("context 'here' do",
#                                    "  let(:useful) { 42 }",
#                                    "  it 'should do something'",
#                                    "end")}
#      let(:describe_block) { make_io("describe Something do",
#                                     "  let(:useful) { 42 }",
#                                     "  it 'should do something'",
#                                     "end")}
#      let(:indented_block) { make_io("  context 'here' do",
#                                     "    let(:useful) { 42 }",
#                                     "    it 'should do something'",
#                                     "  end")}
#      it 'returns the number of new setup lines between the context and the first test' do
#        expect(context_sizes context_block).to eql [1]
#        expect(context_sizes describe_block).to eql [1]
#        expect(context_sizes indented_block).to eql [1]
#      end
#    end
#
#    context 'given a test with an its clause' do
#      let(:io) { make_io("context 'a context' do",
#                         "  its '#field has some value'",
#                         "end")}
#      it 'returns the number of lines of setup that occurred before this it clause' do
#        expect(context_sizes io).to eql [0]
#      end
#    end
#
#    context 'given a context with 2 or more tests' do
#      let(:multiple_tests) { make_io("context 'multiple tests' do",
#                                     "  it { should be_empty }",
#                                     "  it { should eql('') }",
#                                     "end")}
#      it 'only returns the number of lines of setup code before the first test' do
#        expect(context_sizes multiple_tests).to eql [0]
#      end
#    end
#
#    context 'given multiple contexts' do
#      let(:multiple_contexts) { make_io("context 'one' do",
#                                        "  it 'does something'",
#                                        "end",
#                                        "context 'two' do",
#                                        "  let(:data) { :available }",
#                                        "  it 'does something else'",
#                                        "end")}
#      it 'returns an entry for each context that has 1 or more tests' do
#        expect(context_sizes multiple_contexts).to eql [0, 1]
#      end
#    end

#    context 'given a context with tests at multiple levels of nesting' do
#      let(:io) { make_io("context 'parent' do",
#                         "  let(:generic) { 42 }",
#                         "  it { should do_something }",
#                         "  context 'child' do",
#                         "    let(:specific_a) { 43 }",
#                         "    let(:specific_b) { 44 }",
#                         "    it { should do_something_else }",
#                         "  end",
#                         "end")}
#      it 'returns the number of new setup lines that occur before each new series of tests' do
#        expect(context_sizes io).to eql [1, 2]
#      end
#      it 'the sum of all returned context sizes is the total number of lines of context setup' do
#        sizes = context_sizes io
#        expect(sizes.sum).to eql(3)
#      end
#    end

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
