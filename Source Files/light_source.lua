--Light Source Structure

LightSource={}
LightSource.__index=LightSource
function LightSource:new(x,y,w,h,level,range,frequency,parent)
	return setmetatable({X=x,Y=y,W=w,H=h,Level=level,Range=range,Parent=parent},self)
end