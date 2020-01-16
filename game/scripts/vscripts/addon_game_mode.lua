require('gamemode')
require('donate')
function Precache( context )

end

function Activate()
	local GM = GameRules:GetGameModeEntity()
	GM:SetCustomGameForceHero("npc_dota_hero_puck")
	GameRules:SetHeroSelectionTime(0)
	GameRules:SetStrategyTime(0)
	GameRules:SetShowcaseTime(0)
	GameRules:SetCustomGameSetupAutoLaunchDelay(0)

	Convars:SetBool("sv_cheats", true)
end
