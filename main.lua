local mod = RegisterMod("sitt", 1)
local enemyCount = 0
local bosscount = 0
local runstartedtime = 0
local runtime = 0
local totalruntime = 0
local roomsentered = 0
local runid = 0
local hassavedata = 0
local json = require("json")
mod:RemoveData() --remove data for testing purposes
--idk if tboi allows only one persistent data table per mod, maybe have to make enemycount2 and so on for each run
local persistentData = {}


function mod:runstarted(_, continue)
    runstartedtime = Isaac.GetTime()
    if continue == false then
        if mod:HasData() == false then
            runid = 0
        else
            runid = persistentData.runid + 1
        end
        --currentrunid = check last runid and add 1
        enemyCount = 0
        bosscount = 0
        totalruntime = 0
        roomsentered = 0
    else
        Isaac.ConsoleOutput("\n loading save data")
        if mod:HasData() then
            persistentData = json.decode(mod:LoadData())
            enemyCount = persistentData.enemyCount
            bosscount = persistentData.bosscount
            totalruntime = persistentData.totalruntime
            roomsentered = persistentData.roomsentered
            Isaac.ConsoleOutput("\n loaded save data")
        else
            Isaac.ConsoleOutput("\n no save data found")
            hassavedata = 255
        end
    end
end


function mod:onEnemyDeath(enemy)
    if CurrentRoom:GetType() == RoomType.ROOM_BOSS and CurrentRoom:GetAliveEnemiesCount() <= 1 then
        bosscount = bosscount + 1 --counts boss kills only in the boss room
    elseif enemy:GetBossID() == 0 then
        enemyCount = enemyCount + 1 --wont count bosses in not boss rooms
    end
end


function mod:runended(_, died)
    runtime = Isaac.GetTime() - runstartedtime
    totalruntime = totalruntime + runtime
    Isaac.ConsoleOutput("\n run ended  saving data")
    persistentData = {
        runid = runid,
        enemyCount = enemyCount,
        bosscount = bosscount,
        totalruntime = totalruntime,
        roomsentered = roomsentered
    }
    --[[Idk if this works
    local jsonString = json.encode(persistentData)
    mod:SaveData(jsonString)
    --]]

end


function mod:exitedrun()
    runtime = Isaac.GetTime() - runstartedtime
    totalruntime = totalruntime + runtime
    --[[Idk if this works
    local jsonString = json.encode(persistentData)
    mod:SaveData(jsonString)
    
    local jsonString = json.encode(persistentData)
    mod:SaveData(jsonString)
    --]]
end


function mod:onRoomCleared()
    CurrentRoom = Game():GetRoom()
    if CurrentRoom:IsFirstVisit() then
        roomsentered = roomsentered + 1
    end
end



Isaac.DebugString("Run history initialized")


function mod:render()
    Isaac.RenderText("enemies: " ..enemyCount.. " bosses: "..bosscount.." runid: "..runid, 100, 90, 255, 255, 255, 255)
    Isaac.RenderText("No saved data found", 100, 80, 255, 0, 0, hassavedata)
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.render)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.onEnemyDeath)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onRoomCleared)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.runstarted)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.runended)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.exitedrun)