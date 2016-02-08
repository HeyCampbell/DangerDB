# A simple implementation of basic db operations to be held in memory.

class DangerDatabase

  def initialize
    @working_row_stack = []
    @commited_row = {}
  end

  def active_row
    @working_row_stack[0] || @commited_row
  end

  def current_working_row
    row = @working_row_stack.reverse.reduce({}, :merge)
    @commited_row.merge(row)
  end

  def set(args)
    self.active_row[args[0]] = args[1]
  end

  def unset(key)
    self.active_row.delete(key[0])
  end

  def get(key)
    puts self.current_working_row[key[0]] || 'NULL'
  end

  def numequalto(value)
    puts self.active_row.count {|k,v| v[0]==value[0]}
  end

  def begin args=nil
    @working_row_stack.unshift(Marshal.load(Marshal.dump(self.active_row)))
  end

  def rollback args=nil
    transaction = @working_row_stack.shift
    if transaction.nil?
      puts 'NO TRANSACTION'
    end
  end

  def commit args=nil

    if @working_row_stack.empty?
      puts 'NO TRANSACTION'
    else
      @commited_row = (Marshal.load(Marshal.dump(self.current_working_row)))
    end
    @working_row_stack = []
  end

  def end args=nil
    @accepting_input = false
    exit
  end

  def process_command(command_input)
    args = command_input.split(' ')
    command = args.shift.downcase
    begin
      self.send(command, args)
    rescue NameError
      puts "Invalid Command"
    end
  end

  def interactive_mode
    @accepting_input = true
    puts 'Danger DataBase Management System'
    puts 'Slightly more robust than > /dev/null'
    until @accepting_input == false
      print "Command: "
      command_input = gets.chomp
      process_command(command_input)
    end
  end

  def file_input_mode
    ARGF.readlines.each {|command_input| self.process_command(command_input)}
    if ARGF.eof?
      self.end
    end
  end
end

database = DangerDatabase.new
if ARGV.empty?
  database.interactive_mode
else
  database.file_input_mode
end


