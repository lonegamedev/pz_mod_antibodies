require("ISUI/ISButton")

local AntibodiesUI = {
	FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small),
	FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium),
	FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.NewLarge),

	CONTENT_PADDING_X = 10,
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

return AntibodiesUI
