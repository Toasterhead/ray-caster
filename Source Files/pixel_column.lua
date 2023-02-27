--Pixel Column Structure

PixelColumn={}
PixelColumn.__index=PixelColumn
function PixelColumn:new(id,sourceColumn,sourceHeight,horizontalOffset,bobOffset,distance,height,transparent,darkness,background,bits,colorMap)
	return setmetatable(
		{
			Id=id,
			SourceColumn=sourceColumn,
			SourceHeight=sourceHeight,
			HorizontalOffset=horizontalOffset,
			BobOffset=bobOffset,
			Distance=distance,
			Height=height,
			Transparent=transparent,
			Darkness=darkness,
			Background=background,
			Bits=bits or 4,
			ColorMap=colorMap
		},self)
end