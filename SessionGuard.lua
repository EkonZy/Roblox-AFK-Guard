--[[
    Universal Persistence Loader (Master Script)
    ----------------------------------------------------------
    Instructions:
    1. Place THIS file (Universal_Persistence.lua) in your Executor's 'autoexec' folder.
    2. Create a folder named 'my_scripts' in your Executor's 'workspace' folder.
       (Usually: AppData\Local\YourExecutor\workspace\my_scripts)
    3. Put all your other scripts (AntiAFK, TDS, etc.) INSIDE the 'my_scripts' folder.
    4. Do NOT put the other scripts in 'autoexec', otherwise they might run twice (or fail).
    ----------------------------------------------------------
]]

-- Configuration
local SCRIPTS_FOLDER = "my_scripts" -- Name of the folder in workspace containing your scripts
local SELF_PATH = "autoexec/Universal_Persistence.lua" -- Path to this file relative to executor root

local function safeLog(msg)
    print(":: Universal Loader :: " .. tostring(msg))
    if writefile and appendfile then
        pcall(function()
             appendfile("universal_loader_log.txt", os.date("[%H:%M:%S] ") .. tostring(msg) .. "\n")
        end)
    end
end

local function runUserScripts()
    safeLog("Searching for scripts in folder: " .. SCRIPTS_FOLDER)
    
    if not isfolder(SCRIPTS_FOLDER) then
        safeLog("Folder '" .. SCRIPTS_FOLDER .. "' not found. Creating it...")
        makefolder(SCRIPTS_FOLDER)
        safeLog("Please put your .lua/.txt scripts inside 'workspace/" .. SCRIPTS_FOLDER .. "'")
        return
    end

    if listfiles then
        local files = listfiles(SCRIPTS_FOLDER)
        local count = 0
        for _, file in ipairs(files) do
            if file:match("%.lua$") or file:match("%.txt$") then
                safeLog("Executing: " .. file)
                task.spawn(function()
                    local success, err = pcall(function()
                        loadstring(readfile(file))()
                    end)
                    if not success then
                        safeLog("Error executing " .. file .. ": " .. tostring(err))
                    end
                end)
                count = count + 1
            end
        end
        safeLog("Executed " .. count .. " scripts.")
    else
        safeLog("CRITICAL: Executor does not support 'listfiles'. Cannot load scripts.")
    end
end

-- 1. Run all scripts immediately upon joining
safeLog("Initializing...")
if not game:IsLoaded() then
    game.Loaded:Wait()
    task.wait(2) -- Extra buffer
end
runUserScripts()

-- 2. Queue THIS script to run again on the next server
local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

if queue_on_teleport then
    local Players = game:GetService("Players")
    if Players.LocalPlayer then
        safeLog("Registering auto-execute for next server...")
        
        -- Capture own source code to ensure 100% persistence without file access reliance
        local mySource = ""
        if isfile(SELF_PATH) then
            mySource = readfile(SELF_PATH)
            safeLog("Successfully read self source code.")
        else
            safeLog("WARNING: Could not find self at " .. SELF_PATH .. ". Persistence might fail if file IO is blocked.")
        end

        Players.LocalPlayer.OnTeleport:Connect(function(state)
            if state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then
                 safeLog("Teleporting! Queueing persistence...")
                 
                 local queuePayload
                 if mySource ~= "" then
                     -- Option A: We have the source, just run it.
                     -- Use robust string quoting to avoid syntax errors
                     queuePayload = "task.wait(3); loadstring(" .. string.format("%q", mySource) .. ")()"
                 else
                     -- Option B: Fallback to reading file (risky)
                      queuePayload = [[
                         task.wait(3)
                         if isfile("]] .. SELF_PATH .. [[") then
                             loadstring(readfile("]] .. SELF_PATH .. [["))()
                         end
                     ]]
                 end
                 
                 queue_on_teleport(queuePayload)
            end
        end)
    end
else
    safeLog("WARNING: queue_on_teleport not supported. Persistence will fail.")
end
