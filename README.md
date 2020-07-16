# Po'Pro: The Poor-Man's Progress Indicator

[![Version](https://badge.fury.io/rb/popro.svg)](https://badge.fury.io/rb/popro) 
[![Tests](https://github.com/MikeSmithEU/PoPro/workflows/Code%20quality%20&%20unit%20tests/badge.svg)](https://github.com/MikeSmithEU/PoPro/actions?query=workflow%3A%22Code+quality+%26+unit+tests%22)

## Current TODOs

 - [ ] properly update documentation
 - [ ] simplify some stuff (each0?)
 - [ ] 100% code coverage

## Why?

Easier and cleaner progress indication.

## How?

### Basic usage

The invocation `Popro#did(yielded)` is used to signify that one step in progress has been finished.

1. Create a `Progress` object
   ```ruby
   progress = Popro.new(500)
   ```

2. Use the progress indicator
  ```ruby
  (0..499).each { progress.did }
  ```

  Will result in a default progress outputted to STDOUT, e.g.

  ```bash
  irb> (0..499).each { |n| sleep(0.1) & "Just did #{n}" }
  [221/500] 44.2% Just did 220
  ```

  Note, `Popro#did` can be passed as a `Proc` using the shortcut `&progress`.
  So below code would be equivalent and slightly more concise:

  ```ruby
  (0.499).each &progress
  ```

Block notation is usually preferable (cleaner) to using the `Progress` instance directly (see below).
The functionality is the same though.

### Using block context

`Popro.new` can be called with a block. This block will then be executed after `Progress` has initialized
and will receive a `Context` instance as the first parameter.  On this instance you can call e.g.
`each`, `did`, `will` and `formatter`.

E.g.

```ruby
Popro.new(500) do |p|
  (1..500).each &p
end
```

or

```ruby
Popro.new do |progress|
  progress.each(1..500)
end
```

### Using `Proc` shortcut notation

`&Popro.new`  can be used for a more concise syntax. This is just syntactical sugar for calling
`Popro#did` directly.

For example:

```ruby
def job(size=100)
  (1..size).each do
    sleep 0.01
    yield
  end
end

# Below invocations are all equivalent.

puts "\n job(&progress)"
progress = Popro.new(100)
job(&progress)

puts "\n job { progress.did }"
progress = Popro.new(100)
job { progress.did }

puts "\n using Popro.new(100)"

# below code is a more concise equivalent to:
#   `progress = Popro.new(100); job &progress`
# or
#   `progress = Popro.new(100); job { |*args| progress.did(*args) }`

job(&Popro.new(100))
```

### Using each notation

`Popro.each` or `Popro#each` can be used to loop over enumerables while providing progress
feedback.

`Popro.each(enumerable, size=nil)` will use `enumerable.size` to determine the total amount of elements
only if the `size` argument is `nil`.
If this method is not available you should manually provide a `size` argument, i.e.  `Popro.each(enumerable, 50)`.

Shortcut methods `Popro.each0(enumerable)` and `Popro#each0(enumerable)` are available for enumerables
that are used if you do not want to update the total with `enumerable.size`.
I.e. this is equivalent to `Popro.each(enumerable, 0)` and `Popro#each(enumerable, 0)` respectively.

E.g. below are all equivalent.

```ruby
sleeper = proc { sleep 0.05 }

Popro.each(1..50) { sleep 0.05 }
Popro.new.each(1..50, 50) { sleep 0.05 }
Popro.new(50).each(1..50, 0) { sleep 0.05 }
Popro.new(50).each0(1..50) { sleep 0.05 }

Popro.each(1..50, &sleeper)
Popro.new(50).each(1..50, 0, &sleeper)
Popro.new(50).each0(1..50, &sleeper)

Popro.each(1..50, 50, &sleeper)
Popro.new.each(1..50, 50, &sleeper)
```

It is easy to chain multiple items, the total will be updated at the start of each `each` block. It
might be preferable to provide a total sum in advance, and passing a `size` argument of `0` to
`Popro#each` (or using `Popro#each0`), e.g.

```ruby

Popro.new(200)
  .each0(1..50) { |n| sleep(0.1) && "#{n} of first 50" }
  .each0(1..100) { |n| sleep(0.1) && "#{n} of second 100" }
  .each0(1..50) { |n| sleep(0.1) && "#{n} of last 50" }

```

Or, using a block:

```ruby

Popro.new(200) do |p|
  p.each0(1..50) { |n| sleep(0.1) && "#{n} of first 50" }
  p.each0(1..100) { |n| sleep(0.1) && "#{n} of second 100" }
  p.each0(1..50) { |n| sleep(0.1) && "#{n} of last 50" }
end

```

Note that when using `Popro.each(enumberable, &block)` or `Popro#each(enumerable, &block)` the arguments
passed to `block` on invocation are not the same as for `Popro.new`.

`Popro.each` invokes `enumerable.each` and the argument signature of the `Popro.each` `&block` is the
same as the signature that `enumerable.each` uses to call the block. Only the named argument `progress` is
added (as opposed to being the first argument as for `Popro.new`).

E.g.

```ruby

Popro.each(1..100) do |number, progress:|
  progress.will "count sheep ##{number} and sleep for a bit" do
    sleep 0.1
  end
end

```

would be equivalent to:

```ruby

Popro.new(100) do |p|
  p.each(1..100) do |number, progress:|
    # note, `p == progress`, only added `progress:` to `each` call for example purposes
    p.will "count sheep ##{number} and sleep for a bit" do
      sleep 0.1
    end
  end
end

```

### Using `Popro#will`

The helper `Popro#will(message, &block)` can be used to signify intention. When given a block, it will mark
this intention as done when the block has finished (using a call to `Popro#did`). If no block is passed,
`Popro#did` needs to be invoked manually once the intention has been fulfilled.

This method sends the `message` passed to `Popro#will` to the `Indicator` so it can handle it (usually output to
screen).

Thus `Popro#will` can be used to signify the action about to take place instead of the action that has just finished.
If the script encounters some kind of error, we can now see in which context this error occured instead of seeing
the last invocation that did not cause an error.

E.g.

```ruby
Popro.each(1..200) do |progress:|
  progress.will "sleep a bit" do
    sleep 0.1
  end
end

# equivalent to

Popro.new(200) do |p|
  200.times do
    p.will "sleep a bit" do
      sleep 0.01
    end
  end
end

# equivalent to

Popro.new(200) do |p|
  200.times do
    p.will "sleep a bit"
    sleep 0.01
    p.done "sleep a bit: DONE"
  end
end
```

### Using `Popro.each_will`

`Popro.each_will(enumerator, titler, size = nil, &block)` is a shortcut for:

```ruby
Popro.each(enumerator, size) do |*args, **kwargs, progress:|
  progress.will titler.call(*args) do
    block.call(*args, **kwargs)
  end
end
```

So instead of e.g.

```ruby
Popro.each(SomeModel.all) do |model, progress:|
  progress.will "Delete #{model.id}" do
    model.destroy
  end
end
```

A more concise syntax is available:

```ruby
titler = ->(model) { "Delete #{model.id}" }
Popro.each_will(SomeModel.all, titler) do |model|
  model.destroy
end
```

## Formatters

You can set your own formatters using `Popro#formatter(&block)`. Each formatter can be a `Proc`, `block` or
class implementing the `call` method (e.g. the `Popro::Formatter::*` classes).

The formatter will be invoked with 2 arguments:

  1. `info`, an instance of `Popro::Info` containing e.g. `current` and `total`.
  2. `yielded`, whatever was passed to the `Popro#did` method.

It can also be used inside blocks.

E.g.

```ruby

progress = Popro.new
progress.formatter do |info, yielded|
  "#{info.current}, yielded #{yielded}\n"
end
progress.each(1..8) { |i| i**2 }
progress.formatter { "." } # output a dot
progress.each(1..8) { |i| i**2 }

# or equivalent, more concise:

Popro.new do |p|
  p.formatter { |info, yielded| "#{info.current}, yielded #{yielded}\n" }
  p.each(1..8) { |i| i**2 }

  p.formatter { "." } # output a dot
  p.each(1..8) { |i| i**2 }
end

```

would output:

```
 1, yielded 1
 2, yielded 4
 3, yielded 9
 4, yielded 16
 5, yielded 25
 6, yielded 36
 7, yielded 49
 8, yielded 64
 ........
```


## Indicator Classes

Indicator classes are responsible for communicating the progress (or not, as the case may be).

It is possible to provide your own "indicators" or use one of the provided ones (see `Popro::Indicator` module).

The default `Popro::Indicator` class is `Popro::Indicator.default` (which returns an instance of `Popro::Indicator::Stream`), which outputs the progress to STDOUT each time `Popro#did` or `Popro#will` is called.

