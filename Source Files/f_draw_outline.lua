function draw_outline(imageMask,x,y,width,height,dark)
	for i=0,height-1 do
		for j=0,width-1 do
			if not imageMask[index_from(j,i,width)] and (
				(imageMask[index_from(j-1,i-1,width)] and imageMask[index_from(j-1,i-1,width)]==true) or
				(imageMask[index_from(j,  i-1,width)] and imageMask[index_from(j,  i-1,width)]==true) or
				(imageMask[index_from(j+1,i-1,width)] and imageMask[index_from(j+1,i-1,width)]==true) or
				(imageMask[index_from(j-1,i,  width)] and imageMask[index_from(j-1,i,  width)]==true) or
				(imageMask[index_from(j+1,i,  width)] and imageMask[index_from(j+1,i,  width)]==true) or
				(imageMask[index_from(j-1,i+1,width)] and imageMask[index_from(j-1,i+1,width)]==true) or
				(imageMask[index_from(j,  i+1,width)] and imageMask[index_from(j,  i+1,width)]==true) or
				(imageMask[index_from(j+1,i+1,width)] and imageMask[index_from(j+1,i+1,width)]==true)) then
				
				pix(x+j-1,y+i-1,dark) end
		end
	end
end