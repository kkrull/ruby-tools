class RSpecGateway
  def initialize(io)
    @io = io
  end

  def context_sizes
    outside_context []
  end

  private
  attr_reader :io

  def outside_context(context_sizes)
    return context_sizes if io.eof?
    case io.readline
    when /^\s*context|^\s*describe/
      inside_context context_sizes, io.lineno
    else 
      outside_context context_sizes
    end
  end

  def inside_context(context_sizes, start_of_context)
    return context_sizes if io.eof?
    case io.readline
    when /^\s*its?\b/
      reached_tests(context_sizes.push (io.lineno - start_of_context - 1))
    when /^\s*$/
      inside_context context_sizes, start_of_context+1
    else
      inside_context context_sizes, start_of_context
    end
  end

  def reached_tests(context_sizes)
    return context_sizes if io.eof?
    case io.readline
    when /^\s*context|^\s*describe/
      inside_context context_sizes, io.lineno
    when /^\s*its?\b/
      reached_tests context_sizes
    end
  end
end


#def no_context(file)
#  return [] if file.eof?
#  case file.readline
#  when /^\s*context/
#    start_context file, file.lineno, []
#  when /^\s*describe/
#    start_context file, file.lineno, []
#  else
#    no_context file
#  end
#end
#
#def start_context(file, x, context_sizes)
#  raise "Context without tests starting around line #{x}" if file.eof?
#  case file.readline
#  when /^\s*it/
#    size = file.lineno - x - 1
#    start_test file, x, file.lineno, context_sizes.push(size)
#  when /^\s*context/
#    start_context file, x+1, context_sizes
#  when /^\s*describe/
#    start_context file, x+1, context_sizes
#  else
#    start_context file, x+1, context_sizes
#  end
#end
#
#def start_test(file, x, y, context_sizes)
#  if file.eof? then
#    context_sizes
#  else
#    case file.readline
#    when /^\s*context/
#      start_context file, file.lineno, context_sizes
#    when /^\s*describe/
#      start_context file, file.lineno, context_sizes
#    else
#      start_test file, x, y, context_sizes
#    end
#  end
#end
