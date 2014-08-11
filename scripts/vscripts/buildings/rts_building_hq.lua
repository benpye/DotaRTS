require( "buildings.rts_building_base" )

if RTS.Buildings.HQ == nil then
	RTS.Buildings.HQ = class({}, {}, RTS.Buildings.Base)
end

RTS.Buildings.HQ.BUILDTIME = 1.0
RTS.Buildings.HQ.TICKSIZE = 0.1
RTS.Buildings.HQ.UNIT = "npc_rts_building_hq"
RTS.Buildings.HQ.MAXCOUNT = 1
RTS.Buildings.HQ.ABILITIES = {
	"rts_spawn_worker",
	"rts_spawn_lumberjack"
}