if RTS.BuildingBase == nil then
	RTS.BuildingBase = class({})
end

-- Base building class, provides simple building mechanic

RTS.BuildingBase.BUILDTIME = 1.0
RTS.BuildingBase.TICKSIZE = 0.1
RTS.BuildingBase.UNIT = "npc_rts_building_hq"
RTS.BuildingBase.Complete = false
RTS.BuildingBase._inProgress = false

function RTS.BuildingBase:constructor( position, player, team )
	self.Player = player
	self.Team = team
	self.Entity = CreateUnitByName( self.UNIT, position, false,
					self.Player, self.Player, self.Team )

	self.Entity:SetInvulnCount( 0 )
	self.Entity:SetHealth( 1 )

	self.Entity:AddAbility( "rts_building_incomplete" )

	-- Add self to list of buildings
	table.insert( RTS.BuildingList, self )
end

function RTS.BuildingBase:Building()
	-- If we stop building stop building
	if self._inProgress == false then
		return nil
	end

	local maxHealth = self.Entity:GetMaxHealth()
	local healthTick = maxHealth / ( self.BUILDTIME / self.TICKSIZE )
	local curHealth = self.Entity:GetHealth()
	local newHealth = curHealth + healthTick
	if newHealth > maxHealth then
		self.Complete = true
		newHealth = maxHealth
	end
	self.Entity:SetHealth( newHealth )

	if self.Complete == true then
		-- Building is being built, not repaired
		if self.Entity:HasAbility( "rts_building_incomplete" ) then
			self.Entity:RemoveAbility( "rts_building_incomplete" )
		end

		self.Caster:InterruptChannel()
		self._inProgress = false
		-- add correct "abilities" here
		return nil
	end

	return self.TICKSIZE
end

function RTS.BuildingBase:StopBuilding()
	self._inProgress = false
end

function RTS.BuildingBase:ResumeBuilding( caster )
	self._inProgress = true
	self.Caster = caster
	self.Entity:SetThink( "Building", self, "building", self.TICKSIZE )
end

function RTS.BuildingBase:IsBuilding()
	return self._inProgress
end