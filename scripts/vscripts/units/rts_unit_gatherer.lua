require( "units.rts_unit_base" )
require( "buildings.rts_building_hq" )
require( "utils.abilities" )
require( "rts_resource_manager" )

if RTS.Units.Gatherer == nil then
	RTS.Units.Gatherer = class({}, {}, RTS.Units.Base)
end

RTS.Units.Gatherer.BUILDTIME = 1.0
RTS.Units.Gatherer.TICKSIZE = 0.1
RTS.Units.Gatherer.UNIT = "npc_rts_unit_lumberjack"
RTS.Units.Gatherer.MAXCOUNT = -1
RTS.Units.Gatherer.TYPE = "RESOURCE_WOOD"
RTS.Units.Gatherer.INVENTORY = 100
RTS.Units.Gatherer.RATE = 50
RTS.Units.Gatherer.ABILITIES = {
	"rts_get_wood",
	"rts_deposit_resource"
}
RTS.Units.Gatherer.GATHER_ABILITY = "rts_get_wood"

RTS.Units.Gatherer.Resources = 0
RTS.Units.Gatherer.IsGathering = false

function RTS.Units.Gatherer:GatherResource( resource )
	self.CurrentResource = resource
	self.IsGathering = true
	self.Entity:SetThink( "Gathering", self, "gathering", self.TICKSIZE )
end

function RTS.Units.Gatherer:Gathering()
	if self.IsGathering == false then
		return nil
	end

	local newResources = self.Resources + self.RATE * self.TICKSIZE
	if newResources >= self.INVENTORY then
		newResources = self.INVENTORY
		self.IsGathering = false
	end

	local take = newResources - self.Resources

	local possibleResource = self.CurrentResource.Units

	if take > possibleResource then
		take = possibleResource
		newResources = self.Resources + take
		-- We were previously over the limit, we now need to check again
		if newResources < self.INVENTORY then
			self.IsGathering = true
		end
	end

	self.CurrentResource.Units = self.CurrentResource.Units - take

	if self.CurrentResource.Units == 0 then
		RTS.Utils.KillTree( self.CurrentResource.Entity )

		local newResource = nil
		local possible = Entities:FindAllByClassnameWithin( "ent_dota_tree", self.CurrentResource.Entity:GetOrigin(), 300.0 )
		for _, ent in pairs( possible ) do
			local res = RTS.Resources.GetByEntity( ent )
			if res.Type == self.TYPE and res.Units > 0 then
				newResource = res
				break
			end
		end

		if newResource ~= nil then
			self:GoAndGather( newResource )
		else
			self.IsGathering = false
		end

		for _, unit in pairs( RTS.Units.List ) do
			if unit.CurrentResource == self.CurrentResource then
				unit.CurrentResource = newResource
				if unit.IsGathering == true then
					if newResource == nil then
						unit:GoAndDesposit()
					else
						unit:GoAndGather( newResource )
					end
					unit:StopGathering()
				end
			end
		end
	end

	self.Resources = newResources

	if self.IsGathering == false then
		self:GoAndDesposit()

		return nil
	else
		return self.TICKSIZE
	end
end

function RTS.Units.Gatherer:StopGathering()
	self.IsGathering = false
end

function RTS.Units.Gatherer:GoAndDesposit()
	local buildings = RTS.Buildings.GetByPlayer( self.Player, RTS.Buildings.HQ )
	local hq = buildings[ 1 ]

	local ability = RTS.Utils.GetAbilityByName( self.Entity, "rts_deposit_resource" )
	self.Entity:CastAbilityOnTarget( hq.Entity, ability, 0 )
end

function RTS.Units.Gatherer:GoAndGather( ent )
	self.CurrentResource = ent
	local ability = RTS.Utils.GetAbilityByName( self.Entity, self.GATHER_ABILITY )
	self.Entity:CastAbilityOnPosition( self.CurrentResource.Entity:GetOrigin(), ability, 0 )
end

function RTS.Units.Gatherer:DepositResource()
	RTS.Resources.GivePlayerResources( self.Player, self.TYPE, self.Resources )
	self.Resources = 0
end