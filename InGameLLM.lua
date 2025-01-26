-- =============================================
-- Core Initialization (Classic-Compatible)
-- =============================================

function InGameLLM_OnLoad(frame)
    -- Store reference to main frame
    InGameLLMFrame = frame
    
    -- Create background texture
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
    bg:SetPoint("TOPLEFT", 10, -10)
    bg:SetPoint("BOTTOMRIGHT", -10, 10)
    
    -- Create border textures (Classic-style)
    local borderTop = frame:CreateTexture(nil, "BORDER")
    borderTop:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Border")
    borderTop:SetTexCoord(0.25, 0.75, 0, 0.25)
    borderTop:SetPoint("TOPLEFT", -15, 15)
    borderTop:SetPoint("TOPRIGHT", 15, 15)
    borderTop:SetHeight(32)

    local borderBottom = frame:CreateTexture(nil, "BORDER")
    borderBottom:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Border")
    borderBottom:SetTexCoord(0.25, 0.75, 0.75, 1)
    borderBottom:SetPoint("BOTTOMLEFT", -15, -15)
    borderBottom:SetPoint("BOTTOMRIGHT", 15, -15)
    borderBottom:SetHeight(32)

    local borderLeft = frame:CreateTexture(nil, "BORDER")
    borderLeft:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Border")
    borderLeft:SetTexCoord(0, 0.25, 0.25, 0.75)
    borderLeft:SetPoint("TOPLEFT", -15, 15)
    borderLeft:SetPoint("BOTTOMLEFT", -15, -15)
    borderLeft:SetWidth(32)

    local borderRight = frame:CreateTexture(nil, "BORDER")
    borderRight:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Border")
    borderRight:SetTexCoord(0.75, 1, 0.25, 0.75)
    borderRight:SetPoint("TOPRIGHT", 15, 15)
    borderRight:SetPoint("BOTTOMRIGHT", 15, -15)
    borderRight:SetWidth(32)

    -- Position the frame
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    -- Make frame movable
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Register slash command
    SLASH_INGAMELLM1 = "/ask"
    SlashCmdList["INGAMELLM"] = function()
        frame:SetShown(not frame:IsShown())
    end

    -- Hide by default
    frame:Hide()
end

-- Keep your existing database and query processing code unchanged below

-- =============================================
-- Database
-- =============================================

local database = {
    ["Thunderfury"] = {
        keywords = {"thunderfury", "blessed blade", "legendary sword"},
        response = "|cFF00FF00Thunderfury, Blessed Blade of the Windseeker|r\n"..
                   "Source: Drops from Baron Geddon and Garr in Molten Core.\n"..
                   "Combine bindings with Elementium Ingots."
    },
    ["Illidan Stormrage"] = {
        keywords = {"illidan", "stormrage", "black temple"},
        response = "|cFF00FF00Illidan Stormrage|r\n"..
                   "Location: Black Temple (Shadowmoon Valley, Outland)\n"..
                   "Final boss of the Tier 6 raid."
    },
    ["Defias Brotherhood"] = {
        keywords = {"defias", "brotherhood", "deadmines"},
        response = "|cFF00FF00Defias Brotherhood|r\n"..
                   "Location: Deadmines (Westfall)\n"..
                   "Level range: 18-23\n"..
                   "Final boss: Edwin VanCleef"
    }
}

-- =============================================
-- Query Processing
-- =============================================

function InGameLLM_ProcessQuery(input)
    input = string.lower(input)
    local bestMatch = nil
    local bestScore = 0

    -- Search database
    for entryName, data in pairs(database) do
        local score = 0
        for _, keyword in ipairs(data.keywords) do
            if string.find(input, string.lower(keyword)) then
                score = score + 1
            end
        end
        
        -- Update best match
        if score > bestScore then
            bestScore = score
            bestMatch = data.response
        end
    end

    -- Display results
    OutputText:SetText(bestMatch or "|cFFFF0000No matching information found.|r")
    OutputFrame:SetVerticalScroll(0) -- Reset scroll position
end