--fast, small recursive pretty printer with optional indentation and cycle detection
local pf = require'pformat'
local glue = require'glue'

local function pretty(v, write, indent, parents, quote, onerror, depth, wwrapper)
	if pf.is_serializable(v) then
		pf.pwrite(v, write, quote)
	elseif getmetatable(v) and getmetatable(v).__pwrite then
		wwrapper = wwrapper or function(v)
			pretty(v, write, nil, parents, quote, onerror, -1, wwrapper)
		end
		getmetatable(v).__pwrite(v, write, wwrapper)
	elseif type(v) == 'table' then
		if parents then
			if parents[v] then
				write(onerror and onerror('cycle', v, depth) or 'nil --[[cycle]]')
				return
			end
			parents[v] = true
		end
		write'{'
		local maxn = 0; while v[maxn+1] ~= nil do maxn = maxn+1 end
		local first = true
		for k,v in pairs(v) do
			if not (maxn > 0 and type(k) == 'number' and k == math.floor(k) and k >= 1 and k <= maxn) then
				if first then first = false else write',' end
				if indent then write'\n'; write(indent:rep(depth)) end
				if pf.is_identifier(k) then
					write(k); write'='
				else
					write'['; pretty(k, write, indent, parents, quote, onerror, depth + 1, wwrapper); write']='
				end
				pretty(v, write, indent, parents, quote, onerror, depth + 1, wwrapper)
			end
		end
		for k,v in ipairs(v) do
			if first then first = false else write',' end
			if indent then write'\n'; write(indent:rep(depth)) end
			pretty(v, write, indent, parents, quote, onerror, depth + 1, wwrapper)
		end
		if indent then write'\n'; write(indent:rep(depth-1)) end
		write'}'
		if parents then parents[v] = nil end
	else
		write(onerror and onerror('unserializable', v, depth) or
					string.format('nil --[[unserializable %s]]', type(v)))
	end
end

local function to_sink(v, write, indent, parents, quote, onerror)
	return pretty(v, write, indent, parents, quote, onerror, 1)
end

local function to_string(v, indent, parents, quote, onerror)
	local buf = {}
	pretty(v, function(s) buf[#buf+1] = s end, indent, parents, quote, onerror, 1)
	return table.concat(buf)
end

local function to_file(file, v, indent, parents, quote, onerror)
	local f = assert(io.open(file, 'wb'))
	f:write'return '
	pretty(v, function(s) f:write(s) end, indent, parents, quote, onerror, 1)
	f:close()
end

local function pp(...)
	local t = {}
	for i=1,select('#',...) do
		t[i] = to_string(select(i,...), '   ', {})
	end
	print(unpack(t))
	return ...
end

if not ... then require'pp_test' end

return {
	pformat = to_string,
	pwrite = to_sink,
	fwrite = to_file,
	pp = pp,
}
