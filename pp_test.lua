local pp=require'pp'
local pformat=pp.pformat

print(pformat({1,2,3,a={4,5,6,b={c={d={e={f={7,8,9}}}}}}}))
print(pformat({[{[{[{[{[{[{}]='f'}]='e'}]='d'}]='c'}]='b'}]='a',}))
print(pformat{})
print(pformat({'a','b','c','d',a=1,b={a=1,b=2}}, '   '))
local meta={}
local meta2={}
local t2=setmetatable({a=1,b='zzz'},meta2)
local t=setmetatable({a=1,b=t2},meta)
meta.__pwrite = function(v, write, write_value)
	write'tuple('; write_value(v.a); write','; write_value(v.b); write')'
end
meta2.__pwrite = function(v, write, write_value)
	write'tuple('; write_value(v.a); write','; write_value(v.b); write')'
end
print(pformat(t))
local t={a={}}; t.a=t; print(pformat(t,' ',{}))
print(pformat({a=coroutine.create(function() end)},' ',{}))
