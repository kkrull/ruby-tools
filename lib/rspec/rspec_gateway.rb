class RSpecGateway
  def initialize(io)
    @io = io
  end

  def context_sizes
    looking_for_new_context []
  end

  private
  BLANK = /^\s*$/
  CONTEXT = /^\s*context\b/
  DESCRIBE = /^\s*describe\b/
  TEST = /^\s*its?\b/
  attr_reader :io

  def looking_for_new_context(context_sizes)
    return done(context_sizes) if io.eof?
    case io.readline
    when CONTEXT, DESCRIBE 
      @setup_loc = 0
      looking_for_first_test context_sizes
    else
      looking_for_new_context context_sizes
    end
  end

  def looking_for_first_test(context_sizes)
    return done(context_sizes) if io.eof?
    case io.readline
    when TEST 
      looking_for_new_context(context_sizes.push(@setup_loc))
    when BLANK, CONTEXT, DESCRIBE
      looking_for_first_test context_sizes
    else
      @setup_loc += 1
      looking_for_first_test context_sizes
    end
  end

  def done(context_sizes)
    context_sizes
  end
end
