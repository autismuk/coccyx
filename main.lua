display.setStatusBar( display.HiddenStatusBar )

-- this requires the line object to be a display.newLine(0,0,1,0)

local function positionLine(lineObject,x1,y1,x2,y2)
	lineObject.x,lineObject.y = x1,y1 															-- set base position
	x2 = x2 - x1 y2 = y2 - y1 																	-- convert end position to offset.
	local lineSize = math.max(0.001,math.sqrt(x2*x2+y2*y2))										-- calculate the line length - must be > 0 as cannot set xScale to zero.
	lineObject.xScale = lineSize 			 													-- scale it to whatever the line length is calculated using pythagoras
	lineObject.rotation = math.deg(math.atan2(y2,x2)) 											-- rotate the line so it points in the right direction.
end

-- arrange an image around the given position - hinge descriptor = xBone (horizontal position of vertically running bone, yTop, yBottom fraction in top and bottom)

local function positionImage(imageObject,x1,y1,x2,y2,hingeDescriptor)
	hingeDescriptor = hingeDescriptor or {} 													-- hinge descriptor.
	imageObject.anchorX,imageObject.anchorY = 0,0 												-- position as of top left.
	imageObject.xScale, imageObject.yScale = 1,1 												-- reset scale to 1,1
	imageObject.x,imageObject.y = x1,y1 														-- move to the correct position.
	imageObject.anchorX,imageObject.anchorY = hingeDescriptor.xBone or 0.5,hingeDescriptor.yTop or 0.0
	x2 = x2 - x1 y2 = y2 - y1 																	-- convert end position to offset.
	imageObject.rotation = math.deg(math.atan2(y2,x2)) - 90 									-- rotate to the correct position.

	local reqLength = math.sqrt(x2*x2+y2*y2) 													-- the required length if it wasn't for the end points.
	reqLength = reqLength / ( 1 - (hingeDescriptor.yTop or 0) - (hingeDescriptor.yBottom or 0)) -- this is how long we want it to be, adjusting for that.
	local reqScale = math.max(0.001,reqLength / imageObject.height) 							-- this is the required scale, at least 0.001 
	imageObject.xScale,imageObject.yScale = reqScale,reqScale 									-- scale to fit.
end

local function testLine(x1,y1,x2,y2)
	local line = display.newLine(0,0,1,0)
	line:setStrokeColor(1,0,0)
	line.strokeWidth = 1
	positionLine(line,x1,y1,x2,y2)
end


local function testImage(x1,y1,x2,y2)
local d = display.newImage("testimage.png",100,100)
	positionImage(d,x1,y1,x2,y2,{ xBone = 0.2,yTop = 0.1,yBottom = 0.1})
end

for i = 1,1 do
	local x1,y1 = math.random(20,280),math.random(20,440)
	local x2,y2 = math.random(20,280),math.random(20,440)


	testImage(x1,y1,x2,y2)
	testLine(x1,y1,x2,y2)

	display.newCircle(x1,y1,5):setFillColor(0,1,0)
	display.newCircle(x2,y2,5):setFillColor(1,1,0)

end

