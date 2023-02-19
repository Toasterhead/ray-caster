function draw_pixel_column(pixelColumn,dither_filter,dark)
	
	local id=pixelColumn.Id+(pixelColumn.SourceColumn//TILE_SIZE)
	local sourceColumn=pixelColumn.SourceColumn%TILE_SIZE
	local transparent=pixelColumn.Transparent
	local sourceHeight=TILE_SIZE*pixelColumn.SourceHeight
	local height=pixelColumn.Height
	local horizontalOffset=pixelColumn.HorizontalOffset
	local verticalOffset=(0.5*viewport.height)-(0.5*pixelColumn.Height)
	local background=pixelColumn.Background
	local interval=sourceHeight/height
	local dark=dark or 0
	
	local bits=pixelColumn.Bits
	local bitScale=MAX_COLOR_DEPTH//bits
	
	local idOffset=id*PIXELS_PER_TILE
	local subIdOffset=id%bitScale
	
	if subIdOffset>0 then
		idOffset=((id-subIdOffset)*PIXELS_PER_TILE)+(subIdOffset*TILE_SIZE)
	end
	
	local start=((MAX_BITS//bits)*ADDR_TILE)+idOffset
	
	local tilesPerRow=bitScale*16
	local x=viewport.x+horizontalOffset
	local y=viewport.y+verticalOffset
	
	for i=0,height-1 do
	
		if y+i>=viewport.y and y+i<viewport.y+viewport.height then
		
			local verticalIndex=math.floor((i*interval)%TILE_SIZE)
			local tileRowIndex=(i*interval)//TILE_SIZE
			local pixelIndex=(tileRowIndex*tilesPerRow*PIXELS_PER_TILE)+(bitScale*verticalIndex*TILE_SIZE)+sourceColumn
			local addr=start+pixelIndex
			local color=peek(addr,bits)
			
			if not transparent or color~=transparent then
				if dither_filter and dither_filter(x,y+i,pixelColumn.Darkness)==true then
					pix(x,y+i,dark)
				else pix(x,y+i,color) end
			elseif background and y+i>=viewport.y+bgSettings.verticalPosition and y+i<viewport.y+bgSettings.verticalPosition+bgSettings.height then
				local bgSourceWidth=bgSettings.sourceWidth*TILE_SIZE
				local bgSourceHeight=bgSettings.sourceHeight*TILE_SIZE
				color=color_from(
					math.floor((coterminal(background)/FULL_ROTATION)*bgSourceWidth),
					math.floor(((y+i-bgSettings.verticalPosition)/bgSettings.height)*bgSourceHeight),
					bgSettings.id,
					bgSettings.bits)
				pix(x,y+i,color,bits)
			end
		end
	end
end