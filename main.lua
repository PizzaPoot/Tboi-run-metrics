local mod = RegisterMod("sitt", 1)
local enemyCount = 0
local bosscount = 0
local runstartedtime = 0
local runtime = 0
local totalruntime = 0
local roomsentered = 0
local runid = 1
local hassavedata = 0
local json = require("json")
local persistentData = {}
local rundata = {}
local hasconfigmenu = 0
local diedEnding = false
local timeString = ""
local exit = false

function mod:ontick() --temporary
    if Input.IsButtonTriggered(Keyboard.KEY_L, 0)  then
        ModConfigMenu.RemoveSubcategory("Run history", "Current run")
        ModConfigMenu.AddText("Run history", "Current run", "Enemies killed: " .. tostring(enemyCount))
        ModConfigMenu.AddText("Run history", "Current run", "Bosses killed: " .. tostring(bosscount))
        ModConfigMenu.AddText("Run history", "Current run", "Rooms entered: " .. tostring(roomsentered))
        totalruntime = totalruntime + Isaac.GetTime() - runstartedtime
        timeString = mod:getPrettyTime(totalruntime)
        ModConfigMenu.AddText("Run history", "Current run", "Total run time: " .. timeString)
    end
end

function mod:getPrettyTime(time)
    local totalSeconds = time / 1000
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = math.floor(totalSeconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function modConfigMenuInit()
    if ModConfigMenu == nil then
        hasconfigmenu = 255
    end
    ModConfigMenu.AddTitle("Run history", "Info", "Run stats history")
    ModConfigMenu.AddTitle("Run history", "Info", "By PizzaPoot")
    ModConfigMenu.AddSpace("Run history", "Info")

    ModConfigMenu.AddTitle("Run history", "Current run", "Current run stats")
    ModConfigMenu.AddSpace("Run history", "Current run")
    ModConfigMenu.AddText("Run history", "Current run", "Enemies killed: " .. tostring(enemyCount))
    ModConfigMenu.AddText("Run history", "Current run", "Bosses killed: " .. tostring(bosscount))
    ModConfigMenu.AddText("Run history", "Current run", "Rooms entered: " .. tostring(roomsentered))
    totalruntime = totalruntime + Isaac.GetTime() - runstartedtime
    timeString = mod:getPrettyTime(totalruntime)
    ModConfigMenu.AddText("Run history", "Current run", "Total run time: " .. timeString)

    ModConfigMenu.AddTitle("Run history", "History", "Previous run stats")
    ModConfigMenu.AddSpace("Run history", "History")
    for key, data in ipairs(persistentData) do --load history
        local prettyTotalRunTime = mod:getPrettyTime(data.totalruntime)
        if data.diedEnding == true then
            ending = "Died"
        elseif data.exited == true then
            ending = "Exited"
        else
            ending = "Completed"
        end
        ModConfigMenu.AddText("Run history", "History", "Enemies killed" .. tostring(data.enemyCount) .. "Bosses killed" .. tostring(data.bosscount))
        ModConfigMenu.AddText("Run history", "History", "Rooms entered" .. tostring(data.roomsentered) ..  "Total run time" .. tostring(prettyTotalRunTime) ..  "End: " .. ending)
        ModConfigMenu.AddSpace("Run history", "History")
        --Maybe have to do some scrollbar shit cause idk if it lets me scroll in the menu 
    end
end


local function runstarted(_,continue)
    hassavedata = 0
    hasconfigmenu = 0
    modConfigMenuInit()
    runstartedtime = Isaac.GetTime()
    Isaac.ConsoleOutput("\n run started\n continue: " .. tostring(continue))
    persistentData = json.decode(mod:LoadData())
    if continue == true then
        if mod:HasData() then
            for key in ipairs(persistentData) do
                if key > runid then
                    runid = key
                end
            end
            Isaac.ConsoleOutput("\n HasData: ".. tostring(mod:HasData()))
            Isaac.ConsoleOutput("\n runid:" .. tostring(runid) .. "\n" .. tostring(persistentData[runid]))
            if persistentData[runid] == nil then
                Isaac.ConsoleOutput("\n no save data found(WTF)")
                hassavedata = 255
                return
            end
            rundata = persistentData[runid]
            runid = rundata.runid
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
    elseif enemy:GetBossID() ~= 0 and CurrentRoom:GetType() ~= RoomType.ROOM_BOSS then
        enemyCount = enemyCount + 1
    end
end


function mod:runended(_, died)

    runtime = Isaac.GetTime() - runstartedtime
    totalruntime = totalruntime + runtime
    if died == true then
        diedEnding = true
    else
        diedEnding = false
    end
    rundata = {runid = runid, enemyCount = enemyCount, bosscount = bosscount, totalruntime = totalruntime, roomsentered = roomsentered, diedEnding = diedEnding, exited=false}
    persistentData[runid] = rundata
    local jsonString = json.encode(persistentData)
    mod:SaveData(jsonString)
end


function mod:exitedrun(createsave)
    runtime = Isaac.GetTime() - runstartedtime
    totalruntime = totalruntime + runtime
    if createsave == true then
        exit = true
    else
        exit = false
    end
    rundata = {runid = runid, enemyCount = enemyCount, bosscount = bosscount, totalruntime = totalruntime, roomsentered = roomsentered, diedEnding = diedEnding, exited=exit}
    persistentData[runid] = rundata
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