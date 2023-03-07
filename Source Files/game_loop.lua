--Game Loop

function BOOT()
	renderables={}
	observer=Observer:new(12,4,math.pi/4,nil,{0,0,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3,3,3,2,2,2,1,1,1})
	lightSources=
	{
		LightSource:new(10,3,5,nil,0.95,0.05,20),
		LightSource:new(1,11,3,3,0.2,0.6,120)
	}
	lookupColorMap=
	{
		{id=192,term={0,1,3}}
	}
	lookupTransparent=
	{
		{id=198,term=1}
	}
	cls(8)
end

function TIC()
	
	if tDelta.start then
		tDelta.elapsed=time()-tDelta.start
		tDelta.start=nil
	end
	
	if tDelta.delay<=0 then
		tDelta.start=time()
		tDelta.delay=math.floor(tDelta.elapsed/TICK_DURATION)-1
	end
		
	if btn(0) then observer:move_forward() end
	if btn(1) then observer:move_backward() end
	if key(17) then observer:strafe_left() end
	if key(23) then observer:strafe_right() end
	if btn(2) then observer:turn(-observer.fullTurnSpeed) end
	if btn(3) then observer:turn(observer.fullTurnSpeed) end
	if keyp(49) then overheadOn=not overheadOn end

	--for i=viewport.width-1,0,-1 do
	--	renderables[i+1]=PixelColumn:new(192,i%24,2,i+1,viewport.height-i,0,math.floor(0.75*i),0,1-(i/viewport.width),((i/viewport.width)+(t/100))*FULL_ROTATION,4)
	--	draw_pixel_column(renderables[i+1],dither_filter,0)
	--end
	
	--scalableSprite=ScalableSprite:new(192,8,8,3,3,50,85,0,0,0,true,4)
	--draw_scaled_sprite(scalableSprite,dither_filter,0)
	
	--for i=0*8,3*8-1 do
	--	for j=12*8,15*8-1 do
	--		pix(i,j-(12*8),color_from(i,j,4))
	--	end
	--end
	
	if tDelta.delay<=0 then
		
		cls(8)
		clip(viewport.x,viewport.y,viewport.width,viewport.height)
		cls(0)
	
		renderables=cast_rays(observer)
		reverseSort=true
		table.sort(renderables,compare_distance)	
		
		for i=1,#renderables do
			draw_pixel_column(renderables[i],dither_filter,0)
		end
		
	else tDelta.delay=tDelta.delay-1 end
	
	if overheadOn==true then draw_overhead() end
		
	observer:update()
	t=t+1
end