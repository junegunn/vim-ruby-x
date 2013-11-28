vim-ruby-x
==========

`:RubyX` command extends Ruby interface of Vim, making it (marginally) easier to use.

### Easier variable access

- `VIM[]`
- `VIM[]=`
- `VIM.exists?(varname)`
- `VIM.fetch(varname, default)`
- `VIM.unlet(*varnames)`

```ruby
var1 = VIM['g:var1']
var2 = VIM.fetch 'g:var2', 0

VIM['g:vars'] = { :vars => [var1, var2], :sum => var1 + var2 }

VIM.unlet 'g:var1', 'g:var2'
```

### Shortcuts to VIM::command and VIM::evaluate

- `String#vim!`
- `String#vim?`

```ruby
'redraw!'.vim!
count = 'len(g:array)'.vim?
```

### Vimscript representation of Ruby values

- `Object#to_v`

```ruby
'hello world'.to_v
  # "hello world"

[1, 2, 3, %w[hello world], { 'hello' => { 'world' => '!' } }].to_v
  # [1, 2, 3, ["hello", "world"], {"hello": {"world": "!"}}]
```

### Calling Vim functions

- `VIM.call(name, *args)`

```ruby
VIM.call(:feedkeys, "\C-c")
```

### Making Ruby code interruptible with CTRL-C

```ruby
VIM.interruptible do
  begin
    sleep
  rescue Interrupt
    puts 'Interrupted!'
  end
end
```

