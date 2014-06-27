class RSpecGateway
  def initialize(io)
    @io = io
  end

  def context_sizes
    looking_for_new_context []
  end

  private
  attr_reader :io

  def looking_for_new_context(context_sizes)
    return done(context_sizes) if io.eof?
    case io.readline
    when /^\s*context\b/, /^\s*describe\b/
      @setup_loc = 0
      looking_for_first_test context_sizes
    else
      looking_for_new_context context_sizes
    end
  end

  def looking_for_first_test(context_sizes)
    return done(context_sizes) if io.eof?
    case io.readline
    when /^\s*its?\b/
      looking_for_new_context(context_sizes.push(@setup_loc))
    when /^\s*$/, /\s*context\b/, /\s*describe\b/
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
