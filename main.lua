--	The Gnome came from Ray Wenderlich, incidentally.

display.setStatusBar( display.HiddenStatusBar )

_G.Base =  _G.Base or { new = function(s,...) local o = { } setmetatable(o,s) s.__index = s o:initialise(...) return o end, initialise = function() end }

--//	This represents a single bone, which may have an associated line (in debug mode) and image.
--//	This class is abstract - getPoint() is not defined.

local BoneGraphic = Base:new()

BoneGraphic.showBone = true 																	-- static member, if true bone lines are drawn over animation.

--//	Initialise a bone graphic
--//	@startPoint [number] 	index of start point
--//	@endPoint [number] 		index of end point
--//	@imageFile [string]		image to use for this bone (optional)
--//	@hingePoint [table]		optional table for body, specifies vertical line through body, and top and bottom in positions.

function BoneGraphic:initialise(startPoint,endPoint,imageFile,hingePoints)
	self.boneLine = nil 																		-- bone line, if used.
	self.boneImage = nil 																		-- bone image, if used.
	self.hingePoints = nil 																		-- hinge points.
	self.startPoint = startPoint 																-- save start and end points
	self.endPoint = endPoint 	
	self.hasMoved = false 																		-- set to true after first move.
	if imageFile ~= nil then self:setImage(imageFile,hingePoints) end 							-- set image file if one provided.
end

--//	Set the current bone image
--//	@imageFile [string]		image to use for this bone (optional)
--//	@hingePoint [table]		optional table for body, specifies vertical line through body, and top and bottom in positions.
--//	@return [BoneGraphic]	self

function BoneGraphic:setImage(imageFile,hingePoints)
	self.boneImage = display.newImage(imageFile)												-- create image object
	self.hingePoints = hingePoints or {} 														-- save hinge points
	if self.x1 ~= nil then  																	-- if it has already been positioned move it.
		self:move()
	end
	return self 																				-- chains
end

--//	Update the position of the bone, get the point coordinates then move the line and/or image
--//	@return [BoneGraphic]	self

function BoneGraphic:move()
	self.x1,self.y1 = self:getPoint(self.startPoint)											-- get new points
	self.x2,self.y2 = self:getPoint(self.endPoint)
	if self.boneLine == nil and BoneGraphic.showBone then 										-- create the bone line if needed.
		self.boneLine = display.newLine(0,0,1,0)
		self.boneLine:setStrokeColor(1,1,0)
		self.boneLine.strokeWidth = 3
		self.boneLine:toFront() 																-- needs to be on top.
	end
	if self.boneLine ~= nil then 																-- reposition bone line
		self:_positionLine(self.x1,self.y1,self.x2,self.y2)
	end
	if self.boneImage ~= nil then 																-- reposition bone image
		self:_positionImage(self.x1,self.y1,self.x2,self.y2)
	end
	return self
end

--//	Position a line object 
--//	@x1		[number]		coordinate
--//	@y1		[number]		coordinate
--//	@x2		[number]		coordinate
--//	@y2		[number]		coordinate

function BoneGraphic:_positionLine(x1,y1,x2,y2)
	self.boneLine.x,self.boneLine.y = x1,y1 													-- set base position
	x2 = x2 - x1 y2 = y2 - y1 																	-- convert end position to offset.
	local lineSize = math.max(0.001,math.sqrt(x2*x2+y2*y2))										-- calculate the line length - must be > 0 as cannot set xScale to zero.
	self.boneLine.xScale = lineSize 			 												-- scale it to whatever the line length is calculated using pythagoras
	self.boneLine.rotation = math.deg(math.atan2(y2,x2)) 										-- rotate the line so it points in the right direction.
end

--//	Position an image to fit along a line.
--//	@x1		[number]		coordinate
--//	@y1		[number]		coordinate
--//	@x2		[number]		coordinate
--//	@y2		[number]		coordinate

function BoneGraphic:_positionImage(x1,y1,x2,y2)
	self.boneImage.anchorX,self.boneImage.anchorY = 0,0 										-- position as of top left.
	self.boneImage.x,self.boneImage.y = x1,y1 													-- move to the correct position.
	self.boneImage.anchorX,self.boneImage.anchorY = self.hingePoints.xBone or 0.5,self.hingePoints.yTop or 0.0
	x2 = x2 - x1 y2 = y2 - y1 																	-- convert end position to offset.
	self.boneImage.rotation = math.deg(math.atan2(y2,x2)) - 90 									-- rotate to the correct position.

	local reqLength = math.sqrt(x2*x2+y2*y2) 													-- the required length if it wasn't for the end points.
	reqLength = reqLength / (1-(self.hingePoints.yTop or 0) - (self.hingePoints.yBottom or 0)) 	-- this is how long we want it to be, adjusting for that.
	local reqScale = math.max(0.001,reqLength / self.boneImage.height) 							-- this is the required scale, at least 0.001 
	self.boneImage.yScale = reqScale 															-- scale vertically
	if not self.hasMoved then self.boneImage.xScale = reqScale end 								-- first moves scales horizontally appropriately.
	self.hasMoved = true
end


--	Points of the demo figure
local points = {
	{ 160,80 }, { 160,180} , { 160,280} , { 290,250}, { 30,250}, { 290,400 }, { 30,400 }
}

--	Subclass Bonegraphic to access points array

local DemoBoneGraphic = BoneGraphic:new()

function DemoBoneGraphic:getPoint(n)
	return points[n][1],points[n][2]
end

--	Create background.

local background = display.newRect(0,0,320,480)
background.anchorX,background.anchorY = 0,0
background:setFillColor( 0,0,1 )
display.newText("Bone Animation Demo 1",160,32,system.nativeFont,16)
--	Create list of bones of the bits

local bgList = {}
bgList[#bgList+1] = DemoBoneGraphic:new(1,2,"head.png")
bgList[#bgList+1] = DemoBoneGraphic:new(2,4,"arm2.png")
bgList[#bgList+1] = DemoBoneGraphic:new(2,5,"arm.png")
bgList[#bgList+1] = DemoBoneGraphic:new(3,6,"leg.png", { xBone = 0.25 })
bgList[#bgList+1] = DemoBoneGraphic:new(3,7,"leg.png", { xBone = 0.25 })
bgList[#bgList+1] = DemoBoneGraphic:new(2,3,"body.png", { yBottom = 0.2, yTop = 0.05 })
bgList[#bgList+1] = DemoBoneGraphic:new(1,2,"head.png")

--	and (very simply) animate them. 
--	obviously control files will do this bit :)

local frame = 0

Runtime:addEventListener( "enterFrame", function(e)

	frame = (frame + 1)
	local offset = frame * 2 % 200
	if offset > 100 then offset = 200-offset end
	points[1][1] = 160 - offset / 4 + 12
	points[5][2] = 250 - offset
	points[4][2] = 150 + offset
	points[6][1] = 160+offset
	points[6][2] = 400+offset/6
	points[7][1] = 160-offset
	points[7][2] = points[6][2]
	-- points[3][2] = 280 - offset/5
	for _,bone in ipairs(bgList) do bone:move() end
end)

-- todo first move establishes horizontal scale.
