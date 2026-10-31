--!strict
local Rot = {}
function Rot.Advance(current: number, target: number, progress: number): number
	return math.clamp(math.max(current, target * math.clamp(progress, 0, 1)), 0, 100)
end
return Rot
