--Vector Class

Vector={}
Vector.__index=Vector
function Vector:new(x,y) return setmetatable({x=x or 0,y=y or 0},self) end

function Vector:magnitude() return math.sqrt(self.x^2+self.y^2) end

function Vector:normalize() return self:scale(1/self:magnitude()) end

function Vector:add(other) return Vector:new(self.x+other.x,self.y+other.y) end

function Vector:scale(scalar) return Vector:new(scalar*self.x,scalar*self.y) end

function Vector:angle()
	local theta=math.atan(self.y/self.x)
	if self.x<0 then theta=math.pi+theta end
	return theta%(2*math.pi)
end