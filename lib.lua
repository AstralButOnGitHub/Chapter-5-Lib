---@diagnostic disable: invisible
local lib = {}

Registry.registerGlobal("Chapter5Lib", lib)
Chapter5Lib = lib

function Chapter5Lib:init()
    Chapter5Lib.logger = Logger("Chapter5Lib", ConsoleFormatting({ 1, 0.5, 1 }, { EscapeSequences.FOREGROUND_YELLOW }))
    Chapter5Lib.logger:info("Loaded Chapter5Lib")

    local function registerBasicEvents(events)
        for _, event in ipairs(events) do
            Game:registerEvent(ClassUtils.getClassName(event), function(data)
                return event(data)
            end)
        end
    end

    registerBasicEvents({
        WateringPedestal,
        WaterableFlower,
        WaterableFlowerSmall,
        WaterableGrass,
        WaterableReeds,
        WaterableClimbArea,
        WanderingScissors,
        ScissorGenerator,
        ScissorRemoveZone,
        VineCuttable,
        KnockoffBar,
        MushroomStool,
        NetskieObject,
        PeachGenerator,
        PeachRemoveZone,
        ToriiGate,
        MudZone,
        FusumaDoor,
        SlidingTerakota,
        ObjectFallArea,
        AquaKnife,
        BunnyPlant,
        PuzzleBell,
        LeafPile
    })

    Game:registerEvent("FusumaWall", function(data)
        return FusumaWall(data.x, data.y, {data.width, data.height}, data.properties)
    end)
    -- will add later
    -- Game:registerEvent("ZenSand", function(data)
    --     return ZenSand(data.x, data.y, {data.width, data.height}, data.properties)
    -- end)
    Game:registerEvent("TallGrass", function(data)
        return TallGrass(data.x, data.y, {data.width, data.height}, data.properties)
    end)
end

function Chapter5Lib:scr_clamp_gradual(arg0, arg1, arg2, arg3)
    if (arg0 < arg1) then
        arg0 = arg0 + math.abs(arg3)

        if (arg0 > arg1) then
            return arg1
        end
    end

    if (arg0 > arg2) then
        arg0 = arg0 - math.abs(arg3)

        if (arg0 < arg2) then
            return arg2
        end
    end

    return arg0;
end

return lib
