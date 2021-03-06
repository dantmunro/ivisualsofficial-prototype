--------------------------------------------------------------------------------
--
-- main.lua
-- FIXME Add id's to everything
--------------------------------------------------------------------------------

--IMPORTS
local widget = require("widget")
local constants = require ("lib.init")
local colors = require("lib.colors")
local native = require("native")
local sys = require("system")

--CONSTANTS
const.RGB_TO_VECTOR_SCALE = 255
const.IMAGE_DIR = "img"
const.LIB_DIR = "lib"
const.MAIN_DIR = ""
const.IMAGE_EXT = ".png"
const.FILE_SEPARATOR = "/"
const.FONT = "Roboto"
const.IVISUALS_COLORS = {
	ORANGE = {228, 84, 57},
	GREEN = {130, 190, 187},
	BLUE = {109, 118, 155},
	PURPLE = {55, 60, 140},
	WHITE = {255, 255, 255}
}
const.RGB_INDICES = {
	RED = 1,
	GREEN = 2,
	BLUE = 3
}
const.BTN = {
	UPPER_MARGIN = .3*display.contentHeight,
	LOWER_MARGIN = .025*display.contentHeight,
	SPACE = .6*display.contentHeight,
	WIDTH = .6*display.contentWidth,
	HEIGHT = .07*display.contentHeight,
	LABEL_TEXT_SIZE = 15
}
const.ABOUT_US = {
	--VIDEO = "https://www.dropbox.com/s/tu7ta40iavxgf8u/"..
	--	"ivisuals%20Capabilities%202014%2016X9%20PPT%20timed%20latest%20v2"..
	--	".mp4?dl=0",
	VIDEO = "ivisuals Capabilities 2014 16X9 PPT timed latest v2.mp4",
	SCALE = .25
}
const.CONTACT_INFO = {
	Y = .975*display.contentHeight,
	FONT_SIZE = 8.5,
	SPACING = .5*display.contentCenterX,
	PHONE_NO = "800-688-2076",
	EMAIL = "sales@ivisuals.com",
	WEB = "ivisuals.com"
}
const.ICON = {
	Y = .125*display.contentHeight,
	SCALE = .3
}
const.STRIP = {
	WIDTH = .1*display.viewableContentWidth,
	HEIGHT = 2*display.contentHeight,
	WIDTH_TOP = 2*display.contentWidth,
	HEIGHT_TOP = display.topStatusBarContentHeight > 0 
		and 2*display.topStatusBarContentHeight or const.STRIP.WIDTH 
}
const.EMBEDDED = {
	X_OFFSET = .3*const.BTN.WIDTH,
	SCALE = .025
}
const.MACROS = {
	GET_LOCAL_IMAGE = function(name) 
		return const.IMAGE_DIR..const.FILE_SEPARATOR..name..const.IMAGE_EXT 
	end,
	RGB_TO_VECTOR = function(rgb) 
		return {
			rgb[const.RGB_INDICES.RED]/const.RGB_TO_VECTOR_SCALE,
			rgb[const.RGB_INDICES.GREEN]/const.RGB_TO_VECTOR_SCALE,
			rgb[const.RGB_INDICES.BLUE]/const.RGB_TO_VECTOR_SCALE
		}
	end
}

--"GLOBAL" VARIABLES

--lists
local buttons = {}
local strips = {}
local contacts = {}
local buttonDefaults = {
	id = "",
	shape = "roundedRect",
	width = const.BTN.WIDTH,
	height = const.BTN.HEIGHT,
	cornerRadius = 2,
	fillColor = {
		default = const.MACROS.RGB_TO_VECTOR(const.IVISUALS_COLORS.BLUE), 
		over = const.MACROS.RGB_TO_VECTOR(const.IVISUALS_COLORS.PURPLE)
	},
	strokeColor = {
		default = const.MACROS.RGB_TO_VECTOR(const.IVISUALS_COLORS.ORANGE), 
		over = const.MACROS.RGB_TO_VECTOR(const.IVISUALS_COLORS.ORANGE)
	},
	strokeWidth = 4,
	labelColor = {
		default = const.MACROS.RGB_TO_VECTOR(const.IVISUALS_COLORS.GREEN), 
		over = const.MACROS.RGB_TO_VECTOR(const.IVISUALS_COLORS.GREEN)
	},
	label = "",
	labelAlign = "center"
}

--LISTENERS
local function onComplete(event)
   print("video session ended")
end

local function aboutUsListener(event)
	if event.phase == "began" then
		print("You touched the object")
		media.playVideo(
			const.ABOUT_US.VIDEO, 
			--media.RemoteSource, 
			true, 
			listener
		)
		return true
	elseif event.errorCode then
        native.showAlert("Error!", event.errorMessage, {"OK"})
        return false
    end
end

--FUNCTIONS
local function addAllListeners(widget, listener)
	widget:addEventListener("tap", listener)
	widget:addEventListener("touch", listener)
	widget:addEventListener("mouse", listener)
end

local function initButton(label, listener)
	local btn = nil
	if label == "About Us" then --add special icon instead of button defaults
		btn = display.newImage(const.MACROS.GET_LOCAL_IMAGE("about_us_button"))
		btn:scale(const.ABOUT_US.SCALE, const.ABOUT_US.SCALE)
		btn.regular = false
	else
		btn = widget.newButton(buttonDefaults)
		btn:setLabel( label )
		btn.regular = true
	end
	btn.id = label
	btn.listener = listener
	table.insert( buttons, btn )
	btn.x = display.contentCenterX
	for i = 1,#buttons do
		buttons[i].y = i* ((const.BTN.SPACE)/(#buttons + 1)) 
		+ const.BTN.UPPER_MARGIN 
		- const.BTN.LOWER_MARGIN
		addAllListeners(btn, listener)
	end
end

local function initContactInfo(label, screenPrefix, sysPrefix)
	local contactInfo = display.newText(
		screenPrefix..label, 
		0, 
		const.CONTACT_INFO.Y, 
		const.FONT, 
		const.CONTACT_INFO.FONT_SIZE 
	)
	table.insert(contacts, contactInfo)
	local listener = function(event) 
		if event.phase == "began" then 
			system.openURL(sysPrefix..label) 
		end 
	end
	addAllListeners(contactInfo, listener)
	return contactInfo
end

--SCRIPT

--create background
display.setDefault("background", 
	colors.white[const.RGB_INDICES.RED],
	colors.white[const.RGB_INDICES.GREEN],
	colors.white[const.RGB_INDICES.BLUE]
)
local background = display.getDefault("background")

--create header icon
local icon = display.newImage(
	const.MACROS.GET_LOCAL_IMAGE("logo_full"), 
	display.contentCenterX, 
	const.ICON.Y 
)
icon:scale(const.ICON.SCALE, const.ICON.SCALE)

--create "about us" button
local aboutBtn = initButton("About Us", aboutUsListener)

--create contact info (phone, email, website)
local phoneNoInfo = initContactInfo(
	string.gsub(const.CONTACT_INFO.PHONE_NO, "-", "."), 
	"P: ", 
	"tel:"
)
local emailInfo = initContactInfo(const.CONTACT_INFO.EMAIL, "E: ", "mailto:")
local webInfo  = initContactInfo(const.CONTACT_INFO.WEB, "W: ", "http://www.")

--add IDs to all pieces created thus far
icon.id = "icon"
phoneNoInfo.id = "Phone Number"
emailInfo.id = "Email"
webInfo.id = "Web"

--color contact info text and place it along bottom of screen
local contactInfoColor = const.MACROS.RGB_TO_VECTOR(
	const.IVISUALS_COLORS.PURPLE
)
for i = 1, #contacts do
	contacts[i]:setTextColor(
		contactInfoColor[const.RGB_INDICES.RED], 
		contactInfoColor[const.RGB_INDICES.GREEN], 
		contactInfoColor[const.RGB_INDICES.BLUE]
	)
	contacts[i].x = i*const.CONTACT_INFO.SPACING
end

--create strips along sides and top of app
local leftStrip = display.newRect(
	display.screenOriginX, 
	0, 
	const.STRIP.WIDTH, 
	const.STRIP.HEIGHT
)
local rightStrip = display.newRect(
	display.viewableContentWidth + display.screenOriginX, 
	0, 
	const.STRIP.WIDTH, 
	const.STRIP.HEIGHT
)
local topStrip = display.newRect(
	0, 
	display.screenOriginY, 
	const.STRIP.WIDTH_TOP,
	const.STRIP.HEIGHT_TOP
)

--add IDs to all strips
leftStrip.id = "Left Strip"
rightStrip.id = "Right Strip"
topStrip.id = "Top Strip"

--color all strips
table.insert(strips, leftStrip)
table.insert(strips, rightStrip)
table.insert(strips, topStrip)
local stripColor = const.MACROS.RGB_TO_VECTOR(const.IVISUALS_COLORS.BLUE)
for i = 1,#strips do
	strips[i]:setFillColor(
		stripColor[const.RGB_INDICES.RED], 
		stripColor[const.RGB_INDICES.GREEN], 
		stripColor[const.RGB_INDICES.BLUE] 
	)
end