--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:ac76c38b7d927e47d0aeeb50badc463c:5fa9696c0dc87aac4c9ee506aef903ca:e4cead54b14afc086eff9dd198e5a863$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- arm
            x=196,
            y=138,
            width=27,
            height=105,

            sourceX = 10,
            sourceY = 0,
            sourceWidth = 45,
            sourceHeight = 105
        },
        {
            -- arm2
            x=197,
            y=2,
            width=26,
            height=107,

            sourceX = 14,
            sourceY = 0,
            sourceWidth = 54,
            sourceHeight = 107
        },
        {
            -- body
            x=136,
            y=2,
            width=59,
            height=134,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 61,
            sourceHeight = 134
        },
        {
            -- head
            x=2,
            y=2,
            width=132,
            height=161,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 136,
            sourceHeight = 161
        },
        {
            -- leg
            x=136,
            y=138,
            width=58,
            height=109,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 60,
            sourceHeight = 109
        },
    },
    
    sheetContentWidth = 225,
    sheetContentHeight = 249
}

SheetInfo.frameIndex =
{

    ["arm"] = 1,
    ["arm2"] = 2,
    ["body"] = 3,
    ["head"] = 4,
    ["leg"] = 5,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
