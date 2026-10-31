--!strict
local Players = game:GetService("Players")
local DisasterIsland = {}
-- This ordinary disaster is separate from the future corruption event director.
function DisasterIsland.Start(parent: Instance): () -> ()
	local running = true
	local effects = Instance.new("Folder")
	effects.Name = "DisasterEffects"
	effects.Parent = parent
	local rng = Random.new()
	local function strike(position: Vector3)
		local marker = Instance.new("Part")
		marker.Name = "DebrisWarning"
		marker.Shape = Enum.PartType.Cylinder
		marker.Size = Vector3.new(0.2, 16, 16)
		marker.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.pi / 2)
		marker.Anchored = true
		marker.CanCollide = false
		marker.Material = Enum.Material.Neon
		marker.Color = Color3.fromRGB(255, 65, 50)
		marker.Transparency = 0.35
		marker.Parent = effects
		task.wait(2.5)
		if not running then return end
		local debris = Instance.new("Part")
		debris.Name = "FallingDebris"
		debris.Size = Vector3.new(5, 5, 5)
		debris.Anchored = true
		debris.CanCollide = false
		debris.Color = Color3.fromRGB(90, 90, 90)
		debris.Parent = effects
		-- Sweep the full rock volume so even edge hits stop at the roof.
		local params = RaycastParams.new()
		local excluded: {Instance} = {effects}
		local visitor = parent:FindFirstChild("BrokenVisitor")
		if visitor then table.insert(excluded, visitor) end
		for _, player in Players:GetPlayers() do
			if player.Character then table.insert(excluded, player.Character) end
		end
		params.FilterDescendantsInstances = excluded
		params.RespectCanCollide = true
		local start = position + Vector3.new(0, 65, 0)
		local hit = workspace:Blockcast(CFrame.new(start), debris.Size, Vector3.new(0, -70, 0), params)
		local travel = if hit then hit.Distance else 65
		local finish = start - Vector3.new(0, travel, 0)
		debris.Material = Enum.Material.Slate
		debris.Position = start
		local started = os.clock()
		repeat
			debris.Position = start:Lerp(finish, math.clamp((os.clock() - started) / 0.8, 0, 1))
			task.wait()
		until not running or os.clock() - started >= 0.8
		if not running then return end
		debris.Position = finish
		-- Server raycast: roofs and solid map geometry protect players below them.
		for _, player in Players:GetPlayers() do
			local character = player.Character
			local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
			local body = if character then character:FindFirstChild("HumanoidRootPart") else nil
			if player:GetAttribute("Participation") == "Active" and humanoid and body and body:IsA("BasePart") then
				local delta = body.Position - position
				if Vector2.new(delta.X, delta.Z).Magnitude <= 8 and math.abs(delta.Y) < 12 then
					local params = RaycastParams.new()
					local excluded: {Instance} = {effects}
					for _, other in Players:GetPlayers() do
						if other.Character then table.insert(excluded, other.Character) end
					end
					params.FilterDescendantsInstances = excluded
					params.RespectCanCollide = true
					local hit = workspace:Raycast(body.Position, Vector3.new(0, 90, 0), params)
					if not hit then humanoid:TakeDamage(40) end
				end
			end
		end
		marker:Destroy()
		task.wait(0.35)
		if not running then return end
		debris:Destroy()
	end
	local worker = task.spawn(function()
		task.wait(5)
		while running do
			local targets = {}
			for _, player in Players:GetPlayers() do
				if player:GetAttribute("Participation") == "Active" and player.Character then
					local body = player.Character:FindFirstChild("HumanoidRootPart")
					if body and body:IsA("BasePart") then table.insert(targets, body.Position) end
				end
			end
			local target = Vector3.new(250 + rng:NextNumber(-40, 40), 12.2, rng:NextNumber(-40, 40))
			if #targets > 0 and rng:NextNumber() < 0.7 then
				local chosen = targets[rng:NextInteger(1, #targets)]
				target = Vector3.new(chosen.X, 12.2, chosen.Z)
			end
			strike(target)
			task.wait(rng:NextNumber(1.5, 3))
		end
	end)
	return function()
		running = false
		if coroutine.status(worker) ~= "dead" then task.cancel(worker) end
		effects:Destroy()
	end
end
return DisasterIsland
