---
project: pp
tagline: table serialization
---

## `local pp = require'pp'`

Fast, compact serialization producing portable Lua source code.

Can serialize all Lua types except coroutines, userdata, cdata and C functions.

Any type featuring the `__pwrite` metamethod can also be serialized.


## Output characteristics

  * **compact**: no spaces, dot notation for identifier keys, minimal quoting of strings, implicit keys for the array part of tables.
  * **portable** between LuaJIT 2, Lua 5.1, Lua 5.2: dot key notation only for ascii identifiers, numbers are in decimal.
  * **portable** between Windows, Linux, Mac: quoting of \n and \r protects binary integrity when opening in text mode.
  * **embeddable**: can be copy-pasted into Lua source code: quoting of \0 and \t protects binary integrity with code editors.
  * **human readable**: indentation (optional, configurable); array part printed separately with implicit keys.
  * **stream-based**: the string bits are written with a writer function to minimize the amount of string concatenation and memory footprint.


## Limitations

  * non-deterministic output: table keys are not sorted.
  * recursive: stack-bound on depth.
  * some fractions are not compact eg. the fraction 5/6 takes 19 bytes vs 8 bytes native.
  * strings need escaping which could become noticeable with large strings featuring many newlines, tabs, zero bytes, apostrophes, backslashes or control characters.
  * table references are dereferenced without warning thus object identity is not tracked and is not preserved.
  * loading back the output with the Lua interpreter is not safe and can DoS Lua with infinite loops or infinite heap allocations, even when the loading environment itself is clean.


## `pp.pp(v1,...)`

Pretty-print the arguments to standard output. Cycle detection and indentation are enabled and unserializable values get a comment in place.


## `pp.pwrite(v,write[,indent][,parents][,quote][,onerror])`

Pretty-print a value using a supplied write function that takes a string. The other arguments are:

  * `indent` - enable indentation eg. `'\t'` indents by one tab (default is compact output with no whitespace)
  * `parents` - enable cycle detection eg. `{}`
  * `quote` - change string quoting eg. `'"'` (default is "'")
  * `onerror` - enable error handling eg. `function(err_type, v, depth) error(err_type..': '..tostring(v)) end`

Note: wrapping `to_sink` into a coroutine with `coroutine.wrap` and passing `coroutine.yield` as the write function
turns the serialization process into an iterator.


## `pp.fwrite(file,v[,indent][,parents][,quote][,onerror])`

Pretty-print a value to a file.


## `pp.pformat(v[,indent][,parents][,quote][,onerror]) -> s`

Pretty-print a value to a string.
