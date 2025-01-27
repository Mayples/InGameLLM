if InGameLLM_DB and InGameLLM_DB.Merge then
    InGameLLM_DB:Merge({
        ITEMS = {
            [19019] = {
                name = "Thunderfury, Blessed Blade of the Windseeker",
                keywords = {"legendary", "sword", "thunderfury"},
                response = "Drops from Baron Geddon/Garr in Molten Core. Required for the quest 'Thunderfury'.",
                icon = "inv_sword_39"
            },
            [19872] = {
                name = "Lucid Nightmare Mount",
                keywords = {"mount", "secret", "puzzle"},
                response = "Solve the Lucid Nightmare puzzle in Legion Dalaran. Guide: /lmadd search 'lucid nightmare guide'.",
                icon = "inv_misc_head_dragon_black"
            }
        },
        QUESTS = {
            [7848] = {
                name = "Attunement to the Core",
                keywords = {"molten core", "attunement", "blackrock"},
                response = "Start in Blackrock Depths. Requires killing Lyceum mobs. Unlocks Molten Core access.",
                icon = "inv_misc_scroll_02"
            }
        },
        TIPS = {
            GoldTip = {  -- Changed to plain string key
                name = "Gold Farming Tip",
                keywords = {"gold", "farming", "auction house"},
                response = "Farm Un'Goro Crater for Deviate Fish and sell them on the Auction House.",
                icon = "inv_misc_coin_01"
            }
        }
    })
else
  --  print("")
end