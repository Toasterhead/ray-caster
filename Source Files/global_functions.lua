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

function get_distance(x,y,a,b) return math.sqrt((a-x)^2+(b-y)^2) end

function compare_distance(a,b)
	if a.distance and b.distance then
		if reverseSort==true then
			return a.distance>b.distance
		else return a.distance<b.distance end
	elseif a.Distance and b.Distance then
		if reverseSort==true then
		 return a.Distance>b.Distance
		else return a.Distance<b.Distance end
	end
end

function dot_product(v1,v2)
	return (v1.x*v2.x)+(v1.y*v2.y)
end

function corrected_distance(observer,rayVector,distance)
	return dot_product(vector_from(observer.Direction),rayVector:normalize():scale(distance))
end

function quadrant_from(vector)
  if vector.x>=0 and vector.y>=0 then return QI
  elseif vector.x<0 and vector.y>=0 then return QII
  elseif vector.x<0 and vector.y<0 then return QIII
  else return QIV end
end

function get_lookup(id,flagIndex)
	local lookup=lookupColorMap
	if flagIndex==FLAG_TRANSPARENT then lookup=lookupTransparent
	else end
	for i=1,#lookup do
		if lookup[i].id==id then return lookup[i].term end
	end
end

function light_at(x,y,lightSources)
	local total=0
	for i=1,#lightSources do
		local ls=lightSources[i]
		if ls.H and x>=ls.X and x<ls.X+ls.W and y>=ls.Y and y<ls.Y+ls.H then
			total=total+ls.Level+light_adjustment(ls)
		elseif not ls.H and x>=ls.X-ls.W and x<ls.X+ls.W and y>=ls.Y-ls.W and y<ls.Y+ls.W then
			local intensity=1-(get_distance(x,y,ls.X,ls.Y)/ls.W)
			if intensity>0 then total=total+(intensity*ls.Level)+light_adjustment(ls) end
		end
	end
	return total
end

function light_adjustment(ls)
	if ls.Range and ls.Period then
		local tElapsed=t%ls.Period
		local halfPeriod=0.5*ls.Period
		if tElapsed<halfPeriod then
			return (tElapsed/halfPeriod)*ls.Range
		else return ((ls.Period-tElapsed)/halfPeriod)*ls.Range end
	end
	return 0
end