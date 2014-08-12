require( "buildings.rts_building_base" )

if RTS.Buildings.Barracks == nil then
	RTS.Buildings.Barracks = class({}, {}, RTS.Buildings.Base)
end

RTS.Buildings.Barracks.BUILDTIME = 1.0
RTS.Buildings.Barracks.UNIT = "npc_rts_building_barracks"
RTS.Buildings.Barracks.MAXCOUNT = 3
RTS.Buildings.Barracks.ABILITIES = {
	"rts_spawn_soldier"
}