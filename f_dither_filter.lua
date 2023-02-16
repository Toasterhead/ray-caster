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