local mod = RegisterMod("sitt", 1)
local enemyCount = 0
local bosscount = 0
local runstartedtime = 0
local runtime = 0
local totalruntime = 0
local roomsentered = 0
local json = require("json")
local persistentData = {
    enemyCount = 0,
    bosscount = 0,
    totalruntime = 0,
    roomsentered = 0

  }

function mod:onEnemyDeath(enemy)
    if CurrentRoom:GetType() == RoomType.ROOM_BOSS and CurrentRoom:GetAliveEnemiesCount() <= 1 then
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
    --Idk if this works
    local jsonString = json.encode(persistentData)
    mod:SaveData(jsonString)
end


function mod:exitedrun()
    runtime = Isaac.GetTime() - runstartedtime
    totalruntime = totalruntime + runtime
    Isaac.ConsoleOutput("\n exited run, runtime: " .. runtime / 1000 .. "sec" .. ", total runtime: " .. totalruntime / 1000 .."sec")
    --Idk if this works
    local jsonString = json.encode(persistentData)
    mod:SaveData(jsonString)
end


function mod:onRoomCleared()
    if CurrentRoom:IsFirstVisit() then
        roomsentered = roomsentered + 1
    end
    CurrentRoom = Game():GetRoom()
end



Isaac.DebugString("Run history initialized")


function mod:render()
    Isaac.RenderText("enemies killed: " ..enemyCount, 100, 100, 255, 255, 255, 255)
    Isaac.RenderText("bosses killed:  " ..bosscount, 100, 90, 255, 255, 255, 255)
    Isaac.RenderText("rooms entered:  " ..roomsentered, 100, 80, 255, 255, 255, 255)
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.render)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.onEnemyDeath)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onRoomCleared)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.runstarted)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.runended)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.exitedrun)