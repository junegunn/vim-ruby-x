let s:extended = 0

function! s:extend_ruby()
  if s:extended
    return
  endif

  let s:extended = 1
ruby << RB

# Monkey-patching core classes, yay!
class String
  # Shortcut for VIM::command(command)
  # @return [nil]
  def vim!
    VIM::command self
  end

  # Shortcut for VIM::evaluate(command)
  # @return [Object]
  def vim?
    VIM::evaluate self
  end
end

class Object
  # Translates Ruby data structure into Vimscript string representation
  # FIXME: ugly
  # @return [String]
  def to_v
    case self
    when Symbol
      to_s.inspect
    when String
      inspect
    when Array
      '[' << map { |e| e.to_v }.join(', ') << ']'
    when Hash
      '{' << map { |k, v| [k.to_v, v.to_v].join ': ' }.join(', ') << '}'
    when Range
      if self.begin.is_a?(Integer) && self.end.is_a?(Integer) && self.end > self.begin
        "range(#{self.begin}, #{self.end - (exclude_end? ? 1 : 0)})"
      else
        to_a.to_v
      end
    when true
      1
    when false
      0
    else
      to_s
    end
  end
end

module VIM
class << self
  # Returns the value of the variable of the given name
  # @param [#to_s] varname
  def [] varname
    varname = varname.to_s
    exists?(varname) ? evaluate(varname) : nil
  end

  # Updates the variable of the given name
  # @param [#to_s] varname
  # @param [Object] value
  def []= varname, value
    command "let #{varname} = #{value.to_v}"
  end
  alias let []=

  # Unsets the variable
  # @param [#to_s] varname
  def unlet *varnames
    command "unlet! #{varnames.join ' '}"
  end

  # Returns the value of the variable of the given name.
  # If the variable does not exist, returns the default value given
  # @param [#to_s] varname
  # @param [Object] default
  def fetch varname, default
    if exists? varname
      evaluate varname
    else
      default
    end
  end

  # Checks if the variable of the given name exists
  # @param [#to_s] varname
  def exists? varname
    call(:exists, varname) == 1
  end

  # Calls Vim function with the given arguments
  # @param [#to_s] func
  def call func, *args
    evaluate "#{func}(#{args.map { |a| a.to_v }.join ', '})"
  end

  # Executes the given block while allowing it to be interruptible with CTRL-C
  # @param [Numeric] interval
  def interruptible interval = 0.1
    main    = Thread.current
    watcher = Thread.new {
      sleep interval while evaluate 'getchar(1)'
      main.raise Interrupt
    }
    begin
      yield
    ensure
      watcher.kill
    end
  end
end
end
RB
endfunction

command! RubyX call s:extend_ruby()
