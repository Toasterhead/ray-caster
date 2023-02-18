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

function dot_product(v1,v2)
	return (v1.x*v2.x)+(v1.y+v2.y)
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