local ObservationService = {}

local ObservedPlayer = require(script:FindFirstChild("ObservedPlayer"))

local ObservedPlayers: {[string]: ObservedPlayer.ObservedPlayer} = {}

function ObservationService.ObservePlayer(Player: Player): ObservedPlayer.ObservedPlayer
	local observedPlayer = ObservedPlayer.new(Player)
	
	ObservedPlayers[Player.Name] = observedPlayer
	
	observedPlayer:StartObserving()
	
	return observedPlayer
end

function ObservationService.StopObserving(Player: Player, observationStopCallback: (string) -> ()?)
	local observedPlayer = ObservedPlayers[Player.Name]
	
	if observedPlayer then
		
		if observedPlayer:IsObserved() then
			if observationStopCallback then
				observationStopCallback(Player.Name)
			end

			observedPlayer:StopObserving()
			
			ObservedPlayers[Player.Name] = nil
		end
		
	else
		error(`Player {Player.Name} is not being observed!`)
	end
end

function ObservationService.StopObservingEveryone(observationStopCallback: (string) -> ()?)
	for user, observedPlayer in pairs(ObservedPlayers) do
		
		if ObservedPlayer:IsObserved() then
			ObservationService.StopObserving(observedPlayer, observationStopCallback)
		end

	end
	
	ObservedPlayers = {}
end

return ObservationService
