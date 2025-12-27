require("ISUI/ISButton")

local AntibodiesUI = {
	FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small),
	FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium),
	FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.NewLarge),

	CONTENT_PADDING = 10,
	CONTENT_PADDING_Y = 20,
	ROW_MARGIN = 10,
	LINE_MARGIN = 3,
	TEXT_SEP = 5,

	RED = { r = 1.0, g = 0.35, b = 0.35, a = 1 },
	GREEN = { r = 0.247, g = 0.788, b = 0.247, a = 1 },
	GREY = { r = 0.569, g = 0.482, b = 0.482, a = 1 },
}

AntibodiesUI.__index = AntibodiesUI
AntibodiesUI.__name = "AntibodiesUI"

function AntibodiesUI.drawProgressBar(panel, x, y, width, height, percent)
	panel:drawRect(x, y, width, height, 0.25, 0.0, 0.0, 0.0)

	percent = math.min(1.0, math.max(-1.0, percent))
	local barWidth = (width * 0.5) * percent

	if barWidth > 0.0 and barWidth < 1.0 then
		barWidth = 1.0
	elseif barWidth < 0.0 and barWidth > -1.0 then
		barWidth = -1.0
	end

	local color = percent >= 0 and AntibodiesUI.GREEN or AntibodiesUI.RED
	panel:drawRect(x + (width * 0.5), y, barWidth, height, 1.0, color.r, color.g, color.b)
	panel:drawRectBorder(x, y, width, height, 0.25, AntibodiesUI.GREY.r, AntibodiesUI.GREY.g, AntibodiesUI.GREY.b)

	return height
end

return AntibodiesUI
