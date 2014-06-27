require 'rspec/rspec_gateway'
require 'stringio'

describe RSpecGateway do
  describe '#context_sizes' do
    context 'given no contexts' do
      let(:empty_io) { StringIO.new '' }
      let(:blank_io) { StringIO.new "\n\n\n" }
      it 'returns []' do
        expect(context_sizes empty_io).to eql []
        expect(context_sizes blank_io).to eql []
      end
    end

    context 'given a context without any tests' do
      let(:empty) { make_io("context 'empty' do",
                            "end")}
      let(:no_tests) { make_io("context 'no tests' do",
                               "  let(:unused) { 42 }",
                               "end")}
      let(:it_prefix) { make_io("context 'deceptive it' do",
                                "  it_is_not_a_test",
                                "end")}
      let(:it_suffix) { make_io("context 'deceptive it' do",
                                "  do_it",
                                "end")}
      it 'does not return an entry for the context' do
        expect(context_sizes empty).to eql []
        expect(context_sizes no_tests).to eql []
        expect(context_sizes it_prefix).to eql []
        expect(context_sizes it_suffix).to eql []
      end
    end

    context 'given no setup code' do
      let(:empty_setup) { make_io("context 'no setup' do",
                                  "  it { should be_empty }",
                                  "end")}
      let(:blank_setup) { make_io("context 'blank setup' do",
                                  "",
                                  "    ",
                                  "\t\t",
                                  "  it { should be_empty }",
                                  "end")}
      it 'returns 0' do
        expect(context_sizes empty_setup).to eql [0]
        expect(context_sizes blank_setup).to eql [0]
      end
    end

    context 'given a context or describe block with 1 or more tests' do
      let(:context_block) { make_io("context 'here' do",
                                    "  let(:useful) { 42 }",
                                    "  it 'should do something'",
                                    "end")}
      let(:describe_block) { make_io("describe Something do",
                                     "  let(:useful) { 42 }",
                                     "  it 'should do something'",
                                     "end")}
      let(:indented_block) { make_io("  context 'here' do",
                                     "    let(:useful) { 42 }",
                                     "    it 'should do something'",
                                     "  end")}
      it 'returns the number of new setup lines between the context and the first test' do
        expect(context_sizes context_block).to eql [1]
        expect(context_sizes describe_block).to eql [1]
        expect(context_sizes indented_block).to eql [1]
      end
    end

    context 'given a test with an its clause' do
      let(:io) { make_io("context 'a context' do",
                         "  its '#field has some value'",
                         "end")}
      it 'returns the number of lines of setup that occurred before this it clause' do
        expect(context_sizes io).to eql [0]
      end
    end

    context 'given a context with 2 or more tests' do
      let(:multiple_tests) { make_io("context 'multiple tests' do",
                                     "  it { should be_empty }",
                                     "  it { should eql('') }",
                                     "end")}
      it 'only returns the number of lines of setup code before the first test' do
        expect(context_sizes multiple_tests).to eql [0]
      end
    end

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
