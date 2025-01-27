InGameLLM_DB = InGameLLM_DB or {
    ITEMS = {},
    QUESTS = {},
    NPCS = {},
    ZONES = {},
    TIPS = {}
}

-- Add Merge function to database
function InGameLLM_DB:Merge(data)
    for category, entries in pairs(data) do
        self[category] = self[category] or {}
        for id, entry in pairs(entries) do
            entry.entryID = id
            entry.category = category
            entry.keywords = entry.keywords or {}
            self[category][id] = entry
        end
    end
end


-- Assign to global AFTER defining Merge


-- Registration function (call Merge via DB)
function LoremasterLexicon_RegisterDataPack(dataPack)
    DB:Merge(dataPack)  -- Directly use DB instead of InGameLLM_DB
end





-- Run when the player enters the world


--InGameLLM_DB = DB