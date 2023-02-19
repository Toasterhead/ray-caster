--Observer Class

Observer={}
Observer.__index=Observer
function Observer:new(x,y,direction,span)
  local span=span or FULL_ROTATION/6
  return setmetatable(
    {
      Position=Vector:new(x,y),
      Direction=direction or 0,
      Span=span,
      Interval=span/viewport.width
    },self)
end

function Observer:move(magnitude,strafe)
	local direction=self.Direction
	if strafe and strafe==-1 or strafe==1 then
		direction=coterminal(self.Direction+(strafe*0.5*math.pi))
	end
	self.Position=self.Position:add(vector_from(direction,magnitude))
end

function Observer:turn(angle) self.Direction=coterminal(self.Direction+angle) end

function Observer:get_ray_vectors()
  rays={}
  leftEdge=coterminal(self.Direction-(0.5*self.Span))
  for i=1,viewport.width do
    angle=coterminal(leftEdge+((i-1)*self.Interval))
    rays[i]=vector_from(angle,CELL_SIZE)
  end
  return rays
end