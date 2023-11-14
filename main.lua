local mod = RegisterMod("sitt", 1)
local enemyCount = 0
local bosscount = 0
function mod:onEnemyDeath(enemy)
    if enemy:IsBoss() == true and Game():GetRoom():GetType() ~= RoomType.ROOM_MINIBOSS and enemy:GetLastParent():IsDead() then
        bosscount = bosscount + 1
    else
        enemyCount = enemyCount + 1
    end


end


Isaac.DebugString("Mod initialized")


function mod:render()
    Isaac.RenderText("Killed enemies: " .. enemyCount, 100, 100, 255, 255, 255, 255)
    Isaac.RenderText("Killed bosses: " ..bosscount, 100, 90, 255, 255, 255, 255)
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.render)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.onEnemyDeath)