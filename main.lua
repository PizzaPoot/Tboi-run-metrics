local mod = RegisterMod("sitt", 1)
local enemyCount = 0

function mod:onEnemyDeath()
    enemyCount = enemyCount + 1
    Isaac.ConsoleOutput(tostring(enemyCount))
end

Isaac.DebugString("Mod initialized")





mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.onEnemyDeath)
