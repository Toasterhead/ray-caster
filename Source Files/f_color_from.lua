function color_from(sourceX,sourceY,id,bits)
	
	local bits=bits or 4
	local bitScale=MAX_COLOR_DEPTH//bits	
	local startAddress=(MAX_BITS//bits)*ADDR_TILE
	local tilesPerRow=bitScale*16
	local sourceX=sourceX
	local sourceY=sourceY
	
	if id then
		local startX=(id%tilesPerRow)*TILE_SIZE
		local startY=(id//tilesPerRow)*TILE_SIZE
		sourceX=startX+sourceX
		sourceY=startY+sourceY
	end
	
	local tileRowIndex=sourceY//TILE_SIZE
	local verticalTileIndex=sourceY%TILE_SIZE
	local verticalAddress=(tileRowIndex*tilesPerRow*PIXELS_PER_TILE)+(bitScale*verticalTileIndex*TILE_SIZE)
	
	local tileColumnIndex=sourceX//TILE_SIZE		
	tileColumnIndex=tileColumnIndex-(tileColumnIndex%bitScale)
	
	local horizontalTileIndex=sourceX%(bitScale*TILE_SIZE)
	local horizontalAddress=(tileColumnIndex*PIXELS_PER_TILE)+horizontalTileIndex
	
	local address=startAddress+verticalAddress+horizontalAddress
	local color=peek(address,bits)
	
	return color
	
end