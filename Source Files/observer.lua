Observer={}
Observer.__index=Observer
function Observer:new(x,y,direction,span,bob)
  
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
  
  return setmetatable({
			Position=Vector:new(x,y),
			Velocity=Vector:new(0,0),
			Direction=direction or 0,
			Span=span,
			RayAngles=rayAngles,
			BobPattern=bob or {},
			BobIndex=0,
			MovementFlag=false,
			TurnSpeed=0.035,
			fullSpeed=0.1,
			fullTurnSpeed=0.035,
			acceleration=0.01},self)
end

function Observer:move_forward() self:move(self.acceleration) end

function Observer:move_backward() self:move(-self.acceleration) end

function Observer:strafe_left() self:move(self.acceleration,-1) end

function Observer:strafe_right() self:move(self.acceleration,1) end

function Observer:neutralize()
	local speed=self.Velocity:magnitude()-self.acceleration
	if speed<=0 then
		self.Velocity=Vector:new()
	else self.Velocity=self.Velocity:normalize():scale(speed) end
end

function Observer:move(magnitude,strafe)
	local direction=self.Direction
	if strafe and strafe==-1 or strafe==1 then
		direction=coterminal(self.Direction+(strafe*0.5*math.pi))
	end
	self.Velocity=self.Velocity:add(vector_from(direction,magnitude))
	if self.Velocity:magnitude()>self.fullSpeed then
		self.Velocity=self.Velocity:normalize():scale(self.fullSpeed)
	end
	self.MovementFlag=true
end

function Observer:turn(angle) self.Direction=coterminal(self.Direction+angle) end

function Observer:update_bob()
	if self.MovementFlag==true then
		self.BobIndex=(self.BobIndex+(self.Velocity:magnitude()/self.fullSpeed))%#self.BobPattern
	elseif self.BobIndex~=0 then
		self.BobIndex=math.floor(self.BobIndex+1)%#self.BobPattern
	end
end

function Observer:get_bob_offset()
	local bobPattern=self.BobPattern[math.floor(self.BobIndex)+1]
	return (self.Velocity:magnitude()/self.fullSpeed)*bobPattern
end

function Observer:get_ray_vectors()
  rays={}
  for i=1,#self.RayAngles do rays[i]=vector_from(self.Direction+self.RayAngles[i],CELL_SIZE) end
  return rays
end

function Observer:update()
	self:update_bob()	
	if self.MovementFlag==false then self:neutralize() end
	self.MovementFlag=false
	self.Position=self.Position:add(self.Velocity)
end