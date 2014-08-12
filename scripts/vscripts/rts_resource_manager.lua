if RTS.Resources == nil then
	RTS.Resources = {}
	RTS.Resources.Regions = {}
	RTS.Resources.List = {}
	RTS.Resources.Players = {}
	RTS.Resources.Resource = class({})
end

function RTS.Resources._KVStringToVector( str )
	local split = vlua.split( str, " " )
	return { tonumber( split[ 1 ] ), tonumber( split[ 2 ] ) }
end

function RTS.Resources._VectorInRegion( vec, region )
	if vec.x >= region.Min[ 1 ] and vec.y >= region.Min[ 2 ] then
		if vec.x <= region.Max[ 1 ] and vec.y <= region.Max[ 2 ] then
			return true
		end
	end
	return false
end

function RTS.Resources.GetByEntity( ent )
	for _, resource in pairs( RTS.Resources.List ) do
		if resource.Entity == ent then
			return resource
		end
	end

	return nil
end

function RTS.Resources.Init()
	local resourceEntities = Entities:FindAllByClassname( "ent_dota_tree" )

	local kv = LoadKeyValues( "scripts/resources/" .. GetMapName() .. ".txt" )

	if kv == nil then
		Warning( "[RESOURCES] No resources defined for map " .. GetMapName() .. "\n" )
		return
	end


	for _, region in pairs( kv.ResourceRegions ) do
		local minVec = RTS.Resources._KVStringToVector( region.Min )
		local maxVec = RTS.Resources._KVStringToVector( region.Max )
		local res = region.Type

		table.insert( RTS.Resources.Regions, {
			Min = minVec,
			Max = maxVec,
			Resource = res
			})
	end

	for _, ent in pairs( resourceEntities ) do
		table.insert( RTS.Resources.List, RTS.Resources.Resource( ent ) )
	end
end

function RTS.Resources.GetResourceForPlayer( player, resource )
	local playerID = player:GetPlayerID()
	local playerResources = RTS.Resources.Players[ playerID ]
	if playerResources == nil then
		return 0
	else
		local playerResource = playerResources[ resource ]
		if playerResource == nil then
			return 0
		else
			return playerResource
		end
	end
end

function RTS.Resources.GivePlayerResources( player, resource, count )
	local playerID = player:GetPlayerID()
	if RTS.Resources.Players[ playerID ] == nil then
		RTS.Resources.Players[ playerID ] = {}
	end

	if RTS.Resources.Players[ playerID ][ resource ] == nil then
		RTS.Resources.Players[ playerID ][ resource ] = 0
	end

	RTS.Resources.Players[ playerID ][ resource ] = RTS.Resources.Players[ playerID ][ resource ] + count

	Msg( "[RESOURCES] Player " .. PlayerResource:GetPlayerName( playerID ) .. " has "
		.. tostring( RTS.Resources.Players[ playerID ][ resource ] ) .. " " .. resource .. "\n" )

	RTS.Resources.SendPlayerUpdate( player )
end

function RTS.Resources.SendPlayerUpdate( player )
	local resourceUpdate = {}
	resourceUpdate.playerID = player:GetPlayerID()
	resourceUpdate.wood = RTS.Resources.GetResourceForPlayer( player, "RESOURCE_WOOD" )
	resourceUpdate.stone = RTS.Resources.GetResourceForPlayer( player, "RESOURCE_STONE" )
	FireGameEvent( "rts_resource_update", resourceUpdate )
end

function RTS.Resources.Resource:constructor( ent )
	self.Origin = ent:GetOrigin()

	for k, region in pairs( RTS.Resources.Regions ) do
		if RTS.Resources._VectorInRegion( self.Origin, region ) then
			self.RegionID = k
			self.Type = region.Resource
			Msg( "Resource " .. self.Type .. " at " .. tostring( self.Origin ) .. "\n" )
		end
	end

	self.Entity = ent
	self.Units = 1000
end