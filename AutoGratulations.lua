-- Each message takes a player name (%s), then their new level (%d).
local messages = {
    "gz %s on %d!",
    "grats %s, %d!",
    "nice, %s hit %d. gz!",
    "gz %s, level %d",
    "grats on the ding %s! %d now",
}

local levels = {}
local ready = false
local elapsedTime = 0
local frame = CreateFrame("Frame")

local function Print(text)
    DEFAULT_CHAT_FRAME:AddMessage("|cff80ff80Auto Gratulations:|r " .. text)
end

local function IsRaid()
    if IsInRaid then
        return IsInRaid()
    end
    return GetNumRaidMembers and GetNumRaidMembers() > 0
end

local function ScanParty(announce)
    if not ready then return end
    if IsRaid() then
        levels = {}
        return
    end

    local present = {}
    for index = 1, 4 do
        local unit = "party" .. index
        if UnitExists(unit) and UnitIsConnected(unit) then
            local name, realm = UnitName(unit)
            local level = UnitLevel(unit)
            if name and name ~= UNKNOWNOBJECT then
                local identity = name
                if realm and realm ~= "" then
                    identity = name .. "-" .. realm
                end
                present[identity] = true
                local previous = levels[identity]
                -- Unknown/out-of-range levels must never replace a known level.
                if level and level > 0 then
                    levels[identity] = level
                    if announce and AutoGratulationsDB.enabled and previous and level > previous then
                        local nextMessage = AutoGratulationsDB.nextMessage
                        local message = string.format(messages[nextMessage], name, level)
                        SendChatMessage(message, "PARTY")
                        AutoGratulationsDB.nextMessage = nextMessage + 1
                        if AutoGratulationsDB.nextMessage > table.getn(messages) then
                            AutoGratulationsDB.nextMessage = 1
                        end
                    end
                end
            end
        elseif UnitExists(unit) then
            -- Retain the baseline while a party member is disconnected.
            local name, realm = UnitName(unit)
            if name then
                local identity = name
                if realm and realm ~= "" then identity = name .. "-" .. realm end
                present[identity] = true
            end
        end
    end

    for identity in pairs(levels) do
        if not present[identity] then levels[identity] = nil end
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, eventName)
    -- Older clients expose event arguments as globals.
    eventName = eventName or event
    if eventName == "PLAYER_LOGIN" then
        if type(AutoGratulationsDB) ~= "table" then AutoGratulationsDB = {} end
        if AutoGratulationsDB.enabled == nil then AutoGratulationsDB.enabled = true end
        local nextMessage = AutoGratulationsDB.nextMessage
        if type(nextMessage) ~= "number" or nextMessage < 1
            or nextMessage > table.getn(messages) or nextMessage ~= math.floor(nextMessage) then
            AutoGratulationsDB.nextMessage = 1
        end
        ready = true
        ScanParty(false)
    elseif eventName == "PLAYER_ENTERING_WORLD" then
        -- Establish a fresh baseline after loading screens; do not send stale grats.
        levels = {}
        ScanParty(false)
    end
end)

-- Polling also handles clients that update UnitLevel after UNIT_LEVEL fires.
frame:SetScript("OnUpdate", function(self, elapsed)
    elapsedTime = elapsedTime + (elapsed or arg1 or 0)
    if elapsedTime >= 1 then
        elapsedTime = 0
        ScanParty(true)
    end
end)

SLASH_AUTOGRATULATIONS1 = "/autogratulations"
SlashCmdList["AUTOGRATULATIONS"] = function(command)
    if not ready then return end
    command = string.lower(command or "")
    if command == "on" then
        ScanParty(false)
        AutoGratulationsDB.enabled = true
        Print("Enabled.")
    elseif command == "off" then
        AutoGratulationsDB.enabled = false
        Print("Disabled.")
    else
        local status = "disabled"
        if AutoGratulationsDB.enabled then status = "enabled" end
        Print("Currently " .. status .. ". Use /autogratulations on or /autogratulations off.")
    end
end
