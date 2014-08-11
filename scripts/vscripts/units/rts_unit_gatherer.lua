require( "units.rts_unit_base" )

if RTS.Units.Gatherer == nil then
	RTS.Units.Gatherer = class({}, {}, RTS.Units.Base)
end

RTS.Units.Gatherer.BUILDTIME = 1.0
RTS.Units.Gatherer.TICKSIZE = 0.1
RTS.Units.Gatherer.UNIT = "npc_rts_unit_lumberjack"
RTS.Units.Gatherer.MAXCOUNT = 1
RTS.Units.Gatherer.ABILITIES = {
}

