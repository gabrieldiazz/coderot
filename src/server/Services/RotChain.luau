--!strict
local Players = game:GetService("Players")
local Chain = {}
function Chain.Start(parent: Instance, origin: Vector3, stage: number, hostile: boolean): () -> ()
	local model = Instance.new("Model")
	model.Name = "BrokenVisitor"
	local pieces = {}
	for _, spec in { {"Torso", Vector3.new(2,2,1), Vector3.new(0,0,0)}, {"Head", Vector3.new(2,1,1), Vector3.new(0,1.5,0)}, {"LeftArm", Vector3.new(1,2,1), Vector3.new(-1.5,0,0)}, {"RightArm", Vector3.new(1,2,1), Vector3.new(1.5,0,0)}, {"LeftLeg", Vector3.new(1,2,1), Vector3.new(-0.5,-2,0)}, {"RightLeg", Vector3.new(1,2,1), Vector3.new(0.5,-2,0)} } do
		local part = Instance.new("Part")
		part.Name = spec[1]
		part.Size = spec[2]
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CFrame = CFrame.new(origin + spec[3])
		part.Color = if part.Name == "Head" then Color3.fromRGB(245,205,48) else Color3.fromRGB(50,100,170)
		if part.Name == "Head" then
			local surface = Instance.new("SurfaceGui")
			surface.Face = Enum.NormalId.Front
			surface.Parent = part
			local face = Instance.new("TextLabel")
			face.Size = UDim2.fromScale(1,1)
			face.BackgroundTransparency = 1
			face.TextColor3 = Color3.fromRGB(30,25,20)
			face.Font = Enum.Font.Code
			face.TextScaled = true
			face.Text = ":)"
			face.Rotation = 90
			face.Parent = surface
		end
		part.Parent = model
		table.insert(pieces, {part = part, offset = spec[3]})
	end
	model.Parent = parent
	local alive = true
	local position = origin
	local began = os.clock()
	local hits: {[Player]: number} = {}
	local worker = task.spawn(function()
		local previous = os.clock()
		while alive do
			local now = os.clock()
			local dt = math.min(now - previous, 0.2)
			previous = now
			local target: BasePart? = nil
			local owner: Player? = nil
			local distance = math.huge
			for _, player in Players:GetPlayers() do
				local character = player.Character
				local body = if character then character:FindFirstChild("HumanoidRootPart") else nil
				local human = if character then character:FindFirstChildOfClass("Humanoid") else nil
				if body and body:IsA("BasePart") and human and human.Health > 0 and (not hostile or player:GetAttribute("Participation") == "Active") then
					local d = (body.Position - position).Magnitude
					if d < distance then target = body; owner = player; distance = d end
				end
			end
			local pursuing = hostile and now - began > 5 and (now - began) % 20 < 12
			if pursuing and target then
				local delta = Vector3.new(target.Position.X-position.X,0,target.Position.Z-position.Z)
				if delta.Magnitude > 3 then
					local step = delta.Unit * math.min(12*dt,delta.Magnitude-3)
					local params = RaycastParams.new()
					params.FilterDescendantsInstances = {model, target.Parent :: Instance}
					if not workspace:Raycast(position, step.Unit * (step.Magnitude+2), params) then
						local nextPosition = position + step
						if math.abs(nextPosition.X-origin.X) < 40 and math.abs(nextPosition.Z-origin.Z) < 40 then position = nextPosition end
					end
				end
				if owner and distance <= 4 and now-(hits[owner] or 0) >= 2 then
					local params = RaycastParams.new()
					params.FilterDescendantsInstances = {model}
					local hit = workspace:Raycast(position,target.Position-position,params)
					if hit and hit.Instance:IsDescendantOf(target.Parent) then
						local human = target.Parent:FindFirstChildOfClass("Humanoid")
						if human then human:TakeDamage(20); hits[owner]=now end
					end
				end
			end
			local facing = if target and stage > 1 then Vector3.new(target.Position.X,position.Y,target.Position.Z) else position+Vector3.new(0,0,1)
			local frame = if (facing-position).Magnitude > 0.01 then CFrame.lookAt(position,facing) else CFrame.new(position)
			-- A periodic stumble, pause on the floor, then recover; never spin.
			local cycle = (now - began) % 10
			local collapse = if cycle < 5 then 0 else if cycle < 5.5 then (cycle-5)/0.5 else if cycle < 7.5 then 1 else if cycle < 8.5 then 1-(cycle-7.5) else 0
			if stage == 1 then
				frame = frame * CFrame.new(0, -2 * collapse, 0) * CFrame.Angles(math.rad(80)*collapse,0,0)
			end
			for _, item in pieces do
				local limb = CFrame.new(item.offset)
				if stage == 1 and string.find(item.part.Name,"Arm") then
					limb *= CFrame.Angles(0,0,math.rad(35)*collapse)
				end
				item.part.CFrame = frame * limb
			end
			task.wait(0.1)
		end
	end)
	return function() alive=false; task.cancel(worker); model:Destroy(); table.clear(hits) end
end
return Chain
