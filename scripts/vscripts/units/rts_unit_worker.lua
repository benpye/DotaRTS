require( "units.rts_unit_base" )

if RTS.Units.Worker == nil then
	RTS.Units.Worker = class({}, {}, RTS.Units.Base)
end

RTS.Units.Worker.BUILDTIME = 1.0
RTS.Units.Worker.UNIT = "npc_rts_unit_worker"
RTS.Units.Worker.MAXCOUNT = -1
RTS.Units.Worker.ABILITIES = {
	"rts_spawn_worker"
}