--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local World = require(script.Services.World)
local DisasterIsland = require(script.Services.DisasterIsland)
local Rot = require(script.Services.RotService)
local Chain = require(script.Services.RotChain)
Players.CharacterAutoLoads = false
World.Start()
local state = Instance.new("Folder")
state.Name = "CodeRotState"
state.Parent = ReplicatedStorage
local spawning: {[Player]: boolean} = {}
local destination = World.LobbySpawn
local function spawnPlayer(player: Player, participation: string)
	while spawning[player] and player.Parent == Players do task.wait() end
	if player.Parent ~= Players then return end
	spawning[player] = true
	player:SetAttribute("Participation", participation)
	local ok, err = pcall(function() player:LoadCharacterAsync() end)
	if ok and player.Character and player.Parent == Players then
		local target = if participation == "Active" then destination else World.LobbySpawn
		player.Character:PivotTo(target * CFrame.new(math.random(-10, 10), 0, math.random(-8, 8)))
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		local spawnedCharacter = player.Character
		if humanoid then
			humanoid.Died:Connect(function()
				if player.Character == spawnedCharacter and player:GetAttribute("Participation") == "Active" then
					player:SetAttribute("Participation", "Eliminated")
				end
			end)
		end
	else
		warn("CODE ROT spawn failed", player.Name, err)
		player:SetAttribute("Participation", "Waiting")
	end
	spawning[player] = nil
end
local function setup(player: Player)
	player:SetAttribute("Participation", "Waiting")
	task.spawn(spawnPlayer, player, "Waiting")
end
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player) spawning[player] = nil end)
for _, player in Players:GetPlayers() do setup(player) end
local function activeCount(): number
	local count = 0
	for _, player in Players:GetPlayers() do
		if player:GetAttribute("Participation") == "Active" then count += 1 end
	end
	return count
end
local function phase(name: string, duration: number, round: number)
	local playing = name == "Round" or name == "Finale"
	state:SetAttribute("Phase", "Preparing")
	state:SetAttribute("Deadline", 0)
	state:SetAttribute("Round", round)
	if playing then World.ResetIsland() end
	destination = if playing then World.IslandSpawn else World.LobbySpawn
	for _, player in Players:GetPlayers() do
		local outcome = player:GetAttribute("Participation") or "Waiting"
		spawnPlayer(player, if playing then "Active" else "Waiting")
		if name == "Results" then player:SetAttribute("Participation", outcome) end
	end
	state:SetAttribute("Phase", name)
	state:SetAttribute("Objective", if name == "Round" then "Survive falling debris. Avoid red markers or shelter under the roof."
		else if name == "Finale" then "Finale placeholder — escape is not implemented yet."
		else if name == "Results" then "Match finished. A new match starts shortly."
		else "Wait in the lobby for the next round.")
	local deadline = workspace:GetServerTimeNow() + duration
	state:SetAttribute("Deadline", deadline)
	local rotStart = state:GetAttribute("GlobalRot") or 0
	local rotTarget = if name == "Round" then round*30 else if name == "Intermission" then round*30+3 else rotStart
	if name == "Finale" then state:SetAttribute("GlobalRot",100) end
	local chainCleanup = Chain.Start(workspace.CodeRotRuntime, if playing then Vector3.new(270,15,0) else Vector3.new(20,14,0), math.clamp(round,1,3), playing and round >= 3)
	local cleanup = if name == "Round" then DisasterIsland.Start(workspace.CodeRotRuntime) else nil
	repeat
		task.wait(0.25)
		local progress = math.clamp(1-(deadline-workspace:GetServerTimeNow())/duration,0,1)
		state:SetAttribute("GlobalRot",Rot.Advance(state:GetAttribute("GlobalRot") or 0, rotStart+(rotTarget-rotStart)*progress,1))
		World.ApplyRot(state:GetAttribute("GlobalRot") or 0)
		if name == "Round" then
			for _, player in Players:GetPlayers() do
				local character = player.Character
				local body = if character then character:FindFirstChild("HumanoidRootPart") else nil
				local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
				if player:GetAttribute("Participation") == "Active" and body and body:IsA("BasePart") and humanoid and body.Position.Y < 6 then
					humanoid.Health = 0
				end
			end
		end
	until #Players:GetPlayers() == 0 or (playing and activeCount() == 0) or workspace:GetServerTimeNow() >= deadline
	if cleanup then cleanup() end
	chainCleanup()
	state:SetAttribute("GlobalRot",math.max(state:GetAttribute("GlobalRot") or 0,rotTarget))
	for _, player in Players:GetPlayers() do
		if player:GetAttribute("Participation") == "Active" then
			player:SetAttribute("Participation", if name == "Finale" then "Defeated" else "Survived")
		elseif name == "Finale" and player:GetAttribute("Participation") == "Eliminated" then
			player:SetAttribute("Participation", "Defeated")
		end
	end
end
while true do
	state:SetAttribute("Phase", "Waiting")
	state:SetAttribute("Deadline", 0)
	repeat task.wait(0.5) until #Players:GetPlayers() > 0
	state:SetAttribute("GlobalRot",0)
	phase("Lobby", Config.LobbyDuration, 0)
	for round = 1, Config.RoundCount do
		if #Players:GetPlayers() == 0 then break end
		phase("Round", Config.RoundDuration, round)
		if round < Config.RoundCount and #Players:GetPlayers() > 0 then phase("Intermission", Config.IntermissionDuration, round) end
	end
	if #Players:GetPlayers() > 0 then
		phase("Finale", Config.FinaleDuration, 4)
		phase("Results", Config.ResultsDuration, 4)
	end
end
