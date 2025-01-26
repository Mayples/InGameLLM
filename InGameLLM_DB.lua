local DB = {
    ITEMS = {},
    QUESTS = {},
    NPC = {}
}

function DB:Merge(newDB)
    for category, entries in pairs(newDB) do
        if self[category] then
            for id, data in pairs(entries) do
                self[category][id] = data
            end
        end
    end
end

InGameLLM_DB = DB