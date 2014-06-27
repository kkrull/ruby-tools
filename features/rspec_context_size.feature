Feature: RSpec context size
  In order to make informed decisions about test code
  As a programmer with a bunch of RSpec files
  I want to know how many lines of code are spent in setting up tests

  Scenario: No arguments given
    When I run `rspec-utils`
    Then the exit status should not be 0
    And the output should contain:
    """
    Usage: rspec-utils context-loc <xyz_spec.rb> ...
    """

  Scenario: Invalid option given
    When I run `rspec-utils --bogus`
    Then the exit status should not be 0
    And the output should contain:
    """
    Invalid option: --bogus
    """

  Scenario: No files given
    When I run `rspec-utils context-loc`
    Then the exit status should not be 0
    And the output should contain:
    """
    Usage: rspec-utils context-loc <xyz_spec.rb> ...
    """

  Scenario: Empty file
    Given an empty file named "empty_spec.rb"
    When I run `rspec-utils context-loc empty_spec.rb`
    Then the exit status should be 0
    And the stdout should not contain anything
    And the stderr should not contain anything

  Scenario: RSpec file
    Given a file named "one_test_spec.rb" with:
    """
    require 'production'
    describe Widget do
      describe '#foo' do
        subject { Widget.new }
        let(:useful) { 42 }
        it 'returns the only useful value' do
          expect(subject.foo).to be(42)
        end
      end
    end
    """
    When I run `rspec-utils context-loc one_test_spec.rb`
    Then the exit status should be 0
    And the stdout should contain:
    """
    2
    """
    And the stderr should not contain anything
