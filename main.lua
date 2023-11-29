local mod = RegisterMod("sitt", 1)
local enemyCount = 0
local bosscount = 0
local runstartedtime = 0
local runtime = 0
local totalruntime = 0


function mod:onEnemyDeath(enemy)
    if CurrentRoom:GetType() == RoomType.ROOM_BOSS and CurrentRoom:GetAliveEnemiesCount() == 1 then
        bosscount = bosscount + 1 --counts boss kills only in the boss room
    elseif enemy:GetBossID() == 0 then
        enemyCount = enemyCount + 1 --wont count bosses in not boss rooms
    end
end


function mod:runstarted(_, continue)
    runstartedtime = Isaac.GetTime()
    if continue == false then
        enemyCount = 0
        bosscount = 0
    else
        Isaac.ConsoleOutput("\n loading save data")
        --load save data
    end
end


function mod:runended(_, died)
    runtime = Isaac.GetTime() - runstartedtime
    totalruntime = totalruntime + runtime
    Isaac.ConsoleOutput("\n run ended  saving data")
    --save data
end


function mod:exitedrun()
    runtime = Isaac.GetTime() - runstartedtime
    totalruntime = totalruntime + runtime
    Isaac.ConsoleOutput("\n exited run")
    --save data
end


function mod:onRoomCleared()
    CurrentRoom = Game():GetRoom()
end



Isaac.DebugString("Run history initialized")


function mod:render()
    Isaac.RenderText("enemies killed: " ..enemyCount, 100, 100, 255, 255, 255, 255)
    Isaac.RenderText("bosses killed:  " ..bosscount, 100, 90, 255, 255, 255, 255)
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.render)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.onEnemyDeath)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onRoomCleared)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.runstarted)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.runended)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.exitedrun)