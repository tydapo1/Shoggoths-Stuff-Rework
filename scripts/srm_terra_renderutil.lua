-- various helper functions to parse directives, mix colours, and convert colours
 
renderutil = {}

function renderutil.parseDirectivesFromPath(p)
    return renderutil.parseDirectiveString(string.sub(p,string.find(p,"?"),-1))
end
function renderutil.parseDirectivesAndPath(p)
    return string.sub(p,0,string.find(p,"?")-1), renderutil.parseDirectiveString(string.sub(p,string.find(p,"?"),-1))
end
function renderutil.splitPathAndDirectives(p)
    return string.sub(p,0,string.find(p,"?")-1), string.sub(p,string.find(p,"?"),-1)
end
function renderutil.parseDirectiveString(d)
    local split = {}
    for v in string.gmatch(d,"([^?]+)") do
        table.insert(split, v)
    end
    local ops = {}
    for k,v in next, split do
        local op = {t=nil,d=nil}
        local parts = {}
        for s in string.gmatch(v,"([^;]+)") do
            table.insert(parts, s)
        end
        local isReplace = true
        for k,v2 in next, parts do
            if k == 1 and v2 ~= "replace" then
                -- this isn't a replace
                parts = {}
                isReplace = false
                for s in string.gmatch(v,"([^=]+)") do
                    table.insert(parts, s)
                end
                break
            elseif k == 1 then
                op.t = "replace"
                op.d = {}
            else
                local colours = {}
                for s in string.gmatch(v2,"([^=]+)") do
                    table.insert(colours, s)
                end
                table.insert(op.d, colours)
            end
        end
        if not isReplace then
            op.t = parts[1]
            op.d = jarray()
            if parts[2] then
                for s in string.gmatch(parts[2],"([^;]+)") do
                    table.insert(op.d, s)
                end
            end
        end
        table.insert(ops, op)
    end
    return ops
end
function renderutil.operationsToString(d)
    local o = ""
    for k,v in next, d do
        o = o.."?"..v.t
        if v.t == "replace" then
            for k,v2 in next, v.d do
                o = o..";"..v2[1].."="..v2[2]
            end
        else
            if type(v.d) == "table" then
                if #v.d == 1 then
                    o = o.."="..v.d[1]
                else
                    for k,v2 in next, v.d do
                        o = o..";"..v2
                    end
                end
            else
                o = o..v.d
            end
        end
    end
    return o
end
function renderutil.toHexColour(c)
    if c[4] then
        return string.format("%02x%02x%02x%02x",table.unpack(c))
    else
        return string.format("%02x%02x%02x",table.unpack(c))
    end
end
function renderutil.toVectorColour(c, includeAlpha)
    local alpha = false
    if #c == 4 or #c == 8 then
        alpha = true
        includeAlpha = true
    end
    if #c <= 4 then
        -- minimal, double it (probably inaccurate)
        local oc = c
        c = string.sub(oc,1,1)..string.sub(oc,1,1)..string.sub(oc,2,2)..string.sub(oc,2,2)..string.sub(oc,3,3)..string.sub(oc,3,3)
        if alpha then
            c = c..string.sub(oc,4,4)..string.sub(oc,4,4)
        end
    end
    -- convert to number, then bitwise AND the channels out
    local n = tonumber(c, 16)
    local out
    if alpha then
        out = {
            (n & tonumber("ff000000",16)) >> 24,
            (n & tonumber("00ff0000",16)) >> 16,
            (n & tonumber("0000ff00",16)) >> 8,
            (n & tonumber("000000ff",16))
        }
    else
        out = {
            (n & tonumber("ff0000",16)) >> 16,
            (n & tonumber("00ff00",16)) >> 8,
            (n & tonumber("0000ff",16))
        }
    end
    if #out == 3 and includeAlpha then
        table.insert(out, 255)
    end
    return out
end
function renderutil.toHSV(c)
    local Rd = c[1]/255
    local Gd = c[2]/255
    local Bd = c[3]/255
    local Cma = math.max(Rd,Gd,Bd)
    local Cmi = math.min(Rd,Gd,Bd)
    local delta = Cma-Cmi
    local Hu = 0
    if delta == 0 then
    elseif Cma == Rd then
        Hu = (Gd-Bd)/delta%6
    elseif Cma == Gd then
        Hu = (Bd-Rd)/delta+2
    elseif Cma == Bd then
        Hu = (Rd-Gd)/delta+4
    end
    local Sa = 0
    if Cma ~= 0 then
        Sa = delta/Cma
    end
    if c[4] then
        return {60*Hu,Sa,Cma,c[4]/255}
    else
        return {60*Hu,Sa,Cma}
    end
end
function renderutil.toRGB(c)
    local C = c[3]*c[2]
    local X = C*(1-math.abs((c[1]/60)%2-1))
    local m = c[3]-C
    local ops = {
        {C,X,0},
        {X,C,0},
        {0,C,X},
        {0,X,C},
        {X,0,C},
        {C,0,X},
    }
    local RGBd = ops[math.floor(c[1]/60)%6+1]
    local o = {math.floor((RGBd[1]+m)*255),math.floor((RGBd[2]+m)*255),math.floor((RGBd[3]+m)*255)}
    if c[4] then
        table.insert(o,math.floor(c[4]*255))
    end
    return o
end
function renderutil.mixRGB(ca,cb,r,t)
    return renderutil.toRGB(renderutil.mixHSV(renderutil.toHSV(ca),renderutil.toHSV(cb),r,t))
end
function renderutil.mixHSV(ca,cb,r,t)
    if r == nil then r = 0.5 end
    local function lerp(a,b)
        return a+(b-a)*r
    end
    local h
    local diff = math.abs(ca[1]-cb[1])
    if diff > 180 then
        if ca[1] < cb[1] then
            h = lerp(ca[1]+360,cb[1])
        else
            h = lerp(ca[1],cb[1]+360)
        end
    elseif diff == 180 then
        -- tie
        h = lerp(ca[1],cb[1])
        if t then
            if t > 0 then
                h = h + 180
            end
        else
            math.randomseed(os.clock())
            if math.random() > 0.5 then
                h = h + 180
            end
        end
    else
        h = lerp(ca[1],cb[1])
    end
    local o = {h%360, lerp(ca[2],cb[2]), lerp(ca[3],cb[3])}
    if #ca > 3 or #cb > 3 then
        if #ca > 3 and #cb > 3 then
            o[4] = lerp(ca[4],cb[4])
        else
            o[4] = ca[4] or cb[4]
        end
    end
    return o
end
function table.find(org, findValue)
    for key,value in pairs(org) do
        if value == findValue then
            return key
        end
    end
    return nil
end
function renderutil.entityIdentity(e)
    if world.entityType(e) ~= "player" and world.entityType(e) ~= "npc" then
        return nil
    end
    local identity = {
        gender=world.entityGender(e),
        species=world.entitySpecies(e),
        name=world.entityName(e),
        color={51,117,237},
    }
    local data = root.assetJson(string.format("/species/%s.species", identity.species))
    local genderdata = {}
    if identity.gender == "male" then
        genderdata = data.genders[1]
    else
        genderdata = data.genders[2]
    end
    identity.hairGroup = genderdata.hairGroup or "hair"
    identity.facialHairGroup = genderdata.facialHairGroup or ""
    identity.facialMaskGroup = genderdata.facialMaskGroup or ""
    local portrait = world.entityPortrait(e, "fullnude")
    local parts = {}
    for k,v in next, portrait do
        local pathAndFrame, directives = renderutil.splitPathAndDirectives(v.image)
        local fileName = string.match(pathAndFrame,"[^/]*.png")
        local name = string.sub(fileName, 0, string.find(fileName,".png")-1)
        local frame = string.sub(pathAndFrame,string.find(pathAndFrame,":")+1,-1)
        local keys = {
            ["malebody"]="bodyDirectives",
            ["femalebody"]="bodyDirectives",
            ["emote"]="emoteDirectives"
        }
        if name == "frontarm" then
            identity.personalityArmIdle = frame
            identity.personalityArmOffset = v.position
        end
        if name == "malehead" or name == "femalehead" then
            identity.personalityHeadOffset = v.position
        end
        local key = keys[name]
        if not key then
            if tonumber(name) or tonumber(string.sub(name,4)) or tonumber(string.sub(name,5)) then
                -- likely hair or something similar
                if string.find(pathAndFrame, genderdata.hairGroup or "hair") then
                    key = "hairDirectives"
                    identity.hairType = name
                elseif string.find(pathAndFrame, genderdata.facialHairGroup or "ohno") then
                    key = "facialHairDirectives"
                    identity.facialHairType = name
                elseif string.find(pathAndFrame, genderdata.facialMaskGroup or "ohno") then
                    key = "facialMaskDirectives"
                    identity.facialMaskType = name
                end
            end
        elseif key == "bodyDirectives" then
            identity.personalityIdle = frame
        end
        if key then
            identity[key] = directives
        end
    end
    return identity
end
