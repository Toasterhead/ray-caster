--Scalable Sprite Structure

ScalableSprite={}
ScalableSprite.__index=ScalableSprite
function ScalableSprite:new(id,x,y,sourceWidth,sourceHeight,width,height,distance,transparent,darkness,outline,bits)
	--Modify such that width and height are automatically derived from distance. Implement later.
	return setmetatable(
		{
			Id=id,
			X=x,
			Y=y,
			SourceWidth=sourceWidth,
			SourceHeight=sourceHeight,
			Width=width,
			Height=height,
			Distance=distance,
			Transparent=transparent or 0,
			Darkness=darkness or 0,
			Outline=outline or false,
			Bits=bits or 4
		},self)
end