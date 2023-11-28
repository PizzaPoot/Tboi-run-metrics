local mod = RegisterMod("sitt", 1)
local enemyCount = 0
local bosscount = 0
function mod:onEnemyDeath(enemy)
    if CurrentRoom:GetType() == RoomType.ROOM_BOSS and CurrentRoom:GetAliveEnemiesCount() == 1 then
        bosscount = bosscount + 1
    elseif enemy:GetBossID() == 0 then
        enemyCount = enemyCount + 1
    end
    Isaac.ConsoleOutput(tostring(enemy:GetBossID()))
    Isaac.ConsoleOutput(tostring(enemy:IsBoss()))
    --[[
    Enembid = enemy:GetBossID()
    if enemy:IsBoss() == true and enemy:GetBossID() ~= 0 then
        bosscount = bosscount + 1
    else
        enemyCount = enemyCount + 1
    end
    --]]
end



function mod:onRoomCleared()
    CurrentRoom = Game():GetRoom()
end
--[[
    local entities = Isaac.GetRoomEntities()
    for i = 1, #entities do
        if entities[i].Type == EntityType.ENTITY_LARRYJR then
            return true
        end
    end
    return false
--]]
Isaac.DebugString("Mod initialized")


function mod:render()
    Isaac.RenderText("enemies killed: " ..enemyCount, 100, 100, 255, 255, 255, 255)
    Isaac.RenderText("bosses killed:  " ..bosscount, 100, 90, 255, 255, 255, 255)
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.render)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.onEnemyDeath)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onRoomCleared)
--mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.gametick)