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
       -- local f = CreateFrame("Button", nil, OutputContainer, "InGameLLM_ResultTemplate")
        f:SetPoint("TOPLEFT", 0, -((i-1)*20))
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
    
    -- Detail popup
    StaticPopupDialogs["InGameLLM_DetailPopup"] = {
        text = "Details",
        button2 = CLOSE,
        hasEditBox = true,
        editBoxWidth = 350,
        OnShow = function(self, data)
            self.editBox:SetText(data.text)
            self.editBox:HighlightText(0, 0)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true
    }
    
    -- Debug panel background
    local debugBG = DebugFrame:CreateTexture(nil, "BACKGROUND")
    debugBG:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
    debugBG:SetAllPoints(DebugFrame)
    
    DebugFrame:Hide()
end

-- =============================================
-- Fuzzy Search
-- =============================================

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

-- =============================================
-- Query Processing
-- =============================================

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
            if type(entries) == "table" then
                for id, data in pairs(entries) do
                    if type(data) == "table" and data.keywords then
                        local match = false
                        for _, keyword in ipairs(data.keywords) do
                            if FuzzyMatch(input, keyword) then
                                match = true
                            end
                        end
                        if match then
                            table.insert(matches, {
                                name = data.name or "Unknown",
                                response = data.response or "No description",
                                icon = data.icon or "inv_misc_questionmark",
                                category = category or "Misc"
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Sort results
    table.sort(matches, function(a,b)
        if a.category == b.category then
            return a.name < b.name
        end
        return a.category < b.category
    end)
    
    -- Display results
    for i = 1, MAX_RESULTS do
        local f = resultFrames[i]
        if f then
            if matches[i] then
                if f.Icon then
                    f.Icon:SetTexture("Interface\\Icons\\"..matches[i].icon)
                end
                if f.Text then
                    f.Text:SetText(matches[i].name)
                end
                f:Show()
            else
                f:Hide()
            end
        end
    end
    InGameLLM_OutputFrame:SetVerticalScroll(0)
    
    -- Update debug panel
    local debugOutput = {}
    for keyword in pairs(debugKeywords) do
        table.insert(debugOutput, "|cFF00FF00"..keyword.."|r")
    end
    DebugText:SetText(table.concat(debugOutput, "\n") or "|cFFFF0000No keyword matches|r")
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