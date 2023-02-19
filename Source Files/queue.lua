--Queue Class

Queue={}
Queue.__index=Queue
function Queue:new() return setmetatable({Values={}},self) end

function Queue:clear() self.Values={} end

function Queue:enqueue(value) self.Values[#self.Values+1]=value end

function Queue:dequeue()
	value=self.Values[1]
	for i=1,#self.Values-1 do self.Values[i]=self.Values[i+1] end
	self.Values[#self.Values]=nil
	return value
end

function Queue:queue_peek() return self.Values[1] end

function Queue:count() return #self.Values end