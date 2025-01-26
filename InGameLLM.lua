-- Early declaration (prevents nil errors)
function InGameLLM_OnLoad(frame) end

-- =============================================
-- Core Initialization
-- =============================================

local MAX_RESULTS = 15
local resultFrames = {}

function InGameLLM_OnLoad(frame) -- Now properly defined
    InGameLLMFrame = frame
    frame:SetSize(450, 350)
    
    -- Create results container reference
    OutputContainer = _G["OutputContainer"]
    
    -- Make movable
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Create results frames
    for i = 1, MAX_RESULTS do
        local f = CreateFrame("Button", "Result"..i, OutputContainer, "ResultTemplate")
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
end

-- =============================================
-- Fuzzy Search
-- =============================================

local function FuzzyMatch(input, target)
    input = input:lower()
    target = target:lower()
    local j = 1
    for i = 1, #target do
        if j > #input then return true end
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
    if #input < 2 then
        for i = 1, MAX_RESULTS do
            if resultFrames[i] then
                resultFrames[i]:Hide()
            end
        end
        return
    end
    
    local matches = {}
    
    -- Search database
    if InGameLLM_DB then
        for category, entries in pairs(InGameLLM_DB) do
            if type(entries) == "table" then
                for id, data in pairs(entries) do
                    if type(data) == "table" and data.keywords then
                        local match = false
                        for _, keyword in ipairs(data.keywords) do
                            if FuzzyMatch(input, keyword) then
                                match = true
                                break
                            end
                        end
                        if match then
                            table.insert(matches, {
                                name = data.name or "Unknown",
                                response = data.response or "No description",
                                icon = data.icon or "temp",
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
        if matches[i] then
            local textField = _G[f:GetName().."Text"]
            textField:SetText(matches[i].name)
            
            -- Safeguard icon access
            if f.Icon then
                if matches[i].icon and matches[i].icon ~= "" then
                    f.Icon:SetTexture("Interface\\Icons\\"..matches[i].icon)
                else
                    f.Icon:SetTexture("Interface\\Icons\\inv_misc_questionmark")
                end
                f.Icon:Show()
            end
            
            f.data = matches[i]
            f:Show()
        else
            if f.Icon then f.Icon:Hide() end
            f:Hide()
        end
    end
    OutputFrame:SetVerticalScroll(0)
end


-- =============================================
-- ATT Integration
-- =============================================

if LibStub then
    local ATT = LibStub("AceAddon-3.0"):GetAddon("AllTheThings", true)
    if ATT then
        function InGameLLM_GetATTData(itemID)
            return ATT.GetItemData(itemID)
        end
    end
end