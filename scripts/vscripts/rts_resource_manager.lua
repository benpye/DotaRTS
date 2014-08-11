if RTS.Resources == nil then
	RTS.Resources = {}
end

function RTS.Resources.Init()
	local resourceEntities = Entities:FindAllByClassname( "ent_dota_tree" )
	--DeepPrintTable( resourceEntities )
	--DeepPrintTable( Entities:FindAllByModel( "models/props_rock/riveredge_rock006a.vmdl" ) )
	for _, ent in pairs(resourceEntities) do
		Msg( ent:GetMaxHealth() .. "\n" )
	end
end