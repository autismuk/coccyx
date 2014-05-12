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
--//	@startPoint [number]	start of bone point (e.g relates to top)
--//	@endPoint [number]		end of bone point (e.g relates to top)
--//	@pointList [table]		array of two entry lists defining sprite point
--//	@imageFile [string]		image to use for this bone (optional)
--//	@hingePoint [table]		optional table for body, specifies vertical line through body, and top and bottom in positions.

function BoneGraphic:initialise(startPoint,endPoint,pointList,imageFile,hingePoints)
	self.boneLine = nil 																		-- bone line, if used.
	self.boneImage = nil 																		-- bone image, if used.
	self.hingePoints = nil 																		-- hinge points.
	self.startPoint = startPoint 																-- save start and end points
	self.endPoint = endPoint 	
	self.pointList = pointList
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
	local x1,y1 = self.pointList[self.startPoint][1],self.pointList[self.startPoint][2]
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

function BoneAnimation:initialise()
	self.boneList = {} 																			-- list of bones.
	self.pointList = {} 																		-- list of points.
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
--//	@index 	[number]		bone number
--//	@startp [number]		start of bone point (e.g relates to top)
--//	@endp [number]			end of bone point (e.g relates to top)
--//	@imageFile [string]		image to use for this bone (optional)
--//	@hingePoint [table]		optional table for body, specifies vertical line through body, and top and bottom in positions.

function BoneAnimation:setBone(index,startp,endp,imageFile,hingeData)
	local bone = BoneGraphic:new(startp,endp,self.pointList,imageFile,hingeData) 				-- create a new bone
	-- TODO: Remove it if it already exists.
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
display.newText("Bone Animation Demo",160,32,system.nativeFont,16)

-- Create animation.

local anim = BoneAnimation:new()
for _,points in ipairs(points) do anim:setPoint(_,points[1],points[2]) end
anim:setBone(1,2,4,"arm2.png")
anim:setBone(2,2,5,"arm.png")
anim:setBone(3,3,6,"leg.png", { xBone = 0.25 })
anim:setBone(4,3,7,"leg.png", { xBone = 0.25 })
anim:setBone(5,2,3,"body.png", { yBottom = 0.2, yTop = 0.05 })
anim:setBone(6,1,2,"head.png", { xBone = 0.6 })

--	and (very simply) animate them. 
--	obviously control files will do this bit :)

local frame = 0
local speed = 3


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

--TODO: Bone.remove and code in
--TODO: Fix to use spritesheet
--TODO: Anchor point

