--!strict
local Spectator = require(script.Controllers.Spectator)
local Lighting = game:GetService("Lighting")
local originalBrightness = Lighting.Brightness
local Players = game:GetService("Players")
local state = game:GetService("ReplicatedStorage"):WaitForChild("CodeRotState")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CodeRotHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.9, 0, 0, 110)
label.Position = UDim2.new(0.05, 0, 0, 10)
label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
label.BackgroundTransparency = 0.2
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.Code
label.TextSize = 18
label.TextWrapped = true
label.Parent = gui
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.8, 0, 0, 48)
button.Position = UDim2.new(0.1, 0, 1, -110)
button.BackgroundColor3 = Color3.fromRGB(35, 55, 75)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextWrapped = true
button.TextSize = 16
button.Visible = false
button.Parent = gui
local index = 0
button.Activated:Connect(function() index += 1 end)
while gui.Parent do
	Spectator.Update(player, button, index)
	local rot = state:GetAttribute("GlobalRot") or 0
	Lighting.Brightness = originalBrightness * (1-rot/160)
	local deadline = state:GetAttribute("Deadline") or 0
	local remaining = math.max(0, math.ceil(deadline - workspace:GetServerTimeNow()))
	label.Text = string.format("CODE ROT | %s | Round %d | %ds\n%s", state:GetAttribute("Phase") or "Waiting", state:GetAttribute("Round") or 0, remaining, player:GetAttribute("Participation") or "Waiting") .. string.format(" | Rot %d%%",rot) .. "\n" .. (state:GetAttribute("Objective") or "")
	task.wait(0.2)
end
