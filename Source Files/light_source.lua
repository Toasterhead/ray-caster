--Light Source Structure

LightSource={}
LightSource.__index=LightSource
function LightSource:new(x,y,w,h,level,range,period,parent)
	return setmetatable({X=x,Y=y,W=w,H=h,Level=level,Range=range,Period=period,Parent=parent},self)
end