function draw_overhead()
	cls(8)
	for i=0,136-1 do
		for j=0,240-1 do
			local x=j-(j%2)
			local y=i-(i%2)
			if mget(x,y)~=0 or mget(x,y+1)~=0 then
				line(x*TILE_SIZE,(y+0)*TILE_SIZE,x*TILE_SIZE,(y+1)*TILE_SIZE-1,2)
				line(x*TILE_SIZE,(y+1)*TILE_SIZE,x*TILE_SIZE,(y+2)*TILE_SIZE-1,4)
			end
			if mget(x+1,y)~=0 or mget(x+1,y+1)~=0 then
				line((x+0)*TILE_SIZE,y*TILE_SIZE,(x+1)*TILE_SIZE-1,y*TILE_SIZE,3)
				line((x+1)*TILE_SIZE,y*TILE_SIZE,(x+2)*TILE_SIZE-1,y*TILE_SIZE,5)
			end 
		end
	end
	rayVectors=observer:get_ray_vectors()
	selectedRays={1,#rayVectors//2,#rayVectors}
	for i=1,#selectedRays do
		local x1=observer.Position.x
		local y1=observer.Position.y
		local x2=observer.Position.x+rayVectors[selectedRays[i]]:scale(5).x
		local y2=observer.Position.y+rayVectors[selectedRays[i]]:scale(5).y
		line(x1*TILE_SIZE,y1*TILE_SIZE,x2*TILE_SIZE,y2*TILE_SIZE,6)
	end
end