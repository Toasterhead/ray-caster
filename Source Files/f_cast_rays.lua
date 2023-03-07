function cast_rays(observer)

	local rayVectors=observer:get_ray_vectors()
	local renderables={}
	local hitStack=Stack:new()
	local castDistance=math.floor(torch*DRAW_DISTANCE)
	
	for i=1,#rayVectors do
		
		local q=quadrant_from(rayVectors[i])
		local rayPosition=Vector:new(observer.Position.x,observer.Position.y)
		
		for j=0,DRAW_DISTANCE-1 do
			
			local rayNext=rayPosition:add(rayVectors[i])			
			local cell={x=rayPosition.x,y=rayPosition.y}
			cell={x=cell.x-(cell.x%2),y=cell.y-(cell.y%2)}
			
			if q==QI then
				hitStack:push(cell_has_vertical(cell.x+CELL_SIZE,cell.y,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_horizontal(cell.x,cell.y+CELL_SIZE,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_vertical(cell.x+CELL_SIZE,cell.y+CELL_SIZE,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_horizontal(cell.x+CELL_SIZE,cell.y+CELL_SIZE,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
			elseif q==QII then
				hitStack:push(cell_has_vertical(cell.x,cell.y,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_vertical(cell.x-CELL_SIZE,cell.y,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_horizontal(cell.x,cell.y+CELL_SIZE,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_vertical(cell.x,cell.y+CELL_SIZE,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_horizontal(cell.x-CELL_SIZE,cell.y+CELL_SIZE,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				--hitStack:push(cell_has_vertical(cell.x-CELL_SIZE,cell.y+CELL_SIZE,rayPosition,rayNext))
				--if not hitStack:stack_peek() then hitStack:pop() end
			elseif q==QIII then
				hitStack:push(cell_has_horizontal(cell.x,cell.y,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_vertical(cell.x,cell.y,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_horizontal(cell.x-CELL_SIZE,cell.y,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_vertical(cell.x-CELL_SIZE,cell.y,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_vertical(cell.x,cell.y-CELL_SIZE,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_horizontal(cell.x,cell.y-CELL_SIZE,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
			elseif q==QIV then
				hitStack:push(cell_has_horizontal(cell.x,cell.y,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_horizontal(cell.x,cell.y-CELL_SIZE,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_horizontal(cell.x+CELL_SIZE,cell.y,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_vertical(cell.x+CELL_SIZE,cell.y,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				hitStack:push(cell_has_vertical(cell.x+CELL_SIZE,cell.y-CELL_SIZE,rayPosition,rayNext))
				if not hitStack:stack_peek() then hitStack:pop() end
				--hitStack:push(cell_has_horizontal(cell.x+CELL_SIZE,cell.y-CELL_SIZE,rayPosition,rayNext))
				--if not hitStack:stack_peek() then hitStack:pop() end
			end
			
			local selected={}
			local candidates={}
			
			while hitStack:count()>0 do
				local hit=hitStack:pop()
				local distance=get_distance(observer.Position.x,observer.Position.y,hit.intersection.x,hit.intersection.y)
				local transparent=nil
				if fget(hit.id,FLAG_TRANSPARENT)==true then transparent=get_lookup(hit.id,FLAG_TRANSPARENT) end
				candidates[#candidates+1]={id=hit.id,intersection=hit.intersection,distance=distance,transparent=transparent,vertical=hit.vertical}
			end
			
			if #candidates==1 then 
				selected[1]=candidates[1]
			else
				reverseSort=false
				table.sort(candidates,compare_distance)				
				for k=1,#candidates do
					selected[#selected+1]=candidates[k]
					if not candidates[k].transparent then break end
				end
			end
			
			for k=1,#selected do
				local sourceColumn
				local positionRatio
				local darkness=0
				local darknessThreshold=0.4*(castDistance*CELL_SIZE)
				local background=nil
				local colorMap=get_lookup(selected[k].id)
				local height=math.floor((SCALE_RATE*viewport.height)/corrected_distance(observer,rayVectors[i],selected[k].distance))
				
				if selected[k].distance>darknessThreshold then
					darkness=(selected[k].distance-darknessThreshold)/((castDistance*CELL_SIZE)-darknessThreshold)
				end
				darkness=darkness*(1-light_at(selected[k].intersection.x,selected[k].intersection.y,lightSources))
				if darkness<0then darkness=0 end
				
				if height%2==1 then height=height+1 end
				
				cell={x=math.floor(selected[k].intersection.x),y=math.floor(selected[k].intersection.y)}
				cell={x=cell.x-(cell.x%2),y=cell.y-(cell.y%2)}
				
				if selected[k].vertical==true then
					positionRatio=(selected[k].intersection.y-cell.y)/CELL_SIZE
				else
					positionRatio=1-((selected[k].intersection.x-cell.x)/CELL_SIZE)
				end
				
				sourceColumn=math.floor(positionRatio*(textureSettings.sourceWidth*TILE_SIZE))
				renderables[#renderables+1]=PixelColumn:new(
					selected[k].id,
					sourceColumn,
					textureSettings.sourceHeight,
					i-1,
					observer:get_bob_offset(),
					selected[k].distance,
					height,
					selected[k].transparent,
					darkness,
					background,
					bitDepths.texture,
					colorMap)
			end
		  
			rayPosition=rayNext
			
			if #selected>0 and not selected[#selected].transparent then break end
		 
		end
		
		if #renderables>0 and renderables[#renderables].Transparent then
			renderables[#renderables].Background=rayVectors[i]:angle()			
		end
		
	end
	
	return renderables
	
end

function cell_has_vertical(x,y,rayCurrent,rayNext)
	if mget(x,y)~=0 or mget(x,y+1)~=0 then
		linearCurve=LinearCurve:new(rayCurrent.x,rayCurrent.y,rayNext.x,rayNext.y)
		intersection=linearCurve:intersects_vertical_segment(x,y,y+2)
		if intersection then
			if not intersection.y then intersection.y=y end
			local id=mget(x,y)
			if rayCurrent.x>=rayNext.x then id=mget(x,y+1) end
			id=id*(MAX_COLOR_DEPTH//bitDepths.texture)
			return {id=id,intersection=intersection,vertical=true}
		end
	end
	return nil
end

function cell_has_horizontal(x,y,rayCurrent,rayNext)
	if mget(x+1,y)~=0 or mget(x+1,y+1)~=0 then
		linearCurve=LinearCurve:new(rayCurrent.x,rayCurrent.y,rayNext.x,rayNext.y)
		intersection=linearCurve:intersects_horizontal_segment(x,x+2,y)
		if intersection then
			if not intersection.x then intersection.x=x end
			local id=mget(x+1,y)
			if rayCurrent.y>=rayNext.y then id=mget(x+1,y+1) end
			id=id*(MAX_COLOR_DEPTH//bitDepths.texture)
			return {id=id,intersection=intersection,vertical=false}
		end
	end
	return nil
end