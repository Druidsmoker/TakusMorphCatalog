-- settings
local Debug = false
local MaxNumberOfColumn = 12
local MinNumberOfColumn = 3
local NumberOfColumn = 12
local MaxModelID = 1000000
local WindowWidth = 1000
local WindowHeight = 760
-- vars
local Cells = {}
local OffsetModelID = 0
local ModelID = OffsetModelID
local LastMaxModelID = 0
local GoBackStack = {}
local GoBackDepth = 0
local DisplayFavorites = false
-- vars (mounts)
local DisplayMounts = false
local Mounts = {}
foreach(C_MountJournal.GetMountIDs(),
	function(k,v)
		local creatureDisplayInfoID, _, _, _, _, _, _, _, _ = C_MountJournal.GetMountInfoExtraByID(v)
		if creatureDisplayInfoID then
			Mounts[creatureDisplayInfoID] = 1
		end
	end
)

--
TakusMorphCatalogDB = {
	FavoriteList = {}
}

print("TakusMorphCatalog: Type /tmc to display the morph catalog !")
-- end vars and settings

-- TMCFrame (main)
local TMCFrame = CreateFrame("Frame", nil, UIParent)
TMCFrame:Hide()
TMCFrame:SetFrameStrata("DIALOG")
TMCFrame:SetWidth(WindowWidth) 
TMCFrame:SetHeight(WindowHeight)
TMCFrame:SetPoint("CENTER",0,0)
TMCFrame:SetMovable(true)
TMCFrame:SetMinResize(400, 400)
TMCFrame:SetClampedToScreen(true)
TMCFrame:SetBackdrop( { 
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", 
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, 
  insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
-- end TMCFrame

if Debug then
	print("TMCFrame OK")
end

-- Collection
TMCFrame.Collection = CreateFrame("Button",nil,TMCFrame, "UIPanelButtonTemplate")
TMCFrame.Collection:SetSize(120,30)
TMCFrame.Collection:SetPoint("TOPLEFT",10,-10)
TMCFrame.Collection:SetText("All Models")
TMCFrame.Collection:SetScript("OnClick", function(self, Button, Down)
	OffsetModelID = 0
	ModelID = 0
	DisplayFavorites = false
	DisplayMounts = false
	--
	NumberOfColumn = MaxNumberOfColumn
	TMCFrame.Gallery:Load(true)
end)
-- end Collection

-- Mounts
TMCFrame.Mounts = CreateFrame("Button",nil,TMCFrame, "UIPanelButtonTemplate")
TMCFrame.Mounts:SetSize(120,30)
TMCFrame.Mounts:SetPoint("TOPLEFT",130,-10)
TMCFrame.Mounts:SetText("Mounts")
TMCFrame.Mounts:SetScript("OnClick", function(self, Button, Down)
	OffsetModelID = 0
	ModelID = 0
	DisplayMounts = true
	DisplayFavorites = false
	--
	NumberOfColumn = MaxNumberOfColumn
	TMCFrame.Gallery:Load(true)
end)
-- end Mounts

-- Favorites
TMCFrame.Favorites = CreateFrame("Button",nil,TMCFrame, "UIPanelButtonTemplate")
TMCFrame.Favorites:SetSize(120,30)
TMCFrame.Favorites:SetPoint("TOPLEFT",250,-10)
TMCFrame.Favorites:SetText("Favorites")
TMCFrame.Favorites:SetScript("OnClick", function(self, Button, Down)
	OffsetModelID = 0
	ModelID = 0
	DisplayFavorites = true
	GoBackDepth = 0
	TMCFrame.Gallery:Load(true)
end)
-- end Favorites

-- ModelPreview
TMCFrame.ModelPreview = CreateFrame("Frame",nil,TMCFrame)
TMCFrame.ModelPreview:SetScript("OnMouseDown", function(self, Button, Down)
	TMCFrame.ModelPreview:Hide()
end)
TMCFrame.ModelPreview:SetFrameStrata("DIALOG")
TMCFrame.ModelPreview:SetFrameLevel(5)
TMCFrame.ModelPreview:SetBackdrop( { 
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
TMCFrame.ModelPreview:SetAllPoints()
--
TMCFrame.ModelPreview.ModelFrame = CreateFrame("PlayerModel", nil, TMCFrame.ModelPreview)
TMCFrame.ModelPreview:Hide()
--
TMCFrame.ModelPreview.FontString = TMCFrame.ModelPreview.ModelFrame:CreateFontString(nil,nil,"GameFontNormal")
TMCFrame.ModelPreview.FontString:SetPoint("TOP",0, 22)
--
TMCFrame.ModelPreview.ModelFrame.DisplayInfo = 0
TMCFrame.ModelPreview.ModelFrame:SetWidth(WindowWidth / 3) 
TMCFrame.ModelPreview.ModelFrame:SetHeight(WindowHeight / 2)
TMCFrame.ModelPreview.ModelFrame:SetPoint("CENTER",0,0)
TMCFrame.ModelPreview.ModelFrame:SetBackdrop( { 
  bgFile = "Interface\\FrameGeneral\\UI-Background-Marble.PNG",
  insets={bottom=-50, top=-40, left=-20, right=-20}
})
--
TMCFrame.ModelPreview.Favorite=TMCFrame.ModelPreview.ModelFrame:CreateTexture(nil,"ARTWORK")
TMCFrame.ModelPreview.Favorite:SetPoint("TOPLEFT",-20,30)
TMCFrame.ModelPreview.Favorite:SetSize(40,40)
TMCFrame.ModelPreview.Favorite:SetTexture("Interface\\Collections\\Collections")
TMCFrame.ModelPreview.Favorite:SetTexCoord(0.18, 0.02, 0.18, 0.07, 0.23, 0.02, 0.23, 0.07)
--
TMCFrame.ModelPreview.AddToFavorite = CreateFrame("Button",nil,TMCFrame.ModelPreview.ModelFrame, "UIPanelButtonTemplate")
TMCFrame.ModelPreview.AddToFavorite:SetSize(120,30)
TMCFrame.ModelPreview.AddToFavorite:SetPoint("BOTTOMLEFT",-10,-40)
TMCFrame.ModelPreview.AddToFavorite:SetText("Add to Favorite")
TMCFrame.ModelPreview.AddToFavorite:SetScript("OnClick", function(self, Button, Down)
	TakusMorphCatalogDB.FavoriteList[TMCFrame.ModelPreview.ModelFrame.DisplayInfo] = 1
	TMCFrame.ModelPreview.AddToFavorite:Hide()
	TMCFrame.ModelPreview.RemoveFavorite:Show()
	TMCFrame.ModelPreview.Favorite:Show()
	ModelID = OffsetModelID
	TMCFrame.Gallery:Load()
end)
--
TMCFrame.ModelPreview.RemoveFavorite = CreateFrame("Button",nil,TMCFrame.ModelPreview.ModelFrame, "UIPanelButtonTemplate")
TMCFrame.ModelPreview.RemoveFavorite:SetSize(120,30)
TMCFrame.ModelPreview.RemoveFavorite:SetPoint("BOTTOMLEFT",-10,-40)
TMCFrame.ModelPreview.RemoveFavorite:SetText("Remove Favorite")
TMCFrame.ModelPreview.RemoveFavorite:SetScript("OnClick", function(self, Button, Down)
	TakusMorphCatalogDB.FavoriteList[TMCFrame.ModelPreview.ModelFrame.DisplayInfo] = nil
	TMCFrame.ModelPreview.AddToFavorite:Show()
	TMCFrame.ModelPreview.RemoveFavorite:Hide()
	TMCFrame.ModelPreview.Favorite:Hide()
	ModelID = OffsetModelID
	TMCFrame.Gallery:Load()
end)
--
TMCFrame.ModelPreview.CopyID = CreateFrame("Button",nil,TMCFrame.ModelPreview.ModelFrame, "UIPanelButtonTemplate")
TMCFrame.ModelPreview.CopyID:SetSize(70,30)
TMCFrame.ModelPreview.CopyID:SetPoint("BOTTOMLEFT",120,-40)
TMCFrame.ModelPreview.CopyID:SetText("Copy ID")
TMCFrame.ModelPreview.CopyID:SetScript("OnClick", function(self, Button, Down)
	ChatFrame1EditBox:Show()
	ChatFrame1EditBox:SetFocus()
	ChatFrame1EditBox:SetText(TMCFrame.ModelPreview.ModelFrame.DisplayInfo)
	ChatFrame1EditBox:HighlightText()
end)
-- end ModelPreview

-- TitleFrame
TMCFrame.TitleFrame = CreateFrame("Frame", nil, TMCFrame)
TMCFrame.TitleFrame:SetSize(TMCFrame:GetWidth(), 40)
TMCFrame.TitleFrame:SetPoint("TOP")
TMCFrame.TitleFrame.Background = TMCFrame.TitleFrame:CreateTexture(nil,"BACKGROUND")
TMCFrame.TitleFrame.Background:SetColorTexture(1,0,0,0)
TMCFrame.TitleFrame.Background:SetAllPoints(TMCFrame.TitleFrame)
TMCFrame.TitleFrame.FontString = TMCFrame.TitleFrame:CreateFontString(nil,nil,"GameFontNormal")
TMCFrame.TitleFrame.FontString:SetText("Taku's Morph Catalog")
TMCFrame.TitleFrame.FontString:SetAllPoints(TMCFrame.TitleFrame)
TMCFrame.TitleFrame.CloseButton = CreateFrame("Button", nil, TMCFrame.TitleFrame, "UIPanelCloseButton")
TMCFrame.TitleFrame.CloseButton:SetPoint("RIGHT", -3, 0)
TMCFrame.TitleFrame.CloseButton:SetScript("OnClick", function(self, Button, Down)
	TMCFrame:Hide()
end)
TMCFrame.TitleFrame:SetScript("OnMouseDown", function(self, Button)
	TMCFrame:StartMoving()
end)
TMCFrame.TitleFrame:SetScript("OnMouseUp", function(self, Button)
	TMCFrame:StopMovingOrSizing()
end)
-- end TitleFrame

--[[local ResizeFrame = CreateFrame("Button", nil, TMCFrame)
ResizeFrame:SetSize(20,20)
ResizeFrame.Texture = ResizeFrame:CreateTexture(nil,"ARTWORK")
ResizeFrame.Texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
ResizeFrame.Texture:SetAllPoints(ResizeFrame)
ResizeFrame:SetPoint("BOTTOMRIGHT", -10, 10)
ResizeFrame:SetScript("OnMouseDown", function(self, Button)
	TMCFrame:StartSizing("BOTTOMRIGHT")
end)
ResizeFrame:SetScript("OnMouseUp", function(self, Button)
	TMCFrame:StopMovingOrSizing()
end)--]]

--[[TMCFrame:SetScript("OnSizeChanged", function(self, Width, Height)
	WindowWidth = Width
	WindowHeight = Height
	TMCFrame.Gallery:Load()
	TitleFrame:SetSize(TMCFrame:GetWidth(), 40)
	TitleFrame:SetPoint("TOP")
	TMCFrame.PageController:SetSize(TMCFrame:GetWidth(), 75)
	TMCFrame.PageController:SetPoint("BOTTOM")
end)--]]

-- PageController
TMCFrame.PageController = CreateFrame("Frame", nil, TMCFrame)
TMCFrame.PageController:SetSize(TMCFrame:GetWidth(), 75)
TMCFrame.PageController:SetPoint("BOTTOM")
TMCFrame.PageController.FontString = TMCFrame.PageController:CreateFontString(nil,nil,"GameFontWhite")
TMCFrame.PageController.FontString:SetAllPoints(TMCFrame.PageController)

function TMCFrame.PageController:UpdateButtons()
	if (ModelID >= MaxModelID) then
		TMCFrame.NextPageButton:SetBackdrop( { 
		  bgFile = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled", 
		  insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
	else
		TMCFrame.NextPageButton:SetBackdrop( { 
		  bgFile = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", 
		  insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
	end
	if (GoBackDepth == 0) then
		TMCFrame.PreviousPageButton:SetBackdrop( { 
		  bgFile = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled", 
		  insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
	else
		TMCFrame.PreviousPageButton:SetBackdrop( { 
		  bgFile = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", 
		  insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
	end	
end

-- end PageController

-- NextPageButton
TMCFrame.NextPageButton = CreateFrame("Button", nil, TMCFrame.PageController)
--
TMCFrame.NextPageButton:SetSize(45, 45)
TMCFrame.NextPageButton:SetPoint("Center",100,0)
TMCFrame.NextPageButton:SetBackdrop( { 
  bgFile = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", 
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
--
TMCFrame.NextPageButton.HoverGlow = TMCFrame.NextPageButton:CreateTexture(nil,"BACKGROUND")
TMCFrame.NextPageButton.HoverGlow:SetTexture("Interface\\Buttons\\CheckButtonGlow")
TMCFrame.NextPageButton.HoverGlow:SetAllPoints(TMCFrame.NextPageButton)
TMCFrame.NextPageButton.HoverGlow:SetAlpha(0)
--
TMCFrame.NextPageButton:SetScript("OnEnter", function()
	if (ModelID < MaxModelID) then
		TMCFrame.NextPageButton.HoverGlow:SetAlpha(1)
	end
end);
--
TMCFrame.NextPageButton:SetScript("OnLeave", function()
	TMCFrame.NextPageButton.HoverGlow:SetAlpha(0)
end);
--
TMCFrame.NextPageButton:SetScript("OnClick", function(self, Button, Down)
	if (ModelID >= MaxModelID) then
		return
	end
	OffsetModelID = ModelID
	--
	GoBackStack[GoBackDepth] = {LastMaxModelID=LastMaxModelID, Zoom=NumberOfColumn}
	GoBackDepth = GoBackDepth + 1
	--
	TMCFrame.Gallery:Load()
	--
end)
-- end NextPageButton

-- GoToEditBox
TMCFrame.GoToEditBox = CreateFrame('EditBox', nil, TMCFrame.PageController, "InputBoxTemplate")
--
TMCFrame.GoToEditBox.FontString = TMCFrame.GoToEditBox:CreateFontString(nil,nil,"GameFontWhite")
TMCFrame.GoToEditBox.FontString:SetPoint("LEFT", -50, 0)
TMCFrame.GoToEditBox.FontString:SetText("Go to :")
--
TMCFrame.GoToEditBox:SetPoint("LEFT", 150, 0)
TMCFrame.GoToEditBox:SetMultiLine(false)
TMCFrame.GoToEditBox:SetAutoFocus(false)
TMCFrame.GoToEditBox:EnableMouse(true)
TMCFrame.GoToEditBox:SetMaxLetters(6)
--[[TMCFrame.GoToEditBox:SetTextColor(0,0,0,1)--]]
TMCFrame.GoToEditBox:SetTextInsets(0,0,0,0)
TMCFrame.GoToEditBox:SetFont('Fonts\\ARIALN.ttf', 12, '')	
TMCFrame.GoToEditBox:SetWidth(70)
TMCFrame.GoToEditBox:SetHeight(20)
TMCFrame.GoToEditBox:SetScript('OnEscapePressed', function() TMCFrame.GoToEditBox:ClearFocus() end)
TMCFrame.GoToEditBox:SetScript('OnEnterPressed', function()
	TMCFrame.GoToEditBox:ClearFocus()
	--
	OffsetModelID = tonumber(TMCFrame.GoToEditBox:GetText())
	if OffsetModelID >= MaxModelID then
		OffsetModelID = MaxModelID
	end
	NumberOfColumn = MaxNumberOfColumn
	ModelID = OffsetModelID
	TMCFrame.Gallery:Load(true)
end)
-- end GoToEditBox

-- PreviousPageButton
TMCFrame.PreviousPageButton = CreateFrame("Button", nil, TMCFrame.PageController)
TMCFrame.PreviousPageButton:SetSize(45, 45)
TMCFrame.PreviousPageButton:SetPoint("Center",-100,0)
TMCFrame.PreviousPageButton:SetBackdrop( { 
  bgFile = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled", 
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
TMCFrame.PreviousPageButton.HoverGlow = TMCFrame.PreviousPageButton:CreateTexture(nil,"BACKGROUND")
TMCFrame.PreviousPageButton.HoverGlow:SetTexture("Interface\\Buttons\\CheckButtonGlow")
TMCFrame.PreviousPageButton.HoverGlow:SetAllPoints(TMCFrame.PreviousPageButton)
TMCFrame.PreviousPageButton.HoverGlow:SetAlpha(0)
TMCFrame.PreviousPageButton:SetScript("OnEnter", function()
	if (GoBackDepth > 0) then
		TMCFrame.PreviousPageButton.HoverGlow:SetAlpha(1)
	end
end);
TMCFrame.PreviousPageButton:SetScript("OnLeave", function()
	TMCFrame.PreviousPageButton.HoverGlow:SetAlpha(0)
end);
TMCFrame.PreviousPageButton:SetScript("OnClick", function(self, Button, Down)
	if (GoBackDepth == 0) then
		return
	end
	OffsetModelID = GoBackStack[GoBackDepth - 1].LastMaxModelID
	--
	ModelID = OffsetModelID
	NumberOfColumn = MaxNumberOfColumn
	TMCFrame.Gallery:Load(true)
	--
	ModelID = OffsetModelID
	NumberOfColumn = GoBackStack[GoBackDepth - 1].Zoom
	GoBackStack[GoBackDepth - 1] = nil
	GoBackDepth = GoBackDepth - 1
	TMCFrame.Gallery:Load()
	--
end)
-- end PreviousPageButton

-- Gallery
TMCFrame.Gallery = CreateFrame("Frame", nil, TMCFrame)
TMCFrame.Gallery:SetPoint("TOP", 0, -50)
TMCFrame.Gallery:SetScript("OnMouseWheel", function(self, delta)
	NewNumberOfColumn = NumberOfColumn
	if (delta < 0) then
		if (NumberOfColumn == MaxNumberOfColumn) then
			return
		end
		NewNumberOfColumn = NumberOfColumn * 2
		-- pop all inferior zoom from gobackstack
		Depth = GoBackDepth - 1
		while Depth > 0 and GoBackStack[Depth].Zoom < NumberOfColumn do
			GoBackStack[Depth] = nil
			Depth = Depth - 1
			GoBackDepth = GoBackDepth - 1
		end
	else
		if (NumberOfColumn == MinNumberOfColumn) then
			return 
		end
		NewNumberOfColumn = NumberOfColumn / 2
	end
	ModelID = OffsetModelID
	NumberOfColumn = NewNumberOfColumn
	TMCFrame.Gallery:Load()
end)

function TMCFrame.Gallery:Load(Reset)
	if Debug then
		print("--- TMCFrame.Gallery:Load ---")
		print("DisplayMounts .. " .. DisplayMounts)
		print("ModelID .. " .. ModelID)
		print("LastMaxModelID .. " .. LastMaxModelID)
		print("OffsetModelID .. " .. OffsetModelID)
	end
	TMCFrame.Gallery:SetSize(TMCFrame:GetWidth() - 50, TMCFrame:GetHeight() - 125)
	local ColumnWidth = TMCFrame.Gallery:GetWidth() / NumberOfColumn
	local MaxNumberOfRowsOnSinglePage = floor(TMCFrame.Gallery:GetHeight() / ColumnWidth)
	LastMaxModelID = ModelID
	ModelID = OffsetModelID
	local CellIndex = 0
	while CellIndex < NumberOfColumn * MaxNumberOfRowsOnSinglePage do
		OffsetX = CellIndex % NumberOfColumn 
		OffsetY = floor(CellIndex / NumberOfColumn)
		if (OffsetY == MaxNumberOfRowsOnSinglePage) then
			break
		end
		local bNewWidget = (Cells[CellIndex] == nil)
		if bNewWidget then
			Cells[CellIndex] = CreateFrame("Button", nil, TMCFrame.Gallery)
			Cells[CellIndex].Favorite=Cells[CellIndex]:CreateTexture(nil,"ARTWORK")
			Cells[CellIndex].Favorite:SetPoint("TOPLEFT",-5,0)
			Cells[CellIndex].Favorite:SetSize(20,20)
			Cells[CellIndex].Favorite:SetTexture("Interface\\Collections\\Collections")
			Cells[CellIndex].Favorite:SetTexCoord(0.18, 0.02, 0.18, 0.07, 0.23, 0.02, 0.23, 0.07)
			Cells[CellIndex]:SetFrameStrata("DIALOG")
			Cells[CellIndex].HighlightBackground = Cells[CellIndex]:CreateTexture(nil,"BACKGROUND")
			Cells[CellIndex].HighlightBackground:SetColorTexture(1,1,1,0.5)
			Cells[CellIndex].HighlightBackground:SetAllPoints(Cells[CellIndex])
			Cells[CellIndex]:SetHighlightTexture(Cells[CellIndex].HighlightBackground)
			Cells[CellIndex]:RegisterForClicks("AnyUp")
			Cells[CellIndex].ModelFrame = CreateFrame("PlayerModel", nil, Cells[CellIndex])
			Cells[CellIndex]:SetScript("OnClick", function(self, Button, Down)
				TMCFrame.ModelPreview.ModelFrame:SetDisplayInfo(self.ModelFrame.DisplayInfo)
				TMCFrame.ModelPreview.ModelFrame.DisplayInfo = self.ModelFrame.DisplayInfo
				TMCFrame.ModelPreview.FontString:SetText(TMCFrame.ModelPreview.ModelFrame.DisplayInfo)
				if TakusMorphCatalogDB.FavoriteList[TMCFrame.ModelPreview.ModelFrame.DisplayInfo] then
					TMCFrame.ModelPreview.Favorite:Show()
					TMCFrame.ModelPreview.AddToFavorite:Hide()
					TMCFrame.ModelPreview.RemoveFavorite:Show()
				else
					TMCFrame.ModelPreview.Favorite:Hide()
					TMCFrame.ModelPreview.AddToFavorite:Show()
					TMCFrame.ModelPreview.RemoveFavorite:Hide()
				end
				TMCFrame.ModelPreview:Show()
			end)
		end
		-- always do
		Cells[CellIndex]:Show()
		if bNewWidget or Cells[CellIndex].ModelFrame.DisplayInfo < ModelID or Reset then
			Cells[CellIndex].ModelFrame:SetDisplayInfo(2418)
			BlankModelFileID = Cells[CellIndex].ModelFrame:GetModelFileID()
			if (DisplayFavorites) then
				while ModelID <= MaxModelID do
					if (TakusMorphCatalogDB.FavoriteList[ModelID]) then
						Cells[CellIndex].ModelFrame:SetDisplayInfo(ModelID)
						ModelID = ModelID + 1
						break
					end
					ModelID = ModelID + 1
				end
			elseif (DisplayMounts) then
				while ModelID <= MaxModelID do
					if (Mounts[ModelID]) then
						Cells[CellIndex].ModelFrame:SetDisplayInfo(ModelID)
						ModelID = ModelID + 1
						break
					end
					ModelID = ModelID + 1						
				end
			else
				while ModelID <= MaxModelID do
					Cells[CellIndex].ModelFrame:SetDisplayInfo(ModelID)
					ModelID = ModelID + 1
					if Cells[CellIndex].ModelFrame:GetModelFileID() ~= nil and Cells[CellIndex].ModelFrame:GetModelFileID() ~= BlankModelFileID then
						break
					end
				end
			end
			Cells[CellIndex].ModelFrame.DisplayInfo = ModelID - 1
		else
			ModelID = Cells[CellIndex].ModelFrame.DisplayInfo + 1
		end
		if (Cells[CellIndex].ModelFrame.DisplayInfo == MaxModelID) then
			Cells[CellIndex]:Hide()
		end
		Cells[CellIndex]:SetWidth(ColumnWidth)
		Cells[CellIndex]:SetHeight(ColumnWidth)
		Cells[CellIndex]:SetPoint("TOPLEFT",OffsetX * ColumnWidth,OffsetY * -ColumnWidth)
		if (TakusMorphCatalogDB.FavoriteList[Cells[CellIndex].ModelFrame.DisplayInfo]) then
			Cells[CellIndex].Favorite:Show()
		else
			Cells[CellIndex].Favorite:Hide()
		end
		Cells[CellIndex].ModelFrame:SetAllPoints()
		CellIndex = CellIndex + 1
	end --while
	while Cells[CellIndex] ~= nil do
		Cells[CellIndex]:Hide()
		CellIndex = CellIndex + 1
	end
	--
	TMCFrame.PageController.FontString:SetText(LastMaxModelID .. " - " .. ModelID - 1)
	TMCFrame.PageController:UpdateButtons()
end
-- end Gallery

if Debug then
	print("ModelFrames OK")
end

-- slash commands
SLASH_TAKUSMORPHCATALOG1 = '/tmc'
function SlashCmdList.TAKUSMORPHCATALOG()
	TMCFrame:Show()
	ModelID=LastMaxModelID
	TMCFrame.Gallery:Load()
end
-- end slash commands
