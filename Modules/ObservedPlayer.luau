local ObservedPlayer = {}
ObservedPlayer.__index = ObservedPlayer

local ObservationService = script.Parent

local Observer = require(ObservationService:FindFirstChild("Observer"))

--[[
	Wraps <code>Player</code> and provides an interface to observe the player.
]]
function ObservedPlayer.new(Player: Player)
	local self = setmetatable({}, ObservedPlayer)
	
	self.Player = Player
	self.Character = Player.Character or Player.CharacterAdded:Wait()
	
	self._Observed = false
	
	self.onObservationStart = Instance.new("BindableEvent")
	self.onObservationStop = Instance.new("BindableEvent")
	
	self.SpeedObserved = false
	self.JumpObserved = false
	
	return self
end

export type ObservedPlayer = typeof(ObservedPlayer.new())

--[[
	Starts observing the player.
]]
function ObservedPlayer.StartObserving(self: ObservedPlayer)
	self._Observed = true

	self.onObservationStart:Fire()
end

--[[
	Stops observing the player.
]]
function ObservedPlayer.StopObserving(self: ObservedPlayer)
	self._Observed = false
	
	self.onObservationStop:Fire()
end

--[[
	Checks if the player is being observed.
]]
function ObservedPlayer.IsObserved(self: ObservedPlayer)
	return self._Observed
end

--[[
	Observes the walkspeed of the Player.
	Flags when the player has a different walkspeed on their client.
	
	Usage:
	‎| ‎ ‎ ‎ local Observer = ObservationService.ObservePlayer(Player)
	|	
	| ‎ ‎ ‎ Observer:StartObserving()
	|	
	| ‎ ‎ ‎ local speedObserver = Observer:ObserveSpeed()
	|	
	| ‎ ‎ ‎ speedObserver.Flagged.Event:Connect(function(reason)
	| ‎ ‎ ‎ ‎‎ ‎ ‎ ‎ print(reason)
	| ‎ ‎ ‎ end)
]]
function ObservedPlayer.ObserveSpeed(
	self: ObservedPlayer,
	allowedSpeed: number?,
	onDetect: (threshold: number, speed: number, state: Enum.HumanoidStateType, ping: number) -> (),
	speedDetectionWait: number?
): Observer.Observer
	if not self:IsObserved() then
		error('Observation needs to be started first!')
		return
	end
	
	if self.SpeedObserved then
		error('Walkspeed is already being observed!')
		return
	end
	
	local ob: Observer.Observer = Observer.new(self.Player)
	
	self.SpeedObserved = true
	
	local PlayerHumanoid: Humanoid? = self.Character:FindFirstChildOfClass("Humanoid")
	local PlayerRoot: BasePart? = self.Character:FindFirstChild("HumanoidRootPart")
	
	if not PlayerHumanoid or not PlayerRoot then
		error(`Player {self.Player.Name} doesn't have a humanoid or root part to observe!`)
		return
	end
	
	local checkDelay = speedDetectionWait or 1
	
	ob.ObservationStop.Event:Once(function()
		self.SpeedObserved = false
	end)
	
	ob:Start(function()
		if PlayerHumanoid.MoveDirection ~= Vector3.zero then
						
			-- do state check here to increase performance
			
			local state = PlayerHumanoid:GetState()
			
			if state ~= Enum.HumanoidStateType.Running then
				return
			end
						
			local oldPosition = PlayerRoot.Position
			
			task.wait(checkDelay)
			
			-- Ignores this tick to avoid false positives
			
			if ob._amountOfTicksToIgnore >= 1 then
				ob._amountOfTicksToIgnore -= 1
				return
			end
			
			local newPosition = PlayerRoot.Position
			local newerPosition = Vector3.new(newPosition.X, oldPosition.Y, newPosition.Z)
			
			local coveredDistance = (newerPosition - oldPosition).Magnitude
			
			local plrPing = self.Player:GetNetworkPing()
			
			local speed = coveredDistance / (checkDelay + (plrPing / 1.25))
			
			ob:PushData(speed) -- Useful for when making auto admin notifier
			
			local threshold = allowedSpeed or PlayerHumanoid.WalkSpeed * 1.25
			
			if speed > threshold then
				if onDetect then
					onDetect(threshold, speed, state, plrPing)
				else
					ob:Flag(`Exceeded allowed walkspeed of {threshold} (Speed: {speed}) while in state {state.Name} with ping buffer of {math.round(plrPing * 1000)}ms`)
				end
			end
		end
	end)
	
	return ob
end

function ObservedPlayer.ObserveJump(
	self: ObservedPlayer,
	allowedJumpHeight: number?,
	onDetect: (threshold: number, jumpHeight: number, state: Enum.HumanoidStateType) -> ()
)
	if not self:IsObserved() then
		error('Observation needs to be started first!')
		return
	end

	if self.JumpObserved then
		error('JumpHeight is already being observed!')
		return
	end
	
	local ob: Observer.Observer = Observer.new(self.Player)

	self.JumpObserved = true

	local PlayerHumanoid: Humanoid? = self.Character:FindFirstChildOfClass("Humanoid")
	local PlayerRoot: BasePart? = self.Character:FindFirstChild("HumanoidRootPart")

	if not PlayerHumanoid or not PlayerRoot then
		error(`Player {self.Player.Name} doesn't have a humanoid or root part to observe!`)
		return
	end

	ob.ObservationStop.Event:Once(function()
		self.JumpObserved = false
	end)

	local threshold = allowedJumpHeight or PlayerHumanoid.JumpHeight * 1.25

	ob:Start(function()
		
		-- Ignores this tick to avoid false positives

		if ob._amountOfTicksToIgnore >= 1 then
			ob._amountOfTicksToIgnore -= 1
			return
		end
		
		-- do state check here to increase performance

		local state = PlayerHumanoid:GetState()

		if state ~= Enum.HumanoidStateType.Freefall then
			return
		end
		
		local currentPos = PlayerRoot.Position
		
		local positions = {}
		
		repeat
			local pos = PlayerRoot.Position
			
			table.insert(positions, pos.Y)
			
			task.wait()
		until PlayerHumanoid:GetState() ~= Enum.HumanoidStateType.Freefall
		
		local highest = math.max(table.unpack(positions))
		
		local difference = highest - currentPos.Y
		
		ob:PushData(positions) -- Useful for when making auto admin notifier
		
		if difference > threshold then
			if onDetect then
				onDetect(threshold, difference, state)
			else
				ob:Flag(`Exceeded allowed jump height of {threshold} (Jump Height: {difference}) while in state {state.Name}`)
			end
		end
	end)

	return ob
end

return ObservedPlayer
