if RTS.Buildings == nil then
	RTS.Buildings = {}
	RTS.Buildings.List = {}
	RTS.Buildings.Base = class({})
end

function RTS.Buildings.GetByEntity( ent )
	for _, building in pairs( RTS.Buildings.List ) do
		if building.Entity == ent then
			return building
		end
	end

	return nil
end

function RTS.Buildings.GetByPlayer( player, klass )
	local buildings = {}
	for _, building in pairs( RTS.Buildings.List ) do
		if building.UNIT == klass.UNIT then
			if building.Player == player then
				table.insert( buildings, building )
			end
		end
	end

	return buildings
end

-- Base building class, provides simple building mechanic

RTS.Buildings.Base.BUILDTIME = 1.0
RTS.Buildings.Base.TICKSIZE = 0.1
RTS.Buildings.Base.UNIT = "npc_rts_building_base"
RTS.Buildings.Base.MAXCOUNT = -1
RTS.Buildings.Base.ABILITIES = {}
RTS.Buildings.Base.Valid = false
RTS.Buildings.Base.Complete = false
RTS.Buildings.Base._inProgress = false

function RTS.Buildings.Base:constructor( position, player, team )
	if self.MAXCOUNT ~= -1 then
		local existingCount = 0
		for _, building in pairs(RTS.Buildings.List) do
			if building.Player == player and building.Team == team and building.UNIT == self.UNIT then
				existingCount = existingCount + 1
			end
		end

		-- TODO: Better UI for too many of a unit
		if existingCount >= self.MAXCOUNT then
			GameRules:SendCustomMessage( "Unit cap reached", team, player:GetPlayerID() )
			return
		end
	end

	self.Player = player
	self.Team = team
	self.Entity = CreateUnitByName( self.UNIT, position, false,
					self.Player, self.Player, self.Team )
	self.Entity:SetControllableByPlayer( self.Player:GetPlayerID(), true )

	self.Entity:SetInvulnCount( 0 )
	self.Entity:SetHealth( 1 )
	self.Entity:SetRenderColor( 0, 0, 255 )

	self.Entity:AddAbility( "rts_building_incomplete" )

	-- Add self to list of buildings
	table.insert( RTS.Buildings.List, self )

	-- If we get this far, we're probably valid
	self.Valid = true
end

function RTS.Buildings.Base:DoComplete()
	self.Entity:RemoveAbility( "rts_building_incomplete" )

	self.Entity:SetRenderColor( 255, 255, 255 )

	self._inProgress = false
	
	-- add correct "abilities" here
	for _,v in pairs( self.ABILITIES ) do
		self.Entity:AddAbility( v )
	end

	for i=0, self.Entity:GetAbilityCount() - 1, 1 do
		local ability = self.Entity:GetAbilityByIndex( i )
		if ability == nil then
			break
		end
		ability:SetLevel( ability:GetMaxLevel() )
	end
end

function RTS.Buildings.Base:Building()
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
		self.Caster:InterruptChannel()
		self:DoComplete()
		return nil
	end

	return self.TICKSIZE
end

function RTS.Buildings.Base:StopBuilding()
	self._inProgress = false
end

function RTS.Buildings.Base:ResumeBuilding( caster )
	self._inProgress = true
	self.Caster = caster
	self.Entity:SetThink( "Building", self, "building", self.TICKSIZE )
end

function RTS.Buildings.Base:IsBuilding()
	return self._inProgress
end