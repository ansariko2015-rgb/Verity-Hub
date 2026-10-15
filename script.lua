-- Автозапуск скрипта после телепортации в катку
if queue_on_teleport then
	queue_on_teleport([[
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    ]])
end

task.spawn(function()
	task.wait(0.2)

	local Players = game:GetService("Players")
	local CoreGui = game:GetService("CoreGui")
	local Workspace = game:GetService("Workspace")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")

	local LocalPlayer = Players.LocalPlayer
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local Camera = Workspace.CurrentCamera

	pcall(function() CoreGui.VerityTDHub:Destroy() end)
	pcall(function() PlayerGui.VerityTDHub:Destroy() end)

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "VerityTDHub"
	ScreenGui.ResetOnSpawn = false

	local parentSuccess = pcall(function() ScreenGui.Parent = CoreGui end)
	if not parentSuccess or not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

	-- Переменные состояний
	local notifsEnabled = true
	local freeButtonMovable = false
	local selectedPlayer = nil
	local selectedServerBtn = nil
	local spectating = false
	local espStates = {}
	local espBestStates = {}

	-- Авто-плей состояние
	local autoPlaceEnabled = false
	local selectedPlaceUnit = nil

	-- Playtime переменные
	local playtimeSeconds = 0
	local plusClicks = 0
	local minusClicks = 0
	local currentCount = 0

	-- Цены юнитов для расстановки
	local unitPrices = {
		["Verity"] = 100,
		["Falsity"] = 150,
		["Curiosity"] = 200,
		["Lovity"] = 250,
		["Cruelity"] = 500,
		["Stupidity"] = 650,
		["Manipulity"] = 700,
		["Quadrupedal Stalker"] = 800,
		["Lord Verity"] = 800,
		["Calamity"] = 1000,
		["Clownity"] = 175,
		["Verity Boss"] = 2000,
		["Hydro Verity"] = 2000
	}

	-- Координаты карт
	local backroomsCoordinates = {
		Vector3.new(0.9, 118.9, -18.4),
		Vector3.new(-2.4, 118.9, -15.6),
		Vector3.new(-3.0, 118.9, -18.6),
		Vector3.new(15.2, 118.9, -36.9),
		Vector3.new(18.3, 118.9, -36.0),
		Vector3.new(18.6, 118.9, -32.2),
		Vector3.new(-12.1, 118.9, -49.5),
		Vector3.new(-20.5, 118.9, -50.5),
		Vector3.new(-20.5, 118.9, -53.0)
	}

	local mobsHouseCoordinates = {
		Vector3.new(-25.3, 37.1, 5.3),
		Vector3.new(-29.1, 37.1, -2.5),
		Vector3.new(-29.1, 37.1, 1.7),
		Vector3.new(-28.9, 37.1, 5.1),
		Vector3.new(-28.8, 37.1, 4.9),
		Vector3.new(-0.9, 37.1, -63.8),
		Vector3.new(-1.5, 37.1, -61.1),
		Vector3.new(-1.1, 37.1, -66.4),
		Vector3.new(-1.1, 37.1, -58.7),
		Vector3.new(-1.8, 37.1, -68.2)
	}

	local locustsManorCoordinates = {
		Vector3.new(25.3, 118.9, 38.5),
		Vector3.new(28.8, 118.9, 38.6),
		Vector3.new(32.6, 118.9, 38.5),
		Vector3.new(35.3, 118.9, 38.8),
		Vector3.new(38.5, 118.9, 39.0),
		Vector3.new(30.2, 118.9, 27.7),
		Vector3.new(25.2, 118.9, 27.6),
		Vector3.new(20.2, 118.9, 27.5),
		Vector3.new(19.8, 118.9, 38.0),
		Vector3.new(21.9, 118.9, 38.5),
		Vector3.new(36.4, 118.9, 27.6),
		Vector3.new(33.1, 118.9, 27.7)
	}

	-- Уведомления
	local NotifContainer = Instance.new("Frame", ScreenGui)
	NotifContainer.Size = UDim2.new(0, 270, 1, 0)
	NotifContainer.Position = UDim2.new(1, -280, 0, 15)
	NotifContainer.BackgroundTransparency = 1
	NotifContainer.ZIndex = 100

	local function Notify(text)
		if not notifsEnabled then return end

		local NFrame = Instance.new("Frame", NotifContainer)
		NFrame.Size = UDim2.new(1, 0, 0, 48)
		NFrame.Position = UDim2.new(1, 290, 0, 0)
		NFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
		NFrame.BorderSizePixel = 0
		NFrame.ZIndex = 101
		Instance.new("UICorner", NFrame).CornerRadius = UDim.new(0, 8)

		local NStroke = Instance.new("UIStroke", NFrame)
		NStroke.Color = Color3.fromRGB(255, 170, 0)
		NStroke.Thickness = 1.2

		local NLabel = Instance.new("TextLabel", NFrame)
		NLabel.Size = UDim2.new(1, -12, 1, 0)
		NLabel.Position = UDim2.new(0, 6, 0, 0)
		NLabel.BackgroundTransparency = 1
		NLabel.Text = "🥭 " .. text
		NLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
		NLabel.Font = Enum.Font.GothamBold
		NLabel.TextSize = 12
		NLabel.TextWrapped = true
		NLabel.ZIndex = 102

		NFrame:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.4, true)

		task.delay(3, function()
			NFrame:TweenPosition(UDim2.new(1, 290, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true, function()
				NFrame:Destroy()
			end)
		end)
	end

	Notify("Verity Tower Defense Mango Hub Loaded! 🥭")

	-- Кнопка Mango
	local OpenBtn = Instance.new("TextButton", ScreenGui)
	OpenBtn.Size = UDim2.new(0, 45, 0, 45)
	OpenBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
	OpenBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	OpenBtn.Text = "🥭"
	OpenBtn.TextSize = 24
	OpenBtn.Visible = false
	OpenBtn.Active = true
	Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 10)

	local OStroke = Instance.new("UIStroke", OpenBtn)
	OStroke.Color = Color3.fromRGB(60, 60, 60)
	OStroke.Thickness = 1.2

	local draggingBtn, dragInputBtn, dragStartBtn, startPosBtn
	OpenBtn.InputBegan:Connect(function(input)
		if freeButtonMovable and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			draggingBtn = true
			dragStartBtn = input.Position
			startPosBtn = OpenBtn.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then draggingBtn = false end
			end)
		end
	end)
	OpenBtn.InputChanged:Connect(function(input)
		if freeButtonMovable and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			dragInputBtn = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInputBtn and draggingBtn then
			local delta = input.Position - dragStartBtn
			OpenBtn.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)
		end
	end)

	-- Главное окно
	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 420, 0, 410)
	Main.Position = UDim2.new(0.5, -210, 0.5, -205)
	Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	Main.Active = true
	Main.Draggable = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

	local MainStroke = Instance.new("UIStroke", Main)
	MainStroke.Color = Color3.fromRGB(50, 50, 50)
	MainStroke.Thickness = 1.5

	local TopBar = Instance.new("Frame", Main)
	TopBar.Size = UDim2.new(1, 0, 0, 35)
	TopBar.BackgroundTransparency = 1

	local Title = Instance.new("TextLabel", TopBar)
	Title.Size = UDim2.new(1, -75, 1, 0)
	Title.Position = UDim2.new(0, 12, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "Verity Tower Defense Mango Hub 🥭"
	Title.TextColor3 = Color3.fromRGB(240, 240, 240)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 13
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local MinBtn = Instance.new("TextButton", TopBar)
	MinBtn.Size = UDim2.new(0, 26, 0, 26)
	MinBtn.Position = UDim2.new(1, -62, 0.5, -13)
	MinBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	MinBtn.Text = "-"
	MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	MinBtn.Font = Enum.Font.GothamBold
	MinBtn.TextSize = 16
	Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

	local CloseBtn = Instance.new("TextButton", TopBar)
	CloseBtn.Size = UDim2.new(0, 26, 0, 26)
	CloseBtn.Position = UDim2.new(1, -32, 0.5, -13)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	CloseBtn.Text = "X"
	CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 12
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

	MinBtn.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	OpenBtn.MouseButton1Click:Connect(function()
		if not draggingBtn then
			Main.Visible = true
			OpenBtn.Visible = false
		end
	end)

	-- Вкладки (6 штук)
	local TabContainer = Instance.new("Frame", Main)
	TabContainer.Size = UDim2.new(1, -16, 0, 32)
	TabContainer.Position = UDim2.new(0, 8, 0, 38)
	TabContainer.BackgroundTransparency = 1

	local TabLayout = Instance.new("UIListLayout", TabContainer)
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	TabLayout.Padding = UDim.new(0, 3)

	local function CreateTabHeader(text)
		local Btn = Instance.new("TextButton", TabContainer)
		Btn.Size = UDim2.new(0.16, 0, 1, 0)
		Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		Btn.Text = text
		Btn.TextColor3 = Color3.fromRGB(170, 170, 170)
		Btn.Font = Enum.Font.GothamBold
		Btn.TextSize = 10
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

		local Scroll = Instance.new("ScrollingFrame", Main)
		Scroll.Size = UDim2.new(1, -16, 1, -80)
		Scroll.Position = UDim2.new(0, 8, 0, 78)
		Scroll.BackgroundTransparency = 1
		Scroll.BorderSizePixel = 0
		Scroll.ScrollBarThickness = 3
		Scroll.Visible = false
		Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

		local listLayout = Instance.new("UIListLayout", Scroll)
		listLayout.Padding = UDim.new(0, 6)

		return Btn, Scroll
	end

	local TabMainBtn, MainPage = CreateTabHeader("🏠 Main")
	local TabTeleportBtn, TeleportPage = CreateTabHeader("🌀 Teleport")
	local TabServerBtn, ServerPage = CreateTabHeader("🌐 Server")
	local TabGameBtn, GamePage = CreateTabHeader("🎮 Game")
	local TabShopBtn, ShopPage = CreateTabHeader("🛒 Shop")
	local TabPlaytimeBtn, PlaytimePage = CreateTabHeader("⏱️ Playtime")

	local allTabs = {
		{btn = TabMainBtn, page = MainPage},
		{btn = TabTeleportBtn, page = TeleportPage},
		{btn = TabServerBtn, page = ServerPage},
		{btn = TabGameBtn, page = GamePage},
		{btn = TabShopBtn, page = ShopPage},
		{btn = TabPlaytimeBtn, page = PlaytimePage}
	}

	local function SwitchTab(target)
		for _, t in ipairs(allTabs) do
			t.btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
			t.btn.TextColor3 = Color3.fromRGB(170, 170, 170)
			t.page.Visible = false
		end
		target.btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		target.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		target.page.Visible = true
	end

	TabMainBtn.MouseButton1Click:Connect(function() SwitchTab(allTabs[1]) end)
	TabTeleportBtn.MouseButton1Click:Connect(function() SwitchTab(allTabs[2]) end)
	TabServerBtn.MouseButton1Click:Connect(function() SwitchTab(allTabs[3]) end)
	TabGameBtn.MouseButton1Click:Connect(function() SwitchTab(allTabs[4]) end)
	TabShopBtn.MouseButton1Click:Connect(function() SwitchTab(allTabs[5]) end)
	TabPlaytimeBtn.MouseButton1Click:Connect(function() SwitchTab(allTabs[6]) end)

	SwitchTab(allTabs[1])

	local function AddSectionTitle(parent, text)
		local SectionLabel = Instance.new("TextLabel", parent)
		SectionLabel.Size = UDim2.new(1, 0, 0, 20)
		SectionLabel.BackgroundTransparency = 1
		SectionLabel.Text = text
		SectionLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
		SectionLabel.Font = Enum.Font.GothamBold
		SectionLabel.TextSize = 11
		SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
		return SectionLabel
	end

	local function CreateActionButton(parent, text, callback)
		local Btn = Instance.new("TextButton", parent)
		Btn.Size = UDim2.new(1, 0, 0, 36)
		Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		Btn.Text = text
		Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
		Btn.Font = Enum.Font.GothamBold
		Btn.TextSize = 12
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

		local Stroke = Instance.new("UIStroke", Btn)
		Stroke.Color = Color3.fromRGB(45, 45, 45)
		Stroke.Thickness = 1

		Btn.MouseButton1Click:Connect(callback)
		return Btn
	end

	local function CreateToggleableButton(parent, baseText, callback)
		local Btn = Instance.new("TextButton", parent)
		Btn.Size = UDim2.new(1, 0, 0, 36)
		Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		Btn.Text = baseText .. " [OFF]"
		Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
		Btn.Font = Enum.Font.GothamBold
		Btn.TextSize = 12
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

		local Stroke = Instance.new("UIStroke", Btn)
		Stroke.Color = Color3.fromRGB(45, 45, 45)
		Stroke.Thickness = 1

		local isOn = false

		Btn.MouseButton1Click:Connect(function()
			isOn = not isOn
			callback(isOn)

			if isOn then
				Btn.Text = baseText .. " [ON]"
				Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			else
				Btn.Text = baseText .. " [OFF]"
				Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
			end
		end)

		return Btn
	end

	-- --- 🏠 MAIN ---
	AddSectionTitle(MainPage, "--- GENERAL OPTIONS ---")
	CreateToggleableButton(MainPage, "🔔 Notifications", function(state)
		notifsEnabled = state
	end)
	CreateToggleableButton(MainPage, "🔓 Free Button (Movable)", function(state)
		freeButtonMovable = state
		Notify(state and "Open Button is now movable!" or "Open Button locked!")
	end)

	-- --- ⏱️ PLAYTIME ---
	AddSectionTitle(PlaytimePage, "--- ⏱️ PLAYTIME TRACKER & CLICKS ---")

	local PlaytimeInfoFrame = Instance.new("Frame", PlaytimePage)
	PlaytimeInfoFrame.Size = UDim2.new(1, 0, 0, 90)
	PlaytimeInfoFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	Instance.new("UICorner", PlaytimeInfoFrame).CornerRadius = UDim.new(0, 6)

	local PlaytimeLabel = Instance.new("TextLabel", PlaytimeInfoFrame)
	PlaytimeLabel.Size = UDim2.new(1, -12, 1, 0)
	PlaytimeLabel.Position = UDim2.new(0, 6, 0, 0)
	PlaytimeLabel.BackgroundTransparency = 1
	PlaytimeLabel.Text = "⏱️ Time in Hub: 00:00:00\n🎁 Status: Active & Counting!"
	PlaytimeLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
	PlaytimeLabel.Font = Enum.Font.GothamBold
	PlaytimeLabel.TextSize = 12
	PlaytimeLabel.TextXAlignment = Enum.TextXAlignment.Left

	task.spawn(function()
		while true do
			task.wait(1)
			playtimeSeconds = playtimeSeconds + 1
			local hours = math.floor(playtimeSeconds / 3600)
			local minutes = math.floor((playtimeSeconds % 3600) / 60)
			local seconds = playtimeSeconds % 60
			PlaytimeLabel.Text = string.format("⏱️ Time in Hub: %02d:%02d:%02d\n🎁 Status: Active & Counting!", hours, minutes, seconds)
		end
	end)

	local ClickContainer = Instance.new("Frame", PlaytimePage)
	ClickContainer.Size = UDim2.new(1, 0, 0, 40)
	ClickContainer.BackgroundTransparency = 1

	local ClickLayout = Instance.new("UIListLayout", ClickContainer)
	ClickLayout.FillDirection = Enum.FillDirection.Horizontal
	ClickLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ClickLayout.Padding = UDim.new(0, 10)

	local PlusBtn = Instance.new("TextButton", ClickContainer)
	PlusBtn.Size = UDim2.new(0.48, 0, 1, 0)
	PlusBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	PlusBtn.Text = "➕ PLUS (+)"
	PlusBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
	PlusBtn.Font = Enum.Font.GothamBold
	PlusBtn.TextSize = 13
	Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 6)

	local MinusBtn = Instance.new("TextButton", ClickContainer)
	MinusBtn.Size = UDim2.new(0.48, 0, 1, 0)
	MinusBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	MinusBtn.Text = "➖ MINUS (-)"
	MinusBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
	MinusBtn.Font = Enum.Font.GothamBold
	MinusBtn.TextSize = 13
	Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 6)

	local StatsFrame = Instance.new("Frame", PlaytimePage)
	StatsFrame.Size = UDim2.new(1, 0, 0, 75)
	StatsFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 6)

	local StatsLabel = Instance.new("TextLabel", StatsFrame)
	StatsLabel.Size = UDim2.new(1, -12, 1, 0)
	StatsLabel.Position = UDim2.new(0, 6, 0, 0)
	StatsLabel.BackgroundTransparency = 1
	StatsLabel.Text = "📊 Stats:\n➕ Plus Clicks: 0\n➖ Minus Clicks: 0\n🎯 Total Count Value: 0"
	StatsLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
	StatsLabel.Font = Enum.Font.GothamBold
	StatsLabel.TextSize = 12
	StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

	local function UpdateStatsText()
		StatsLabel.Text = string.format("📊 Stats:\n➕ Plus Clicks: %d\n➖ Minus Clicks: %d\n🎯 Total Count Value: %d", plusClicks, minusClicks, currentCount)
	end

	PlusBtn.MouseButton1Click:Connect(function()
		plusClicks = plusClicks + 1
		currentCount = currentCount + 1
		UpdateStatsText()
	end)

	MinusBtn.MouseButton1Click:Connect(function()
		minusClicks = minusClicks + 1
		currentCount = currentCount - 1
		UpdateStatsText()
	end)

	-- --- 🛒 SHOP ---
	AddSectionTitle(ShopPage, "--- 📦 Custom Crate & Shop ---")
	local CrateInfoFrame = Instance.new("ScrollingFrame", ShopPage)
	CrateInfoFrame.Size = UDim2.new(1, 0, 0, 300)
	CrateInfoFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	CrateInfoFrame.ScrollBarThickness = 3
	CrateInfoFrame.CanvasSize = UDim2.new(0, 0, 0, 380)
	CrateInfoFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Instance.new("UICorner", CrateInfoFrame).CornerRadius = UDim.new(0, 6)

	local CrateLabel = Instance.new("TextLabel", CrateInfoFrame)
	CrateLabel.Size = UDim2.new(1, -12, 0, 360)
	CrateLabel.Position = UDim2.new(0, 6, 0, 5)
	CrateLabel.BackgroundTransparency = 1
	CrateLabel.Text = [[🎁 Custom Crate Drop Info:

🤡 Clownity (70%):
  • Damage: 3 -> 15
  • Range: 6 -> 9
  • Cooldown: 0.5 -> 0.5
  • DPS: 6 -> 30

🟡 Stupidity (20%):
  • Damage: 20 -> 115
  • Range: 7 -> 14
  • Cooldown: 1 -> 1
  • DPS: 20 -> 115

💧 Hydro Verity (1%):
  • Damage: 55 -> 375
  • Range: 12 -> 25
  • Cooldown: 1.5 -> 1
  • DPS: 41 -> 375

💎 Crate Prices:
  • 1 Custom Crate -> 100 Gems
  • 3 Custom Crate -> 300 Gems
  • 10 Custom Crate -> 1000 Gems

━━━━━━━━━━━━━━━━━━━━━
👑 Exclusive Shop Units:
👑 Lord Verity -> 1,000 Gems]]
	CrateLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
	CrateLabel.Font = Enum.Font.GothamBold
	CrateLabel.TextSize = 11
	CrateLabel.TextXAlignment = Enum.TextXAlignment.Left
	CrateLabel.TextYAlignment = Enum.TextYAlignment.Top

	-- --- 🌀 TELEPORT ---
	AddSectionTitle(TeleportPage, "--- GAME MODES (SOLO) ---")
	CreateActionButton(TeleportPage, "🎮 Teleport To Play (Solo)", function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = CFrame.new(-128.1, 49.8, -179.3) Notify("Teleported!") end
	end)
	CreateActionButton(TeleportPage, "♾️ Teleport To Endless (Solo)", function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = CFrame.new(-110.6, 55.8, -225.9) Notify("Teleported!") end
	end)
	CreateActionButton(TeleportPage, "⚔️ Teleport To Raid (Solo)", function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = CFrame.new(-49.5, 31.6, 102.5) Notify("Teleported!") end
	end)

	AddSectionTitle(TeleportPage, "--- LOBBY BUILDINGS ---")
	CreateActionButton(TeleportPage, "🏠 Teleport To Spawn", function()
		local spawnLoc = Workspace:FindFirstChild("SpawnLocation", true)
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp and spawnLoc then hrp.CFrame = spawnLoc.CFrame * CFrame.new(0, 3, 0) Notify("Teleported to Spawn!") end
	end)
	CreateActionButton(TeleportPage, "🔮 Teleport To Summon", function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(-183.5, 45.6, -55.5)
			Notify("Teleported to Summon!")
		end
	end)
	CreateActionButton(TeleportPage, "🛒 Teleport To Raid Shop", function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(-103.6, 25.6, 67.8)
			Notify("Teleported to Raid Shop!")
		end
	end)

	-- --- 🌐 SERVER ---
	AddSectionTitle(ServerPage, "--- 👥 ACTIVE PLAYERS LIST ---")
	local PlayerListScroll = Instance.new("ScrollingFrame", ServerPage)
	PlayerListScroll.Size = UDim2.new(1, 0, 0, 110)
	PlayerListScroll.Ba
