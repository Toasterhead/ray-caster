--Game Object Class

GameObject={}
GameObject.__index=GameObject
function GameObject:new(x,y,z,w,h,sourceWidth,sourceHeight,images,outline,delay,transparent,outline,colorMap)
	local frame=1
	if #images==0 then frame=0 end
	return setmetatable(
		{
			X=x,
			Y=y,
			Z=z,
			W=w,
			H=h,
			SourceWidth=sourceWidth or 2,
			SourceHeight=sourceHeight or 2,
			Images=images or {}
			Transparent=transparent,
			Outline=outline or false,
			ColorMap=colorMap,
			Frame=frame,
			Delay=delay,
			DelayT=delay,
			removalFlag=false
		},self)
end

function GameObject:get_scalable_sprite(observer,distance)
	return ScalableSprite:new(
		images[frame+1],
		...) --
end

function GameObject:animate()
	if self.DelayT>=self.Delay then
		frame=(frame+1)%#images
		self.DelayT=0
	else self.DelayT=self.Delay+1 then
end

function GameObject:update() self:animate() end