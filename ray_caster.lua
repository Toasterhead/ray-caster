-- title:   Ray Caster
-- author:  Lenny Young
-- desc:    A ray-casting engine for rendering a texture-mapped, first-person view from a 2D map.
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

viewport={x=8,y=8,width=160,height=136}
bgSettings={id=64,sourceWidth=8,sourceHeight=2,verticalPosition=20,height=50,bits=4}
textureSettings={sourceWidth=2,sourceHeight=2}

DRAW_DISTANCE=50
FULL_ROTATION=2*math.pi
CELL_SIZE=2

QI=0
QII=1
QIII=2
QIV=3

ADDR_TILE=16384
PIXELS_PER_TILE=64
TILE_SIZE=8
MAX_BITS=8
MAX_COLOR_DEPTH=4

FLAG_TRANSPARENT=0
FLAG_LIGHT_BIT_2=5
FLAG_LIGHT_BIT_1=6
FLAG_LIGHT_BIT_0=7

torch=0.5
t=0

--Stack Class

Stack={}
Stack.__index=Stack
function Stack:new() return setmetatable({Values={}},self) end

function Stack:clear() self.Values={} end

function Stack:push(value) self.Values[#self.Values+1]=value end

function Stack:pop()
	if #self.Values>0 then
		local value=self.Values[#self.Values]
		self.Values[#self.Values]=nil
		return value
	end
	return nil
end

function Stack:stack_peek() return self.Values[#self.Values] end

function Stack:count() return #self.Values end

--Queue Class

Queue={}
Queue.__index=Queue
function Queue:new() return setmetatable({Values={}},self) end

function Queue:clear() self.Values={} end

function Queue:enqueue(value) self.Values[#self.Values+1]=value end

function Queue:dequeue()
	value=self.Values[1]
	for i=1,#self.Values-1 do self.Values[i]=self.Values[i+1] end
	self.Values[#self.Values]=nil
	return value
end

function Queue:queue_peek() return self.Values[1] end

function Queue:count() return #self.Values end

--Vector Class

Vector={}
Vector.__index=Vector
function Vector:new(x,y) return setmetatable({x=x or 0,y=y or 0},self) end

function Vector:magnitude() return math.sqrt(self.x^2+self.y^2) end

function Vector:normalize() return self:scale(1/self:magnitude()) end

function Vector:add(other) return Vector:new(self.x+other.x,self.y+other.y) end

function Vector:scale(scalar) return Vector:new(scalar*self.x,scalar*self.y) end

function Vector:angle()
	local theta=math.atan(self.y/self.x)
	if self.x<0 then theta=math.pi+theta end
	return theta%(2*math.pi)
end

--Linear Curve Class

LinearCurve={}
LinearCurve.__index=LinearCurve
function LinearCurve:new(x1,y1,x2,y2)
  local vertical=x1==x2
  local slope=nil
  local yIntercept=nil
  local xIntercept=nil
  if vertical==false then
    slope=(y2-y1)/(x2-x1)
    yIntercept=y1-(slope*x1)
    xIntercept=-yIntercept/slope 
  else xIntercept=x1 end
  return setmetatable(
      {
        M=slope,
        B=yIntercept,
        XIntercept=xIntercept,
        Vertical=vertical
      },self)
end

function LinearCurve:f(x) return (self.M*x)+self.B end

function LinearCurve:intersects_horizontal_segment(x1,x2,y)

  local intersection={x=0,y=0}

  if x1>x2 then
    tempX2=x2
    x2=x1
    x1=tempX2
  end

  if self.Vertical==false then
    if self.M==0 and self.B==y then return {x=nil,y=y} end
    intersection.x=(y-self.B)/self.M
    if intersection.x>=x1 and intersection.x<x2 then
        intersection.y=self:f(intersection.x)
        return intersection
    end
  else
    intersection.x=self.XIntercept
    if intersection.x>=x1 and intersection.x<x2 then
      	intersection.y=y
        return intersection
    end
  end

  return nil
  
end

function LinearCurve:intersects_vertical_segment(x,y1,y2)

  local intersection={x=0,y=0}

  if y1>y2 then
    tempY2=y2
    y2=y1
    y1=tempY2
  end

  if self.Vertical==false then
    if self.M==0 and self.B>=y1 and self.B<y2 then return {x=x,y=self.B} end
    intersection.y=self:f(x)
    if intersection.y>=y1 and intersection.y<y2 then
      intersection.x=(intersection.y-self.B)/self.M
      return intersection
    end
  elseif self.XIntercept==x then return {x=x,y=nil} end

  return nil
  
end

--Observer Class

Observer={}
Observer.__index=Observer
function Observer:new(x,y,direction,span)
  local span=span or FULL_ROTATION/6
  return setmetatable(
    {
      Position=Vector:new(x,y),
      Direction=direction or 0,
      Span=span,
      Interval=span/viewport.width
    },self)
end

function Observer:move(magnitude,strafe)
	local direction=self.Direction
	if strafe and strafe==-1 or strafe==1 then
		direction=coterminal(self.Direction+(strafe*0.5*math.pi))
	end
	self.Position=self.Position:add(vector_from(direction,magnitude))
end

function Observer:turn(angle) self.Direction=coterminal(self.Direction+angle) end

function Observer:get_ray_vectors()
  rays={}
  leftEdge=coterminal(self.Direction-(0.5*self.Span))
  for i=1,viewport.width do
    angle=coterminal(leftEdge+((i-1)*self.Interval))
    rays[i]=vector_from(angle,CELL_SIZE)
  end
  return rays
end

--Pixel Column Structure

PixelColumn={}
PixelColumn.__index=PixelColumn
function PixelColumn:new(id,sourceColumn,sourceHeight,horizontalOffset,distance,transparent,darkness,background,bits)
	local height=distance --Modify later.
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

--Scalable Sprite Structure

ScalableSprite={}
ScalableSprite.__index=ScalableSprite
function ScalableSprite:new(id,x,y,sourceWidth,sourceHeight,width,height,distance,transparent,darkness,outline,bits)
	--Modify such that width and height are automatically derived from distance. Implement later.
	return setmetatable(
		{
			Id=id,
			X=x,
			Y=y,
			SourceWidth=sourceWidth,
			SourceHeight=sourceHeight,
			Width=width,
			Height=height,
			Distance=distance,
			Transparent=transparent or 0,
			Darkness=darkness or 0,
			Outline=outline or false,
			Bits=bits or 4
		},self)
end

--Global Functions

function index_from(x,y,width) return (y*width)+x end

function in_set(value,a)
	for i=1,#a do
		if value==a[i] then return true end
	end
	return false
end

function vector_from(theta,magnitude)
	v=Vector:new(math.cos(theta),math.sin(theta))
	if magnitude then return v:scale(magnitude) end
	return v
end

function coterminal(theta)
 	if theta<0 then
    while theta+FULL_ROTATION<FULL_ROTATION do theta=theta+FULL_ROTATION end
 	else theta=theta%FULL_ROTATION end
 	return theta
end

function distance(x,y,a,b) return math.sqrt((a-x)^2+(b-y)^2) end

function vector_from(theta,magnitude)
  v=Vector:new(math.cos(theta),math.sin(theta))
  if magnitude then v=v:scale(magnitude) end
  return v
end

function quadrant_from(vector)
  if vector.x>=0 and vector.y>=0 then return QI
  elseif vector.x<0 and vector.y>=0 then return QII
  elseif vector.x<0 and vector.y<0 then return QIII
  else return QIV end
end

--Game Loop

function BOOT()
	renderables={}
	observer=Observer:new(12,12,math.pi/4)
end

function TIC()

	if btn(0) then observer:move(0.8) end
	if btn(1) then observer:move(-0.8) end
	if btn(2) then observer:turn(-0.035) end
	if btn(3) then observer:turn(0.035) end
	if key(17) then observer:move(0.8,-1) end
	if key(23) then observer:move(0.8,1) end
	if keyp(49) then overheadOn=not overheadOn end

	cls(8)
	
	--for i=viewport.width-1,0,-1 do
	--	renderables[i+1]=PixelColumn:new(192,i%24,2,i+1,math.floor(0.75*i),0,1-(i/viewport.width),((i/viewport.width)+(t/100))*FULL_ROTATION,4)
	--	draw_pixel_column(renderables[i+1],dither_filter,0)
	--end
	
	--scalableSprite=ScalableSprite:new(192,8,8,3,3,50,85,0,0,0,true,4)
	--draw_scaled_sprite(scalableSprite,dither_filter,0)
	
	--for i=0*8,3*8-1 do
	--	for j=12*8,15*8-1 do
	--		pix(i,j-(12*8),color_from(i,j,4))
	--	end
	--end
	
	renderables=cast_rays(observer)
	
	for i=1,#renderables do
		draw_pixel_column(renderables[i])
	end
	
	if overheadOn==true then draw_overhead() end
	
	t=t+1
end

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
			end
			
			local shortestDistance=nil
			local selected=nil
			
			while hitStack:count()>0 do
				local hit=hitStack:pop()
				local currentDistance=distance(observer.Position.x,observer.Position.y,hit.intersection.x,hit.intersection.y)
				if not shortestDistance or currentDistance<shortestDistance then
					shortestDistance=currentDistance
					selected={id=hit.id,intersection=hit.intersection,vertical=hit.vertical}
				end
			end
			
			if selected then
				local sourceColumn
				local transparent=0
				local darkness=shortestDistance/(DRAW_DISTANCE*TILE_SIZE)
				cell={x=math.floor(selected.intersection.x),y=math.floor(selected.intersection.y)}
				cell={x=cell.x-(cell.x%2),y=cell.y-(cell.y%2)}
				if fget(selected.id,FLAG_TRANSPARENT)==true then transparent=0 end --Modify later. Consider a lookup table. (key: id, value: transparent)
				if selected.vertical==true then
					sourceColumn=math.floor((selected.intersection.y-cell.y)/CELL_SIZE)*(textureSettings.sourceHeight*TILE_SIZE)
				else
					sourceColumn=math.floor((selected.intersection.y-cell.x)/CELL_SIZE)*(textureSettings.sourceWidth*TILE_SIZE)
				end
				renderables[#renderables+1]=PixelColumn:new(selected.id,sourceColumn,textureSettings.sourceHeight,i-1,shortestDistance,1,darkness,nil,4)
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
			return {id=id,intersection=intersection,vertical=false}
		end
	end
	return nil
end

function dither_filter(x,y,darkness)
	
	local x=math.floor(x)
	local y=math.floor(y)
	
	if darkness>=1 then
		return true
	elseif darkness>=0.875 then
		return not (x%8==7 and y%8==0) and not (x%8==3 and y%8==4)
	elseif darkness>=0.75 then
		return not (x%4==3 and y%4==0) and not (x%4==1 and y%4==2)
	elseif darkness>=0.625 then
		return not (x%2==1 and y%4==0) and not (x%2==0 and y%4==2)
	elseif darkness>=0.5 then
		return x%2==y%2
	elseif darkness>=0.375 then
		return (x%2==0 and y%4==0) or (x%2==1 and y%4==2)
	elseif darkness>=0.25 then
		return (x%4==0 and y%4==0) or (x%4==2 and y%4==2)
	elseif darkness>=0.125 then
		return (x%6==0 and y%8==0) or (x%6==3 and y%8==4)
	end
	
	return false

end

function draw_pixel_column(pixelColumn,dither_filter,dark)
	
	local id=pixelColumn.Id+(pixelColumn.SourceColumn//TILE_SIZE)
	local sourceColumn=pixelColumn.SourceColumn%TILE_SIZE
	local transparent=pixelColumn.Transparent
	local sourceHeight=TILE_SIZE*pixelColumn.SourceHeight
	local height=pixelColumn.Height
	local horizontalOffset=pixelColumn.HorizontalOffset
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
	local y=viewport.y
	
	for i=0,height-1 do
		
		local verticalIndex=math.floor((i*interval)%TILE_SIZE)
		local tileRowIndex=(i*interval)//TILE_SIZE
		local pixelIndex=(tileRowIndex*tilesPerRow*PIXELS_PER_TILE)+(bitScale*verticalIndex*TILE_SIZE)+sourceColumn
		local addr=start+pixelIndex
		local color=peek(addr,bits)
		
		if color~=transparent then
			if dither_filter and dither_filter(x,y+i,pixelColumn.Darkness)==true then
				pix(x,y+i,dark)
			else pix(x,y+i,color) end
		elseif background and y+i>=y+bgSettings.verticalPosition and y+i<bgSettings.verticalPosition+bgSettings.height then
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
			
			if color~=transparent then
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