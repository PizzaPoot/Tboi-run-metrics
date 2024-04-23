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
local datestarted
local dateended
local hasOS = 0
local settings = {myBoolean = false}
local floor = ""


local function modConfigMenuInit()
    if ModConfigMenu == nil then
        hasconfigmenu = 255
    end
    ModConfigMenu.SetCategoryInfo("Run history", "Tracks stats of the current run.")
    ModConfigMenu.AddTitle("Run history", "Run Stats Tracker")
    ModConfigMenu.AddText("Run history", "by PizzaPoot")
    ModConfigMenu.AddSpace("Run history")
    ModConfigMenu.AddText("Run history", "Run Stats Tracker tracks certain stats")
    ModConfigMenu.AddText("Run history", "of the current run and saves them")
    ModConfigMenu.AddText("Run history", " for later viewing.")
    ModConfigMenu.AddSpace("Run history")
    ModConfigMenu.AddText("Run history", "This mod is still in development and bad XD")
    ModConfigMenu.AddSpace("Run history")
    ModConfigMenu.AddSetting("Run history",
  {
    Type = ModConfigMenu.OptionType.BOOLEAN,
    CurrentSetting = function()
      return settings.myBoolean
    end,
    Display = function()
      return "Debug HUD: " .. (settings.myBoolean and "on" or "off")
    end,
    OnChange = function(b)
      settings.myBoolean = b
    end,
    Info = {
      "Toggle the visibility of the debug HUD",
      "The debug HUD shows stats of the current run",
    }
  }
)
end


function mod:onTick()
    if Input.IsButtonTriggered(Keyboard.KEY_DELETE, 0) and Input.IsButtonTriggered(Keyboard.KEY_H, 0) then --H + DEL to delete save data
        Isaac.ConsoleOutput("\n REMOVED MOD DATA")
        mod:RemoveData()
    end
    floor = Game():GetLevel():GetName()
end


local function runstarted(_,continue)
    hassavedata = 0
    hasconfigmenu = 0
    runstartedtime = Isaac.GetTime()
    persistentData = json.decode(mod:LoadData())
    if continue == true then
        if mod:HasData() then
            for key in ipairs(persistentData) do
                if key > runid then
                    runid = key
                end
            end
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
            return
        else
            Isaac.ConsoleOutput("\n no save data found")
            hassavedata = 255
        end
    elseif continue == false then
        if mod:HasData() == false then
            Isaac.ConsoleOutput("\n no save data found")
            runid = 1
        else
            for key in ipairs(persistentData) do
                if key > runid then
                    runid = key
                end
            end
            runid = runid + 1
        end
        enemyCount = 0
        bosscount = 0
        totalruntime = 0
        roomsentered = 0
        diedEnding = false
        floor = ""
        datestarted = os.date("%Y%m%d%H%M%S")
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


function mod:runended(died)
    if died then
        diedEnding = true
    else
        diedEnding = false
    end
end


function mod:exitedrun(createsave) --Save data
    runtime = Isaac.GetTime() - runstartedtime
    totalruntime = totalruntime + runtime
    dateended = os.date("%Y%m%d%H%M%S")
    floor = Game():GetLevel():GetName()
    rundata = {runid = runid, enemyCount = enemyCount, bosscount = bosscount, totalruntime = totalruntime, roomsentered = roomsentered, datestarted = datestarted, dateended = dateended, floor = floor, diedEnding = diedEnding, exited=createsave}
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
modConfigMenuInit()
if os == nil then
    hasOS = 255
end

function mod:render()
    local x = 60
    local y = 35
    if settings.myBoolean == true then
    Isaac.RenderText("enemies killed: " ..tostring(enemyCount), x, y, 255, 255, 255, 255)
    Isaac.RenderText("bosses killed: "..tostring(bosscount), x, y + 10, 255, 255, 255, 255)
    Isaac.RenderText("runid: "..tostring(runid), x, y + 20, 255, 255, 255, 255)
    Isaac.RenderText("total runtime: " ..tostring(totalruntime), x, y + 30, 255, 255, 255, 255)
    Isaac.RenderText("rooms entered: " ..tostring(roomsentered), x, y + 40, 255, 255, 255, 255)
    Isaac.RenderText("date started: " ..tostring(datestarted), x, y + 50, 255, 255, 255, 255)
    Isaac.RenderText("date ended: " ..tostring(dateended), x, y + 60, 255, 255, 255, 255)
    Isaac.RenderText("floor: " ..tostring(floor), x, y + 70, 255, 255, 255, 255)
    end
    Isaac.RenderText("No saved data found", 100, 60, 255, 0, 0, hassavedata)
    Isaac.RenderText("ModConfigMenu NOT FOUND", 100, 80, 255, 0, 0, hasconfigmenu)
    Isaac.RenderText("You dont have luadebug enabled", 100, 70, 255, 0, 0, hasOS)
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.render)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.onEnemyDeath)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onRoomCleared)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, runstarted)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.runended)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.exitedrun)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onTick)

Isaac.ConsoleOutput("Run History Tracker - Loaded")