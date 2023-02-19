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