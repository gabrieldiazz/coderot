--!strict
local Lobby = require(script.Parent.Lobby)
local World = {}
World.LobbySpawn = CFrame.new(0, 16, 0)
World.IslandSpawn = CFrame.new(250, 16, 0)
local root = Instance.new("Folder")
root.Name = "CodeRotRuntime"
root.Parent = workspace
local island: Folder
local function part(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3): Part
	local block = Instance.new("Part")
	block.Name = name
	block.Size = size
	block.Position = position
	block.Anchored = true
	block.Color = color
	block.TopSurface = Enum.SurfaceType.Studs
	block.Parent = parent
	return block
end
local function sign(parent: Instance, title: string, position: Vector3)
	local board = part(parent, "Sign", Vector3.new(24, 9, 1), position, Color3.fromRGB(35, 55, 75))
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.Parent = board
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1, 1, 1)
	text.Font = Enum.Font.Code
	text.TextScaled = true
	text.Text = title
	text.Parent = surface
end
function World.ResetIsland()
	if island then island:Destroy() end
	island = Instance.new("Folder")
	island.Name = "DisasterIsland"
	island.Parent = root
	part(island, "Sand", Vector3.new(100, 4, 100), Vector3.new(250, 9, 0), Color3.fromRGB(194, 178, 128))
	part(island, "Grass", Vector3.new(84, 1, 84), Vector3.new(250, 11.5, 0), Color3.fromRGB(90, 145, 65))
	local water = part(island, "Water", Vector3.new(180, 1, 180), Vector3.new(250, 2, 0), Color3.fromRGB(40, 110, 180))
	water.CanCollide = false
	water.Transparency = 0.3
	for _, offset in {Vector3.new(-15, 8, -30), Vector3.new(15, 8, -30), Vector3.new(-15, 8, -10), Vector3.new(15, 8, -10)} do
		part(island, "ShelterPost", Vector3.new(2, 16, 2), Vector3.new(250, 12, 0) + offset, Color3.fromRGB(125, 80, 45))
	end
	part(island, "ShelterRoof", Vector3.new(36, 2, 26), Vector3.new(250, 29, -20), Color3.fromRGB(160, 55, 45))
	for _, offset in {Vector3.new(-30, 0, 20), Vector3.new(30, 0, 15)} do
		part(island, "TreeTrunk", Vector3.new(3, 15, 3), Vector3.new(250, 19, 0) + offset, Color3.fromRGB(110, 75, 40))
		part(island, "TreeCrown", Vector3.new(15, 12, 15), Vector3.new(250, 31, 0) + offset, Color3.fromRGB(45, 110, 45))
	end
	for _, x in {-38,38} do
		for _, z in {-38,0,38} do
			local rock = part(island,"ShoreRock",Vector3.new(8,5,7),Vector3.new(250+x,12,z),Color3.fromRGB(95,100,103))
			rock.Material = Enum.Material.Slate
			rock.CFrame *= CFrame.Angles(0,math.rad(z),math.rad(12))
		end
	end
	part(island,"ShelterPath",Vector3.new(10,0.2,30),Vector3.new(250,12.1,-4),Color3.fromRGB(185,170,130))
	part(island,"Dock",Vector3.new(12,1,25),Vector3.new(250,11.5,48),Color3.fromRGB(125,80,45))
	sign(island, "DISASTER ISLAND\nWatch red markers!\nRoof blocks debris.", Vector3.new(250, 19, 34))
end
function World.ApplyRot(value: number)
	local lobby = root:FindFirstChild("Lobby")
	if lobby and lobby:IsA("Folder") then Lobby.ApplyRot(lobby,value) end
end
function World.Start()
	Lobby.Build(root)
	World.ResetIsland()
end
return World
