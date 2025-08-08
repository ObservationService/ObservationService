local Flag = {}

function Flag.new(reason: string)
	local self = {
		_reason = reason,
		GetReason = function(self: typeof(Flag.new()))
			return self._reason
		end,
	}
	
	return self
end

return Flag
