--Observer Class

Observer={}
Observer.__index=Observer
function Observer:new(x,y,direction,span)
  
  local span=span or FULL_ROTATION/6
  span=coterminal(span)
  local rayAngles={}
  local cameraPlaneWidth=2*CELL_SIZE*math.tan(span/2)
  local cameraPlaneInterval=cameraPlaneWidth/viewport.width
  local initialPosition=-cameraPlaneWidth/2
  
  for i=1,viewport.width//2 do
  	local currentPosition=initialPosition+((i-1)*cameraPlaneInterval)
  	rayAngles[i]=math.atan2(currentPosition/CELL_SIZE)
  end
  
  if viewport.width%2==1 then rayAngles[#rayAngles+1]=0 end
  
  for i=viewport.width//2,1,-1 do
  	rayAngles[#rayAngles+1]=-rayAngles[i]
  end
  
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