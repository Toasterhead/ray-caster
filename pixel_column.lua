--Pixel Column Structure

PixelColumn={}
PixelColumn.__index=PixelColumn
function PixelColumn:new(id,sourceColumn,sourceHeight,horizontalOffset,distance,height,transparent,darkness,background,bits)
	return setmetatable(
		{
			Id=id,
			SourceColumn=sourceColumn,
			SourceHeight=sourceHeight,
			HorizontalOffset=horizontalOffset,
			Distance=distance,
			Height=height,
			Transparent=transparent or 0,
			Darkness=darkness or 0,
			Background=background,
			Bits=bits or 4
		},self)
end