function cast_rays(observer)

	local rayVectors=observer:get_ray_vectors()
	local renderables={}
	local hitStack=Stack:new()
	
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
				
			end
			
			local distance=nil
			local selected=nil
			
			while hitStack:count()>0 do
				local hit=hitStack:pop()
				local currentDistance=get_distance(observer.Position.x,observer.Position.y,hit.intersection.x,hit.intersection.y)
				if not distance or currentDistance<distance then
					distance=currentDistance
					selected={id=hit.id,intersection=hit.intersection,vertical=hit.vertical}
				end
			end
			
			if selected then
				local sourceColumn
				local positionRatio
				local darkness=0
				local darknessThreshold=0.15*(DRAW_DISTANCE*CELL_SIZE)
				local transparent=nil
				if distance>darknessThreshold then
					darkness=(distance-darknessThreshold)/((DRAW_DISTANCE*CELL_SIZE)-darknessThreshold)
				end
				local height=math.floor((SCALE_RATE*viewport.height)/distance)
				if height%2==1 then height=height+1 end
				cell={x=math.floor(selected.intersection.x),y=math.floor(selected.intersection.y)}
				cell={x=cell.x-(cell.x%2),y=cell.y-(cell.y%2)}
				if fget(selected.id,FLAG_TRANSPARENT)==true then transparent=0 end --Modify later. Consider a lookup table. (key: id, value: transparent)
				if selected.vertical==true then
					positionRatio=(selected.intersection.y-cell.y)/CELL_SIZE
				else
					positionRatio=1-((selected.intersection.x-cell.x)/CELL_SIZE)
				end
				sourceColumn=math.floor(positionRatio*(textureSettings.sourceWidth*TILE_SIZE))
				renderables[#renderables+1]=PixelColumn:new(
					selected.id,
					sourceColumn,
					textureSettings.sourceHeight,
					i-1,
					distance,
					height,
					nil,
					darkness,
					nil,
					bitDepths.texture)
				break
			end
		  
			rayPosition=rayNext
		  
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