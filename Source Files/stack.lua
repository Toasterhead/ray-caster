--Stack Class

Stack={}
Stack.__index=Stack
function Stack:new() return setmetatable({Values={}},self) end

function Stack:clear() self.Values={} end

function Stack:push(value) self.Values[#self.Values+1]=value end

function Stack:pop()
	if #self.Values>0 then
		local value=self.Values[#self.Values]
		self.Values[#self.Values]=nil
		return value
	end
	return nil
end

function Stack:stack_peek() return self.Values[#self.Values] end

function Stack:count() return #self.Values end