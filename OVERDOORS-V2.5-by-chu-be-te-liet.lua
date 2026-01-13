--[[
OVERDOORS FULL ONE FILE (NO CONFLICT)
Guiding Light: ONLY ROOM 45 (ONE TIME)
Includes: Entity list (incl. 200 + Greed + Wh1t3), safe entity loader, Hungerd, A-60
Plus: Center notify "OVERDOORS by chu be te liet" and bottom notify
Merged & fixed by assistant
]]

if getgenv().OVERDOORS_LOADED then return end
getgenv().OVERDOORS_LOADED = true

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

local P = Players.LocalPlayer

--------------------------------------------------
-- SAFE HELPERS
--------------------------------------------------
local function safe(fn) pcall(fn) end
local function clamp(v,a,b) if v<a then return a end if v>b then return b end return v end

--------------------------------------------------
-- SHOW NOTIFIES (CENTER + BOTTOM) - no conflict
--------------------------------------------------
if not getgenv().OVERDOORS_NOTIFIES_LOADED then
	getgenv().OVERDOORS_NOTIFIES_LOADED = true

	local function showCenterText(text, displayTime)
		if not P or not P:FindFirstChild("PlayerGui") then return end
		safe(function()
			local old = P.PlayerGui:FindFirstChild("OVERDOORS_CENTER_TEXT")
			if old then old:Destroy() end
		end)

		local gui = Instance.new("ScreenGui")
		gui.Name = "OVERDOORS_CENTER_TEXT"
		gui.ResetOnSpawn = false
		gui.Parent = P.PlayerGui

		local label = Instance.new("TextLabel", gui)
		label.Size = UDim2.fromScale(1, 0.12)
		label.Position = UDim2.fromScale(0, 0.45)
		label.BackgroundTransparency = 1
		label.Text = text or "OVERDOORS"
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.TextColor3 = Color3.fromRGB(235,235,235)
		label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
		label.TextStrokeTransparency = 0.45
		label.TextTransparency = 1

		pcall(function()
			TweenService:Create(label, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
		end)

		displayTime = displayTime or 2.5
		task.delay(displayTime, function()
			pcall(function()
				TweenService:Create(label, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
			end)
		end)
		Debris:AddItem(gui, displayTime + 0.8)
	end

	local function showBottomNotify(text, displayTime)
		if not P or not P:FindFirstChild("PlayerGui") then return end
		safe(function()
			local old = P.PlayerGui:FindFirstChild("OVERDOORS_BOTTOM_NOTIFY")
			if old then old:Destroy() end
		end)
		local gui = Instance.new("ScreenGui", P.PlayerGui)
		gui.Name = "OVERDOORS_BOTTOM_NOTIFY"
		gui.ResetOnSpawn = false

		local msg = Instance.new("TextLabel", gui)
		msg.Size = UDim2.fromScale(1, 0.07)
		msg.Position = UDim2.fromScale(0, 0.92)
		msg.BackgroundTransparency = 1
		msg.TextScaled = true
		msg.Font = Enum.Font.GothamBold
		msg.TextColor3 = Color3.fromRGB(170,255,200)
		msg.TextTransparency = 1
		msg.Text = text or ""

		pcall(function() TweenService:Create(msg, TweenInfo.new(0.4), {TextTransparency = 0}):Play() end)
		displayTime = displayTime or 3
		task.delay(displayTime, function()
			pcall(function() TweenService:Create(msg, TweenInfo.new(0.4), {TextTransparency = 1}):Play() end)
		end)
		Debris:AddItem(gui, displayTime + 0.6)
	end

	getgenv().OVERDOORS_showCenterText = showCenterText
	getgenv().OVERDOORS_showBottomNotify = showBottomNotify
end

--------------------------------------------------
-- INTRO (keeps original feel)
--------------------------------------------------
task.spawn(function()
	task.wait(0.5)
	if not P or not P:FindFirstChild("PlayerGui") then return end
	local g = Instance.new("ScreenGui",P.PlayerGui); g.ResetOnSpawn=false
	local t = Instance.new("TextLabel", g)
	t.Size = UDim2.fromScale(1,1); t.BackgroundTransparency = 1
	t.Text="THE OVERDOORS"; t.Font=Enum.Font.GothamBlack; t.TextScaled=true
	t.TextColor3=Color3.fromRGB(255,0,0); t.TextTransparency=1
	for i=1,12 do t.TextTransparency = clamp(t.TextTransparency - 0.08,0,1); task.wait(0.04) end
	task.wait(1)
	for i=1,12 do t.TextTransparency = clamp(t.TextTransparency + 0.08,0,1); task.wait(0.04) end
	g:Destroy()
end)

--------------------------------------------------
-- PLAYER STATS
--------------------------------------------------
task.spawn(function()
	while task.wait(1) do
		safe(function()
			if not P then return end
			local c = P.Character
			local h = c and c:FindFirstChildOfClass("Humanoid")
			if h then
				h.WalkSpeed = 20
				h.JumpPower = 38
			end
		end)
	end
end)

--------------------------------------------------
-- LOAD HARDCORE V4 (guarded)
--------------------------------------------------
safe(function()
	local ok, body = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/localplayerr/Doors-stuff/refs/heads/main/Hardcore%20v4%20recreate/main%20code")
	end)
	if ok and body and #body>10 then
		pcall(loadstring(body))
	end
end)

--------------------------------------------------
-- SAFE REMOTE ENTITY LOADER
--------------------------------------------------
local function sanitize(code)
	if type(code) ~= "string" then return code end
	-- clamp explicit Volume = N and huge numbers
	code = code:gsub("Volume%s*=%s*%d+", "Volume = 1.2")
	code = code:gsub("(%d%d%d%d%d+)", "1")
	return code
end

local function safeLoad(url)
	local ok, body = pcall(function()
		return game:HttpGet(url, true)
	end)
	if ok and body and #body > 5 then
		local safeBody = sanitize(body)
		safe(function()
			local fn,err = loadstring(safeBody)
			if fn then
				pcall(fn)
			else
				warn("[OVERDOORS] loadstring error:", err)
			end
		end)
	end
end

-- spawnLoop with URL dedupe protection (prevents adding same URL twice)
local _addedEntityURLs = _addedEntityURLs or {}
local function spawnLoop(delayTime, url, waitRoom)
	if not url or url == "" then return end
	if _addedEntityURLs[url] then return end
	_addedEntityURLs[url] = true

	task.spawn(function()
		while true do
			task.wait(delayTime or 60)
			if waitRoom and RS and RS:FindFirstChild("GameData") and RS.GameData:FindFirstChild("LatestRoom") then
				RS.GameData.LatestRoom.Changed:Wait()
			end
			-- safe-load
			safe(function()
				safeLoad(url)
			end)
		end
	end)
end

--------------------------------------------------
-- ENTITIES (INCLUDING ENTITY 200 + Greed + Wh1t3)
-- (all use waitRoom = true for pacing)
--------------------------------------------------
local entities = {
	{90 ,"https://raw.githubusercontent.com/Junbbinopro/Depth-entity/refs/heads/main/Depth"},
	{150,"https://raw.githubusercontent.com/Junbbinopro/Guardian-entity/refs/heads/main/Guardian"},
	{190,"https://raw.githubusercontent.com/Junbbinopro/Wh1t3/refs/heads/main/Entity"}, -- Wh1t3
	{215,"https://raw.githubusercontent.com/trungdepth-dot/Entity-greance/refs/heads/main/Greance-20"},
	{250,"https://raw.githubusercontent.com/trungdepth-dot/Entity-surge/refs/heads/main/Surge-20"},
	{320,"https://raw.githubusercontent.com/Junbbinopro/Black-smile/refs/heads/main/Black"},
	{420,"https://raw.githubusercontent.com/Junbbinopro/Screamer/refs/heads/main/Entity"},
	{550,"https://raw.githubusercontent.com/Junbbinopro/Greed-entity/refs/heads/main/Greed"}, -- Greed (already requested earlier)
}

for _,v in ipairs(entities) do
	-- v = {delay, url}
	spawnLoop(v[1], v[2], true)
end

-- Hungerd (Entity6) safe spawn
spawnLoop(780, "https://raw.githubusercontent.com/Zeca130/doors-my-version-nightmareMode./refs/heads/main/Entity6", true)

-- A-60 safe spawn (redundant remotes)
local A60_URLS = {
	"https://raw.githubusercontent.com/trungdepth-dot/A-60/refs/heads/main/A-60",
	"https://raw.githubusercontent.com/Idk-lol2/a-60aa/refs/heads/main/---======%20a-60%20agresiv%20spawner%20======---.txt"
}
for _,u in ipairs(A60_URLS) do
	spawnLoop(780, u, true)
end

--------------------------------------------------
-- GUIDING LIGHT (ONLY ROOM 45 - ONE TIME)
--------------------------------------------------
task.spawn(function()
	-- wait gamedata
	while not (RS:FindFirstChild("GameData") and RS.GameData:FindFirstChild("LatestRoom")) do
		task.wait(0.5)
	end

	local LatestRoom = RS.GameData.LatestRoom
	local TRIGGER_ROOM = 45
	local triggered = false

	local function showGuiding()
		if not P or not P:FindFirstChild("PlayerGui") then return end
		safe(function()
			local old = P.PlayerGui:FindFirstChild("GUIDING_ROOM_45")
			if old then old:Destroy() end
		end)

		local g = Instance.new("ScreenGui", P.PlayerGui)
		g.Name = "GUIDING_ROOM_45"
		g.ResetOnSpawn = false

		local t = Instance.new("TextLabel", g)
		t.Size = UDim2.fromScale(1, 0.16)
		t.Position = UDim2.fromScale(0, 0.42)
		t.BackgroundTransparency = 1
		t.TextScaled = true
		t.Font = Enum.Font.GothamBold
		t.TextColor3 = Color3.fromRGB(0,210,255)
		t.TextStrokeTransparency = 0.6
		t.Text = "Do you really trust me?"

		Debris:AddItem(g, 2)
	end

	LatestRoom.Changed:Connect(function()
		if triggered then return end
		if LatestRoom.Value == TRIGGER_ROOM then
			triggered = true
			showGuiding()
			print("[OVERDOORS] Guiding Light triggered at room 45")
		end
	end)
end)

--------------------------------------------------
-- SHOW NOTIFIES NOW (center + bottom)
--------------------------------------------------
-- center: OVERDOORS by chu be te liet
if getgenv().OVERDOORS_showCenterText then
	pcall(function() getgenv().OVERDOORS_showCenterText("OVERDOORS by chu be te liet", 2.7) end)
else
	-- fallback if global not set
	pcall(function()
		if P and P:FindFirstChild("PlayerGui") then
			local gui = Instance.new("ScreenGui", P.PlayerGui)
			gui.Name = "OVERDOORS_CENTER_TEXT"
			gui.ResetOnSpawn = false
			local label = Instance.new("TextLabel", gui)
			label.Size = UDim2.fromScale(1, 0.12)
			label.Position = UDim2.fromScale(0, 0.45)
			label.BackgroundTransparency = 1
			label.Text = "OVERDOORS by chu be te liet"
			label.TextScaled = true
			label.Font = Enum.Font.GothamBold
			label.TextColor3 = Color3.fromRGB(235,235,235)
			label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
			label.TextStrokeTransparency = 0.45
			label.TextTransparency = 0
			Debris:AddItem(gui, 2.8)
		end
	end)
end

-- bottom notify: "script OVERDOORS by chu be te liet"
if getgenv().OVERDOORS_showBottomNotify then
	pcall(function() getgenv().OVERDOORS_showBottomNotify("script OVERDOORS by chu be te liet", 3) end)
else
	-- fallback bottom notify quick inline
	pcall(function()
		if P and P:FindFirstChild("PlayerGui") then
			local gui = Instance.new("ScreenGui", P.PlayerGui)
			gui.Name = "OVERDOORS_BOTTOM_NOTIFY"
			gui.ResetOnSpawn = false
			local msg = Instance.new("TextLabel", gui)
			msg.Size = UDim2.fromScale(1, 0.07)
			msg.Position = UDim2.fromScale(0, 0.92)
			msg.BackgroundTransparency = 1
			msg.TextScaled = true
			msg.Font = Enum.Font.GothamBold
			msg.TextColor3 = Color3.fromRGB(170,255,200)
			msg.TextTransparency = 0
			msg.Text = "script OVERDOORS by chu be te liet"
			Debris:AddItem(gui, 3)
		end
	end)
end

--------------------------------------------------
-- READY
--------------------------------------------------
print("✅ OVERDOORS FULL ONE FILE LOADED (GUIDING ROOM 45 ONLY) - Greed + Wh1t3 added")
