Feature: RSpec context size
  In order to make informed decisions about test code
  As a programmer with a bunch of RSpec files
  I want to know how many lines of code are spent in setting up tests

  Scenario: No arguments given
    When I run `rspec-utils`
    Then the exit status should not be 0
    And the output should contain:
    """
    Usage: rspec-utils --context-loc <xyz_spec.rb> ...
    """
