--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Skeletal Animation (v. simple) experiments
---				Created:	12 May 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	MIT
---
--- ************************************************************************************************************************************************************************

--	The Gnome came from Ray Wenderlich, incidentally.

display.setStatusBar( display.HiddenStatusBar )

_G.Base =  _G.Base or { new = function(s,...) local o = { } setmetatable(o,s) s.__index = s o:initialise(...) return o end, initialise = function() end }

--- ************************************************************************************************************************************************************************
--//								This represents a single bone, which may have an associated line (in debug mode) and image.
--- ************************************************************************************************************************************************************************

local BoneGraphic = Base:new()

BoneGraphic.showBone = true 																	-- static member, if true bone lines are drawn over animation.

--//	Initialise a bone graphic
--//	@startPoint [number]			start of bone point (e.g relates to top)
--//	@endPoint [number]				end of bone point (e.g relates to top)
--//	@pointList [table]				array of two entry lists defining sprite point
--//	@imageSheet [ImageSheet] 		Image Sheet
--//	@imageRef [string/number]		image to use for this bone
--//	@hingePoint [table]				optional table for body, specifies vertical line through body, and top and bottom in positions.

function BoneGraphic:initialise(startPoint,endPoint,pointList,imageSheet,imageRef,hingePoints)
	self.boneLine = nil 																		-- bone line, if used.
	self.boneImage = nil 																		-- bone image, if used.
	self.hingePoints = nil 																		-- hinge points.
	self.startPoint = startPoint 																-- save start and end points
	self.endPoint = endPoint 	
	self.pointList = pointList
	self.hasMoved = false 																		-- set to true after first move.
	self.imageSheet = imageSheet 																-- save image sheet
	if imageRef ~= nil then self:setImage(imageRef,hingePoints) end 							-- set image file if one provided.
end

--//	Clear down a bone graphic object.

function BoneGraphic:remove()
	if self.boneLine ~= nil then self.boneLine:removeSelf() end 								-- remove bone line if exists
	if self.boneImage ~= nil then self.boneImage:removeSelf() end 								-- remove bone image if exists
	self.hingePoints = nil self.startPoint = nil self.endPoint = nil self.pointList = nil 		-- null everything out
	self.hasMoved = nil self.imageSheet = nil
end

--//	Set the current bone image
--//	@imageRef [string/number]		image to use for this bone
--//	@hingePoint [table]				optional table for body, specifies vertical line through body, and top and bottom in positions.
--//	@return [BoneGraphic]			self

function BoneGraphic:setImage(imageRef,hingePoints)
	self.boneImage = display.newImage(self.imageSheet,imageRef)									-- create image object
	self.hingePoints = hingePoints or {} 														-- save hinge points
	if self.x1 ~= nil then  																	-- if it has already been positioned move it.
		self:move()
	end
	return self 																				-- chains
end

--//	Update the position of the bone, get the point coordinates then move the line and/or image
--//	@return [BoneGraphic]	self

function BoneGraphic:move()
	local x1,y1 = self.pointList[self.startPoint][1],self.pointList[self.startPoint][2] 		-- access start and end points.
	local x2,y2 = self.pointList[self.endPoint][1],self.pointList[self.endPoint][2]
	if self.boneLine == nil and BoneGraphic.showBone then 										-- create the bone line if needed.
		self.boneLine = display.newLine(0,0,1,0)
		self.boneLine:setStrokeColor(1,1,0)
		self.boneLine.strokeWidth = 3
	end
	if self.boneLine ~= nil then 																-- reposition bone line
		self:_positionLine(x1,y1,x2,y2)
		self.boneLine:toFront() 																-- needs to be on top.
	end
	if self.boneImage ~= nil then 																-- reposition bone image
		self:_positionImage(x1,y1,x2,y2)
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


--- ************************************************************************************************************************************************************************
--//																Class managing a bone animation
--- ************************************************************************************************************************************************************************


local BoneAnimation = Base:new()

--//	Initialise a bone animation
--//	@imageSheet [ImageSheet/String]		Corona Image Sheet or Sheet Name.

function BoneAnimation:initialise(imageSheet)
	if type(imageSheet) == "string" then 														-- string provided ?
		imageSheet = graphics.newImageSheet(imageSheet..".png", require(imageSheet):getSheet())	-- load image sheet if name given.
	end
	self.boneList = {} 																			-- list of bones.
	self.pointList = {} 																		-- list of points.
	self.imageSheet = imageSheet 																-- save image sheet
end

--//	Set a skeleton point
--//	@index 	[number]		point number
--//	@x 		[number]		x-coordinate
--//	@y 		[number] 		y-coordinate

function BoneAnimation:setPoint(index,x,y) 
	local p = self.pointList 																	-- shortens things a bit
	if p[index] ~= nil then  																	-- if update
		p[index][1] = x or p[index][1] 															-- can use nil to default to current x or y
		p[index][2] = y or p[index][2]
	else
		assert(x ~= nil and y ~= nil,"coordinates must not be nil") 							-- create a new point
		p[index] = { x,y }
	end
	self:repaint() 																				-- force a repaint
	return self
end

--//	Set a bone
--//	@index 	[number]					bone number
--//	@startp [number]					start of bone point (e.g relates to top)
--//	@endp [number]						end of bone point (e.g relates to top)
--//	@imageReference [string/number]		image to use for this bone
--//	@hingePoint [table]					optional table for body, specifies vertical line through body, and top and bottom in positions.

function BoneAnimation:setBone(index,startp,endp,imageReference,hingeData)
	local bone = BoneGraphic:new(startp,endp,self.pointList,									-- create a new bone
											self.imageSheet,imageReference,hingeData) 			
	if self.boneList[index] ~= nil then self.boneList[index]:remove() end 						-- remove pre-existing bones, so you can change them.
	self.boneList[index] = bone 																-- save in the structure
	self:repaint() 																				-- and repaint.
	return self
end

function BoneAnimation:repaint()
	for _,bone in ipairs(self.boneList) do 
		bone:move()
	end
end

--- ************************************************************************************************************************************************************************
--- ************************************************************************************************************************************************************************

-- Remove comment to hide the yellow bone lines.
-- BoneGraphic.showBone = false

--	Points of the demo figure
local points = {
	{ 160,80 }, { 160,180} , { 160,280} , { 290,250}, { 30,250}, { 290,400 }, { 30,400 }
}

--	Create background.

local background = display.newRect(0,0,320,480)
background.anchorX,background.anchorY = 0,0
background:setFillColor( 0,0,1 )
display.newText("Bone Animation Demo 2",160,32,system.nativeFont,16)

-- Create animation.

local anim = BoneAnimation:new("bonesheet")

-- Add the skeleton points

for _,points in ipairs(points) do anim:setPoint(_,points[1],points[2]) end

-- Add the bone images

anim:setBone(1,2,4,2)
anim:setBone(2,2,5,1)
anim:setBone(3,3,6,5, { xBone = 0.25 })
anim:setBone(4,3,7,5, { xBone = 0.25 })
anim:setBone(5,2,3,3, { yBottom = 0.2, yTop = 0.05 })
anim:setBone(6,1,2,4, { xBone = 0.6 })

--	and (very simply) animate them. 
--	obviously control files will do this bit :)

local frame = 0
local speed = 5


Runtime:addEventListener( "enterFrame", function(e)

	frame = (frame + 1)
	local offset = math.round(frame * speed) % 200
	if offset > 100 then offset = 200-offset end
	anim:setPoint(1,160 - offset / 4 + 12,nil)
	anim:setPoint(5,nil,250 - offset)
	anim:setPoint(4,nil,50 + offset*2)
	anim:setPoint(6,160+offset,400+offset/6)
	anim:setPoint(7,160-offset,400+offset/6)
end)

--TODO: Anchor point

