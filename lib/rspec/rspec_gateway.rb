class RSpecGateway
  def context_sizes(path)
  end
end



#def process_path(path)
#  puts "#{path}"
#  File.open(path) do |file|
#    context_sizes = read_context_sizes file
#    context_sizes.each { |x| puts "- #{x.inspect}" }
#  end
#end
#
#def read_context_sizes(file)
#  no_context file
#end
#
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
#
#ARGV.each { |path| process_path(path) }