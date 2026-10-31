--!strict
local Players = game:GetService("Players")
local Spectator = {}
function Spectator.Update(player: Player, button: TextButton, index: number)
	local camera = workspace.CurrentCamera
	if not camera then return end
	local spectating = player:GetAttribute("Participation") == "Eliminated"
	button.Visible = spectating
	if spectating then
		local targets: {Player} = {}
		for _, other in Players:GetPlayers() do
			if other ~= player and other:GetAttribute("Participation") == "Active" and other.Character then
				local humanoid = other.Character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then table.insert(targets, other) end
			end
		end
		table.sort(targets, function(a, b) return a.UserId < b.UserId end)
		if #targets > 0 then
			local target = targets[(index % #targets) + 1]
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
			button.Text = "Watching " .. target.DisplayName .. " — tap for next"
		else
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = CFrame.lookAt(Vector3.new(310, 85, 70), Vector3.new(250, 12, 0))
			button.Text = "Waiting for the next round"
		end
	elseif player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = humanoid
		end
	end
end
return Spectator
