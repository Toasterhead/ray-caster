--Observer Class

Observer={}
Observer.__index=Observer
function Observer:new(x,y,direction,span)
  
  --Experiment with uneven angle distribution later.
  local span=span or FULL_ROTATION/6
  span=coterminal(span)
  local interval=span/viewport.width
  local rayAngles={}
  for i=1,viewport.width do rayAngles[i]=(-span/2)+((i-1)*interval)+(interval/i) end
  
  return setmetatable(
    {
      Position=Vector:new(x,y),
      Direction=direction or 0,
      Span=span,
      RayAngles=rayAngles
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
  for i=1,#self.RayAngles do rays[i]=vector_from(self.Direction+self.RayAngles[i],CELL_SIZE) end
  return rays
end