require "ISUI/ISUIElement"
require "ISUI/ISToolTip"

UXTextEntryBox = ISUIElement:derive("UXTextEntryBox");

function UXTextEntryBox:initialise()
	ISUIElement.initialise(self);
end

function UXTextEntryBox:ignoreFirstInput()
	self.javaObject:ignoreFirstInput();
end

function UXTextEntryBox:setOnlyNumbers(onlyNumbers)
    self.javaObject:setOnlyNumbers(onlyNumbers);
end

function UXTextEntryBox:instantiate()
	self.javaObject = UITextBox2.new(self.font, self.x, self.y, self.width, self.height, self.title, false);
	self.javaObject:setTable(self);
	self.javaObject:setX(self.x);
	self.javaObject:setY(self.y);
	self.javaObject:setHeight(self.height);
	self.javaObject:setWidth(self.width);
	self.javaObject:setAnchorLeft(self.anchorLeft);
	self.javaObject:setAnchorRight(self.anchorRight);
	self.javaObject:setAnchorTop(self.anchorTop);
	self.javaObject:setAnchorBottom(self.anchorBottom);
	self.javaObject:setEditable(true);
end

function UXTextEntryBox:getText()
	return self.javaObject:getText();
end

function UXTextEntryBox:setEditable(editable)
    self.javaObject:setEditable(editable);
    if editable then
        self.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    else
        self.borderColor = {r=0.4, g=0.4, b=0.4, a=0.5}
    end
end

function UXTextEntryBox:setSelectable(enable)
	self.javaObject:setSelectable(enable)
end

function UXTextEntryBox:setMultipleLine(multiple)
    self.javaObject:setMultipleLine(multiple);
end

function UXTextEntryBox:setMaxLines(max)
    self.javaObject:setMaxLines(max);
end

function UXTextEntryBox:setClearButton(hasButton)
    self.javaObject:setClearButton(hasButton);
end

function UXTextEntryBox:setText(str)
    if not str then
        str = "";
    end
	self.javaObject:SetText(str);
	self.title = str;
end

function UXTextEntryBox:onPressDown()
    self:validate()
end

function UXTextEntryBox:onPressUp()
    self:validate()
end

function UXTextEntryBox:focus()
	self:validate()
	return self.javaObject:focus();
end

function UXTextEntryBox:unfocus()
	self:validate()
	return self.javaObject:unfocus();
end

function UXTextEntryBox:getInternalText()
	return self.javaObject:getInternalText();
end

function UXTextEntryBox:setMasked(b)
	return self.javaObject:setMasked(b);
end

function UXTextEntryBox:setMaxTextLength(length)
	self.javaObject:setMaxTextLength(length);
end

function UXTextEntryBox:setForceUpperCase(forceUpperCase)
	self.javaObject:setForceUpperCase(forceUpperCase);
end

function UXTextEntryBox:prerender()

	self.fade:setFadeIn(self:isMouseOver() or self.javaObject:isFocused())
	self.fade:update()

	self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	if self.borderColor.a == 1 then
		local rgb = math.min(self.borderColor.r + 0.2 * self.fade:fraction(), 1.0)
		self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, rgb, rgb, rgb);
	else
		local r = math.min(self.borderColor.r + 0.2 * self.fade:fraction(), 1.0)
		self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, r, self.borderColor.g, self.borderColor.b)
	end

    if self:isMouseOver() and self.tooltip then
        local text = self.tooltip;
        if not self.tooltipUI then
            self.tooltipUI = ISToolTip:new()
            self.tooltipUI:setOwner(self)
            self.tooltipUI:setVisible(false)
        end
        if not self.tooltipUI:getIsVisible() then
            if string.contains(self.tooltip, "\n") then
                self.tooltipUI.maxLineWidth = 1000
            else
                self.tooltipUI.maxLineWidth = 300
            end
            self.tooltipUI:addToUIManager()
            self.tooltipUI:setVisible(true)
            self.tooltipUI:setAlwaysOnTop(true)
        end
        self.tooltipUI.description = text
        self.tooltipUI:setX(self:getMouseX() + 23)
        self.tooltipUI:setY(self:getMouseY() + 23)
    else
        if self.tooltipUI and self.tooltipUI:getIsVisible() then
            self.tooltipUI:setVisible(false)
            self.tooltipUI:removeFromUIManager()
        end
    end
end

function UXTextEntryBox:onMouseMove(dx, dy)
	self.mouseOver = true
end

function UXTextEntryBox:onMouseMoveOutside(dx, dy)
	self.mouseOver = false
end

function UXTextEntryBox:onMouseWheel(del)
	self:setYScroll(self:getYScroll() - (del * 40))
	return true;
end

function UXTextEntryBox:clear()
	self.javaObject:clearInput();
end

function UXTextEntryBox:setHasFrame(hasFrame)
	self.javaObject:setHasFrame(hasFrame)
end

function UXTextEntryBox:setFrameAlpha(alpha)
	self.javaObject:setFrameAlpha(alpha);
end

function UXTextEntryBox:getFrameAlpha()
	return self.javaObject:getFrameAlpha();
end

function UXTextEntryBox:setValid(valid)
	if valid then
		self.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	else
		self.borderColor = {r=0.7, g=0.1, b=0.1, a=0.7}
	end
end

function UXTextEntryBox:setTooltip(text)
	self.tooltip = text and text:gsub("\\n", "\n") or nil
end

function UXTextEntryBox:new(title, x, y, width, height)
	local el = {}
	el = ISUIElement:new(x, y, width, height);

	setmetatable(el, self)
	self.__index = self

	el.x = x;
	el.y = y;
    
	el.title = title;
	el.backgroundColor = {r=0, g=0, b=0, a=0.5};
	el.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	el.width = width;
	el.height = height;
    el.keeplog = false;
    el.logIndex = 0;
	el.anchorLeft = true;
	el.anchorRight = false;
	el.anchorTop = true;
	el.anchorBottom = false;
	el.fade = UITransition.new()
	el.font = UIFont.Small
    el.currentText = title;
    el.isTextEntryBox = true;

	return el
end

return UXTextEntryBox