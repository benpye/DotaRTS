require( "units.rts_unit_base" )

if RTS.Units.Commander == nil then
	RTS.Units.Commander = class({}, {}, RTS.Units.Base)
end

RTS.Units.Commander.BUILDTIME = 1.0
RTS.Units.Commander.TICKSIZE = 0.1
RTS.Units.Commander.UNIT = "npc_rts_unit_commander"
RTS.Units.Commander.MAXCOUNT = 1
RTS.Units.Commander.ABILITIES = {
	"rts_build_hq",
	"rts_internal_destroy_tree"
}