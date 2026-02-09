-- Utils.lua: helpers puros y utilidades compartidas

local _, ns = ...

local E = ns.E

local function Trim(s)
    if type(s) ~= 'string' then return '' end
    return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function NormalizeImportString(s)
    if type(s) ~= 'string' then return '' end

    s = Trim(s)
    if s == '' then return '' end

    -- Soporta exports envueltos con marcadores explícitos dentro del string.
    -- Importante: los delimitadores Lua ([=[...]=], [===[... ]===], etc.) NO forman parte del string.
    -- Por diseño: si los marcadores están incompletos, devolvemos el string original.

    -- Formato preferido:
    -- [===start===[<EXPORT>]===end===]
    local start1 = '[===['
    local end1 = ']===]'

    local startPos = string.find(s, start1, 1, true)
    if startPos then
        local contentStart = startPos + #start1
        local endPos = string.find(s, end1, contentStart, true)
        if endPos then
            return Trim(string.sub(s, contentStart, endPos - 1))
        end
    end

    return s
end

local function SplitWords(msg)
    msg = Trim(msg)
    if msg == '' then return {} end
    local out = {}
    for w in string.gmatch(msg, '%S+') do
        out[#out + 1] = w
    end
    return out
end

local function PrintMsg(msg)
    if E and E.Print then
        E:Print(msg)
    else
        print(msg)
    end
end

local function GradientText(text, r1, g1, b1, r2, g2, b2)
    if type(text) ~= 'string' or text == '' then return '' end

    local len = #text
    if len == 1 then
        return string.format('|cff%02x%02x%02x%s|r', r1, g1, b1, text)
    end

    local out = {}
    for i = 1, len do
        local ch = string.sub(text, i, i)
        if ch == ' ' then
            out[#out + 1] = ch
        else
            local t = (i - 1) / (len - 1)
            local r = math.floor((r1 + (r2 - r1) * t) + 0.5)
            local g = math.floor((g1 + (g2 - g1) * t) + 0.5)
            local b = math.floor((b1 + (b2 - b1) * t) + 0.5)
            out[#out + 1] = string.format('|cff%02x%02x%02x%s|r', r, g, b, ch)
        end
    end

    return table.concat(out)
end

local function StripColorCodes(text)
    if type(text) ~= 'string' or text == '' then return '' end
    return text:gsub('|c%x%x%x%x%x%x%x%x', ''):gsub('|r', '')
end

local function BlueTitle(text)
    text = StripColorCodes(text)
    if text == '' then return '' end
    -- Primer color del degradado del nombre (0, 192, 250) => 00C0FA
    return '|cff00c0fa' .. text .. '|r'
end

local function GetLSM()
    local libStub = _G.LibStub
    if type(libStub) ~= 'table' and type(libStub) ~= 'function' then return nil end

    -- LibStub normalmente es una tabla con __call, así que type(LibStub) == 'table'.
    local ok, lib = pcall(function()
        if type(libStub) == 'table' and type(libStub.GetLibrary) == 'function' then
            return libStub:GetLibrary('LibSharedMedia-3.0', true)
        end
        return libStub('LibSharedMedia-3.0', true)
    end)

    if not ok then return nil end
    return lib
end

local function BuildLSMResourceList(mediaType, requiredPathNeedle)
    local LSM = GetLSM()
    if not (LSM and type(LSM.List) == 'function' and type(LSM.Fetch) == 'function') then
        return '- (LibSharedMedia-3.0 no disponible)'
    end

    local names = LSM:List(mediaType)
    if type(names) ~= 'table' then
        return '- (sin datos)'
    end

    local filtered = {}
    for _, name in ipairs(names) do
        local path = LSM:Fetch(mediaType, name, true)
        if type(path) == 'string' and path ~= '' and string.find(path, requiredPathNeedle, 1, true) then
            filtered[#filtered + 1] = name
        end
    end

    if #filtered == 0 then
        return '- (no hay elementos registrados)'
    end

    table.sort(filtered)

    return table.concat(filtered, ', ')
end

ns.Trim = Trim
ns.NormalizeImportString = NormalizeImportString
ns.SplitWords = SplitWords
ns.PrintMsg = PrintMsg
ns.GradientText = GradientText
ns.StripColorCodes = StripColorCodes
ns.BlueTitle = BlueTitle
ns.BuildLSMResourceList = BuildLSMResourceList
