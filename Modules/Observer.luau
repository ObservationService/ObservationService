local Observer = {}
Observer.__index = Observer

local ObservationService = script.Parent

local FlagClass = require(ObservationService:FindFirstChild("Flag"))

function Observer.new(Player: Player)
	local self = setmetatable({}, Observer)
	
	self.Player = Player
	self.Flagged = Instance.new("BindableEvent")
	self.ObservationStart = Instance.new("BindableEvent")
	self.ObservationStop = Instance.new("BindableEvent")
	
	self.Observing = false
	
	self.data = {}
	
	self._amountOfTicksToIgnore = 0
		
	return self
end

export type Observer = typeof(Observer.new())

--[[
	Starts the observation.
	
	<code>func</code> is the function that is called every <code>delay</code> seconds.
]]
function Observer.Start(self: Observer, func: () -> (), delay: number?)
	if self.Observing then
		error("Observation already in progress!")
		return
	end
	
	self.Observing = true
	self.ObservationStart:Fire()

	self.observationLoop = task.spawn(function()
		while self.Observing do
			func()

			task.wait(delay) -- Pretty sure it defaults to a frame if not provided
		end
	end)
end

--[[
	Stops the observation.
]]
function Observer.Stop(self: Observer)
	if not self.Observing then
		error("Observation must be started to stop!")
		return
	end
	
	self.Observing = false
	self.ObservationStop:Fire()

	if self.observationLoop then
		task.cancel(self.observationLoop)
	end
end

--[[
	Ignores the next tick of detection, useful to avoid false flag detection.
]]
function Observer.IgnoreTick(self: Observer, amount: number?)
	self._amountOfTicksToIgnore += amount or 1
	
	local s, e = pcall(function()
		assert(amount >= 0, "Cannot ignore a negative number of ticks")
	end)
	
	--[[
		Why are you ignoring negative amount of ticks in the first place
		it doesn't work like that
	]]
	
	if not s then
		self._amountOfTicksToIgnore = 0
		if e then
			error(e)
		end
	end
end

function Observer.Flag(self: Observer, reason: string?)
	self.Flagged:Fire(FlagClass.new(reason))
end

--[[
	DO NOT USE!
	
	THIS IS FOR THE FUNCTIONS INSIDE THE OBSERVER!
]]
function Observer._createDataTable(self: Observer)
	warn("Observation has no data table, Creating new data table..")

	self.data = {}
end

--[[
	Adds data to the stored data table of the observer.
]]
function Observer.PushData(self: Observer, data: any)
	if not self.data then
		self:_createDataTable()
	end
	
	table.insert(self.data, data)
end

--[[
	Removes the last data on the stored data table of the observer.
]]
function Observer.PopData(self: Observer)
	if not self.data then
		self:_createDataTable()
	end
	
	table.remove(self.data, #self.data)
end

--[[
	Gets the stored data table of the observer.
]]
function Observer.GetData(self: Observer)
	return self.data
end

return Observer
