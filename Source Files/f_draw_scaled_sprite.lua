function draw_scaled_sprite(scalableSprite,dither_filter,dark)
	
	local x=viewport.x+scalableSprite.X
	local y=viewport.y+scalableSprite.Y
	local transparent=scalableSprite.Transparent
	local sourceHeight=TILE_SIZE*scalableSprite.SourceHeight
	local sourceWidth=TILE_SIZE*scalableSprite.SourceWidth
	local width=scalableSprite.Width
	local height=scalableSprite.Height
	local dark=dark or 0
	
	local imageMask
	if scalableSprite.Outline==true then imageMask={} end
	
	for i=0,height-1 do
		for j=0,width-1 do
			
			local sourceX=math.floor((j/width)*sourceWidth)
			local sourceY=math.floor((i/height)*sourceHeight)
			local color=color_from(sourceX,sourceY,scalableSprite.Id,scalableSprite.Bits)
			
			if not transparent or color~=transparent then
				if dither_filter and dither_filter(x+j,y+i,scalableSprite.Darkness)==true then
					pix(x+j,y+i,dark)
				else
					pix(x+j,y+i,color)
				end
				if imageMask then imageMask[((i+1)*(width+2))+(j+1)]=true end
			end
			
		end
	end
	
	if imageMask then draw_outline(imageMask,x,y,width+2,height+2,dark) end
	
end