--========================================================--
-- 🎮 SCRIPT FINAL COMPLETO AJUSTADO – DELTA (BOTÕES SOMENTE)
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

--========================================================--
-- 🔊 SONS PERSONALIZADOS (PASSOS + PULO PARA TODOS)
--========================================================--

local passosEnabled = false
local FOOTSTEP_ID = "rbxassetid://89746938623207"
local JUMP_ID     = "rbxassetid://76693372307958"

local function aplicarSons(char)
	if not passosEnabled then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _,s in ipairs(root:GetChildren()) do
		if s:IsA("Sound") then
			if s.Name == "Running" then
				s.SoundId = FOOTSTEP_ID
				s.Volume = 0.3
			elseif s.Name == "Jumping" then
				s.SoundId = JUMP_ID
				s.Volume = 0.3
			end
		end
	end
end

if LocalPlayer.Character then aplicarSons(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.3) aplicarSons(c) end)

local function monitorPlayerSounds(plr)
	if plr.Character then aplicarSons(plr.Character) end
	plr.CharacterAdded:Connect(function(c) task.wait(0.3) aplicarSons(c) end)
end

for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then monitorPlayerSounds(p) end end
Players.PlayerAdded:Connect(function(plr) if plr ~= LocalPlayer then monitorPlayerSounds(plr) end end)

--========================================================--
-- 🔥 ESP (JOGADORES + PORTAS)
--========================================================--

local ESP_PLAYERS, ESP_DOORS = false, false
local espObjs = {}

local function highlight(obj, color)
	if obj:FindFirstChild("ESP_HIGHLIGHT") then return end
	local h = Instance.new("Highlight")
	h.Name = "ESP_HIGHLIGHT"
	h.FillColor = color
	h.OutlineColor = color
	h.FillTransparency = 0.6
	h.OutlineTransparency = 0.1
	h.Parent = obj
	table.insert(espObjs, obj)
end

local function limparESP()
	for _,o in ipairs(espObjs) do
		if o:FindFirstChild("ESP_HIGHLIGHT") then
			o.ESP_HIGHLIGHT:Destroy()
		end
	end
	espObjs = {}
end

function atualizarESP()
	limparESP()
	if ESP_PLAYERS then
		for _,p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				highlight(p.Character, Color3.fromRGB(255,0,0))
			end
		end
	end
	if ESP_DOORS then
		for _,m in ipairs(Workspace:GetDescendants()) do
			if m:IsA("Model") then
				local n = m.Name:lower()
				if n:find("door") or n:find("exit") then
					local aberta = false
					if m:FindFirstChild("IsOpen") and m.IsOpen.Value then aberta = true end
					if m:FindFirstChild("Open") and m.Open.Value then aberta = true end
					if m:FindFirstChild("Opened") and m.Opened.Value then aberta = true end

					local cor = aberta and Color3.fromRGB(50,255,50) or Color3.fromRGB(255,220,0)
					highlight(m, cor)
				end
			end
		end
	end
end

--========================================================--
-- 🖥️ PC PROGRESS
--========================================================--

local PC_ENABLED = false
local allPCs = {}

local function corGradiente(p)
	if p >= 1 then return Color3.fromRGB(0,255,0) end
	if p < 0.5 then
		return Color3.fromRGB(255, 255 * p * 2, 255 * p * 2)
	else
		return Color3.fromRGB(255, 255 - ((p-0.5)*2*255), 0)
	end
end

local function setupPC(pc)
	if pc:FindFirstChild("ProgressBar") then return end

	local guiB = Instance.new("BillboardGui", pc)
	guiB.Name = "ProgressBar"
	guiB.Size = UDim2.new(0,160,0,16)
	guiB.StudsOffset = Vector3.new(0,2.6,0)
	guiB.AlwaysOnTop = true
	guiB.Enabled = PC_ENABLED

	local bg = Instance.new("Frame", guiB)
	bg.Size = UDim2.new(1,0,1,0)
	bg.BackgroundColor3 = Color3.fromRGB(0,0,0)

	local bar = Instance.new("Frame", bg)
	bar.Size = UDim2.new(0,0,1,0)

	local txt = Instance.new("TextLabel", bg)
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.TextScaled = true
	txt.Font = Enum.Font.SciFi
	txt.TextColor3 = Color3.new(1,1,1)

	local hl = Instance.new("Highlight", pc)
	hl.Name = "ComputerHighlight"
	hl.Enabled = PC_ENABLED

	allPCs[pc] = {guiB, hl}

	local save = 0

	RunService.Heartbeat:Connect(function()
		local highest = 0
		for _,p in ipairs(pc:GetChildren()) do
			if p:IsA("BasePart") and p.Name:match("ComputerTrigger") then
				for _,t in ipairs(p:GetTouchingParts()) do
					local pl = Players:GetPlayerFromCharacter(t.Parent)
					if pl then
						local m = pl:FindFirstChild("TempPlayerStatsModule")
						if m and not m.Ragdoll.Value then
							highest = math.max(highest, m.ActionProgress.Value)
						end
					end
				end
			end
		end

		save = math.max(save, highest)
		bar.Size = UDim2.new(save,0,1,0)
		bar.BackgroundColor3 = corGradiente(save)

		if save >= 1 then
			txt.Text = "COMPLETED"
			hl.FillColor = Color3.fromRGB(0,255,0)
		else
			txt.Text = math.floor(save*100).."%"
		end
	end)
end

task.spawn(function()
	while true do
		local map = Workspace:FindFirstChild(tostring(ReplicatedStorage.CurrentMap.Value))
		if map then
			for _,o in ipairs(map:GetChildren()) do
				if o.Name == "ComputerTable" then
					setupPC(o)
				end
			end
		end
		task.wait(1)
	end
end)

--========================================================--
-- ⌛ GET UP (PARTE INFERIOR DIREITA)
--========================================================--

local GETUP_ENABLED = false
local getupGui = Instance.new("ScreenGui")
getupGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
getupGui.Enabled = true

local lista = Instance.new("Frame", getupGui)
lista.Size = UDim2.new(0,250,0,400)
lista.Position = UDim2.new(1,-20,1,-20)
lista.AnchorPoint = Vector2.new(1,1)
lista.BackgroundTransparency = 1

local activeLabels = {}

local function getColor(progress)
	return Color3.fromRGB(255*(1-progress),255*progress,0)
end

local function criarGetUp(plr)
	local lbl = Instance.new("TextLabel", lista)
	lbl.Size = UDim2.new(1,0,0,35)
	lbl.BackgroundTransparency = 1
	lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamBold
	lbl.TextXAlignment = Enum.TextXAlignment.Right
	lbl.TextColor3 = Color3.new(1,1,1)

	table.insert(activeLabels, 1, lbl)
	for i,label in ipairs(activeLabels) do
		label.Position = UDim2.new(0,0,1,-(i*35))
	end

	local inicio = tick()
	local tempo = 28

	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not lbl.Parent then
			if conn then conn:Disconnect() end
			return
		end
		lbl.Visible = GETUP_ENABLED
		local restante = tempo - (tick()-inicio)
		if restante > 0 then
			lbl.Text = plr.Name.." - "..string.format("%.3fs",restante)
			lbl.TextColor3 = getColor(restante/tempo)
		else
			lbl.Text = plr.Name.." levantou!"
			task.delay(2,function()
				lbl:Destroy()
				for i=#activeLabels,1,-1 do
					if activeLabels[i] == lbl then
						table.remove(activeLabels,i)
					end
				end
				for i,label in ipairs(activeLabels) do
					label.Position = UDim2.new(0,0,1,-(i*35))
				end
			end)
			if conn then conn:Disconnect() end
		end
	end)
end

local function monitor(plr)
	local function char(c)
		c:WaitForChild("Humanoid").GetPropertyChangedSignal(
			c.Humanoid,"PlatformStand"
		):Connect(function()
			if c.Humanoid.PlatformStand then
				criarGetUp(plr)
			end
		end)
	end
	if plr.Character then char(plr.Character) end
	plr.CharacterAdded:Connect(char)
end

for _,p in ipairs(Players:GetPlayers()) do monitor(p) end
Players.PlayerAdded:Connect(monitor)

--========================================================--
-- 🎛️ PAINEL DE CONTROLE (BOTÕES SOMENTE)
--========================================================--

local guiPanel = Instance.new("ScreenGui")
guiPanel.Name = "FTF_MASTER_PANEL"
guiPanel.Parent = LocalPlayer:WaitForChild("PlayerGui")

local openBtn = Instance.new("ImageButton", guiPanel)
openBtn.Size = UDim2.new(0,45,0,45)
openBtn.Position = UDim2.new(0,10,0.5,-22)
openBtn.Image = "rbxassetid://87074630946606"
openBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
openBtn.BorderSizePixel = 0
Instance.new("UICorner", openBtn)

-- Botão arrastável
local dragging, dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	openBtn.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end
openBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = openBtn.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
openBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
RunService.RenderStepped:Connect(function()
	if dragging and dragInput then
		update(dragInput)
	end
end)

-- Painel limpo
local panel = Instance.new("Frame", guiPanel)
panel.Size = UDim2.new(0,230,0,360)
panel.Position = UDim2.new(0,60,0.5,-180)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.BorderSizePixel = 0
panel.Visible = false
Instance.new("UICorner", panel)

local layout = Instance.new("UIListLayout", panel)
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder

openBtn.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

-- Função para criar toggles
local function criarToggle(texto, callback)
	local btn = Instance.new("TextButton", panel)
	btn.Size = UDim2.new(1,-20,0,40)
	btn.Text = texto.." : OFF"
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn)

	local ativo = false
	btn.MouseButton1Click:Connect(function()
		ativo = not ativo
		btn.Text = texto..(ativo and " : ON" or " : OFF")
		callback(ativo)
	end)
end

-- Criar toggles
criarToggle("🔊 Passos", function(v) 
	passosEnabled=v 
	if v then 
		for _,plr in ipairs(Players:GetPlayers()) do
			if plr.Character then aplicarSons(plr.Character) end
		end
	end 
end)
criarToggle("🚪 Doors ESP", function(v) ESP_DOORS=v atualizarESP() end)
criarToggle("👁️ Players ESP", function(v) ESP_PLAYERS=v atualizarESP() end)
criarToggle("🖥️ PC Progress", function(v)
	PC_ENABLED=v
	for _,v in pairs(allPCs) do
		v[1].Enabled = PC_ENABLED
		v[2].Enabled = PC_ENABLED
	end
end)
criarToggle("⌛ Get Up", function(v) GETUP_ENABLED=v end)

-- Texto de informação
local infoText = Instance.new("TextLabel", panel)
infoText.Size = UDim2.new(1,-20,0,100)
infoText.BackgroundTransparency = 1
infoText.Position = UDim2.new(0,10,1,-110)
infoText.Font = Enum.Font.GothamBold
infoText.TextColor3 = Color3.fromRGB(255,255,255)
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Center
infoText.TextYAlignment = Enum.TextYAlignment.Center
infoText.Text = "🇧🇷 Se você tem ideia de novas atualizações no painel me chame na dm do Discord, user: @y_fer\n\n🇺🇸 If you have any ideas for new updates to the panel, DM me on Discord, username: @y_fer\n\n🇪🇸 Si tienes alguna idea para nuevas actualizaciones del panel, envíame un mensaje en md, Discord, nickname: @y_fer"

print("✅ SCRIPT FINAL – BOTÕES SOMENTE, PAINEL LIMPO")
