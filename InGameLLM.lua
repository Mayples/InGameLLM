

-- Add Merge function to database


-- =============================================
-- Database Entry UI
-- =============================================
local entryFrame = nil
--local detailsFrame = nil


local function CreateEntryFrame()
    if entryFrame then return end
    

  
    -- Main Frame
    entryFrame = CreateFrame("Frame", "LLM_EntryFrame", UIParent, "BackdropTemplate")
    entryFrame:SetSize(400, 300)
    entryFrame:SetPoint("CENTER")
    entryFrame:SetMovable(true)
    entryFrame:RegisterForDrag("LeftButton")
    entryFrame:SetScript("OnDragStart", entryFrame.StartMoving)
    entryFrame:SetScript("OnDragStop", entryFrame.StopMovingOrSizing)
    entryFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })

    -- Title
    local title = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Create New Lexicon Entry")

    -- Close Button
    local closeBtn = CreateFrame("Button", nil, entryFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() entryFrame:Hide() end)

    -- Category Dropdown
    --local categories = {"ITEMS", "QUESTS", "NPCS", "ZONES", "TIPS"}
    local function GetCategories()
        local cats = {}
        for cat in pairs(InGameLLM_DB) do
            table.insert(cats, cat)
        end
        table.sort(cats)
        return cats
    end
    --much better category selector
    UIDropDownMenu_Initialize(dd, function()
        for _, cat in ipairs(GetCategories()) do
            UIDropDownMenu_AddButton({
                text = cat,
                func = function() 
                    UIDropDownMenu_SetText(dd, cat)
                    entryFrame.category = cat
                end
            })
        end
    end)


    
    --[[ 
    local dd = CreateFrame("Frame", "LLM_CategoryDD", entryFrame, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", 20, -50)
    UIDropDownMenu_SetWidth(dd, 150)
    UIDropDownMenu_Initialize(dd, function()
        for _, cat in ipairs(categories) do
            UIDropDownMenu_AddButton({
                text = cat,
                func = function() 
                    UIDropDownMenu_SetText(dd, cat)
                    entryFrame.category = cat
                end
            })
        end
    end) --]]

    -- Entry Name
    local nameEB = CreateFrame("EditBox", "LLM_NameInput", entryFrame, "InputBoxTemplate")
    nameEB:SetPoint("TOPLEFT", dd, "BOTTOMLEFT", 0, -30)
    nameEB:SetSize(350, 20)
    nameEB:SetText("Entry Name")
    nameEB:SetCursorPosition(0)

    -- Keywords
    local keywordEB = CreateFrame("EditBox", "LLM_KeywordInput", entryFrame, "InputBoxTemplate")
    keywordEB:SetPoint("TOPLEFT", nameEB, "BOTTOMLEFT", 0, -30)
    keywordEB:SetSize(350, 20)
    keywordEB:SetText("Comma-separated keywords")
    keywordEB:SetCursorPosition(0)

    -- Strategy Text
    local strategyEB = CreateFrame("EditBox", "LLM_StrategyInput", entryFrame, "InputBoxTemplate")
    strategyEB:SetPoint("TOPLEFT", keywordEB, "BOTTOMLEFT", 0, -30)
    strategyEB:SetSize(350, 150)
    strategyEB:SetMultiLine(true)
    strategyEB:SetText("Detailed strategy/notes...")
    strategyEB:SetCursorPosition(0)

    -- Save Button
    local saveBtn = CreateFrame("Button", nil, entryFrame, "UIPanelButtonTemplate")
    saveBtn:SetPoint("BOTTOM", 0, 20)
    saveBtn:SetSize(100, 25)
    saveBtn:SetText("Save Entry")
    saveBtn:SetScript("OnClick", function()
        if entryFrame.category and nameEB:GetText() ~= "" then
            local newEntry = {
                name = nameEB:GetText(),
                keywords = {strsplit(",", keywordEB:GetText():gsub("%s+", ""))},
                response = strategyEB:GetText(),
                icon = "inv_misc_note_06",
                category = entryFrame.category, -- Add category
                entryID = entryFrame.entryID or string.format("%s_%d", entryFrame.category, time()) -- Add entryID ?fix?
            }
            
            -- Initialize category if needed
            InGameLLM_DB[entryFrame.category] = InGameLLM_DB[entryFrame.category] or {}
            
            -- Update existing entry or create new one
            if entryFrame.entryID then
                InGameLLM_DB[entryFrame.category][entryFrame.entryID] = newEntry
            else
                local entryID = string.format("%s_%d", entryFrame.category, time())
                InGameLLM_DB[entryFrame.category][entryID] = newEntry
            end
            
            -- Clear fields
            nameEB:SetText("")
            keywordEB:SetText("")
            strategyEB:SetText("")
            entryFrame:Hide()
            
            print(string.format("|cFF00FF00Entry saved to %s!|r", entryFrame.category))
        end
    end)
end


-- =============================================
-- Custom Details Frame
-- =============================================
local detailsFrame = nil

local function CreateDetailsFrame()
    if detailsFrame then return end

    -- Main Frame
    detailsFrame = CreateFrame("Frame", "LLM_DetailsFrame", UIParent, "BackdropTemplate")
    detailsFrame:SetSize(400, 300)
    detailsFrame:SetPoint("CENTER")
    detailsFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })

    detailsFrame:SetMovable(true)
    detailsFrame:RegisterForDrag("LeftButton")
    detailsFrame:SetScript("OnDragStart", detailsFrame.StartMoving)
    detailsFrame:SetScript("OnDragStop", detailsFrame.StopMovingOrSizing)

    -- Title
    local title = detailsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Entry Details")

    -- Close Button
    local closeBtn = CreateFrame("Button", nil, detailsFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() detailsFrame:Hide() end)

    -- Icon
    local icon = detailsFrame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("TOPLEFT", 20, -40)

    -- Name
    local nameText = detailsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -5)
    nameText:SetJustifyH("LEFT")

    -- Response (Details)
    local responseText = detailsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    responseText:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -20)
    responseText:SetSize(360, 180)
    responseText:SetJustifyH("LEFT")
    responseText:SetJustifyV("TOP")
    responseText:SetWordWrap(true)

    -- Buttons
    local editBtn = CreateFrame("Button", nil, detailsFrame, "UIPanelButtonTemplate")
    editBtn:SetSize(80, 25)
    editBtn:SetPoint("BOTTOMLEFT", 20, 20)
    editBtn:SetText("Edit")
    editBtn:SetScript("OnClick", function()
        if detailsFrame.data then
            detailsFrame:Hide()
            if not entryFrame then CreateEntryFrame() end
            entryFrame:Show()
            entryFrame.category = detailsFrame.data.category
            entryFrame.entryID = detailsFrame.data.entryID
    
            -- Pre-fill fields with data from the selected entry
            _G["LLM_NameInput"]:SetText(detailsFrame.data.name or "")
            -- Convert keywords table to comma-separated string
            _G["LLM_KeywordInput"]:SetText(table.concat(detailsFrame.data.keywords, ", ") or "")
            _G["LLM_StrategyInput"]:SetText(detailsFrame.data.response or "")
        end
    end)

    local deleteBtn = CreateFrame("Button", nil, detailsFrame, "UIPanelButtonTemplate")
    deleteBtn:SetSize(80, 25)
    deleteBtn:SetPoint("BOTTOMRIGHT", -20, 20)
    deleteBtn:SetText("Delete")
    deleteBtn:SetScript("OnClick", function()
        if detailsFrame.data and detailsFrame.data.entryID and InGameLLM_DB[detailsFrame.data.category] then
            InGameLLM_DB[detailsFrame.data.category][detailsFrame.data.entryID] = nil
            print(string.format("|cFFFF0000Deleted entry: %s|r", detailsFrame.data.name))
            detailsFrame:Hide()
        end
    end)

    -- Store references
    detailsFrame.icon = icon
    detailsFrame.nameText = nameText
    detailsFrame.responseText = responseText
end

-- =============================================
-- Core Initialization
-- =============================================

local MAX_RESULTS = 15
local resultFrames = {}
local debugKeywords = {}

function InGameLLM_OnLoad(frame)
    InGameLLMFrame = frame
    frame:SetSize(700, 350)
    
    -- Get UI elements
    local OutputFrame = _G["InGameLLM_OutputFrame"]
    OutputContainer = OutputFrame:GetScrollChild()
    DebugFrame = _G["InGameLLM_DebugFrame"]
    InputBox = _G["InGameLLM_InputBox"]
    DebugText = _G["InGameLLM_DebugText"]
    DebugScroll = _G["InGameLLM_DebugScroll"]
    
    -- Configure movable frame
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Create result buttons
    for i = 1, MAX_RESULTS do
        local f = CreateFrame("Button", "Result"..i, OutputContainer, "InGameLLM_ResultTemplate")
        f:SetPoint("TOPLEFT", 0, -((i-1)*20))
        f:SetSize(650, 20)  -- Increased width to accommodate category label

        -- Create category label
        f.Category = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        f.Category:SetPoint("LEFT", 10, 0)
        f.Category:SetSize(60, 20)
        f.Category:SetJustifyH("RIGHT")
        f.Category:SetTextColor(1, 0.5, 0.5)  -- --

        -- Adjust existing elements
        if f.Icon then
            f.Icon:ClearAllPoints()
            f.Icon:SetPoint("LEFT", f.Category, "RIGHT", 10, 0)
            f.Icon:SetSize(16, 16)  -- Smaller icon size
        end

        if f.Text then
            f.Text:ClearAllPoints()
            f.Text:SetPoint("LEFT", f.Icon, "RIGHT", 10, 0)
            f.Text:SetJustifyH("LEFT")
        end





        f:SetScript("OnClick", function(self)
            if self.data then
                if not detailsFrame then CreateDetailsFrame() end
                detailsFrame:Show()

                -- Set data
                detailsFrame.data = self.data

                -- Update UI
                detailsFrame.icon:SetTexture("Interface\\Icons\\"..self.data.icon)
                detailsFrame.nameText:SetText(self.data.name)
                detailsFrame.responseText:SetText(self.data.response)
            end
        end)
        resultFrames[i] = f
    end
    
    -- Slash command
    SLASH_INGAMELLM1 = "/ask"
    SlashCmdList["INGAMELLM"] = function() 
        frame:SetShown(not frame:IsShown())
        if frame:IsShown() then
            InputBox:SetFocus()
        end
    end
    
    -- Debug panel background
    local debugBG = DebugFrame:CreateTexture(nil, "BACKGROUND")
    debugBG:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
    debugBG:SetAllPoints(DebugFrame)
    
    DebugFrame:Hide()
end

-- =============================================
-- Fuzzy Search v1
-- =============================================
--[[
local function FuzzyMatch(input, target)
    input = input:lower()
    target = target:lower()
    local j = 1
    for i = 1, #target do
        if j > #input then
            debugKeywords[target] = true
            return true
        end
        if target:sub(i,i) == input:sub(j,j) then
            j = j + 1
        end
    end
    return j > #input
end
]]
-- =============================================
-- Fuzzy Score + Search
-- =============================================
local function FuzzyScore(input, target)
    input = input:lower()
    target = target:lower()
    local score = 0
    local j = 1
    for i = 1, #target do
        if j > #input then break end
        if target:sub(i,i) == input:sub(j,j) then
            score = score + 1
            j = j + 1
        end
    end
    return score
end


function InGameLLM_ProcessQuery(input)
input = input:trim()
wipe(debugKeywords)

if #input < 2 then
    for i = 1, MAX_RESULTS do
        if resultFrames[i] then
            resultFrames[i]:Hide()
        end
    end
    DebugText:SetText("No query")
    return
end

local matches = {}
if InGameLLM_DB then
    for category, entries in pairs(InGameLLM_DB) do
        for id, data in pairs(entries) do
            local score = 0
            local keywordMatches = {}

            -- Check keywords (higher weight)
            for _, keyword in ipairs(data.keywords or {}) do
                local keyScore = FuzzyScore(input, keyword)
                if keyScore > 0 then
                    score = score + keyScore * 3
                    table.insert(keywordMatches, {keyword = keyword, score = keyScore})
                end
            end

            -- Check name (medium weight)
            local nameScore = FuzzyScore(input, data.name or "")
            score = score + nameScore * 2

            -- Check response (lower weight)
            local responseScore = FuzzyScore(input, data.response or "")
            score = score + responseScore

            if score > 0 then
                table.insert(matches, {
                    score = score,
                    name = data.name,
                    response = data.response,
                    icon = data.icon,
                    category = category,
                    keywords = data.keywords,
                    entryID = id,
                    keywordMatches = keywordMatches
                })
            end
        end
    end
end

-- Sort by score descending
table.sort(matches, function(a, b)
    return a.score > b.score
end)

-- Display results
for i = 1, MAX_RESULTS do
    local f = resultFrames[i]
    if f then
        if matches[i] then
            f.Category:SetText(matches[i].category)
            f.Icon:SetTexture("Interface\\Icons\\"..matches[i].icon)
            f.Text:SetText(matches[i].name)
            f.data = matches[i]
            f:Show()

            -- Add matched keywords to debug panel
            for _, match in ipairs(matches[i].keywordMatches) do
                local color
                if match.score >= 3 then
                    color = "|cFF00FF00"  -- Green (strong match)
                elseif match.score >= 2 then
                    color = "|cFFFFFF00"  -- Yellow (medium match)
                else
                    color = "|cFFFF0000"  -- Red (weak match)
                end
                debugKeywords[match.keyword] = color .. match.keyword .. "|r"
            end
        else
            f:Hide()
        end
    end
end

-- Update debug panel
local debugOutput = {}
for keyword, coloredText in pairs(debugKeywords) do
    table.insert(debugOutput, {text = coloredText, color = coloredText:sub(3, 10)})  -- Extract color code
end

-- Sort by color (green > yellow > red)
table.sort(debugOutput, function(a, b)
    if a.color == b.color then
        return a.text < b.text
    end
    -- Green (00FF00) > Yellow (FFFF00) > Red (FF0000)
    return a.color > b.color
end)

-- Combine sorted keywords into a single string
local debugText = ""
for _, entry in ipairs(debugOutput) do
    debugText = debugText .. entry.text .. "\n"
end
DebugText:SetText(debugText ~= "" and debugText or "|cFFFF0000No keyword matches|r")
DebugScroll:SetVerticalScroll(0)
end

-- =============================================
-- Debug Toggle
-- =============================================

SLASH_LLMDEBUG1 = "/llmdebug"
SlashCmdList["LLMDEBUG"] = function()
    DebugFrame:SetShown(not DebugFrame:IsShown())
    print("Debug panel:", DebugFrame:IsShown() and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r")
end


-- =============================================
-- Slash Commands
-- =============================================
SLASH_LLMADD1 = "/lmadd"
SlashCmdList["LLMADD"] = function()
    CreateEntryFrame()
    entryFrame:Show()
end

SLASH_LLMEDIT1 = "/lmedit"
SlashCmdList["LLMEDIT"] = function()
    if not entryFrame then CreateEntryFrame() end
    entryFrame:Show()
end


