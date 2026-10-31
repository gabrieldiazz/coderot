--!strict
-- A small abandoned minigame plaza. All dimensions use studs; floor top is Y=11.
local ServerStorage = game:GetService("ServerStorage")
local Lobby = {}
local palette = {
	brick = Color3.fromRGB(132, 104, 85), stone = Color3.fromRGB(156, 152, 135),
	cream = Color3.fromRGB(212, 202, 167), teal = Color3.fromRGB(55, 102, 98),
	wood = Color3.fromRGB(109, 85, 59), iron = Color3.fromRGB(49, 59, 57),
	soil = Color3.fromRGB(72, 65, 48), green = Color3.fromRGB(95, 110, 69),
}
local function block(parent: Instance, name: string, size: Vector3, frame: CFrame, color: Color3, material: Enum.Material?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = frame
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end
local function lettering(part: BasePart, text: string, color: Color3, face: Enum.NormalId?)
	local surface = Instance.new("SurfaceGui")
	surface.Face = face or Enum.NormalId.Front
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 32
	surface.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.92, 0.86)
	label.Position = UDim2.fromScale(0.04, 0.07)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.TextWrapped = true
	label.Font = Enum.Font.Code
	label.Parent = surface
	return label
end
local function bench(parent: Instance, frame: CFrame)
	local model = Instance.new("Model")
	model.Name = "ParkBench"
	model.Parent = parent
	for _, x in {-4.3, 4.3} do
		block(model,"IronLeg",Vector3.new(0.5,2.3,2.7),frame*CFrame.new(x,1.15,0),palette.iron,Enum.Material.Metal)
		block(model,"BackSupport",Vector3.new(0.4,4.6,0.4),frame*CFrame.new(x,2.3,1.25),palette.iron,Enum.Material.Metal)
	end
	for index = 0, 3 do
		block(model,"SeatSlat",Vector3.new(10,0.35,0.55),frame*CFrame.new(0,2.4,-0.95+index*0.65),palette.wood,Enum.Material.Wood)
	end
	for index = 0, 2 do
		block(model,"BackSlat",Vector3.new(10,0.6,0.35),frame*CFrame.new(0,3.1+index*0.7,1.25),palette.wood,Enum.Material.Wood)
	end
end
local function planter(parent: Instance, center: Vector3)
	local model = Instance.new("Model")
	model.Name = "OvergrownPlanter"
	model.Parent = parent
	block(model,"BrickBed",Vector3.new(10,1.4,7),CFrame.new(center+Vector3.new(0,0.7,0)),palette.brick,Enum.Material.Brick)
	block(model,"Soil",Vector3.new(8.8,0.15,5.8),CFrame.new(center+Vector3.new(0,1.45,0)),palette.soil,Enum.Material.Ground)
	for index = 1, 7 do
		local x = ((index*7)%9)-4
		local z = ((index*3)%5)-2
		local leaf = block(model,"LongGrass",Vector3.new(0.16,1+index%3,0.7),CFrame.new(center+Vector3.new(x,2.1,z))*CFrame.Angles(0,index,0.25),palette.green,Enum.Material.Grass)
		leaf.CanCollide = false
	end
end
local function kiosk(parent: Instance)
	local frame = CFrame.lookAt(Vector3.new(-28,11,-25),Vector3.new(0,11,0))
	local assets = ServerStorage:FindFirstChild("CodeRotAssets")
	local template = if assets then assets:FindFirstChild("InformationKiosk") else nil
	if template and template:IsA("Model") and template:FindFirstChildWhichIsA("BasePart",true) then
		local imported = template:Clone()
		imported.Name = "InformationKiosk"
		for _, item in imported:GetDescendants() do
			if item:IsA("BasePart") then
				item.Anchored = true
				item.CanCollide = false
			elseif item:IsA("LuaSourceContainer") then item:Destroy() end
		end
		local _, size = imported:GetBoundingBox()
		imported:ScaleTo(imported:GetScale()*10/math.max(size.Y,0.01))
		local box, scaledSize = imported:GetBoundingBox()
		local offset = imported:GetPivot():ToObjectSpace(box)
		imported:PivotTo(frame*CFrame.new(0,scaledSize.Y/2,0)*offset:Inverse())
		imported.Parent = parent
		return
	end
	local model = Instance.new("Model")
	model.Name = "InformationKiosk"
	model.Parent = parent
	block(model,"Foot",Vector3.new(6,0.4,4.5),frame*CFrame.new(0,0.2,0),palette.iron,Enum.Material.Metal)
	block(model,"Cabinet",Vector3.new(4.8,4.4,3),frame*CFrame.new(0,2.6,0),palette.teal,Enum.Material.Metal)
	block(model,"MonitorBezel",Vector3.new(5.6,4,2.6),frame*CFrame.new(0,6.3,0.2),palette.cream)
	local screen = block(model,"OfflineScreen",Vector3.new(4.5,2.8,0.12),frame*CFrame.new(0,6.4,-1.16),Color3.fromRGB(16,30,29),Enum.Material.Glass)
	lettering(screen,"PARK DIRECTORY\n\nconnection lost_",Color3.fromRGB(129,169,127))
	local shelf = block(model,"KeyboardShelf",Vector3.new(5.4,0.3,2),frame*CFrame.new(0,4.4,-2)*CFrame.Angles(math.rad(10),0,0),palette.cream)
	for row = 0, 2 do
		for column = 0, 8 do
			block(model,"Key",Vector3.new(0.38,0.1,0.32),shelf.CFrame*CFrame.new(-1.8+column*0.45,0.2,-0.55+row*0.4),palette.iron)
		end
	end
	for _, x in {-3.1,3.1} do
		block(model,"CanopyPost",Vector3.new(0.25,10,0.25),frame*CFrame.new(x,5,1.4),palette.iron,Enum.Material.Metal)
	end
	block(model,"Canopy",Vector3.new(7.3,0.5,5.7),frame*CFrame.new(0,10.1,0),palette.teal,Enum.Material.Metal)
end
function Lobby.Build(parent: Instance): Folder
	local folder = Instance.new("Folder")
	folder.Name = "Lobby"
	folder.Parent = parent
	block(folder,"Foundation",Vector3.new(100,2,100),CFrame.new(0,10,0),palette.stone,Enum.Material.Concrete)
	-- Broad paving bands keep the plaza legible without hundreds of tiny parts.
	for x = -4, 4 do
		for z = -4, 4 do
			local shade = if (x+z)%2 == 0 then palette.stone else Color3.fromRGB(148,145,130)
			block(folder,"PavingSlab",Vector3.new(9.8,0.12,9.8),CFrame.new(x*10,11.08,z*10),shade,Enum.Material.Concrete)
		end
	end
	for _, x in {-48,48} do
		block(folder,"BoundaryWall",Vector3.new(2,6,100),CFrame.new(x,14,0),palette.brick,Enum.Material.Brick)
		block(folder,"WallCap",Vector3.new(2.6,0.5,100),CFrame.new(x,17.2,0),palette.cream,Enum.Material.Concrete)
	end
	block(folder,"RearWall",Vector3.new(94,6,2),CFrame.new(0,14,-48),palette.brick,Enum.Material.Brick)
	for _, x in {-18,18} do
		block(folder,"EntrancePillar",Vector3.new(3,17,3),CFrame.new(x,19.5,-34),palette.brick,Enum.Material.Brick)
		block(folder,"PillarCap",Vector3.new(4,0.7,4),CFrame.new(x,28.3,-34),palette.cream,Enum.Material.Concrete)
	end
	local header = block(folder,"ParkHeader",Vector3.new(34,5,1.3),CFrame.new(0,25,-34),palette.teal,Enum.Material.Wood)
	local title = lettering(header,"CODE ROT\nM I N I G A M E   P A R K",palette.cream)
	-- Face both the spawn and entrance approach.
	lettering(header,"CODE ROT\nM I N I G A M E   P A R K",palette.cream,Enum.NormalId.Back)
	local board = block(folder,"Noticeboard",Vector3.new(15,8,0.8),CFrame.lookAt(Vector3.new(27,17,-33),Vector3.new(0,17,0)),palette.wood,Enum.Material.Wood)
	local notice = lettering(board,"PARK NOTICE\n\nGames start automatically.\nPlease wait in the plaza.\n\nSTAFF: OFFLINE",palette.cream)
	for _, x in {-31,31} do
		bench(folder,CFrame.new(x,11,12)*CFrame.Angles(0,if x < 0 then -math.pi/2 else math.pi/2,0))
		planter(folder,Vector3.new(x,11,29))
	end
	for _, x in {-13,13} do
		local post = block(folder,"LampPost",Vector3.new(0.5,12,0.5),CFrame.new(x,17,30),palette.iron,Enum.Material.Metal)
		local glass = block(folder,"LampGlass",Vector3.new(1.5,2,1.5),post.CFrame*CFrame.new(0,6,0),Color3.fromRGB(230,203,146),Enum.Material.Neon)
		block(folder,"LampCap",Vector3.new(2,0.4,2),post.CFrame*CFrame.new(0,7.2,0),palette.iron,Enum.Material.Metal)
		local light = Instance.new("PointLight")
		light.Color = glass.Color
		light.Brightness = 0.5
		light.Range = 14
		light.Parent = glass
	end
	kiosk(folder)
	folder:SetAttribute("RotStage",-1)
	-- Stable baseline transforms prevent accumulated skew across updates.
	for _, item in folder:GetDescendants() do
		if item:IsA("BasePart") then item:SetAttribute("Baseline",item.CFrame) end
	end
	-- Labels are found by their named boards, never by arbitrary child order.
	title.Name = "ParkTitle"
	notice.Name = "ParkNotice"
	return folder
end
function Lobby.ApplyRot(folder: Folder, value: number)
	local stage = math.min(3,math.floor(value/30))
	if folder:GetAttribute("RotStage") == stage then return end
	folder:SetAttribute("RotStage",stage)
	local board = folder:FindFirstChild("Noticeboard")
	if board and board:IsA("BasePart") then
		local base = board:GetAttribute("Baseline")
		if typeof(base) == "CFrame" then board.CFrame = base*CFrame.Angles(0,0,math.rad(stage*3)) end
		local surface = board:FindFirstChildOfClass("SurfaceGui")
		local notice = if surface then surface:FindFirstChild("ParkNotice") else nil
		if notice and notice:IsA("TextLabel") then
			notice.Text = if stage == 0 then "PARK NOTICE\n\nGames start automatically.\nPlease wait in the plaza.\n\nSTAFF: OFFLINE"
				else if stage == 1 then "PARK NOTICE\n\nWelcome back.\nWelcome back.\n\nSTAFF: STILL OFFLINE"
				else if stage == 2 then "PARK NOTICE\n\nYour game is still running.\nPlease remain where we can see you."
				else "PARK N_TICE\n\nWE NEVER CLOSED."
		end
	end
end
return Lobby
