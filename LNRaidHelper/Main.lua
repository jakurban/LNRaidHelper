--- Opts:
---     name (string): Name of the dropdown (lowercase)
---     parent (Frame): Parent frame of the dropdown.
---     items (Table): String table of the dropdown options.
---     defaultVal (String): String value for the dropdown to default to (empty otherwise).
---     changeFunc (Function): A custom function to be called, after selecting a dropdown option.
local function RH_createDropdown1(opts)
    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
    local menu_items = opts['items'] or {}
    local title_text = opts['title'] or ''
    local dropdown_width = 0
    local default_val = opts['defaultVal'] or ''
    local change_func = opts['changeFunc'] or function (dropdown_val) end
    local dropdown = opts['frame'] or CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')

    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 20, 10)

    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
        if type(item) == 'table' then
            dd_title:SetText(item.title)
        else
            dd_title:SetText(item)
        end
        local text_width = dd_title:GetStringWidth() + 20
        if text_width > dropdown_width then
            dropdown_width = text_width
        end
    end

    UIDropDownMenu_SetWidth(dropdown, min(dropdown_width, 100))
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        for key, val in pairs(menu_items) do
            if type(item) == 'table' then
                info.text = val.title;
            else
                info.text = val;
            end
            info.checked = false
            info.menuList= key
            info.hasArrow = false
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                UIDropDownMenu_SetText(dropdown, b.value)
                --b.checked = true
                change_func(dropdown, b.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return dropdown
end

function RH_createDropdown(parent, name, title, default_val, x, y, anchor)
    local dropdown_name = '$parent_' .. name .. '_dropdown'
    local dropdown = CreateFrame("Frame", dropdown_name, parent, 'UIDropDownMenuTemplate')
    UIDropDownMenu_SetText(dropdown, default_val or '-')
    if title then
        local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
        dd_title:SetText(title)
        dropdown.dd_title = dd_title
        dd_title:SetPoint("TOPLEFT", 20, 10)
    end
    dropdown:SetPoint(anchor or "TOPLEFT", x, y)
    return dropdown
end
function RH_updateDropdown(dropdown, menu_items, width, change_func)
    local dropdown_width = 0
    if not width then
        if dropdown.dd_title then
            dropdown_width = dropdown.dd_title:GetStringWidth() + 20
        end

        local dd_title = nil
        if dropdown.tmp_title then
            dd_title = dropdown.tmp_title
        else 
            dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
            dd_title:Hide()
            dropdown.tmp_title = dd_title
        end

        for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
            if type(item) == 'table' then
                dd_title:SetText(item.title)
            else
                dd_title:SetText(item)
            end
            local text_width = dd_title:GetStringWidth() + 20
            if text_width > dropdown_width then
                dropdown_width = text_width
            end
        end
        dropdown_width = min(dropdown_width, 100)
    else
        dropdown_width = width
    end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        for key, val in pairs(menu_items) do
            if type(item) == 'table' then
                info.text = val.title;
            else
                info.text = val;
            end
            info.checked = false
            info.menuList= key
            info.hasArrow = false
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                UIDropDownMenu_SetText(dropdown, b.value)
                --b.checked = true
                change_func(dropdown, b.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end

local function LN_RH_deep_copy(tb)
    if type(tb) ~= 'table' then
        return tb
    end
    local res = {}
    for k, v in pairs(tb) do
        res[k] = LN_RH_deep_copy(v)
    end
    return res
end

local function LN_RH_emptyChar()
    return {name='', class='Priest'}
end

local function LN_RH_colorizeName(char)
    local colors = {
        ['Death Knight'] = 'C41E3A',
        ['Druid'] = 'FF7C0A',
        ['Hunter'] = 'AAD372',
        ['Mage'] = '3FC7EB',
        ['Paladin'] = 'F48CBA',
        ['Priest'] = 'FFFFFF',
        ['Rogue'] = 'FFF468',
        ['Shaman'] = '0070DD',
        ['Warlock'] = '8788EE',
        ['Warrior'] = 'C69B6D',
    }
    return '|cAA'..colors[char.class]..char.name..'|r'
end
local function LN_RH_characters()
    function IsInRaid() 
        return GetNumRaidMembers() > 0
    end

    function IsInGroup()
        return (GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0)
    end

    function GetNumGroupMembers1()
        if IsInRaid() then 
            return GetNumRaidMembers()
        else
            return GetNumPartyMembers()
        end
    end
    local chars = {}
    local subgroups = {}
    for i = 1, GetNumGroupMembers1() do
        local name, _, subgroup, _, cls = GetRaidRosterInfo(i)
        if name ~= nil then
            if subgroups[subgroup] == nil then
                subgroups[subgroup] = {}
            end
            subgroups[subgroup][#subgroups[subgroup] + 1] = {name=name, ['class'] = cls}
        end
    end
    local i = 1
    for _, subgroup in pairs(subgroups) do
        for _, char in pairs(subgroup) do
            chars[i] = char
            i = i + 1
        end
    end
    return chars
end
local function LN_RH_characters_names()
    local chars = LN_RH_characters()
    local result = {}
    for k, v in pairs(chars) do
        result[k] = LN_RH_colorizeName(v)
    end
    return result
end
local function LN_RH_linksTimings(isTwentyFiveMode)
    local linksTimes = {}
    if isTwentyFiveMode then
        linksTimes = {
            15,
            45,
            75,
            105,
            138, --whirl
            155,
            185,
            215,
            240, --whirl
            260,
            290,
        }
    else
        linksTimes = {
            15,
            45,
            75,
            106,
            135, --whirl
            153,
            183,
            213,
            244, -- ok
            258, --whirl
            275,
        }
    end
    return linksTimes
end

LN_RaidHelper_Sheduler = {}
function LN_RaidHelper_Sheduler:initialize()
    self.isRunning = -1
    self.eventList = {}
    self.frame = CreateFrame("Frame","WaitFrame", UIParent)
    self.frame:Hide()
    self.frame:SetScript("onUpdate", function (self, elapse)
        LN_RaidHelper_Sheduler:handleUpdate(elapse)
    end);
end
function LN_RaidHelper_Sheduler:handleUpdate(elapse)
    if self.isRunning < 1 or self.isRunning > #self.eventList then
        LN_RaidHelper_Sheduler:stop()
        return
    end
    local now = GetTime() - self.startTime
    while self.isRunning <= #self.eventList and self.eventList[self.isRunning].time < now do
        local event = self.eventList[self.isRunning]
        self.isRunning = self.isRunning + 1
        if event.eventType == 'timer' then
            local cmd = 'broadcast timer '..event.duration..' '..event.msg
            SlashCmdList['DEADLYBOSSMODS'](cmd)
        end
    end


end
function LN_RaidHelper_Sheduler:shift_time(list, shift)
    for _, v in pairs(list) do
        local newTime = v.time + shift
        if newTime < 0 and v.eventType == 'timer' then
            v.duration = v.duration + newTime
            newTime = 0
        end
        v.time = newTime
    end
end
function LN_RaidHelper_Sheduler:merge(l1, l2)
    local r = {}
    local i1 = 1
    local i2 = 1
    while i1 <= #l1 or i2 <= #l2 do
        local best = nil
        if i1 <= #l1 and i2 <= #l2 then
            if l1[i1].time < l2[i2].time then
                r[#r + 1] = l1[i1]
                i1 = i1 + 1
            else
                r[#r + 1] = l2[i2]
                i2 = i2 + 1
            end
        elseif i1 <= #l1 then
            r[#r + 1] = l1[i1]
            i1 = i1 + 1
        else
            r[#r + 1] = l2[i2]
            i2 = i2 + 1
        end
    end
    return r
end
function LN_RaidHelper_Sheduler:start(eventList, delay)
    self.isRunning = 1
    self.startTime = GetTime() - (delay or 0)
    self.eventList = eventList
    self.frame:Show()
end
function LN_RaidHelper_Sheduler:startBQL(maxPlayers, delay)
    local bites = {}
    local biteTimes = {}
    if maxPlayers == 25 then
        biteTimes = {
            77, 137, 199, 261
        }
    else
        biteTimes = {
            92, 167, 244, 319
        }
    end
    local bitesTimerDuration = 20
    for b, t in pairs(biteTimes) do
        if b == #biteTimes then break end
        for j=1,2^(b - 1) do
            local b1 = LNRaidHelperDB.bites[j].name == '' and ('char'..j) or LNRaidHelperDB.bites[j].name
            local j2 = j + 2^(b - 1)
            local b2 = LNRaidHelperDB.bites[j2].name == '' and ('char'..j2) or LNRaidHelperDB.bites[j2].name
            bites[#bites + 1] = {time=t,eventType='timer', msg = b1..' -> '..b2, duration = bitesTimerDuration}
        end
    end
    if maxPlayers == 25 then
        for j=1,4 do
            local b1 = LNRaidHelperDB.bites[j].name == '' and ('char'..j) or LNRaidHelperDB.bites[j].name
            local j2 = j + 8
            local b2 = LNRaidHelperDB.bites[j2].name == '' and ('char'..j2) or LNRaidHelperDB.bites[j2].name
            local j3 = j + 4
            local b3 = LNRaidHelperDB.bites[j3].name == '' and ('char'..j3) or LNRaidHelperDB.bites[j3].name
            local j4 = j3 + 8
            local b4 = LNRaidHelperDB.bites[j4].name == '' and ('char'..j4) or LNRaidHelperDB.bites[j4].name

            bites[#bites + 1] = {time=biteTimes[#biteTimes], eventType='timer',
                msg = string.sub(b1, 1, 5)..' > '..string.sub(b2, 1, 5)..' // '..string.sub(b3, 1, 5)..' > '..string.sub(b4, 1, 5),
                duration = bitesTimerDuration
            }
        end
    end
    LN_RaidHelper_Sheduler:shift_time(bites, -bitesTimerDuration)
    local links = {}
    local linksTimerDuration = 20
    local linksTimes = LN_RH_linksTimings(maxPlayers == 25)
    for i, t in pairs(linksTimes) do
        local index = ((i - 1) % 5) + 1
        local am = LNRaidHelperDB.links[index].am
        local ds = LNRaidHelperDB.links[index].ds
        local msg = ''
        local msg2 = ''
        if am.name ~= '' then
            msg = am.name .. ' AM'
        end
        if ds.name ~= '' then
            if am.name == ds.name then
                msg = msg .. ' + DiSac'
            else
                msg2 = ds.name..' DiSac'
            end
        end
        if msg ~= '' then
            msg = msg..' ('..i..')'
            links[#links + 1] = {time=t,eventType='timer',msg=msg,duration=linksTimerDuration}
        end
        if msg2 ~= '' then
            msg2 = msg2..' ('..i..')'
            links[#links + 1] = {time=t,eventType='timer',msg=msg2,duration=linksTimerDuration}
        end
    end
    LN_RaidHelper_Sheduler:shift_time(links, -linksTimerDuration)
    LN_RaidHelper_Sheduler:start(LN_RaidHelper_Sheduler:merge(bites, links), delay)
end
function LN_RaidHelper_Sheduler:stop()
    self.isRunning = -1
    self.eventList = {}
    self.frame:Hide()
end

LN_RaidHelper = {}

function LN_RaidHelper:initialize(parent)
    LN_RaidHelper_Sheduler:initialize()
    self.state = {
        configKey = 'BQL',
        isEnabled=false,
        isFighting = false,
        bql = {
            bites = {},
            links = {},
        },
        charsInfo = LN_RH_characters(),
        charsNames = LN_RH_characters_names(),
        debug = false,
    }
    self.ui = {
        bql = {
            dropdowns = {
                bites = {},
                links = {},
            },
            updates = {
                bites = {},
                links = {},
            },
        },
        importExport = {
            fields = {},
            updates = {},
        },
        debug = {},
        updates = {},
    }

    self.ui.isEnabled = CreateFrame("CheckButton", "LNRaidHelperEnabledCheckbox", parent, "ChatConfigCheckButtonTemplate");
    self.ui.isEnabled:SetSize(30, 30) -- width, height
    self.ui.isEnabled:SetText("Is Enabled")
    self.ui.isEnabled.tooltip = "DBM Timers Enabled"
    self.ui.isEnabled:SetScript("OnClick", function () LN_RaidHelper:handle({id='isEnabledToggle'}) end)
    self.ui.isEnabled:SetPoint("TOPLEFT", 16, -10)

    local title = parent:CreateFontString("LNRaidHelperConfigTitle", "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 50, -16)
    self.ui.updates.title = function(state)
        if state.isEnabled then
            title:SetText("LN Raid Helper Enabled")
        else
            title:SetText("LN Raid Helper |cAAFF0000IS NOT ENABLED|r")
        end
        if state.isEnabled ~= self.ui.isEnabled:GetChecked() then
            self.ui.isEnabled:SetChecked(state.isEnabled)
        end
    end
    self.ui.title = title

    local version = parent:CreateFontString("LNRaidHelperVersion", "ARTWORK", "NumberFontNormalSmallGray")
    version:SetPoint("TOPLEFT", 50, -36)
    version:SetText("v1.0.0")
    
    local configDropdown = RH_createDropdown(parent, 'LNRaidHelperConfigDropdown', 'Config', 'BQL', 0, -16, 'TOPRIGHT')
    self.ui.configDropdown = configDropdown
    self.ui.updates.configDropdown = function(state)
        RH_updateDropdown(configDropdown, {'BQL', 'Import/Export'}, nil, function(dd, value)
            LN_RaidHelper:handle({id='configChange', value=value})
        end)
    end

    local importField = CreateFrame("EditBox", "LNRaidHelperImportEditBox", parent, "InputBoxTemplate")
    self.ui.importExport.fields.importField = importField
    importField:SetMultiLine(false)
    importField:SetPoint("TOPLEFT", 16, -52 - 15 - 30 + 5)
    importField:SetSize(400, 22) -- width, height
    importField:SetText("")
    importField:SetAutoFocus(false)
    importField:Hide()

    local importButton = CreateFrame("Button", "LNRaidHelperImportButton", parent, "UIPanelButtonTemplate")
    self.ui.importExport.fields.importButton = importButton
    importButton:SetSize(100, 22) -- width, height
    importButton:SetText("Import Bites")
    importButton:SetPoint("TOPLEFT", 16, -52 - 15 + 5)
    importButton:SetScript("OnClick", function()
        LN_RaidHelper:handle({id='import', value=importField:GetText()})
    end)
    importButton:Hide()

    local exportField = CreateFrame("EditBox", "LNRaidHelperExportEditBox", parent, "InputBoxTemplate")
    self.ui.importExport.fields.exportField = exportField
    exportField:SetMultiLine(false)
    exportField:SetPoint("TOPLEFT", 16, -52 - 15 + 5 - 40 * 3 + 10)
    exportField:SetSize(400, 22)
    exportField:SetText("")
    exportField:SetAutoFocus(false)
    exportField:Hide()

    local exportButton = CreateFrame("Button", "LNRaidHelperExportButton", parent, "UIPanelButtonTemplate")
    self.ui.importExport.fields.exportButton = exportButton
    exportButton:SetSize(100, 22) -- width, height
    exportButton:SetText("Export Players")
    exportButton:SetPoint("TOPLEFT", 16, -52 - 15 + 5 - 40 * 2)
    exportButton:SetScript("OnClick", function()
        LN_RaidHelper:handle({id='export', value=exportField:GetText()})
    end)
    exportButton:Hide()

    local dropdownWidth = 80
    for k, v in pairs(LNRaidHelperDB.bites) do
        local x = 16 + (k > 8 and 120 or 0)
        local y = -52 - 15 - 40 * ((k - 1) % 8)
        local raidDD = RH_createDropdown(parent, 'LNRaidHelperBiteDropdown'..k, 'Bite'..k, LN_RH_colorizeName(v), x, y)
        self.state.bql.bites[k] = v
        self.ui.bql.dropdowns.bites[k] = raidDD
        self.ui.bql.updates.bites[k] = function(state)
            RH_updateDropdown(raidDD, state.charsNames, dropdownWidth, function(dd, value)
                LN_RaidHelper:handle({id='bite', bite=k, value=value})
            end)
        end
    end
    for l, cs in pairs(LNRaidHelperDB.links) do
        local x1 = 16 + 240
        local x2 = x1 + 120
        local y = -52 - 15 - 40 * (l - 1)
        local raidDD1 = RH_createDropdown(parent, 'LNRaidHelperLinkAMDropdown'..l, 'Aura Mastery '..l, LN_RH_colorizeName(cs.am), x1, y)
        local raidDD2 = RH_createDropdown(parent, 'LNRaidHelperLinkDSDropdown'..l, 'DiSac '..l, LN_RH_colorizeName(cs.ds), x2, y)
        self.state.bql.links[l] = {am=cs.am, ds = cs.ds}
        self.ui.bql.dropdowns.links[l] = {am=raidDD1, ds=raidDD2}
        self.ui.bql.updates.links[l] = {
            am=function(state)
                RH_updateDropdown(raidDD1, state.charsNames, dropdownWidth, function(dd, value)
                    LN_RaidHelper:handle({id='link', link=l, defType='am', value=value})
                end)
            end,
            ds=function(state)
                RH_updateDropdown(raidDD2, state.charsNames, dropdownWidth, function(dd, value)
                    LN_RaidHelper:handle({id='link', link=l, defType='ds', value=value})
                end)
            end
        }
    end

    do
        local b = CreateFrame("Button", "LNRaidHelperDEBUGPull", parent, "UIPanelButtonTemplate")
        b:SetSize(80 ,22)
        b:SetPoint("CENTER")
        b:SetPoint("TOPRIGHT", -200, -10)
        b:Hide()
        self.ui.debug.fight = b
        self.ui.updates.debug_fight = function(state)
            local b = self.ui.debug.fight
            if state.debug then
                b:Show()
            else
                b:Hide()
            end
            b:SetScript("OnClick", function()
                if state.isFighting then
                    LN_RaidHelper:handle({id='kill'})
                else
                    LN_RaidHelper:handle({id='pull',boss='Lanathel',maxPlayers=25,delay=-5})
                end
            end)
            b:SetText(state.isFighting and "Kill" or "Pull")
        end
    end

    DBM:RegisterCallback('DBM_Pull', function(event, mod, delay)
        local _, _, _, maxPlayers = DBM:GetCurrentInstanceDifficulty()
        LN_RaidHelper:handle({id='pull', boss=mod.id, maxPlayers=maxPlayers,delay=(delay or 0)})
    end)
    DBM:RegisterCallback('DBM_Wipe', function(event)
        LN_RaidHelper:handle({id='kill'})
    end)
    DBM:RegisterCallback('DBM_Kill', function(event)
        LN_RaidHelper:handle({id='kill'})
    end)

    LN_RaidHelper:feedback({}, {id='init'}, self.state)
end

function LN_RaidHelper:reduce(state, event, nextState)
    function setUniqueChar(count, index, name, getChar, setChar)
        for b=1,count do
            local c = getChar(b)
            if b ~= index and LN_RH_colorizeName(c) == name then
                setChar(b, LN_RH_emptyChar())
            end
        end
        for i, cn in pairs(state.charsNames) do
            if name == cn then
                if getChar(index).name == state.charsInfo[i].name then
                    setChar(index, LN_RH_emptyChar())
                else
                    setChar(index, state.charsInfo[i])
                end
            end
        end
    end
    if event.id == 'bite' then
        nextState.isEnabled = true
        setUniqueChar(#state.bql.bites, event.bite, event.value,
            function(i) return state.bql.bites[i] end,
            function(i, c) nextState.bql.bites[i] = c end)
    elseif event.id == 'link' then
        nextState.isEnabled = true
        setUniqueChar(#state.bql.links, event.link, event.value,
            function(i) return state.bql.links[i][event.defType] end,
            function(i, c) nextState.bql.links[i][event.defType] = c end)
    elseif event.id == 'reload' then
        nextState.charsInfo = LN_RH_characters()
        nextState.charsNames = LN_RH_characters_names()
    elseif event.id == 'isEnabledToggle' then
        nextState.isEnabled = not state.isEnabled
    elseif event.id == 'debug' then
        nextState.debug = not nextState.debug
    elseif event.id == 'pull' and nextState.isEnabled then
        nextState.isFighting = true
    elseif event.id == 'kill' then
        nextState.isFighting = false
    elseif event.id == 'configChange' then
        nextState.configKey = event.value
    elseif event.id == 'import' then
        nextState.isEnabled = true
        function getChar(char)
            if char == nil then
                return LN_RH_emptyChar()
            end
            local name = char.name
            if name == nil then
                return LN_RH_emptyChar()
            end
            for _, c in pairs(state.charsInfo) do
                if c.name == name then
                    return c
                end
            end
            local c = LN_RH_emptyChar()
            c.name = name
            c.class = char.class
            return c
        end
        local imp = ln_json.parse(event.value)
        for i, cn in pairs(imp.bites) do
            nextState.bql.bites[i] = getChar(cn)
        end
        for i, def in pairs(imp.palaDefs) do
            nextState.bql.links[i].am = getChar(def.am)
            nextState.bql.links[i].ds = getChar(def.ds)
        end
    end
end

function LN_RaidHelper:feedback(prevState, event, state)
    function updateDropdowns(count, index, getChar, getDropdown, updateGlobal)
        for b=1,count do
            local c = getChar(state, b)
            if c.name ~= getChar(prevState, b).name then
                if b ~= index or c.name == '' then
                    local name = LN_RH_colorizeName(c)
                    local dropdown = getDropdown(b)
                    UIDropDownMenu_SetSelectedValue(dropdown, name, name)
                    UIDropDownMenu_SetText(dropdown, name)
                end
                updateGlobal(b, c)
            end
        end
    end
    if event.id == 'init' or event.id == 'reload' then
        for _, update in pairs(self.ui.bql.updates.bites) do
            update(state)
        end
        for _, updates in pairs(self.ui.bql.updates.links) do
            updates.am(state)
            updates.ds(state)
        end
        for _, update in pairs(self.ui.updates) do
            update(state)
        end
    elseif event.id == 'import' then
        self.ui.updates.title(state)
        for j, _ in pairs(state.bql.bites) do
            updateDropdowns(#state.bql.bites, j,
                function(s, i) return s.bql.bites[i] end,
                function(i) return self.ui.bql.dropdowns.bites[i] end,
                function(i, c) LNRaidHelperDB.bites[i] = c end)
        end
        for j, _ in pairs(state.bql.links) do
            updateDropdowns(#state.bql.links, j,
                function(s, i) return s.bql.links[i].am end,
                function(i) return self.ui.bql.dropdowns.links[i].am end,
                function(i, c) LNRaidHelperDB.links[i].am = c end)
            updateDropdowns(#state.bql.links, j,
                function(s, i) return s.bql.links[i].ds end,
                function(i) return self.ui.bql.dropdowns.links[i].ds end,
                function(i, c) LNRaidHelperDB.links[i].ds = c end)
        end
    elseif event.id == 'bite' then
        self.ui.updates.title(state)
        updateDropdowns(#state.bql.bites, event.bite,
            function(s, i) return s.bql.bites[i] end,
            function(i) return self.ui.bql.dropdowns.bites[i] end,
            function(i, c) LNRaidHelperDB.bites[i] = c end)
    elseif event.id == 'link' then
        self.ui.updates.title(state)
        updateDropdowns(#state.bql.links, event.link,
            function(s, i) return s.bql.links[i][event.defType] end,
            function(i) return self.ui.bql.dropdowns.links[i][event.defType] end,
            function(i, c) LNRaidHelperDB.links[i][event.defType] = c end)
    elseif event.id == 'isEnabledToggle' then
        if not state.isEnabled then
            LN_RaidHelper_Sheduler:stop()
        end
        self.ui.updates.title(state)
    elseif event.id == 'pull' then
        if state.isEnabled then
            if event.boss == 'Lanathel' then
                if event.delay < 0 and state.debug then
                    SlashCmdList["DEADLYBOSSMODS"]('timer '..(-event.delay)..' Pull')
                end
                LN_RaidHelper_Sheduler:startBQL(event.maxPlayers, event.delay)
            end
        end
        if state.debug then
            self.ui.updates.debug_fight(state)
        end
    elseif event.id == 'kill' then
        LN_RaidHelper_Sheduler:stop()
        if state.debug then
            self.ui.updates.debug_fight(state)
        end
    elseif event.id == 'export' then
        local exp = {
            characters = LN_RH_characters()
        }
        local str = ln_json.stringify(exp)
        self.ui.importExport.fields.exportField:SetText(str)
    elseif event.id == 'configChange' then
        UIDropDownMenu_SetSelectedValue(self.ui.configDropdown, event.value, event.value)
        UIDropDownMenu_SetText(self.ui.configDropdown, event.value)
        if prevState.configKey == 'BQL' then
            for _, element in pairs(self.ui.bql.dropdowns.bites) do
                element:Hide()
            end
            for _, element in pairs(self.ui.bql.dropdowns.links) do
                element.am:Hide()
                element.ds:Hide()
            end
        elseif prevState.configKey == 'Import/Export' then
            self.ui.importExport.fields.importField:Hide()
            self.ui.importExport.fields.importButton:Hide()
            self.ui.importExport.fields.exportField:Hide()
            self.ui.importExport.fields.exportButton:Hide()
        end
        if state.configKey == 'BQL' then
            for _, element in pairs(self.ui.bql.dropdowns.bites) do
                element:Show()
            end
            for _, element in pairs(self.ui.bql.dropdowns.links) do
                element.am:Show()
                element.ds:Show()
            end
        elseif state.configKey == 'Import/Export' then
            self.ui.importExport.fields.importField:Show()
            self.ui.importExport.fields.importButton:Show()
            self.ui.importExport.fields.exportField:Show()
            self.ui.importExport.fields.exportButton:Show()
        end
    elseif event.id == 'debug' then
        self.ui.updates.debug_fight(state)
    end
end

function LN_RaidHelper:handle(event)
    local state = self.state
    local nextState = LN_RH_deep_copy(state)
    LN_RaidHelper:reduce(state, event, nextState)
    self.state = nextState
    LN_RaidHelper:feedback(state, event, nextState)
end

function setup_raid_helper()
    function pull()
        local pullTimer = 30
        local cmd = 'broadcast timer'
        if LNRaidHelperDB.debug then
            cmd = 'timer'
        end
        function dbm(msg)
            SlashCmdList['DEADLYBOSSMODS'](msg)
        end
        function timer(t, msg)
            dbm(cmd..' '..t..' '..msg)
        end
        function reverse(tb)
            local result = {}
            for i=1,#tb do
                result[#tb - i + 1] = tb[i]
            end
            return result
        end
        local biteTimes = {
            77, 137, 199, 261
        }
        for b, t in pairs(biteTimes) do
            for j=1,2^(b - 1) do
                local b1 = LNRaidHelperDB.bites[j].name == '' and 'UNKNOWN' or LNRaidHelperDB.bites[j].name
                local b2 = LNRaidHelperDB.bites[j + 2^(b - 1)].name == '' and 'UNKNOWN' or LNRaidHelperDB.bites[j + 2^(b - 1)].name
                if LNRaidHelperDB.debug then
                    print(t, LNRaidHelperDB.bites[j].name, LNRaidHelperDB.bites[j + 2^(b - 1)].name, j, j + 2^(b - 1))
                end
                timer(t + pullTimer, b1..' -> '..b2)
            end
        end

        local linksTimes = LN_RH_linksTimings(true)
        for i, t in pairs(linksTimes) do
            local index = ((i - 1) % 5) + 1
            local am = LNRaidHelperDB.links[index].am
            local ds = LNRaidHelperDB.links[index].ds
            local msg = ''
            local msg2 = ''
            if am.name ~= '' then
                msg = am.name .. ' AM'
            end
            if ds.name ~= '' then
                if am.name == ds.name then
                    msg = msg .. ' + DiSac'
                else
                    msg2 = ds.name..' DiSac'
                end
            end
            if msg ~= '' then
                msg = msg..' ('..i..')'
                if LNRaidHelperDB.debug then
                    print(t, msg)
                end
                timer(t + pullTimer, msg)
            end
            if msg2 ~= '' then
                msg2 = msg2..' ('..i..')'
                if LNRaidHelperDB.debug then
                    print(t, msg2)
                end
                timer(t + pullTimer, msg2)
            end
        end
        if not LNRaidHelperDB.debug then
            dbm('pull 30')
        end
    end
    local biteDropdowns = {}
    local linksDropdowns = {}
    function handleCommand(cmd)
        if cmd == "debug" then
            LN_RaidHelper:handle({id='debug'})
        else
            LN_RaidHelper:handle({id='reload'})
            InterfaceOptionsFrame_OpenToCategory("LN Raid Helper")
        end
    end
    --Slash handler
    _G["SlashCmdList"]["LN_RAID_HELPER"] = handleCommand
    _G["SLASH_LN_RAID_HELPER1"] = "/rh"
    _G["SLASH_LN_RAID_HELPER2"] = "/lnrh"

    local raidHelper = CreateFrame("Frame", "LNRaidHelperConfig", InterfaceOptionsFramePanelContainer)
    raidHelper:Hide()
    raidHelper.name = "LN Raid Helper"
    InterfaceOptions_AddCategory(raidHelper)

    LN_RaidHelper:initialize(raidHelper)
end

do
local frame = CreateFrame("FRAME")   -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED")  -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT") -- Fired when about to log out

function frame:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "LNRaidHelper" then 
        if LNRaidHelperDB == nil then
            LNRaidHelperDB = {}
        end
        function checkChar(tb)
            if type(tb) ~= 'table' then
                return false
            end
            if tb.name == nil then
                return false
            end
            if tb.class == nil then
                return false
            end
            return true
        end
        function checkChars(tb)
            if type(tb) ~= 'table' then
                return false
            end
            for _, v in pairs(tb) do
                if not checkChar(v) then
                    return false
                end
            end
            return true
        end
        function checkCharsLink(tb)
            if type(tb) ~= 'table' then
                return false
            end
            for _, v in pairs(tb) do
                if (not checkChar(v.am)) or (not checkChar(v.ds)) then
                    return false
                end
            end
            return true
        end
        if LNRaidHelperDB.bites == nil or (not checkChars(LNRaidHelperDB.bites)) then
            LNRaidHelperDB.bites = {
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
                {name='', class='Priest'},
            }
        end
        if LNRaidHelperDB.links == nil or (not checkCharsLink(LNRaidHelperDB.links)) then
            LNRaidHelperDB.links = {
                {am={name='', class='Priest'},ds={name='', class='Priest'}},
                {am={name='', class='Priest'},ds={name='', class='Priest'}},
                {am={name='', class='Priest'},ds={name='', class='Priest'}},
                {am={name='', class='Priest'},ds={name='', class='Priest'}},
                {am={name='', class='Priest'},ds={name='', class='Priest'}},
            }
        end
        -- if LNRaidHelperDB.debug == nil then
            LNRaidHelperDB.debug = nil
        -- end
        setup_raid_helper()
    elseif event == "PLAYER_LOGOUT" then

    end
end
frame:SetScript("OnEvent", frame.OnEvent);
end
