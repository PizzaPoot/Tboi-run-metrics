local mod = RegisterMod("sitt", 1)
local enemyCount = 0

function mod:onEnemyDeath()
    enemyCount = enemyCount + 1
end

Isaac.DebugString("Mod initialized")


function mod:GameTick()
    Isaac.ConsoleOutput(tostring(enemyCount))
    print(enemyCount)
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    Isaac.RenderText("Killed enemies: " .. enemyCount, 100, 100, 255, 255, 255, 255)
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.GameTick)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.onEnemyDeath)
