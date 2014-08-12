require( "units.rts_unit_base" )

if RTS.Units.Soldier == nil then
	RTS.Units.Soldier = class({}, {}, RTS.Units.Base)
end

RTS.Units.Soldier.BUILDTIME = 4.0
RTS.Units.Soldier.UNIT = "npc_rts_unit_soldier"
RTS.Units.Soldier.MAXCOUNT = 20
RTS.Units.Soldier.ABILITIES = { }