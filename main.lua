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
local persistentData = {}
local rundata = {}
local hasconfigmenu = 0

function mod:ontick() --temporary
    if Input.IsButtonPressed(Keyboard.KEY_U, 0)  then
        mod:RemoveData()
        Isaac.ConsoleOutput("\n deleted data")
    end
end


local function modConfigMenuInit()
    if ModConfigMenu == nil then
        hasconfigmenu = 255
    end
    ModConfigMenu.AddTitle("Run history", "Info", "Your previous runs")
    ModConfigMenu.AddSpace("Run history", "Info")
    ModConfigMenu.AddText("Run history", "Runs", "My Text")
    ModConfigMenu.AddSpace("Run history", "Runs")
    
end

local function runstarted(_,continue)
    modConfigMenuInit()
    runstartedtime = Isaac.GetTime()
    Isaac.ConsoleOutput("\n run started\n continue: " .. tostring(continue))
    persistentData = json.decode(mod:LoadData())
    Isaac.ConsoleOutput("\n loaded persistentData")
    if continue == true then
        if mod:HasData() then
            for key in ipairs(persistentData) do
                if key > runid then
                    runid = key
                end
            end
            Isaac.ConsoleOutput("\n runid:" .. tostring(runid) .. "\n" .. tostring(persistentData[runid]))
            if persistentData[runid] == nil then
                Isaac.ConsoleOutput("\n no save data found(WTF)")
                hassavedata = 255
                return
            end
            rundata = persistentData[runid]
            enemyCount = rundata.enemyCount
            bosscount = rundata.bosscount
            totalruntime = rundata.totalruntime
            roomsentered = rundata.roomsentered

            Isaac.ConsoleOutput("\n loaded save data")
            return
        else
            Isaac.ConsoleOutput("\n no save data found")
            hassavedata = 255
        end
    elseif continue == false then
        Isaac.ConsoleOutput("\n HasData: " .. tostring(mod:HasData()))
        if mod:HasData() == false then
            Isaac.ConsoleOutput("\n no save data found")
            runid = 1
        else
            Isaac.ConsoleOutput("\n loading runid")
            for key in ipairs(persistentData) do
                if key > runid then
                    runid = key
                end
            end
            runid = runid + 1
            Isaac.ConsoleOutput("\n runid:" .. tostring(runid))
        end
        enemyCount = 0
        bosscount = 0
        totalruntime = 0
        roomsentered = 0
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
    rundata = {runid = runid, enemyCount = enemyCount, bosscount = bosscount, totalruntime = totalruntime, roomsentered = roomsentered}
    persistentData[runid] = {rundata}
    local jsonString = json.encode(persistentData)
    mod:SaveData(jsonString)
end


function mod:exitedrun()

    runtime = Isaac.GetTime() - runstartedtime
    totalruntime = totalruntime + runtime
    rundata = {runid = runid, enemyCount = enemyCount, bosscount = bosscount, totalruntime = totalruntime, roomsentered = roomsentered}
    persistentData[runid] = {rundata}
    local jsonString = json.encode(persistentData)
    mod:SaveData(jsonString)
end


function mod:onRoomCleared()
    CurrentRoom = Game():GetRoom()
    if CurrentRoom:IsFirstVisit() then
        roomsentered = roomsentered + 1
    end
end



Isaac.DebugString("Run history initialized")


function mod:render()
    Isaac.RenderText("enemies: " ..tostring(enemyCount).. " bosses: "..tostring(bosscount).." runid: "..tostring(runid), 100, 90, 255, 255, 255, 255)
    Isaac.RenderText("No saved data found", 100, 80, 255, 0, 0, hassavedata)
    Isaac.RenderText("ModConfigMenu NOT FOUND", 100, 80, 255, 0, 0, hasconfigmenu)
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.render)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.onEnemyDeath)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onRoomCleared)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, runstarted)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.runended)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.exitedrun)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.ontick)