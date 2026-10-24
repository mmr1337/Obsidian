local ui = {}
local ps = game:GetService("Players")
local function new(className, props)
	local obj = Instance.new(className)
	for key, value in pairs(props) do
		if key ~= "Parent" then
			obj[key] = value
		end
	end
	if props.Parent then
		obj.Parent = props.Parent
	end
	return obj
end

local function round(obj, radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius), Parent = obj })
end

local function outline(obj, color, transparency)
	return new("UIStroke", {
		Color = color,
		Transparency = transparency,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = obj,
	})
end

local function drawIcon(parent, kind, size)
	local holder = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	local fills, strokes = {}, {}
	local full = UDim.new(1, 0)
	local s = size
	local thin = math.max(2, math.floor(s * 0.16 + 0.5))

	local function fill(dx, dy, w, h, radius, rotation)
		local part = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, dx, 0.5, dy),
			Size = UDim2.fromOffset(w, h),
			BorderSizePixel = 0,
			Rotation = rotation or 0,
			Parent = holder,
		})
		if radius then
			new("UICorner", { CornerRadius = radius, Parent = part })
		end
		table.insert(fills, part)
	end

	local function ring(w)
		local part = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(w, w),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		new("UICorner", { CornerRadius = full, Parent = part })
		table.insert(strokes, new("UIStroke", { Thickness = math.max(1, thin - 1), Parent = part }))
	end

	if kind == "eye" then
		ring(s * 0.85)
		fill(0, 0, s * 0.34, s * 0.34, full)
	elseif kind == "ring" then
		ring(s * 0.8)
	elseif kind == "diamond" then
		fill(0, 0, s * 0.62, s * 0.62, UDim.new(0, 2), 45)
	elseif kind == "dots" then
		for _, d in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do
			fill(d[1] * s * 0.22, d[2] * s * 0.22, s * 0.32, s * 0.32, full)
		end
	elseif kind == "bars" then
		for i = -1, 1 do
			fill(0, i * s * 0.3, s * 0.85, thin, full)
		end
	elseif kind == "plus" then
		fill(0, 0, s * 0.85, thin, full)
		fill(0, 0, thin, s * 0.85, full)
	elseif kind == "x" then
		fill(0, 0, s * 0.85, thin, full, 45)
		fill(0, 0, s * 0.85, thin, full, -45)
	elseif kind == "kebab" then
		for i = -1, 1 do
			fill(0, i * s * 0.32, thin + 1, thin + 1, full)
		end
	elseif kind == "search" then
		local lens = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, -s * 0.1, 0.5, -s * 0.1),
			Size = UDim2.fromOffset(s * 0.58, s * 0.58),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		new("UICorner", { CornerRadius = full, Parent = lens })
		table.insert(strokes, new("UIStroke", { Thickness = math.max(1, thin - 1), Parent = lens }))
		fill(s * 0.25, s * 0.25, s * 0.34, thin, full, 45)
	elseif kind == "chevron" then
		fill(-s * 0.16, 0, s * 0.5, thin, full, 45)
		fill(s * 0.16, 0, s * 0.5, thin, full, -45)
	elseif kind == "square" then
		local square = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(s * 0.62, s * 0.8),
			BackgroundTransparency = 1,
			Parent = holder,
		})
		table.insert(strokes, new("UIStroke", { Thickness = math.max(1, thin - 1), Parent = square }))
	elseif kind == "tracer" then
		fill(0, s * 0.05, s * 0.75, thin, full, -60)
		fill(s * 0.2, -s * 0.3, thin + 2, thin + 2, full)
	elseif kind == "palette" then
		fill(0, -s * 0.22, s * 0.36, s * 0.36, full)
		fill(-s * 0.22, s * 0.16, s * 0.36, s * 0.36, full)
		fill(s * 0.22, s * 0.16, s * 0.36, s * 0.36, full)
	else
		fill(0, 0, s * 0.5, s * 0.5, full)
	end

	return function(color)
		for _, part in ipairs(fills) do
			part.BackgroundColor3 = color
		end
		for _, stroke in ipairs(strokes) do
			stroke.Color = color
		end
	end
end

local LOGO_BG = Color3.fromRGB(8, 6, 12)
local CRYSTAL_RIM = Color3.fromRGB(226, 216, 255)
local CRYSTAL_TOP = Color3.fromRGB(176, 156, 248)
local CRYSTAL_BOTTOM = Color3.fromRGB(112, 90, 204)

local function drawLogoMark(square, size)
	local markSize = math.floor(size * 0.52 + 0.5)
	local rim = math.max(1, math.floor(size * 0.025 + 0.5))

	local gap = rim * 2 + math.max(1, math.floor(size * 0.025 + 0.5))
	local tile = (markSize - gap) / 2

	local mark = new("Frame", {
		Name = "LogoMark",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(markSize, markSize),
		Rotation = 45,
		BackgroundTransparency = 1,
		Parent = square,
	})
	mark:SetAttribute("KeepColor", true)

	for row = 0, 1 do
		for column = 0, 1 do

			local corner = math.max(1, math.floor(size * 0.03))
			local piece = new("Frame", {
				Position = UDim2.fromOffset(column * (tile + gap), row * (tile + gap)),
				Size = UDim2.fromOffset(tile, tile),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.25,
				BorderSizePixel = 0,
				Parent = mark,
			})
			round(piece, corner)
			piece:SetAttribute("KeepColor", true)

			new("UIGradient", {
				Rotation = 45,
				Color = ColorSequence.new(CRYSTAL_TOP, CRYSTAL_BOTTOM),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.1),
					NumberSequenceKeypoint.new(0.5, 0.45),
					NumberSequenceKeypoint.new(1, 0.6),
				}),
				Parent = piece,
			})

			local stroke = new("UIStroke", {
				Color = CRYSTAL_RIM,
				Thickness = rim,
				Transparency = 0.1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Parent = piece,
			})
			stroke:SetAttribute("KeepColor", true)

			local gloss = new("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.45,
				BorderSizePixel = 0,
				Parent = piece,
			})
			round(gloss, corner)
			gloss:SetAttribute("KeepColor", true)
			new("UIGradient", {
				Rotation = 45,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(0.42, 0.75),
					NumberSequenceKeypoint.new(0.45, 1),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Parent = gloss,
			})
		end
	end

	if size >= 48 then
		for _, gem in ipairs({
			{ 0.17, 0.22, 0.05 }, { 0.24, 0.16, 0.06 }, { 0.2, 0.3, 0.04 }, { 0.28, 0.27, 0.035 },
			{ 0.8, 0.7, 0.05 }, { 0.85, 0.79, 0.06 }, { 0.75, 0.83, 0.035 },
			}) do
			local d = math.max(2, math.floor(gem[3] * size))
			local dot = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(gem[1], gem[2]),
				Size = UDim2.fromOffset(d, d),
				BackgroundColor3 = CRYSTAL_TOP,
				BackgroundTransparency = 0.45,
				BorderSizePixel = 0,
				Parent = square,
			})
			round(dot, d)
			local dotStroke = new("UIStroke", { Color = CRYSTAL_RIM, Thickness = 1, Transparency = 0.05, Parent = dot })
			dot:SetAttribute("KeepColor", true)
			dotStroke:SetAttribute("KeepColor", true)
		end
	end

	return mark
end
ui.new = new
ui.round = round
ui.outline = outline
ui.drawIcon = drawIcon
ui.drawLogoMark = drawLogoMark
ui.logoBg = LOGO_BG
function ui.window(C, MENU_STYLE, CONFIG, pg, lp)
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local screenGui = new("ScreenGui", {
	Name = "ESP_Menu",
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	ResetOnSpawn = false,
	DisplayOrder = 100,

	Enabled = false,
	Parent = pg,
})

local frame = new("Frame", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(600, 400),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Parent = screenGui,
})
round(frame, 12)
outline(frame, C.line, 0.35)

local windowBackground = new("Frame", {
	Name = "Background",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	ZIndex = 0,
	Parent = frame,
})
round(windowBackground, 12)

new("Frame", {
	Position = UDim2.fromOffset(14, 0),
	Size = UDim2.new(1, -28, 0, 1),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.82,
	BorderSizePixel = 0,
	ZIndex = 0,
	Parent = frame,
})
local sheen = new("Frame", {
	Size = UDim2.new(1, 0, 0.45, 0),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.94,
	BorderSizePixel = 0,
	ZIndex = 0,
	Parent = frame,
})
round(sheen, 12)
new("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new(0, 1),
	Parent = sheen,
})
new("UIGradient", {
	Color = ColorSequence.new(C.bgTop, C.bgBottom),
	Rotation = 55,
	Parent = windowBackground,
})

local topBar = new("Frame", {
	Size = UDim2.new(1, 0, 0, 48),
	BackgroundTransparency = 1,
	Parent = frame,
})

new("Frame", {
	Position = UDim2.new(0, 0, 1, -1),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = C.line,
	BackgroundTransparency = 0.6,
	BorderSizePixel = 0,
	Parent = topBar,
})

local logo = new("Frame", {
	Position = UDim2.fromOffset(14, 11),
	Size = UDim2.fromOffset(26, 26),
	BackgroundColor3 = LOGO_BG,
	BorderSizePixel = 0,
	Parent = topBar,
})
round(logo, 6)
outline(logo, C.line, 0.5)
drawLogoMark(logo, 26)

do
	local brand = new("Frame", {
		Position = UDim2.fromOffset(48, 0),
		Size = UDim2.fromOffset(144, 48),
		BackgroundTransparency = 1,
		Parent = topBar,
	})
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = brand,
	})
	new("TextLabel", {
		LayoutOrder = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		TextSize = 16,
		TextColor3 = C.text,
		Text = "OPUS",
		Parent = brand,
	})
	new("TextLabel", {
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = C.sub,
		Text = "client",
		Parent = brand,
	})

	local CLIENT_VERSION = "v1.5"
	new("TextLabel", {
		LayoutOrder = 3,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = C.accent,
		Text = CLIENT_VERSION,
		Parent = brand,
	})
end

local searchBox = new("Frame", {
	Position = UDim2.fromOffset(198, 9),
	Size = UDim2.new(1, -198 - 176, 0, 30),
	BackgroundColor3 = C.panel,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	Parent = topBar,
})
round(searchBox, 8)
outline(searchBox, C.line, 0.6)

local searchIcon = new("Frame", {
	Position = UDim2.fromOffset(8, 7),
	Size = UDim2.fromOffset(16, 16),
	BackgroundTransparency = 1,
	Parent = searchBox,
})
drawIcon(searchIcon, "search", 14)(C.sub)

local search = new("TextBox", {
	Position = UDim2.fromOffset(28, 0),
	Size = UDim2.new(1, -36, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.text,
	PlaceholderText = "Поиск...",
	PlaceholderColor3 = C.sub,
	ClearTextOnFocus = false,
	Text = "",
	Parent = searchBox,
})

new("TextLabel", {
	Position = UDim2.new(1, -170, 0, 8),
	Size = UDim2.fromOffset(120, 18),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Right,
	TextColor3 = C.text,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Text = lp.DisplayName,
	Parent = topBar,
})

new("TextLabel", {
	Position = UDim2.new(1, -170, 0, 25),
	Size = UDim2.fromOffset(120, 14),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Right,
	TextColor3 = C.sub,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Text = "@" .. lp.Name,
	Parent = topBar,
})

local avatar = new("ImageLabel", {
	Position = UDim2.new(1, -44, 0, 8),
	Size = UDim2.fromOffset(32, 32),
	BackgroundColor3 = C.card,
	BorderSizePixel = 0,
	Parent = topBar,
})
round(avatar, 16)
outline(avatar, C.accent, 0.3)

task.spawn(function()
	local ok, image = pcall(function()
		return ps:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	end)
	if ok then
		avatar.Image = image
	end
end)

local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

uis.InputChanged:Connect(function(input)
	if dragging
		and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

local sidebar = new("Frame", {
	Position = UDim2.fromOffset(0, 48),
	Size = UDim2.new(0, 150, 1, -48),
	BackgroundColor3 = C.panel,
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
	Parent = frame,
})
round(sidebar, 12)

new("Frame", {
	Position = UDim2.new(1, -1, 0, 0),
	Size = UDim2.new(0, 1, 1, 0),
	BackgroundColor3 = C.line,
	BackgroundTransparency = 0.6,
	BorderSizePixel = 0,
	Parent = sidebar,
})

local sidebarList = new("Frame", {
	Size = UDim2.new(1, 0, 1, -30),
	BackgroundTransparency = 1,
	Parent = sidebar,
})
new("UIPadding", {
	PaddingTop = UDim.new(0, 10),
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 9),
	Parent = sidebarList,
})
new("UIListLayout", {
	Padding = UDim.new(0, 2),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = sidebarList,
})

local menuHint = new("TextLabel", {
	Position = UDim2.new(0, 8, 1, -50),
	Size = UDim2.new(1, -16, 0, 44),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextWrapped = true,
	TextColor3 = C.sub,
	Text = "RightControl — меню\nПКМ по карточке — клавиша\ntgk: opus_client_rbx",
	Parent = sidebar,
})

local groups = {}
do
	local groupOrder = 0

	local function createGroup(name, iconKind)
		groupOrder += 1

		local header = new("TextButton", {
			LayoutOrder = groupOrder * 2 - 1,
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = C.accentDim,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			Parent = sidebarList,
		})
		round(header, 7)

		local iconHolder = new("Frame", {
			Position = UDim2.new(0, 8, 0.5, -9),
			Size = UDim2.fromOffset(18, 18),
			BackgroundTransparency = 1,
			Parent = header,
		})
		local setIcon = drawIcon(iconHolder, iconKind, 14)

		local label = new("TextLabel", {
			Position = UDim2.fromOffset(32, 0),
			Size = UDim2.new(1, -52, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.sub,
			Text = name,
			Parent = header,
		})

		local arrow = new("Frame", {
			Position = UDim2.new(1, -22, 0.5, -7),
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			Parent = header,
		})
		drawIcon(arrow, "chevron", 10)(C.sub)

		local list = new("Frame", {
			LayoutOrder = groupOrder * 2,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = sidebarList,
		})
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
		new("UIPadding", { PaddingBottom = UDim.new(0, 8), Parent = list })

		header.MouseButton1Click:Connect(function()
			list.Visible = not list.Visible
			arrow.Rotation = list.Visible and 0 or -90
		end)
		header.MouseEnter:Connect(function()
			label.TextColor3 = C.text
		end)
		header.MouseLeave:Connect(function()
			label.TextColor3 = groups[name].active and C.text or C.sub
		end)

		groups[name] = { header = header, label = label, setIcon = setIcon, list = list, sections = {}, active = false }
		return groups[name]
	end

	createGroup("Modules", "diamond")
	createGroup("Settings", "plus")
end

local content = new("Frame", {
	Position = UDim2.fromOffset(162, 48),
	Size = UDim2.new(1, -174, 1, -58),
	BackgroundTransparency = 1,
	Parent = frame,
})

local backButton = new("TextButton", {
	Position = UDim2.fromOffset(0, 6),
	Size = UDim2.fromOffset(22, 22),
	BackgroundColor3 = C.card,
	BackgroundTransparency = 0.2,
	AutoButtonColor = true,
	Text = "",
	Visible = false,
	Parent = content,
})
round(backButton, 6)
local backIcon = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(12, 12),
	Rotation = 90,
	BackgroundTransparency = 1,
	Parent = backButton,
})
drawIcon(backIcon, "chevron", 10)(C.text)

local breadcrumb = new("TextLabel", {
	Position = UDim2.fromOffset(2, 6),
	Size = UDim2.new(1, -2, 0, 22),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.sub,
	RichText = true,
	Text = "",
	Parent = content,
})

local counterLabel = new("TextLabel", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -6, 0, 6),
	Size = UDim2.fromOffset(170, 22),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Right,
	TextColor3 = C.sub,
	RichText = true,
	Text = "",
	Parent = content,
})

local function makeScroller(name)
	local scroller = new("ScrollingFrame", {
		Name = name,
		Position = UDim2.fromOffset(0, 36),
		Size = UDim2.new(1, 0, 1, -36),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		Parent = content,
	})
	new("UIPadding", {
		PaddingTop = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 1),
		PaddingRight = UDim.new(0, 7),
		PaddingBottom = UDim.new(0, 2),
		Parent = scroller,
	})
	return scroller
end

local sections = {}
local uiRefreshers = {}
local sectionOrder = 0
local currentSection = nil
local currentModule = nil

local function updateCounter()
	local section = sections[currentSection]
	if currentModule or not section or #section.modules == 0 then
		counterLabel.Text = ""
		return
	end
	local on = 0
	for _, def in ipairs(section.modules) do
		if def.source[def.key] then
			on += 1
		end
	end
	counterLabel.Text = string.format('<font color="#FFFAFB"><b>%d</b></font> из %d включено', on, #section.modules)
end

local function crumbs(...)
	local section = sections[currentSection]
	local parts = { section and section.group or "Modules" }
	for _, part in ipairs({ ... }) do
		table.insert(parts, part)
	end
	local last = table.remove(parts)
	local text = table.concat(parts, "  /  ")
	return text .. '  /  <font color="#FFFAFB"><b>' .. last .. "</b></font>"
end

local function slideIn(page)
	page.Position = UDim2.fromOffset(0, 48)
	ts:Create(page, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(0, 36),
	}):Play()
end

local searchGrid = nil
local searchQuery = ""
local searchFound = 0

local function showGrid()
	if currentModule then
		currentModule.page.Visible = false
		currentModule = nil
	end
	local searching = searchGrid ~= nil and searchQuery ~= ""
	for name, section in pairs(sections) do
		local visible = not searching and name == currentSection
		if visible and not section.grid.Visible then
			slideIn(section.grid)
		end
		section.grid.Visible = visible
	end
	if searchGrid then
		searchGrid.Visible = searching
	end
	backButton.Visible = false
	breadcrumb.Position = UDim2.fromOffset(2, 6)
	if searching then
		local safeQuery = searchQuery:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
		breadcrumb.Text = 'Поиск  /  <font color="#FFFAFB"><b>' .. safeQuery .. "</b></font>"
		counterLabel.Text = searchFound > 0 and string.format("найдено: %d", searchFound) or "ничего не найдено"
	else
		breadcrumb.Text = crumbs(currentSection)
		updateCounter()
	end
end

local function selectSection(name)
	if search.Text ~= "" then
		search.Text = ""
	end
	currentSection = name
	for sectionName, section in pairs(sections) do
		local active = sectionName == name
		section.nav.setIcon(active and C.accent or C.sub)
		section.nav.label.TextColor3 = active and C.text or C.sub
		section.nav.label.Font = active and Enum.Font.GothamBold or Enum.Font.Gotham
		section.nav.pill.Visible = active
	end
	for _, group in pairs(groups) do
		group.active = group.sections[name] == true
		group.header.BackgroundTransparency = group.active and 0.35 or 1
		group.label.TextColor3 = group.active and C.text or C.sub
		group.setIcon(group.active and C.accent or C.sub)
	end
	showGrid()
end

local function openSettings(module)
	for _, section in pairs(sections) do
		section.grid.Visible = false
	end
	if searchGrid then
		searchGrid.Visible = false
	end
	if currentModule then
		currentModule.page.Visible = false
	end
	currentModule = module
	module.page.Visible = true
	slideIn(module.page)
	backButton.Visible = true
	breadcrumb.Position = UDim2.fromOffset(30, 6)
	breadcrumb.Text = crumbs(currentSection, module.name)
	updateCounter()
end

backButton.MouseButton1Click:Connect(showGrid)

searchGrid = makeScroller("SearchResults")
new("UIGridLayout", {
	CellSize = UDim2.new(0.5, -5, 0, 66),
	CellPadding = UDim2.fromOffset(10, 10),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = searchGrid,
})

local function restoreSearchCards()
	for _, section in pairs(sections) do
		for _, entry in ipairs(section.cards) do
			if entry.frame.Parent == searchGrid then
				entry.frame.Parent = section.grid
				entry.frame.LayoutOrder = entry.homeOrder or entry.frame.LayoutOrder
			end
		end
	end
end

search:GetPropertyChangedSignal("Text"):Connect(function()
	restoreSearchCards()
	searchQuery = search.Text:gsub("^%s+", ""):gsub("%s+$", "")
	searchFound = 0

	if searchQuery ~= "" then
		local query = searchQuery:lower()
		local ordered = {}
		for _, section in pairs(sections) do
			table.insert(ordered, section)
		end
		table.sort(ordered, function(a, b)
			return a.order < b.order
		end)
		for _, section in ipairs(ordered) do
			for _, entry in ipairs(section.cards) do
				local haystack = (entry.name .. " " .. entry.desc):lower()
				if entry.frame.Parent and haystack:find(query, 1, true) then
					searchFound += 1
					entry.homeOrder = entry.homeOrder or entry.frame.LayoutOrder
					entry.frame.Parent = searchGrid
					entry.frame.LayoutOrder = searchFound
				end
			end
		end
	end

	if currentModule then
		currentModule.page.Visible = false
		currentModule = nil
	end
	showGrid()
end)

local SECTION_ICONS = {
	ESP = "eye",
	Visuals = "diamond",
	Misc = "dots",
	["Образы"] = "eye",
	Config = "bars",
	Themes = "palette",
}

local function createSection(name, groupName)
	sectionOrder += 1
	groupName = groupName or "Modules"
	local group = groups[groupName]
	group.sections[name] = true

	local nav = new("TextButton", {
		LayoutOrder = sectionOrder,
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = group.list,
	})

	local pill = new("Frame", {
		Position = UDim2.fromOffset(24, 3),
		Size = UDim2.new(1, -24, 1, -6),
		BackgroundColor3 = C.accentDim,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Visible = false,
		Parent = nav,
	})
	round(pill, 6)

	new("Frame", {
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = C.line,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = nav,
	})

	new("Frame", {
		Position = UDim2.new(0, 16, 0.5, 0),
		Size = UDim2.fromOffset(8, 1),
		BackgroundColor3 = C.line,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = nav,
	})

	local iconHolder = new("Frame", {
		Position = UDim2.new(0, 28, 0.5, -7),
		Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1,
		Parent = nav,
	})
	local setIcon = drawIcon(iconHolder, SECTION_ICONS[name] or "dot", 11)
	setIcon(C.sub)

	local label = new("TextLabel", {
		Position = UDim2.fromOffset(48, 0),
		Size = UDim2.new(1, -48, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.sub,
		Text = name,
		Parent = nav,
	})

	local grid = makeScroller(name .. "_Grid")
	new("UIGridLayout", {
		CellSize = UDim2.new(0.5, -5, 0, 66),
		CellPadding = UDim2.fromOffset(10, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = grid,
	})

	sections[name] = {
		grid = grid,
		cards = {},
		modules = {},
		group = groupName,
		order = sectionOrder,
		nav = { setIcon = setIcon, label = label, pill = pill },
	}

	nav.MouseEnter:Connect(function()
		if currentSection ~= name then
			label.TextColor3 = C.text
		end
	end)
	nav.MouseLeave:Connect(function()
		if currentSection ~= name then
			label.TextColor3 = C.sub
		end
	end)

	nav.MouseButton1Click:Connect(function()
		selectSection(name)
	end)

	return sections[name]
end
return { screenGui = screenGui, frame = frame, windowBackground = windowBackground, menuHint = menuHint, sidebar = sidebar,
 makeScroller = makeScroller, sections = sections, uiRefreshers = uiRefreshers, updateCounter = updateCounter, showGrid = showGrid,
 selectSection = selectSection, openSettings = openSettings, createSection = createSection,
 currentSection = function() return currentSection end, currentModule = function() return currentModule end }
end
function ui.settings(C, uiRefreshers, playToggleSound)
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local COLOR_PRESETS = {
	Color3.fromRGB(255, 90, 90),
	Color3.fromRGB(255, 160, 60),
	Color3.fromRGB(255, 230, 90),
	Color3.fromRGB(90, 220, 120),
	Color3.fromRGB(90, 230, 230),
	Color3.fromRGB(90, 170, 255),
	Color3.fromRGB(150, 185, 255),
	Color3.fromRGB(50, 90, 255),
	Color3.fromRGB(30, 50, 170),
	Color3.fromRGB(170, 110, 255),
	Color3.fromRGB(255, 120, 200),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(180, 190, 210),
	Color3.fromRGB(60, 60, 70),
	Color3.fromRGB(15, 15, 15),
}

local glassRows = {}

local function settingRow(page, labelText, height)
	local row = new("Frame", {
		LayoutOrder = #page:GetChildren(),
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = C.card,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Parent = page,
	})
	round(row, 8)
	outline(row, C.line, 0.7)
	table.insert(glassRows, row)
	new("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(215, 215, 215)),
		Parent = row,
	})

	new("TextLabel", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -140, 0, 38),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.text,
		Text = labelText,
		Parent = row,
	})

	return row
end

local function toggleSetting(page, labelText, key, source)
	local row = settingRow(page, labelText, 38)

	local pill = new("Frame", {
		Position = UDim2.new(1, -50, 0.5, -9),
		Size = UDim2.fromOffset(36, 18),
		BackgroundColor3 = C.off,
		BorderSizePixel = 0,
		Parent = row,
	})
	round(pill, 9)

	local knob = new("Frame", {
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = C.text,
		BorderSizePixel = 0,
		Parent = pill,
	})
	round(knob, 7)

	local button = new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Parent = row,
	})

	local function refresh()
		local on = source[key]
		pill.BackgroundColor3 = on and C.accent or C.off
		knob.Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
	end

	button.MouseButton1Click:Connect(function()
		source[key] = not source[key]
		refresh()
		playToggleSound(source[key])
	end)
	refresh()
	table.insert(uiRefreshers, refresh)
end

local function textSetting(page, labelText, key, maxLength, source)
	local row = settingRow(page, labelText, 38)

	local box = new("TextBox", {
		Position = UDim2.new(1, -142, 0.5, -12),
		Size = UDim2.fromOffset(130, 24),
		BackgroundColor3 = C.inner,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = C.text,
		PlaceholderText = "пусто",
		PlaceholderColor3 = C.sub,
		ClearTextOnFocus = false,
		Text = tostring(source[key]),
		Parent = row,
	})
	round(box, 6)
	outline(box, C.line, 0.6)

	box.FocusLost:Connect(function()
		source[key] = string.sub(box.Text, 1, maxLength)
		box.Text = source[key]
	end)

	table.insert(uiRefreshers, function()
		box.Text = tostring(source[key])
	end)
end

local function actionSetting(page, labelText, buttonText, callback)
	local row = settingRow(page, labelText, 38)

	local button = new("TextButton", {
		Position = UDim2.new(1, -122, 0.5, -12),
		Size = UDim2.fromOffset(110, 24),
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		AutoButtonColor = true,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = C.text,
		Text = buttonText,
		Parent = row,
	})
	round(button, 6)

	button.MouseButton1Click:Connect(callback)
end

local activeSlider = nil

uis.InputChanged:Connect(function(input)
	if activeSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
		activeSlider(input.Position.X)
	end
end)
uis.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		activeSlider = nil
	end
end)

local function numberSetting(page, labelText, key, minValue, maxValue, source)
	local row = settingRow(page, labelText, 56)
	local range = maxValue - minValue
	local step = range <= 5 and 0.05 or (range <= 50 and 0.5 or 1)

	local function format(value)
		if step >= 1 then
			return tostring(math.floor(value + 0.5))
		end
		return (string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", ""))
	end

	local box = new("TextBox", {
		Position = UDim2.new(1, -70, 0, 8),
		Size = UDim2.fromOffset(58, 22),
		BackgroundColor3 = C.inner,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = C.text,
		ClearTextOnFocus = false,
		Text = format(source[key]),
		Parent = row,
	})
	round(box, 6)
	outline(box, C.line, 0.6)

	local track = new("TextButton", {
		Position = UDim2.new(0, 12, 0, 40),
		Size = UDim2.new(1, -24, 0, 6),
		BackgroundColor3 = C.inner,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = row,
	})
	round(track, 3)

	local fill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		Parent = track,
	})
	round(fill, 3)

	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = C.text,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = track,
	})
	round(knob, 7)
	local knobStroke = new("UIStroke", { Color = C.accent, Thickness = 2, Parent = knob })
	local knobScale = new("UIScale", { Parent = knob })

	local function refresh()
		local value = math.clamp(source[key], minValue, maxValue)
		local alpha = range > 0 and (value - minValue) / range or 0
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.fromScale(alpha, 0.5)
		knobStroke.Color = C.accent
		if not box:IsFocused() then
			box.Text = format(source[key])
		end
	end

	local function setFromX(x)
		local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local value = minValue + alpha * range
		value = math.floor(value / step + 0.5) * step
		source[key] = math.clamp(value, minValue, maxValue)
		refresh()
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			activeSlider = setFromX
			setFromX(input.Position.X)
		end
	end)
	track.MouseEnter:Connect(function()
		ts:Create(knobScale, TweenInfo.new(0.1), { Scale = 1.2 }):Play()
	end)
	track.MouseLeave:Connect(function()
		ts:Create(knobScale, TweenInfo.new(0.1), { Scale = 1 }):Play()
	end)

	box.FocusLost:Connect(function()
		local value = tonumber(box.Text)
		if value then
			source[key] = math.clamp(value, minValue, maxValue)
		end
		refresh()
	end)

	refresh()
	table.insert(uiRefreshers, refresh)
end

local function choiceSetting(page, labelText, key, options, source)
	local columns = math.min(#options, 3)
	local rows = math.ceil(#options / columns)
	local chipHeight, gap = 28, 6
	local row = settingRow(page, labelText, 38 + rows * (chipHeight + gap) + 4)

	local grid = new("Frame", {
		Position = UDim2.fromOffset(12, 36),
		Size = UDim2.new(1, -24, 0, rows * (chipHeight + gap)),
		BackgroundTransparency = 1,
		Parent = row,
	})
	new("UIGridLayout", {
		CellSize = UDim2.new(1 / columns, -gap, 0, chipHeight),
		CellPadding = UDim2.fromOffset(gap, gap),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = grid,
	})

	local chips = {}

	local function refresh()
		for option, chip in pairs(chips) do
			local selected = source[key] == option
			chip.button.BackgroundColor3 = selected and C.accent or C.inner
			chip.button.TextColor3 = selected and C.text or C.sub
			chip.button.Font = selected and Enum.Font.GothamBold or Enum.Font.Gotham
			chip.stroke.Color = selected and C.accent or C.line
			chip.stroke.Transparency = selected and 0.2 or 0.6
		end
	end

	for index, option in ipairs(options) do
		local button = new("TextButton", {
			LayoutOrder = index,
			BackgroundColor3 = C.inner,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = C.sub,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = tostring(option),
			Parent = grid,
		})
		round(button, 6)
		local stroke = outline(button, C.line, 0.6)
		chips[option] = { button = button, stroke = stroke }

		button.MouseButton1Click:Connect(function()
			if source[key] ~= option then
				source[key] = option
				refresh()
				playToggleSound(true)
			end
		end)
		button.MouseEnter:Connect(function()
			if source[key] ~= option then
				button.TextColor3 = C.text
				stroke.Transparency = 0.3
			end
		end)
		button.MouseLeave:Connect(function()
			refresh()
		end)
	end

	refresh()
	table.insert(uiRefreshers, refresh)
end

local function colorSetting(page, labelText, key, source)
	local row = settingRow(page, labelText, 94)

	local grid = new("Frame", {
		Position = UDim2.fromOffset(12, 36),
		Size = UDim2.new(1, -24, 0, 52),
		BackgroundTransparency = 1,
		Parent = row,
	})
	new("UIGridLayout", {
		CellSize = UDim2.fromOffset(28, 22),
		CellPadding = UDim2.fromOffset(6, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = grid,
	})

	local function sameColor(a, b)
		if typeof(a) ~= "Color3" or typeof(b) ~= "Color3" then
			return false
		end
		return math.abs(a.R - b.R) < 0.004 and math.abs(a.G - b.G) < 0.004 and math.abs(a.B - b.B) < 0.004
	end

	local swatches = {}
	local function refresh()
		for _, swatch in ipairs(swatches) do
			local selected = sameColor(source[key], swatch.color)
			swatch.ring.Visible = selected
			swatch.ringStroke.Color = C.accent
			swatch.scale.Scale = selected and 1.08 or 1
		end
	end

	for index, color in ipairs(COLOR_PRESETS) do
		local swatch = new("TextButton", {
			LayoutOrder = index,
			AutoButtonColor = false,
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Text = "",
			Parent = grid,
		})
		round(swatch, 5)

		new("UIStroke", {
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = 0.6,
			Thickness = 1,
			Parent = swatch,
		})
		local scale = new("UIScale", { Parent = swatch })

		local ring = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 7, 1, 7),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = swatch,
		})
		round(ring, 8)
		local ringStroke = new("UIStroke", {
			Color = C.accent,
			Thickness = 2,
			Parent = ring,
		})

		swatch:SetAttribute("KeepColor", true)

		swatches[index] = { color = color, ring = ring, ringStroke = ringStroke, scale = scale }

		swatch.MouseButton1Click:Connect(function()
			source[key] = color
			refresh()
			playToggleSound(true)
		end)
		swatch.MouseEnter:Connect(function()
			if not sameColor(source[key], color) then
				scale.Scale = 1.05
			end
		end)
		swatch.MouseLeave:Connect(function()
			refresh()
		end)
	end
	refresh()
	table.insert(uiRefreshers, refresh)
end
return { toggle = toggleSetting, text = textSetting, action = actionSetting, number = numberSetting, choice = choiceSetting, color = colorSetting, rows = glassRows }
end
function ui.toasts(pg, C, MENU_STYLE)
local ts = game:GetService("TweenService")
local showToast
do
	local toastGui = new("ScreenGui", {
		Name = "OpusClient_Toasts",
		ResetOnSpawn = false,
		DisplayOrder = 300,
		Parent = pg,
	})
	local toastHolder = new("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(240, 260),
		BackgroundTransparency = 1,
		Parent = toastGui,
	})
	new("UIListLayout", {
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = toastHolder,
	})
	local toastCount = 0

	function showToast(title, on)
		if not MENU_STYLE.Toasts then
			return
		end
		toastCount += 1

		local slots = {}
		for _, child in ipairs(toastHolder:GetChildren()) do
			if child:IsA("Frame") then
				table.insert(slots, child)
			end
		end
		table.sort(slots, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		for i = 1, #slots - 3 do
			slots[i]:Destroy()
		end

		local slot = new("Frame", {
			LayoutOrder = toastCount,
			Size = UDim2.fromOffset(230, 46),
			BackgroundTransparency = 1,
			Parent = toastHolder,
		})
		local toast = new("Frame", {
			Position = UDim2.fromOffset(260, 0),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = C.bgBottom,
			BackgroundTransparency = 0.04,
			BorderSizePixel = 0,
			Parent = slot,
		})
		round(toast, 8)
		outline(toast, on and C.accent or C.line, 0.3)

		new("Frame", {
			Position = UDim2.fromOffset(8, 9),
			Size = UDim2.new(0, 3, 1, -18),
			BackgroundColor3 = on and C.accent or C.off,
			BorderSizePixel = 0,
			Parent = toast,
		})
		new("TextLabel", {
			Position = UDim2.fromOffset(20, 6),
			Size = UDim2.new(1, -28, 0, 18),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = C.text,
			Text = title,
			Parent = toast,
		})
		new("TextLabel", {
			Position = UDim2.fromOffset(20, 24),
			Size = UDim2.new(1, -28, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = on and C.accent or C.sub,
			Text = on and "включено" or "выключено",
			Parent = toast,
		})

		ts:Create(toast, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(0, 0),
		}):Play()
		task.delay(1.9, function()
			if not slot.Parent then
				return
			end
			local hide = ts:Create(toast, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.fromOffset(260, 0),
			})
			hide:Play()
			hide.Completed:Wait()
			slot:Destroy()
		end)
	end
end
return showToast
end
local MODULE_ICONS = {
	["ESP"] = "eye",
	["Подсветка"] = "diamond",
	["Текст над головой"] = "bars",
	["Имена"] = "bars",
	["Дистанция"] = "ring",
	["Здоровье"] = "plus",
	["Союзники"] = "dots",
	["Боксы"] = "square",
	["Трейсеры"] = "tracer",
	["Hat"] = "diamond",
	["Trail"] = "bars",
	["Jump Circle"] = "ring",
	["Particles"] = "dots",
	["Constellations"] = "plus",
	["Fog"] = "bars",
	["Custom Sky"] = "ring",
	["Shaders"] = "diamond",
	["Auras"] = "eye",
	["Back"] = "square",
	["Bottom"] = "ring",
	["Watermark"] = "bars",
	["Custom Cursor"] = "plus",
	["Target ESP"] = "eye",
	["Custom Pet"] = "dot",
	["Hit Effect"] = "x",
	["Toggle Sounds"] = "dots",
	["ArrayList"] = "bars",
	["Custom Model"] = "dot",
	["Hitbox"] = "square",
	["Растяжение экрана"] = "bars",
	["Размытие фона"] = "ring",
	["Уведомления"] = "bars",
	["Предпросмотр"] = "eye",
	["PNG картинка"] = "square",
	["Стекло"] = "diamond",
}
function ui.modules(C, KEYBINDS, CONFIG, uiRefreshers, makeScroller, openSettings, updateCounter, playToggleSound, showToast)
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local moduleRegistry = {}
local bindingTarget = nil

local function finishBinding()
	if bindingTarget then
		bindingTarget.stop()
		bindingTarget = nil
	end
end

uis.InputBegan:Connect(function(input, gameProcessed)
	if bindingTarget then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local name = bindingTarget.name
			if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
				KEYBINDS[name] = nil
			elseif input.KeyCode ~= CONFIG.MenuKey then

				for otherName, key in pairs(KEYBINDS) do
					if key == input.KeyCode.Name then
						KEYBINDS[otherName] = nil
					end
				end
				KEYBINDS[name] = input.KeyCode.Name
			end
			finishBinding()
			for _, refresh in ipairs(uiRefreshers) do
				refresh()
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			finishBinding()
		end
		return
	end

	if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	for name, key in pairs(KEYBINDS) do
		if key == input.KeyCode.Name and moduleRegistry[name] then
			moduleRegistry[name].toggle()
		end
	end
end)

local function addModule(section, def)

	local card = new("TextButton", {
		LayoutOrder = #section.cards + 1,
		BackgroundColor3 = C.card,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = section.grid,
	})
	round(card, 8)
	local cardStroke = outline(card, C.line, 0.65)
	local cardScale = new("UIScale", { Parent = card })

	new("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(205, 205, 205)),
		Parent = card,
	})

	local switch = new("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 11),
		Size = UDim2.fromOffset(30, 16),
		BackgroundColor3 = C.off,
		BorderSizePixel = 0,
		Parent = card,
	})
	round(switch, 8)
	local switchKnob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = C.text,
		BorderSizePixel = 0,
		Parent = switch,
	})
	round(switchKnob, 6)

	local icon = new("Frame", {
		Position = UDim2.fromOffset(10, 8),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = C.accentDim,
		BorderSizePixel = 0,
		Parent = card,
	})
	round(icon, 6)
	local setIcon = drawIcon(icon, def.icon or MODULE_ICONS[def.name] or "dot", 12)

	local title = new("TextLabel", {
		Position = UDim2.fromOffset(40, 8),
		Size = UDim2.new(1, def.settings and -112 or -88, 0, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = C.text,
		Text = def.name,
		Parent = card,
	})

	local descLabel = new("TextLabel", {
		Position = UDim2.fromOffset(12, 32),
		Size = UDim2.new(1, -24, 0, 28),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = C.sub,
		Text = def.desc,
		Parent = card,
	})

	local iconScale = new("UIScale", { Parent = icon })

	local badge = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, def.settings and -70 or -46, 0, 10),
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = C.inner,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = C.text,
		Text = "",
		Visible = false,
		Parent = card,
	})
	round(badge, 5)
	new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = badge })
	outline(badge, C.line, 0.5)

	local module = { name = def.name, page = nil }

	if def.settings then
		local dots = new("TextButton", {
			Position = UDim2.new(1, -64, 0, 8),
			Size = UDim2.fromOffset(22, 22),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 2,
			Parent = card,
		})
		drawIcon(dots, "kebab", 14)(C.sub)

		local page = makeScroller(def.name .. "_Settings")
		new("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = page,
		})
		def.settings(page)
		module.page = page

		dots.MouseButton1Click:Connect(function()
			openSettings(module)
		end)
	end

	local function refresh()
		local on = def.source[def.key]
		icon.BackgroundColor3 = on and C.accent or C.accentDim
		icon.BackgroundTransparency = on and 0 or 0.25
		setIcon(on and C.text or C.sub)
		title.TextColor3 = C.text
		cardStroke.Color = on and C.accent or C.line
		cardStroke.Transparency = on and 0.3 or 0.65

		switch.BackgroundColor3 = on and C.accent or C.off
		ts:Create(switchKnob, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
			Position = on and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		}):Play()

		local key = KEYBINDS[def.name]
		badge.Visible = key ~= nil
		badge.Text = key or ""
		if bindingTarget == nil or bindingTarget.name ~= def.name then
			descLabel.Text = def.desc
			descLabel.TextColor3 = C.sub
		end
	end

	local function toggle()
		def.source[def.key] = not def.source[def.key]
		refresh()
		updateCounter()
		local on = def.source[def.key]
		playToggleSound(on)
		showToast(def.name, on)

		iconScale.Scale = 1.3
		ts:Create(iconScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		if def.onToggle then
			def.onToggle(on)
		end
	end
	moduleRegistry[def.name] = { toggle = toggle, def = def, group = section.group }

	card.MouseButton1Click:Connect(toggle)

	card.MouseButton2Click:Connect(function()
		finishBinding()
		descLabel.Text = "Нажмите клавишу… (Esc — убрать)"
		descLabel.TextColor3 = C.accent
		bindingTarget = {
			name = def.name,
			stop = function()
				descLabel.Text = def.desc
				descLabel.TextColor3 = C.sub
			end,
		}
	end)

	local hoverInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	card.MouseEnter:Connect(function()
		ts:Create(card, hoverInfo, { BackgroundColor3 = C.cardHover }):Play()
		ts:Create(cardScale, hoverInfo, { Scale = 1.025 }):Play()
	end)
	card.MouseLeave:Connect(function()
		ts:Create(card, hoverInfo, { BackgroundColor3 = C.card }):Play()
		ts:Create(cardScale, hoverInfo, { Scale = 1 }):Play()
	end)

	refresh()
	table.insert(uiRefreshers, refresh)
	table.insert(uiRefreshers, updateCounter)
	table.insert(section.modules, def)
	table.insert(section.cards, { frame = card, name = def.name, desc = def.desc })
end
return addModule, moduleRegistry
end
function ui.boot(pg)
local BOOT = {}
do
	local PINK = Color3.fromRGB(255, 0, 255)
	BOOT.gui = Instance.new("ScreenGui")
	BOOT.gui.Name = "OpusClient_Boot"
	BOOT.gui.IgnoreGuiInset = true
	BOOT.gui.ResetOnSpawn = false
	BOOT.gui.DisplayOrder = 1000
	BOOT.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	BOOT.gui.Parent = pg

	BOOT.screen = Instance.new("Frame")
	BOOT.screen.Size = UDim2.fromScale(1, 1)
	BOOT.screen.BackgroundColor3 = Color3.new(0, 0, 0)
	BOOT.screen.BorderSizePixel = 0
	BOOT.screen.Parent = BOOT.gui

	BOOT.terminal = Instance.new("TextLabel")
	BOOT.terminal.Position = UDim2.fromOffset(18, 14)
	BOOT.terminal.Size = UDim2.new(0.6, 0, 0.6, 0)
	BOOT.terminal.BackgroundTransparency = 1
	BOOT.terminal.Font = Enum.Font.RobotoMono
	BOOT.terminal.TextSize = 16
	BOOT.terminal.TextColor3 = PINK
	BOOT.terminal.TextXAlignment = Enum.TextXAlignment.Left
	BOOT.terminal.TextYAlignment = Enum.TextYAlignment.Top
	BOOT.terminal.Text = ""
	BOOT.terminal.Parent = BOOT.screen

	BOOT.typing = true
	task.spawn(function()
		local lines = { "Decrypting opus system. . ." }
		for _ = 1, 8 do
			lines[#lines + 1] = string.format("PWD: 0x%08X", math.random(0, 0x0FFFFFFF))
		end
		lines[#lines + 1] = "Creator: @opus_client_rbx"
		lines[#lines + 1] = "access granted."
		local shown = {}
		for _, line in ipairs(lines) do
			local i = 0
			while i < #line do
				i = math.min(#line, i + math.random(2, 7))
				BOOT.terminal.Text = table.concat(shown, "\n") .. (#shown > 0 and "\n" or "") .. line:sub(1, i)
				task.wait(math.random() < 0.2 and 0.08 or 0.015)
			end
			shown[#shown + 1] = line
			BOOT.terminal.Text = table.concat(shown, "\n")
		end
		BOOT.typing = false
	end)

	task.delay(15, function()
		if not BOOT.started and BOOT.gui.Parent then
			BOOT.gui:Destroy()
		end
	end)
end
return BOOT
end
function ui.watermark(pg, lp, C)
local rs = game:GetService("RunService")
local WATERMARK, WATERMARK_POSITIONS
local watermarkClicked = Instance.new("BindableEvent")
do
	WATERMARK = {
		Enabled = true,
		ShowLogo = true,
		ShowFPS = true,
		ShowPing = true,
		ShowTime = true,
		ShowSeconds = false,
		Position = "Слева сверху",
	}

	WATERMARK_POSITIONS = { "Слева сверху", "Справа сверху", "Слева снизу", "Справа снизу" }
	local WATERMARK_ANCHORS = {
		["Слева сверху"] = { Vector2.new(0, 0), UDim2.new(0, 12, 0, 12) },
		["Справа сверху"] = { Vector2.new(1, 0), UDim2.new(1, -12, 0, 12) },
		["Слева снизу"] = { Vector2.new(0, 1), UDim2.new(0, 12, 1, -12) },
		["Справа снизу"] = { Vector2.new(1, 1), UDim2.new(1, -12, 1, -12) },
	}

	local watermarkGui = new("ScreenGui", {
		Name = "JustVisuals_Watermark",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		DisplayOrder = 90,
		Parent = pg,
	})

	local watermarkBar = new("TextButton", {
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 28),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = watermarkGui,
	})
	round(watermarkBar, 8)
	local watermarkStroke = outline(watermarkBar, C.line, 0.35)

	watermarkBar.MouseButton1Click:Connect(function()
		watermarkClicked:Fire()
	end)
	watermarkBar.MouseEnter:Connect(function()
		watermarkStroke.Color = C.accent
		watermarkStroke.Transparency = 0.1
	end)
	watermarkBar.MouseLeave:Connect(function()
		watermarkStroke.Color = C.line
		watermarkStroke.Transparency = 0.35
	end)
	new("UIGradient", {
		Color = ColorSequence.new(C.bgTop, C.bgBottom),
		Rotation = 20,
		Parent = watermarkBar,
	})
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 10),
		Parent = watermarkBar,
	})
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = watermarkBar,
	})

	local function watermarkItem(order)
		local holder = new("Frame", {
			LayoutOrder = order,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			Parent = watermarkBar,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = holder,
		})

		local divider = new("Frame", {
			LayoutOrder = 0,
			Size = UDim2.fromOffset(1, 14),
			BackgroundColor3 = C.line,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Parent = holder,
		})

		local value = new("TextLabel", {
			LayoutOrder = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = C.text,
			RichText = true,
			Text = "",
			Parent = holder,
		})

		return { holder = holder, divider = divider, value = value }
	end

	local logoItem = watermarkItem(1)
	logoItem.divider:Destroy()
	logoItem.divider = nil
	local logoSquare = new("Frame", {
		LayoutOrder = 0,
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = LOGO_BG,
		BorderSizePixel = 0,
		Parent = logoItem.holder,
	})
	round(logoSquare, 4)
	drawLogoMark(logoSquare, 18)
	logoItem.value.Font = Enum.Font.GothamBlack
	logoItem.value.Text = "opus client"

	local fpsItem = watermarkItem(2)
	local pingItem = watermarkItem(3)
	local timeItem = watermarkItem(4)

	local watermarkItems = {
		{ item = logoItem, key = "ShowLogo" },
		{ item = fpsItem, key = "ShowFPS" },
		{ item = pingItem, key = "ShowPing" },
		{ item = timeItem, key = "ShowTime" },
	}

	local function subText(text)
		return '<font color="#E2CCD1" size="11">' .. text .. "</font>"
	end

	local function speedColor(good, value, okLimit, badLimit, higherIsBetter)
		local isGood = higherIsBetter and value >= okLimit or (not higherIsBetter and value <= okLimit)
		local isBad = higherIsBetter and value < badLimit or (not higherIsBetter and value > badLimit)
		if isGood then
			return "#7EE2A0"
		elseif isBad then
			return "#FF6B7A"
		end
		return "#FFD27A"
	end

	local frameCount = 0
	local fpsTimer = 0
	local currentFps = 0

	rs.RenderStepped:Connect(function(dt)
		frameCount += 1
		fpsTimer += dt
		if fpsTimer < 0.5 then
			return
		end
		currentFps = math.floor(frameCount / fpsTimer + 0.5)
		frameCount = 0
		fpsTimer = 0

		watermarkGui.Enabled = WATERMARK.Enabled
		if not WATERMARK.Enabled then
			return
		end

		local anchor = WATERMARK_ANCHORS[WATERMARK.Position] or WATERMARK_ANCHORS["Слева сверху"]
		watermarkBar.AnchorPoint = anchor[1]
		watermarkBar.Position = anchor[2]

		local firstVisible = true
		for _, entry in ipairs(watermarkItems) do
			local shown = WATERMARK[entry.key]
			entry.item.holder.Visible = shown
			if shown then
				if entry.item.divider then
					entry.item.divider.Visible = not firstVisible
				end
				firstVisible = false
			end
		end

		fpsItem.value.Text = string.format('<font color="%s">%d</font> %s',
			speedColor(nil, currentFps, 50, 30, true), currentFps, subText("fps"))

		local ok, ping = pcall(function()
			return lp:GetNetworkPing()
		end)
		local pingMs = ok and math.floor(ping * 1000 + 0.5) or 0
		pingItem.value.Text = string.format('<font color="%s">%d</font> %s',
			speedColor(nil, pingMs, 80, 180, false), pingMs, subText("ms"))

		timeItem.value.Text = os.date(WATERMARK.ShowSeconds and "%H:%M:%S" or "%H:%M")
	end)
end
return WATERMARK, WATERMARK_POSITIONS, watermarkClicked
end
function ui.cursor(pg)
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local CURSOR, CURSOR_STYLES
do
	CURSOR = {
		Enabled = false,
		Style = "Крестик",
		Rainbow = false,
		Color = Color3.fromRGB(255, 90, 90),
		Size = 18,
		Thickness = 2,
		Outline = true,
		Spin = false,
		Transparency = 0,
	}

	CURSOR_STYLES = { "Точка", "Крестик", "Круг", "Ромб" }

	local cursorGui = new("ScreenGui", {
		Name = "JustVisuals_Cursor",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 500,
		Enabled = false,
		Parent = pg,
	})

	local cursorRoot = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = cursorGui,
	})

	local cursorShapes = {}
	local cursorBuiltFor = nil
	local cursorHidDefault = false

	local function cursorFill(position, size, circle)
		local part = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = position,
			Size = size,
			BorderSizePixel = 0,
			Parent = cursorRoot,
		})
		if circle then
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = part })
		end
		if CURSOR.Outline then
			new("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Transparency = 0.35,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Parent = part,
			})
		end
		table.insert(cursorShapes, { object = part })
		return part
	end

	local function cursorOutlineShape(size, circle, rotation)

		if CURSOR.Outline then
			local back = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(size, size),
				BackgroundTransparency = 1,
				Rotation = rotation or 0,
				Parent = cursorRoot,
			})
			if circle then
				new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = back })
			end
			new("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Transparency = 0.35,
				Thickness = CURSOR.Thickness + 2,
				Parent = back,
			})
		end

		local shape = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(size, size),
			BackgroundTransparency = 1,
			Rotation = rotation or 0,
			Parent = cursorRoot,
		})
		if circle then
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = shape })
		end
		local stroke = new("UIStroke", {
			Thickness = CURSOR.Thickness,
			Parent = shape,
		})
		table.insert(cursorShapes, { object = shape, stroke = stroke })
	end

	local function buildCursor()
		for _, child in ipairs(cursorRoot:GetChildren()) do
			child:Destroy()
		end
		table.clear(cursorShapes)

		local size = CURSOR.Size
		local thickness = CURSOR.Thickness
		cursorRoot.Size = UDim2.fromOffset(size, size)

		if CURSOR.Style == "Точка" then
			local dot = math.max(thickness * 2, math.floor(size / 3))
			cursorFill(UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(dot, dot), true)

		elseif CURSOR.Style == "Круг" then
			cursorOutlineShape(size, true)
			local dot = thickness + 2
			cursorFill(UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(dot, dot), true)

		elseif CURSOR.Style == "Ромб" then
			cursorOutlineShape(math.floor(size * 0.7), false, 45)

		else
			local gap = math.max(2, math.floor(size * 0.18))
			local length = math.max(2, math.floor(size / 2 - gap))
			local offset = gap + length / 2
			cursorFill(UDim2.new(0.5, 0, 0.5, -offset), UDim2.fromOffset(thickness, length))
			cursorFill(UDim2.new(0.5, 0, 0.5, offset), UDim2.fromOffset(thickness, length))
			cursorFill(UDim2.new(0.5, -offset, 0.5, 0), UDim2.fromOffset(length, thickness))
			cursorFill(UDim2.new(0.5, offset, 0.5, 0), UDim2.fromOffset(length, thickness))
		end

		cursorBuiltFor = table.concat({ CURSOR.Style, size, thickness, tostring(CURSOR.Outline) }, "|")
	end

	rs.RenderStepped:Connect(function()
		local enabled = CURSOR.Enabled and uis.MouseEnabled
		cursorGui.Enabled = enabled

		if not enabled then

			if cursorHidDefault then
				uis.MouseIconEnabled = true
				cursorHidDefault = false
			end
			return
		end

		uis.MouseIconEnabled = false
		cursorHidDefault = true

		local key = table.concat({ CURSOR.Style, CURSOR.Size, CURSOR.Thickness, tostring(CURSOR.Outline) }, "|")
		if key ~= cursorBuiltFor then
			buildCursor()
		end

		local mouse = uis:GetMouseLocation()
		cursorRoot.Position = UDim2.fromOffset(mouse.X, mouse.Y)
		cursorRoot.Rotation = CURSOR.Spin and (os.clock() * 120) % 360 or 0

		local color = CURSOR.Rainbow and Color3.fromHSV((os.clock() * 0.3) % 1, 0.8, 1) or CURSOR.Color
		for _, shape in ipairs(cursorShapes) do
			if shape.stroke then
				shape.stroke.Color = color
				shape.stroke.Transparency = CURSOR.Transparency
			else
				shape.object.BackgroundColor3 = color
				shape.object.BackgroundTransparency = CURSOR.Transparency
			end
		end
	end)
end
return CURSOR, CURSOR_STYLES
end
function ui.arrayList(pg, C, moduleRegistry, WATERMARK)
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
	local ARRAYLIST, ARRAYLIST_POSITIONS
	do
		local TextService = game:GetService("TextService")

		ARRAYLIST = {
			Enabled = true,
			Position = "Справа сверху",
			Suffix = true,
			Background = true,
			Rainbow = false,
		}
		ARRAYLIST_POSITIONS = { "Справа сверху", "Слева сверху", "Справа снизу", "Слева снизу" }

		local ROW_HEIGHT = 20
		local FONT = Enum.Font.GothamBold
		local TEXT_SIZE = 13

		local listGui = new("ScreenGui", {
			Name = "OpusClient_ArrayList",
			ResetOnSpawn = false,
			DisplayOrder = 80,
			Parent = pg,
		})
		local holder = new("Frame", {
			Size = UDim2.fromOffset(260, 600),
			BackgroundTransparency = 1,
			Parent = listGui,
		})

		local rows = {}
		local lastCheck = 0

		local function toHex(color)
			return string.format("#%02X%02X%02X",
				math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
		end

		local function rowText(name, def)
			local suffix = nil
			if ARRAYLIST.Suffix then
				local mode = def.source.Style or def.source.Preset
				if type(mode) == "string" and def.key == "Enabled" then
					suffix = mode
				end
			end
			local plain = suffix and (name .. "  " .. suffix) or name
			local rich = suffix and (name .. '  <font color="' .. toHex(C.sub) .. '">' .. suffix .. "</font>") or name
			return plain, rich
		end

		local function layout()
			local right = ARRAYLIST.Position:find("Справа") ~= nil
			local bottom = ARRAYLIST.Position:find("снизу") ~= nil
			holder.AnchorPoint = Vector2.new(right and 1 or 0, bottom and 1 or 0)
			local topOffset = 12

			if not right and not bottom and WATERMARK and WATERMARK.Enabled and WATERMARK.Position == "Слева сверху" then
				topOffset = 50
			end
			holder.Position = UDim2.new(right and 1 or 0, right and -10 or 10, bottom and 1 or 0, bottom and -10 or topOffset)
			return right, bottom
		end

		local function removeRow(name)
			local row = rows[name]
			if not row or row.removing then
				return
			end
			row.removing = true
			local right = holder.AnchorPoint.X > 0.5
			local tween = ts:Create(row.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = row.frame.Position + UDim2.fromOffset(right and 40 or -40, 0),
				BackgroundTransparency = 1,
			})
			ts:Create(row.label, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
			ts:Create(row.bar, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
			tween:Play()
			tween.Completed:Connect(function()
				row.frame:Destroy()
				if rows[name] == row then
					rows[name] = nil
				end
			end)
		end

		local function update()
			listGui.Enabled = ARRAYLIST.Enabled
			if not ARRAYLIST.Enabled then
				for name in pairs(rows) do
					removeRow(name)
				end
				return
			end
			local right, bottom = layout()

			local active = {}
			for name, entry in pairs(moduleRegistry) do
				local def = entry.def
				if def and entry.group ~= "Settings" and def.source ~= ARRAYLIST and name ~= "Синхронизация"
					and def.source[def.key] then
					local plain, rich = rowText(name, def)
					local width = TextService:GetTextSize(plain, TEXT_SIZE, FONT, Vector2.new(1000, 100)).X + 18
					table.insert(active, { name = name, rich = rich, width = width })
				end
			end

			table.sort(active, function(a, b)
				if a.width ~= b.width then
					return a.width > b.width
				end
				return a.name < b.name
			end)

			local wanted = {}
			for index, item in ipairs(active) do
				wanted[item.name] = true
				local row = rows[item.name]
				local targetY = bottom and (-(index - 1) * ROW_HEIGHT) or ((index - 1) * ROW_HEIGHT)
				local anchor = Vector2.new(right and 1 or 0, bottom and 1 or 0)
				local targetPosition = UDim2.new(right and 1 or 0, 0, bottom and 1 or 0, targetY)

				if not row or row.removing then
					if row then
						row.frame:Destroy()
					end
					local frame = new("Frame", {
						AnchorPoint = anchor,
						Position = targetPosition + UDim2.fromOffset(right and 40 or -40, 0),
						Size = UDim2.fromOffset(item.width, ROW_HEIGHT),
						BackgroundColor3 = C.bgBottom,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Parent = holder,
					})
					local bar = new("Frame", {
						AnchorPoint = Vector2.new(right and 1 or 0, 0),
						Position = UDim2.new(right and 1 or 0, 0, 0, 0),
						Size = UDim2.new(0, 2, 1, 0),
						BackgroundColor3 = C.accent,
						BorderSizePixel = 0,
						Parent = frame,
					})
					local label = new("TextLabel", {
						Position = UDim2.fromOffset(right and 6 or 10, 0),
						Size = UDim2.new(1, -16, 1, 0),
						BackgroundTransparency = 1,
						Font = FONT,
						TextSize = TEXT_SIZE,
						RichText = true,
						TextXAlignment = right and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
						TextColor3 = C.text,
						TextStrokeTransparency = 0.6,
						TextTransparency = 1,
						Text = item.rich,
						Parent = frame,
					})
					row = { frame = frame, bar = bar, label = label }
					rows[item.name] = row

					ts:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Position = targetPosition,
						BackgroundTransparency = ARRAYLIST.Background and 0.3 or 1,
					}):Play()
					ts:Create(label, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
				else
					row.frame.AnchorPoint = anchor
					row.label.Text = item.rich
					row.label.TextXAlignment = right and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
					row.label.Position = UDim2.fromOffset(right and 6 or 10, 0)
					row.bar.AnchorPoint = Vector2.new(right and 1 or 0, 0)
					row.bar.Position = UDim2.new(right and 1 or 0, 0, 0, 0)
					row.frame.BackgroundTransparency = ARRAYLIST.Background and 0.3 or 1

					if row.frame.Position ~= targetPosition then
						ts:Create(row.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							Position = targetPosition,
						}):Play()
					end
					row.frame.Size = UDim2.fromOffset(item.width, ROW_HEIGHT)
				end
				row.index = index
			end

			for name in pairs(rows) do
				if not wanted[name] then
					removeRow(name)
				end
			end
		end

		rs.RenderStepped:Connect(function()
			local now = os.clock()
			if now - lastCheck > 0.15 then
				lastCheck = now
				update()
			end

			for _, row in pairs(rows) do
				if not row.removing then
					local color = ARRAYLIST.Rainbow
						and Color3.fromHSV((now * 0.25 + (row.index or 0) * 0.06) % 1, 0.7, 1)
						or C.accent
					row.bar.BackgroundColor3 = color
					row.frame.BackgroundColor3 = C.bgBottom
					row.label.TextColor3 = ARRAYLIST.Rainbow and color or C.text
				end
			end
		end)
	end

return ARRAYLIST, ARRAYLIST_POSITIONS
end
function ui.finish(ctx)
local rs = ctx.rs
local uis = ctx.uis
local ts = ctx.ts
local lp = ctx.lp
local pg = ctx.pg
local BOOT = ctx.BOOT
local CONFIG = ctx.CONFIG
local HAT = ctx.HAT
local Lighting = ctx.Lighting
local AURA = ctx.AURA
local BACK = ctx.BACK
local C = ctx.C
local MENU_STYLE = ctx.MENU_STYLE
local DECOR_POSITIONS = ctx.DECOR_POSITIONS
local DECOR_LAYERS = ctx.DECOR_LAYERS
local KEYBINDS = ctx.KEYBINDS
local new = ctx.new
local round = ctx.round
local outline = ctx.outline
local drawIcon = ctx.drawIcon
local drawLogoMark = ctx.drawLogoMark
local LOGO_BG = ctx.LOGO_BG
local view = ctx.view
local screenGui = ctx.screenGui
local frame = ctx.frame
local windowBackground = ctx.windowBackground
local menuHint = ctx.menuHint
local sidebar = ctx.sidebar
local sections = ctx.sections
local uiRefreshers = ctx.uiRefreshers
local selectSection = ctx.selectSection
local createSection = ctx.createSection
local numberSetting = ctx.numberSetting
local choiceSetting = ctx.choiceSetting
local glassRows = ctx.glassRows
local showToast = ctx.showToast
local playToggleSound = assert(ctx.playToggleSound, "UI sound callback missing")
local addModule = ctx.addModule
local watermarkClicked = ctx.watermarkClicked
local PET = ctx.PET
do
	local updateMenuBlur

	do
		local THEMES = {
			["Бордовый"] = {
				bgTop = Color3.fromRGB(92, 32, 44), bgBottom = Color3.fromRGB(38, 14, 20),
				panel = Color3.fromRGB(30, 11, 16), card = Color3.fromRGB(80, 30, 40),
				cardHover = Color3.fromRGB(98, 38, 50), inner = Color3.fromRGB(52, 19, 27),
				accent = Color3.fromRGB(250, 90, 106), accentDim = Color3.fromRGB(140, 56, 70),
				off = Color3.fromRGB(104, 76, 82), sub = Color3.fromRGB(226, 204, 209),
				line = Color3.fromRGB(160, 88, 100),
			},
			["Полночь"] = {
				bgTop = Color3.fromRGB(36, 50, 104), bgBottom = Color3.fromRGB(14, 18, 42),
				panel = Color3.fromRGB(12, 16, 36), card = Color3.fromRGB(38, 50, 100),
				cardHover = Color3.fromRGB(48, 62, 120), inner = Color3.fromRGB(22, 28, 58),
				accent = Color3.fromRGB(118, 162, 255), accentDim = Color3.fromRGB(62, 86, 160),
				off = Color3.fromRGB(74, 82, 112), sub = Color3.fromRGB(206, 214, 240),
				line = Color3.fromRGB(88, 110, 184),
			},
			["Аметист"] = {
				bgTop = Color3.fromRGB(80, 38, 116), bgBottom = Color3.fromRGB(30, 15, 46),
				panel = Color3.fromRGB(24, 12, 38), card = Color3.fromRGB(72, 36, 104),
				cardHover = Color3.fromRGB(88, 46, 126), inner = Color3.fromRGB(44, 22, 66),
				accent = Color3.fromRGB(198, 134, 255), accentDim = Color3.fromRGB(110, 70, 160),
				off = Color3.fromRGB(96, 78, 114), sub = Color3.fromRGB(222, 206, 240),
				line = Color3.fromRGB(134, 92, 186),
			},
			["Изумруд"] = {
				bgTop = Color3.fromRGB(26, 88, 72), bgBottom = Color3.fromRGB(10, 32, 27),
				panel = Color3.fromRGB(9, 26, 22), card = Color3.fromRGB(30, 78, 65),
				cardHover = Color3.fromRGB(38, 96, 80), inner = Color3.fromRGB(17, 46, 38),
				accent = Color3.fromRGB(88, 232, 170), accentDim = Color3.fromRGB(44, 128, 96),
				off = Color3.fromRGB(72, 98, 90), sub = Color3.fromRGB(204, 234, 222),
				line = Color3.fromRGB(70, 142, 116),
			},
			["Графит"] = {
				bgTop = Color3.fromRGB(66, 66, 74), bgBottom = Color3.fromRGB(26, 26, 30),
				panel = Color3.fromRGB(20, 20, 24), card = Color3.fromRGB(58, 58, 66),
				cardHover = Color3.fromRGB(72, 72, 82), inner = Color3.fromRGB(36, 36, 42),
				accent = Color3.fromRGB(255, 176, 90), accentDim = Color3.fromRGB(130, 96, 64),
				off = Color3.fromRGB(90, 90, 98), sub = Color3.fromRGB(220, 220, 226),
				line = Color3.fromRGB(118, 118, 130),
			},
			["Неон"] = {
				bgTop = Color3.fromRGB(40, 22, 78), bgBottom = Color3.fromRGB(17, 9, 33),
				panel = Color3.fromRGB(13, 7, 26), card = Color3.fromRGB(35, 19, 68),
				cardHover = Color3.fromRGB(43, 24, 84), inner = Color3.fromRGB(23, 13, 44),
				accent = Color3.fromRGB(255, 70, 200), accentDim = Color3.fromRGB(118, 37, 111),
				off = Color3.fromRGB(83, 76, 102), sub = Color3.fromRGB(238, 216, 235),
				line = Color3.fromRGB(144, 46, 140),
			},
			["Океан"] = {
				bgTop = Color3.fromRGB(18, 64, 92), bgBottom = Color3.fromRGB(8, 27, 39),
				panel = Color3.fromRGB(6, 21, 30), card = Color3.fromRGB(16, 56, 80),
				cardHover = Color3.fromRGB(19, 69, 99), inner = Color3.fromRGB(10, 36, 52),
				accent = Color3.fromRGB(60, 205, 255), accentDim = Color3.fromRGB(31, 107, 139),
				off = Color3.fromRGB(74, 93, 108), sub = Color3.fromRGB(215, 232, 242),
				line = Color3.fromRGB(39, 133, 173),
			},
			["Закат"] = {
				bgTop = Color3.fromRGB(96, 44, 36), bgBottom = Color3.fromRGB(40, 18, 15),
				panel = Color3.fromRGB(32, 15, 12), card = Color3.fromRGB(84, 38, 31),
				cardHover = Color3.fromRGB(104, 48, 39), inner = Color3.fromRGB(55, 25, 21),
				accent = Color3.fromRGB(255, 140, 70), accentDim = Color3.fromRGB(141, 74, 42),
				off = Color3.fromRGB(106, 85, 85), sub = Color3.fromRGB(238, 224, 220),
				line = Color3.fromRGB(176, 91, 54),
			},
			["Сакура"] = {
				bgTop = Color3.fromRGB(92, 46, 72), bgBottom = Color3.fromRGB(39, 19, 30),
				panel = Color3.fromRGB(30, 15, 24), card = Color3.fromRGB(80, 40, 63),
				cardHover = Color3.fromRGB(99, 50, 78), inner = Color3.fromRGB(52, 26, 41),
				accent = Color3.fromRGB(255, 150, 200), accentDim = Color3.fromRGB(139, 78, 109),
				off = Color3.fromRGB(104, 86, 100), sub = Color3.fromRGB(238, 226, 235),
				line = Color3.fromRGB(173, 98, 136),
			},
			["Лава"] = {
				bgTop = Color3.fromRGB(70, 22, 12), bgBottom = Color3.fromRGB(29, 9, 5),
				panel = Color3.fromRGB(23, 7, 4), card = Color3.fromRGB(61, 19, 10),
				cardHover = Color3.fromRGB(76, 24, 13), inner = Color3.fromRGB(40, 13, 7),
				accent = Color3.fromRGB(255, 96, 30), accentDim = Color3.fromRGB(130, 47, 17),
				off = Color3.fromRGB(95, 76, 76), sub = Color3.fromRGB(238, 219, 215),
				line = Color3.fromRGB(161, 58, 21),
			},
			["Лёд"] = {
				bgTop = Color3.fromRGB(44, 70, 92), bgBottom = Color3.fromRGB(18, 29, 39),
				panel = Color3.fromRGB(15, 23, 30), card = Color3.fromRGB(38, 61, 80),
				cardHover = Color3.fromRGB(48, 76, 99), inner = Color3.fromRGB(25, 40, 52),
				accent = Color3.fromRGB(160, 225, 255), accentDim = Color3.fromRGB(82, 118, 139),
				off = Color3.fromRGB(85, 95, 108), sub = Color3.fromRGB(227, 235, 242),
				line = Color3.fromRGB(101, 147, 173),
			},
			["Токсик"] = {
				bgTop = Color3.fromRGB(26, 46, 20), bgBottom = Color3.fromRGB(11, 19, 8),
				panel = Color3.fromRGB(9, 15, 7), card = Color3.fromRGB(23, 40, 17),
				cardHover = Color3.fromRGB(28, 50, 22), inner = Color3.fromRGB(15, 26, 11),
				accent = Color3.fromRGB(150, 255, 60), accentDim = Color3.fromRGB(70, 120, 32),
				off = Color3.fromRGB(78, 86, 79), sub = Color3.fromRGB(226, 238, 218),
				line = Color3.fromRGB(86, 147, 40),
			},
			["Золото"] = {
				bgTop = Color3.fromRGB(58, 46, 22), bgBottom = Color3.fromRGB(24, 19, 9),
				panel = Color3.fromRGB(19, 15, 7), card = Color3.fromRGB(50, 40, 19),
				cardHover = Color3.fromRGB(63, 50, 24), inner = Color3.fromRGB(33, 26, 13),
				accent = Color3.fromRGB(245, 196, 72), accentDim = Color3.fromRGB(122, 97, 38),
				off = Color3.fromRGB(90, 86, 80), sub = Color3.fromRGB(237, 231, 220),
				line = Color3.fromRGB(149, 120, 46),
			},
			["Лаванда"] = {
				bgTop = Color3.fromRGB(66, 54, 100), bgBottom = Color3.fromRGB(28, 23, 42),
				panel = Color3.fromRGB(22, 18, 33), card = Color3.fromRGB(57, 47, 87),
				cardHover = Color3.fromRGB(71, 58, 108), inner = Color3.fromRGB(38, 31, 57),
				accent = Color3.fromRGB(190, 160, 255), accentDim = Color3.fromRGB(102, 86, 142),
				off = Color3.fromRGB(94, 89, 111), sub = Color3.fromRGB(230, 227, 242),
				line = Color3.fromRGB(128, 107, 178),
			},
			["Мята"] = {
				bgTop = Color3.fromRGB(24, 74, 66), bgBottom = Color3.fromRGB(10, 31, 28),
				panel = Color3.fromRGB(8, 24, 22), card = Color3.fromRGB(21, 64, 57),
				cardHover = Color3.fromRGB(26, 80, 71), inner = Color3.fromRGB(14, 42, 38),
				accent = Color3.fromRGB(110, 240, 200), accentDim = Color3.fromRGB(54, 126, 106),
				off = Color3.fromRGB(77, 97, 97), sub = Color3.fromRGB(221, 236, 235),
				line = Color3.fromRGB(66, 156, 132),
			},
			["Кровь"] = {
				bgTop = Color3.fromRGB(60, 8, 12), bgBottom = Color3.fromRGB(25, 3, 5),
				panel = Color3.fromRGB(20, 3, 4), card = Color3.fromRGB(52, 7, 10),
				cardHover = Color3.fromRGB(65, 9, 13), inner = Color3.fromRGB(34, 5, 7),
				accent = Color3.fromRGB(225, 30, 45), accentDim = Color3.fromRGB(114, 15, 22),
				off = Color3.fromRGB(91, 70, 76), sub = Color3.fromRGB(235, 211, 217),
				line = Color3.fromRGB(141, 19, 28),
			},
			["Кофе"] = {
				bgTop = Color3.fromRGB(70, 48, 36), bgBottom = Color3.fromRGB(29, 20, 15),
				panel = Color3.fromRGB(23, 16, 12), card = Color3.fromRGB(61, 42, 31),
				cardHover = Color3.fromRGB(76, 52, 39), inner = Color3.fromRGB(40, 27, 21),
				accent = Color3.fromRGB(225, 170, 120), accentDim = Color3.fromRGB(118, 87, 62),
				off = Color3.fromRGB(95, 86, 85), sub = Color3.fromRGB(235, 228, 226),
				line = Color3.fromRGB(147, 108, 78),
			},
		}

		THEMES["Прозрачный"] = {
			bgTop = Color3.fromRGB(175, 175, 180), bgBottom = Color3.fromRGB(125, 125, 130),
			panel = Color3.fromRGB(95, 95, 100), card = Color3.fromRGB(155, 155, 160),
			cardHover = Color3.fromRGB(180, 180, 186), inner = Color3.fromRGB(115, 115, 120),
			accent = Color3.fromRGB(190, 190, 197), accentDim = Color3.fromRGB(120, 120, 126),
			off = Color3.fromRGB(78, 78, 84), sub = Color3.fromRGB(232, 232, 236),
			line = Color3.fromRGB(236, 236, 240),
		}
		local THEME_ORDER = { "Прозрачный", "Бордовый", "Полночь", "Аметист", "Изумруд", "Графит", "Неон", "Океан", "Закат", "Сакура", "Лава", "Лёд", "Токсик", "Золото", "Лаванда", "Мята", "Кровь", "Кофе" }
		local THEME_KEYS = { "bgTop", "bgBottom", "panel", "card", "cardHover", "inner", "accent", "accentDim", "off", "sub", "line" }
		local appliedTheme = "Бордовый"
		local themeCards = {}

		local function colorKey(color)
			return string.format("%d,%d,%d",
				math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
		end

		local function recolor(root, map)
			for _, obj in ipairs(root:GetDescendants()) do
				if obj:IsA("GuiObject") and obj:GetAttribute("KeepColor") then
					continue
				end
				if obj:IsA("GuiObject") then
					local background = map[colorKey(obj.BackgroundColor3)]
					if background then
						obj.BackgroundColor3 = background
					end
					if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
						local textColor = map[colorKey(obj.TextColor3)]
						if textColor then
							obj.TextColor3 = textColor
						end
						if obj:IsA("TextBox") then
							local placeholder = map[colorKey(obj.PlaceholderColor3)]
							if placeholder then
								obj.PlaceholderColor3 = placeholder
							end
						end
					end
					if obj:IsA("ScrollingFrame") then
						local bar = map[colorKey(obj.ScrollBarImageColor3)]
						if bar then
							obj.ScrollBarImageColor3 = bar
						end
					end
				elseif obj:IsA("UIStroke") then
					local strokeColor = map[colorKey(obj.Color)]
					if strokeColor then
						obj.Color = strokeColor
					end
				elseif obj:IsA("UIGradient") then
					local changed, keypoints = false, {}
					for _, keypoint in ipairs(obj.Color.Keypoints) do
						local mapped = map[colorKey(keypoint.Value)]
						changed = changed or mapped ~= nil
						table.insert(keypoints, ColorSequenceKeypoint.new(keypoint.Time, mapped or keypoint.Value))
					end
					if changed then
						obj.Color = ColorSequence.new(keypoints)
					end
				end
			end
		end

		local function refreshThemeCards()
			for name, entry in pairs(themeCards) do
				local active = name == appliedTheme
				entry.stroke.Color = active and C.accent or C.line
				entry.stroke.Transparency = active and 0.2 or 0.65
				entry.badge.Visible = active
				entry.badge.TextColor3 = C.accent
			end
		end

		local CLEAR_THEME = "Прозрачный"
		local clearLevels = nil
		local clearConnection = nil

		local function clearObject(obj)
			if obj:GetAttribute("KeepColor") then
				return
			end
			if obj:IsA("GuiObject") then
				local level = clearLevels[colorKey(obj.BackgroundColor3)]
				if level and obj.BackgroundTransparency < 1 and obj:GetAttribute("OpusClearBg") == nil then
					obj:SetAttribute("OpusClearBg", obj.BackgroundTransparency)
					obj.BackgroundTransparency = math.max(obj.BackgroundTransparency, level)
				end
				if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox"))
					and obj:GetAttribute("OpusClearText") == nil then
					obj:SetAttribute("OpusClearText", obj.TextStrokeTransparency)
					obj.TextStrokeTransparency = math.min(obj.TextStrokeTransparency, 0.7)
				end
			elseif obj:IsA("UIStroke") and obj:GetAttribute("OpusClearStroke") == nil and obj.Transparency < 1 then

				obj:SetAttribute("OpusClearStroke", obj.Transparency)
				obj.Transparency = obj.Transparency * 0.55
			end
		end

		local function restoreObject(obj)
			local bg = obj:GetAttribute("OpusClearBg")
			if bg ~= nil then
				obj.BackgroundTransparency = bg
				obj:SetAttribute("OpusClearBg", nil)
			end
			local text = obj:GetAttribute("OpusClearText")
			if text ~= nil then
				obj.TextStrokeTransparency = text
				obj:SetAttribute("OpusClearText", nil)
			end
			local stroke = obj:GetAttribute("OpusClearStroke")
			if stroke ~= nil then
				obj.Transparency = stroke
				obj:SetAttribute("OpusClearStroke", nil)
			end
		end

		local function setClearMode(on)
			if on then
				local theme = THEMES[CLEAR_THEME]
				clearLevels = {
					[colorKey(theme.bgTop)] = 0.9, [colorKey(theme.bgBottom)] = 0.88,
					[colorKey(theme.panel)] = 0.9, [colorKey(theme.card)] = 0.86,
					[colorKey(theme.cardHover)] = 0.82, [colorKey(theme.inner)] = 0.85,
					[colorKey(theme.off)] = 0.65, [colorKey(theme.accentDim)] = 0.55,
				}
				for _, obj in ipairs(screenGui:GetDescendants()) do
					clearObject(obj)
				end
				if not clearConnection then

					clearConnection = screenGui.DescendantAdded:Connect(function(obj)
						task.defer(function()
							if obj.Parent and clearLevels then
								clearObject(obj)
							end
						end)
					end)
				end
			else
				if clearConnection then
					clearConnection:Disconnect()
					clearConnection = nil
				end
				if clearLevels then
					clearLevels = nil
					for _, obj in ipairs(screenGui:GetDescendants()) do
						restoreObject(obj)
					end
				end
			end
		end

		local function applyTheme(name)
			local theme = THEMES[name]
			if not theme then
				return
			end
			if name ~= appliedTheme then
				local map = {}
				for _, key in ipairs(THEME_KEYS) do
					map[colorKey(C[key])] = theme[key]
				end
				recolor(screenGui, map)
				local watermark = pg:FindFirstChild("JustVisuals_Watermark")
				if watermark then
					recolor(watermark, map)
				end
				for _, key in ipairs(THEME_KEYS) do
					C[key] = theme[key]
				end
				appliedTheme = name
			end
			MENU_STYLE.Theme = name
			setClearMode(name == CLEAR_THEME)
			for _, refresh in ipairs(uiRefreshers) do
				refresh()
			end
			refreshThemeCards()
			if view.currentSection() and not view.currentModule() then
				selectSection(view.currentSection())
			end
		end

		local themesSection = createSection("Themes", "Settings")

		for index, name in ipairs(THEME_ORDER) do
			local theme = THEMES[name]
			local card = new("TextButton", {
				LayoutOrder = index,
				BackgroundColor3 = C.card,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				Parent = themesSection.grid,
			})
			round(card, 8)
			local stroke = outline(card, C.line, 0.65)

			new("TextLabel", {
				Position = UDim2.fromOffset(12, 8),
				Size = UDim2.new(1, -80, 0, 20),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = C.text,
				Text = name,
				Parent = card,
			})

			local badge = new("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -10, 0, 8),
				Size = UDim2.fromOffset(70, 20),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextColor3 = C.accent,
				Text = "активна",
				Visible = false,
				Parent = card,
			})

			for i, key in ipairs({ "bgTop", "card", "accentDim", "accent" }) do
				local swatch = new("Frame", {
					Position = UDim2.fromOffset(12 + (i - 1) * 24, 36),
					Size = UDim2.fromOffset(18, 18),
					BackgroundColor3 = theme[key],
					BorderSizePixel = 0,
					Parent = card,
				})
				round(swatch, 9)
				new("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.8, Parent = swatch })

				swatch:SetAttribute("KeepColor", true)
			end

			card.MouseButton1Click:Connect(function()
				applyTheme(name)
				playToggleSound(true)
			end)
			card.MouseEnter:Connect(function()
				card.BackgroundColor3 = C.cardHover
			end)
			card.MouseLeave:Connect(function()
				card.BackgroundColor3 = C.card
			end)

			themeCards[name] = { stroke = stroke, badge = badge }
			table.insert(themesSection.cards, { frame = card, name = name, desc = "тема" })
		end

		addModule(themesSection, {
			name = "Стекло",
			desc = "Полупрозрачное меню с размытым миром за ним.",
			source = MENU_STYLE,
			key = "Glass",
			settings = function(page)
				numberSetting(page, "Прозрачность стекла", "GlassLevel", 0, 0.8, MENU_STYLE)
			end,
		})

		addModule(themesSection, {
			name = "PNG картинка",
			desc = "Картинка-украшение рядом с меню.",
			source = MENU_STYLE,
			key = "Decor",
			settings = function(page)
				choiceSetting(page, "Где", "DecorPosition", DECOR_POSITIONS, MENU_STYLE)
				choiceSetting(page, "Слой", "DecorLayer", DECOR_LAYERS, MENU_STYLE)
				numberSetting(page, "Размер", "DecorSize", 40, 600, MENU_STYLE)
				numberSetting(page, "Прозрачность", "DecorTransparency", 0, 0.95, MENU_STYLE)
			end,
		})

		addModule(themesSection, {
			name = "Предпросмотр",
			desc = "Окно справа: ваш аватар с включёнными визуалами.",
			source = MENU_STYLE,
			key = "Preview",
		})

		addModule(themesSection, {
			name = "Уведомления",
			desc = "Всплывающие уведомления при включении функций.",
			source = MENU_STYLE,
			key = "Toasts",
		})

		addModule(themesSection, {
			name = "Размытие фона",
			desc = "Мир за открытым меню размывается.",
			source = MENU_STYLE,
			key = "Blur",
			onToggle = function()
				if updateMenuBlur then
					updateMenuBlur()
				end
			end,
		})

		do
			local function applyMenuKey()
				local key = Enum.KeyCode[MENU_STYLE.MenuKey]
				if not key or key == Enum.KeyCode.Unknown then
					key = Enum.KeyCode.RightControl
					MENU_STYLE.MenuKey = key.Name
				end
				CONFIG.MenuKey = key
				menuHint.Text = key.Name .. " — меню\nПКМ по карточке — клавиша\ntgk: opus_client_rbx"
				return key
			end

			local card = new("TextButton", {
				LayoutOrder = 1000,
				BackgroundColor3 = C.card,
				BackgroundTransparency = 0.05,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				Parent = themesSection.grid,
			})
			round(card, 8)
			local stroke = outline(card, C.line, 0.65)
			local icon = new("Frame", {
				Position = UDim2.fromOffset(10, 8),
				Size = UDim2.fromOffset(22, 22),
				BackgroundColor3 = C.accent,
				BorderSizePixel = 0,
				Parent = card,
			})
			round(icon, 6)
			drawIcon(icon, "square", 12)(C.text)
			new("TextLabel", {
				Position = UDim2.fromOffset(40, 8),
				Size = UDim2.new(1, -50, 0, 22),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = C.text,
				Text = "Клавиша меню",
				Parent = card,
			})
			local desc = new("TextLabel", {
				Position = UDim2.fromOffset(12, 32),
				Size = UDim2.new(1, -24, 0, 28),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = C.sub,
				Text = "",
				Parent = card,
			})

			local capturing = false
			local function refresh()
				local key = applyMenuKey()
				if not capturing then
					desc.Text = "Сейчас: " .. key.Name .. ". Нажмите, чтобы сменить."
					desc.TextColor3 = C.sub
				end
			end

			card.MouseButton1Click:Connect(function()
				capturing = true
				desc.Text = "Нажмите новую клавишу… (Esc — отмена)"
				desc.TextColor3 = C.accent
				stroke.Color = C.accent
				stroke.Transparency = 0.3
			end)

			uis.InputBegan:Connect(function(input)
				if not capturing or input.UserInputType ~= Enum.UserInputType.Keyboard then
					return
				end
				capturing = false
				stroke.Color = C.line
				stroke.Transparency = 0.65
				local key = input.KeyCode
				if key ~= Enum.KeyCode.Escape and key ~= Enum.KeyCode.Unknown then

					task.defer(function()

						for name, bound in pairs(KEYBINDS) do
							if bound == key.Name then
								KEYBINDS[name] = nil
							end
						end
						MENU_STYLE.MenuKey = key.Name
						for _, refresher in ipairs(uiRefreshers) do
							refresher()
						end
						playToggleSound(true)
						showToast("Клавиша меню: " .. key.Name, true)
					end)
				else
					refresh()
				end
			end)

			refresh()
			table.insert(uiRefreshers, refresh)
			table.insert(themesSection.cards, { frame = card, name = "Клавиша меню", desc = "открытие закрытие меню" })
		end

		refreshThemeCards()

		table.insert(uiRefreshers, function()
			if MENU_STYLE.Theme ~= appliedTheme and THEMES[MENU_STYLE.Theme] then
				applyTheme(MENU_STYLE.Theme)
			end
			if updateMenuBlur then
				updateMenuBlur()
			end
		end)
	end

	selectSection("Visuals")

	local windowScale = new("UIScale", { Scale = 1, Parent = frame })

	do
		local glowGui = new("ScreenGui", {
			Name = "OpusClient_MenuGlow",
			ResetOnSpawn = false,
			DisplayOrder = screenGui.DisplayOrder - 1,
			Enabled = false,
			Parent = pg,
		})
		local layers = {}
		for _, spec in ipairs({ { 2, 2, 0.55 }, { 8, 4, 0.82 }, { 18, 6, 0.92 } }) do
			local glow = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = glowGui,
			})
			round(glow, 12 + spec[1] / 2)
			local stroke = new("UIStroke", { Thickness = spec[2], Parent = glow })
			table.insert(layers, {
				frame = glow,
				stroke = stroke,
				scale = new("UIScale", { Parent = glow }),
				grow = spec[1],
				transparency = spec[3],
			})
		end

		local glassEdge = new("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 0.82,
			Thickness = 1,
			Parent = windowBackground,
		})

		local appliedGlass = nil
		local function applyGlass()
			local level = MENU_STYLE.Glass and math.clamp(MENU_STYLE.GlassLevel, 0, 0.8) or 0

			local cardCount = 0
			for _, section in pairs(sections) do
				cardCount += #section.cards
			end
			local clear = MENU_STYLE.Theme == "Прозрачный"
			local key = tostring(MENU_STYLE.Glass) .. level .. "/" .. cardCount .. "/" .. tostring(clear)
			if key == appliedGlass then
				return
			end
			appliedGlass = key

			windowBackground.BackgroundTransparency = clear and 0.9 or (0.04 + level * 0.75)
			sidebar.BackgroundTransparency = clear and 0.92 or math.min(0.45 + level * 0.5, 0.92)
			glassEdge.Transparency = clear and 0.25 or (MENU_STYLE.Glass and 0.7 or 0.9)

			local cardTransparency = clear and 0.86 or (0.05 + level * 0.55)
			for _, section in pairs(sections) do
				for _, entry in ipairs(section.cards) do
					if entry.frame.Parent then
						entry.frame.BackgroundTransparency = cardTransparency
					end
				end
			end
			for _, row in ipairs(glassRows) do
				row.BackgroundTransparency = clear and 0.88 or (0.2 + level * 0.45)
			end
			if updateMenuBlur then
				updateMenuBlur()
			end
		end
		table.insert(uiRefreshers, function()
			appliedGlass = nil
			applyGlass()
		end)
		applyGlass()

		rs.RenderStepped:Connect(function()
			glowGui.Enabled = screenGui.Enabled and frame.Visible
			if not glowGui.Enabled then
				return
			end
			applyGlass()
			for _, layer in ipairs(layers) do
				layer.frame.Position = frame.Position
				layer.frame.Size = frame.Size + UDim2.fromOffset(layer.grow, layer.grow)
				layer.scale.Scale = windowScale.Scale
				layer.stroke.Color = C.accent
				layer.stroke.Transparency = layer.transparency
			end
		end)
	end

	local menuBlur = new("BlurEffect", { Name = "JustVisualsMenuBlur", Size = 0, Parent = game:GetService("Lighting") })
	local menuIsOpen = false

	updateMenuBlur = function()
		local glass = MENU_STYLE.Glass and math.clamp(MENU_STYLE.GlassLevel, 0, 0.8) or 0
		local target = (menuIsOpen and MENU_STYLE.Blur) and (10 + glass * 18) or 0
		ts:Create(menuBlur, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = target }):Play()
	end

	local menuOpen = false
	local animationId = 0

	local WINDOW_SIZE = Vector2.new(600, 400)
	local SCREEN_MARGIN = 24

	local PREVIEW_WIDTH = 210
	local PREVIEW_GAP = 12

	local function previewExtra()
		return MENU_STYLE.Preview and (PREVIEW_WIDTH + PREVIEW_GAP) or 0
	end

	local function getFitScale()
		local available = screenGui.AbsoluteSize
		if available.X < 1 or available.Y < 1 then
			return 1
		end
		local scale = math.min(
			(available.X - SCREEN_MARGIN * 2) / (WINDOW_SIZE.X + previewExtra()),
			(available.Y - SCREEN_MARGIN * 2) / WINDOW_SIZE.Y
		)
		return math.clamp(scale, 0.45, 1)
	end

	local function clampWindow()
		local available = screenGui.AbsoluteSize
		local scale = getFitScale()
		local half = WINDOW_SIZE * scale / 2
		local extra = previewExtra() * scale
		local minX = math.min(0, -(available.X / 2 - half.X - SCREEN_MARGIN))
		local maxX = available.X / 2 - half.X - extra - SCREEN_MARGIN
		if maxX < minX then
			maxX = minX
		end
		local maxY = math.max(0, available.Y / 2 - half.Y - SCREEN_MARGIN)
		frame.Position = UDim2.new(
			0.5, math.clamp(frame.Position.X.Offset, minX, maxX),
			0.5, math.clamp(frame.Position.Y.Offset, -maxY, maxY)
		)
	end

	screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if menuOpen then
			windowScale.Scale = getFitScale()
			clampWindow()
		end
	end)

	uis.InputEnded:Connect(function(input)
		if menuOpen and (input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch) then
			clampWindow()
		end
	end)

	do
		local EFFECT_FOLDERS = { "BackAccessory_Local", "Aura_Local", "CustomPet_Local", "Bulba_Local", "Bottom_Local" }
		local KEEP_CHILDREN = {
			SpecialMesh = true, BlockMesh = true, CylinderMesh = true,
			Decal = true, Texture = true, SurfaceAppearance = true,
		}

		local panel = new("Frame", {
			Name = "Preview",
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(PREVIEW_WIDTH, WINDOW_SIZE.Y),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = windowBackground.BackgroundTransparency,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Visible = false,
			Parent = screenGui,
		})
		round(panel, 12)
		outline(panel, C.line, 0.35)
		new("UIGradient", { Rotation = 55, Color = ColorSequence.new(C.bgTop, C.bgBottom), Parent = panel })

		local panelEdge = new("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = panel,
		})
		round(panelEdge, 12)
		local panelEdgeStroke = new("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 0.82,
			Thickness = 1,
			Parent = panelEdge,
		})
		panelEdgeStroke:SetAttribute("KeepColor", true)
		local panelSheen = new("Frame", {
			Size = UDim2.new(1, 0, 0.45, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.94,
			BorderSizePixel = 0,
			Parent = panel,
		})
		round(panelSheen, 12)
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0, 1), Parent = panelSheen })
		local panelScale = new("UIScale", { Parent = panel })

		new("TextLabel", {
			Position = UDim2.fromOffset(14, 10),
			Size = UDim2.new(1, -28, 0, 20),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.text,
			Text = "Предпросмотр",
			Parent = panel,
		})
		local subtitle = new("TextLabel", {
			Position = UDim2.fromOffset(14, 30),
			Size = UDim2.new(1, -28, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.sub,
			Text = "",
			Parent = panel,
		})

		local viewport = new("ViewportFrame", {
			Position = UDim2.fromOffset(8, 54),
			Size = UDim2.new(1, -16, 1, -88),
			BackgroundColor3 = C.inner,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Ambient = Color3.fromRGB(150, 150, 160),
			LightColor = Color3.fromRGB(235, 235, 240),
			LightDirection = Vector3.new(-0.4, -1, -0.6),
			Parent = panel,
		})
		round(viewport, 10)
		local viewCamera = Instance.new("Camera")
		viewCamera.FieldOfView = 38
		viewCamera.Parent = viewport
		viewport.CurrentCamera = viewCamera

		new("TextLabel", {
			Position = UDim2.new(0, 14, 1, -30),
			Size = UDim2.new(1, -28, 0, 20),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = C.sub,
			Text = "Тяните мышью, чтобы повернуть",
			Parent = panel,
		})

		local yaw = math.rad(200)
		local dragging = false
		local lastX = 0
		local lastDrag = 0
		viewport.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				lastX = input.Position.X
			end
		end)
		uis.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				yaw -= (input.Position.X - lastX) * 0.012
				lastX = input.Position.X
				lastDrag = os.clock()
			end
		end)
		uis.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		local characterCopy = nil
		local characterPairs = {}
		local characterSignature = nil
		local copiedCharacter = nil
		local effectCopies = {}
		local lastScan = 0

		local function stripCopy(copy)
			for _, child in ipairs(copy:GetChildren()) do
				if not KEEP_CHILDREN[child.ClassName] then
					child:Destroy()
				end
			end
			copy.Anchored = true
			copy.CastShadow = false
		end

		local function rebuildCharacter(character)
			if characterCopy then
				characterCopy:Destroy()
				characterCopy = nil
			end
			table.clear(characterPairs)
			if not character then
				return
			end

			local sourcesById = {}
			local nextId = 0
			for _, object in ipairs(character:GetDescendants()) do
				if object:IsA("BasePart") then
					nextId += 1
					object:SetAttribute("OpusPreviewId", nextId)
					sourcesById[nextId] = object
				end
			end

			local restore = {}
			local function allowCopy(object)
				if not object.Archivable then
					object.Archivable = true
					table.insert(restore, object)
				end
			end
			allowCopy(character)
			for _, object in ipairs(character:GetDescendants()) do
				allowCopy(object)
			end
			local ok, copy = pcall(character.Clone, character)
			for _, object in ipairs(restore) do
				if object.Parent or object == character then
					object.Archivable = false
				end
			end
			if not ok or not copy then
				return
			end

			for _, object in ipairs(copy:GetDescendants()) do
				if object:IsA("BaseScript") or object:IsA("Sound") or object:IsA("ParticleEmitter")
					or object:IsA("Trail") or object:IsA("Beam") or object:IsA("Highlight") or object:IsA("Light")
					or object:IsA("JointInstance") or object:IsA("WeldConstraint") or object:IsA("Motor6D") then
					object:Destroy()
				elseif object:IsA("BasePart") then
					object.Anchored = true
					object.CastShadow = false
					local source = sourcesById[object:GetAttribute("OpusPreviewId")]
					if source then
						table.insert(characterPairs, { source = source, copy = object })
					else
						object:Destroy()
					end
				end
			end
			local humanoid = copy:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end
			copy.Parent = viewport
			characterCopy = copy
		end

		local function partCount(character)
			local count = 0
			for _, object in ipairs(character:GetDescendants()) do
				if object:IsA("BasePart") then
					count += 1
				end
			end
			return count
		end

		local function scan(character, root)

			local signature = character and partCount(character) or nil
			if character ~= copiedCharacter or signature ~= characterSignature then
				copiedCharacter = character
				characterSignature = signature
				rebuildCharacter(character)
			end

			local keep = {}
			for _, folderName in ipairs(EFFECT_FOLDERS) do
				for _, folder in ipairs(workspace:GetChildren()) do
					if folder.Name ~= folderName or not root then
						continue
					end
					for _, part in ipairs(folder:GetDescendants()) do
						if part:IsA("BasePart") and (part.Position - root.Position).Magnitude < 12 then
							keep[part] = true
							if not effectCopies[part] then
								local ok, copy = pcall(part.Clone, part)
								if ok and copy then
									stripCopy(copy)
									copy.Parent = viewport
									effectCopies[part] = copy
								end
							end
						end
					end
				end
			end
			for part, copy in pairs(effectCopies) do
				if not keep[part] or not part.Parent then
					copy:Destroy()
					effectCopies[part] = nil
				end
			end
		end

		local function activeVisuals()
			local names = {}
			for _, item in ipairs({ { HAT, "Hat" }, { BACK, "Back" }, { AURA, "Aura" }, { PET, "Pet" } }) do
				if item[1].Enabled then
					table.insert(names, item[2])
				end
			end
			return #names > 0 and table.concat(names, " · ") or "визуалы не включены"
		end

		rs.RenderStepped:Connect(function(dt)
			local visible = MENU_STYLE.Preview and screenGui.Enabled and frame.Visible
			panel.Visible = visible
			if not visible then
				return
			end

			local glass = windowBackground.BackgroundTransparency
			panel.BackgroundTransparency = glass
			viewport.BackgroundTransparency = math.clamp(glass + 0.35, 0.4, 0.97)
			panelEdgeStroke.Transparency = glass > 0.5 and 0.4 or 0.82

			local scale = windowScale.Scale
			panelScale.Scale = scale
			panel.Position = frame.Position + UDim2.fromOffset((WINDOW_SIZE.X / 2 + PREVIEW_GAP) * scale, 0)

			local character = lp.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local now = os.clock()
			if now - lastScan > 0.5 then
				lastScan = now
				scan(character, root)
				subtitle.Text = activeVisuals()
			end
			if not root then
				return
			end

			local look = root.CFrame.LookVector
			local reference = CFrame.new(root.Position) * CFrame.Angles(0, math.atan2(-look.X, -look.Z), 0)
			for _, pair in ipairs(characterPairs) do
				local source, copy = pair.source, pair.copy
				if source.Parent then
					copy.CFrame = reference:ToObjectSpace(source.CFrame)

					copy.Transparency = source.Transparency
					copy.Color = source.Color
					copy.Material = source.Material
					copy.Reflectance = source.Reflectance
				end
			end
			for part, copy in pairs(effectCopies) do
				if part.Parent then
					copy.CFrame = reference:ToObjectSpace(part.CFrame)
					copy.Transparency = part.Transparency
					copy.Color = part.Color
					copy.Material = part.Material
					copy.Reflectance = part.Reflectance
				end
			end

			viewCamera.CFrame = CFrame.Angles(0, yaw, 0) * CFrame.new(0, 0.6, 11.5)
			viewCamera.CFrame = CFrame.lookAt(viewCamera.CFrame.Position, Vector3.new(0, 0.4, 0))
		end)
	end

	do

		local DECOR_W, DECOR_H = 183, 220
		local DECOR_ROWS = [[
	61,0,23,6,0,0,0,0,5,0,22,22,6,0,0,0,18,0,0,0,19,0,26,26,22,0,0,0,60,1,25,4,0,1,0,0,6,1,16,16,7,1,1,1,24,1,0,1,53,2,39,2,0,0,0,0,38,0,0,0,50,3,45,3,0,0,19,19,3,0,0,0,44,0,0,0,49,4,47,4,0,0,2,2,1,0,18,
	18,4,2,1,2,46,0,0,0,47,5,51,2,0,0,0,0,50,0,13,13,45,6,55,2,0,0,0,0,54,0,0,0,44,7,57,2,0,1,0,1,56,2,1,2,41,8,62,2,0,0,0,0,61,0,0,0,40,9,64,2,0,0,0,0,63,1,0,1,39,10,67,2,0,1,0,1,66,0,0,0,36,11,71,3,0,0,
	15,15,1,0,0,0,70,0,0,0,35,12,73,3,0,0,17,17,2,2,0,0,72,0,0,0,34,13,75,2,0,0,0,0,74,0,0,0,32,14,79,4,0,0,0,0,24,15,15,15,77,0,0,0,78,0,24,24,31,15,81,4,0,0,0,0,78,2,0,1,79,0,31,30,80,0,4,4,30,16,82,4,
	0,0,0,0,79,3,0,1,80,0,20,20,81,0,2,2,29,17,83,3,0,0,0,0,51,15,15,15,82,0,0,0,27,18,86,3,0,0,0,0,44,15,15,15,85,0,0,0,26,19,87,4,0,0,28,28,1,0,0,0,46,19,19,19,86,1,1,1,25,20,89,5,0,0,0,0,1,0,30,29,2,2,
	2,3,48,19,19,19,88,1,0,1,25,21,90,3,0,0,0,0,59,19,19,19,89,2,0,2,24,22,91,3,0,0,0,0,49,21,21,21,90,1,0,1,23,23,93,3,0,0,0,0,51,24,24,24,92,0,0,0,22,24,94,4,0,0,22,22,1,2,0,0,53,23,23,23,93,1,1,1,21,
	25,95,5,0,0,5,5,1,0,27,28,2,2,0,0,55,23,23,23,94,1,1,2,20,26,96,3,0,0,6,6,57,22,22,22,95,2,2,2,20,27,97,3,0,0,9,9,58,24,24,24,96,2,1,2,19,28,99,4,0,0,34,32,2,2,0,0,60,24,24,24,98,2,0,2,19,29,99,3,0,0,
	11,11,61,21,21,21,98,1,1,2,18,30,101,3,0,0,0,0,51,22,22,22,100,1,1,1,18,31,101,3,0,2,0,2,51,18,18,18,100,2,1,2,17,32,102,3,0,0,0,1,51,19,19,19,101,2,1,2,16,33,103,3,0,0,0,0,52,20,20,20,102,2,2,2,15,
	34,105,3,0,0,0,0,53,20,20,20,104,2,1,2,15,35,106,3,0,0,0,0,51,19,19,19,105,0,0,0,14,36,107,3,0,0,0,0,52,17,17,17,106,2,0,2,14,37,107,3,0,0,0,0,53,18,18,18,106,2,1,2,14,38,108,3,0,1,1,1,87,17,17,17,
	107,0,0,0,13,39,109,3,0,0,0,0,15,16,16,16,108,1,1,1,12,40,110,3,0,0,0,0,22,17,17,17,109,1,1,1,12,41,110,5,0,0,0,0,69,23,19,24,70,4,3,5,87,17,17,17,109,1,1,2,11,42,111,7,0,0,0,0,22,17,17,17,69,8,5,9,
	70,67,58,67,72,3,1,4,87,16,16,16,110,1,1,2,11,43,111,8,0,0,0,0,66,19,19,19,69,5,5,5,70,30,22,31,71,87,78,88,72,25,19,26,73,5,5,5,110,2,2,2,11,44,112,8,0,0,0,0,21,17,17,17,69,7,7,7,70,30,23,31,71,86,
	77,86,72,70,61,70,73,9,4,11,111,1,1,2,10,45,114,7,0,0,0,0,71,8,5,9,72,65,56,66,73,86,77,86,75,4,1,6,85,16,16,16,113,0,0,2,9,46,115,8,0,0,0,0,69,19,19,19,72,2,0,3,73,54,46,55,75,84,75,84,77,4,0,6,87,
	23,23,23,114,1,0,1,8,47,117,8,0,0,6,6,73,7,7,7,74,21,15,22,75,83,74,83,77,85,76,85,79,6,2,8,89,20,20,20,116,0,0,0,8,48,118,8,0,0,8,8,71,6,5,7,74,18,12,19,75,90,81,90,78,86,77,85,80,5,3,5,88,20,20,20,
	117,0,0,0,8,49,118,12,0,0,8,8,60,4,5,4,61,32,25,33,63,8,8,8,74,6,4,6,75,65,56,65,76,93,83,93,79,80,71,80,80,22,14,24,81,4,2,5,90,19,19,19,117,0,0,0,8,50,119,15,0,0,8,8,23,16,16,16,60,2,1,3,61,40,33,
	41,62,48,40,49,63,3,3,3,64,19,19,19,73,20,20,20,74,3,2,4,76,98,89,98,80,75,67,76,81,18,12,20,82,5,4,6,89,21,21,21,118,0,7,7,8,51,119,14,0,0,8,8,60,6,3,7,61,56,46,57,62,45,37,46,63,3,2,3,64,21,21,21,
	74,6,7,7,75,16,11,17,76,85,76,86,77,95,85,95,81,76,67,76,82,18,12,20,83,9,7,9,118,0,7,7,8,52,119,14,0,0,8,8,22,17,17,17,60,3,0,5,61,95,85,96,62,87,77,89,63,7,3,8,64,17,18,17,75,8,4,9,76,73,64,73,77,
	95,85,95,82,76,67,76,83,20,13,22,84,10,10,10,118,0,7,7,8,53,119,18,0,0,8,8,22,16,16,16,51,4,5,4,53,46,37,47,54,3,3,3,59,8,8,9,60,30,22,31,61,102,91,102,62,99,88,99,63,5,2,6,67,17,17,17,75,3,2,4,77,98,
	88,98,82,85,75,84,83,66,57,67,84,2,0,3,87,19,19,19,118,0,10,10,8,54,119,17,0,0,8,8,51,7,5,8,52,61,52,63,53,16,8,18,59,3,0,4,61,120,108,120,62,100,89,100,63,20,12,22,64,13,12,13,75,8,9,8,76,25,20,26,
	77,87,78,88,80,94,84,94,83,81,72,81,85,2,0,3,92,20,20,20,118,0,10,10,8,55,119,19,0,0,8,8,50,9,9,9,51,13,8,15,52,69,58,70,53,8,4,9,56,7,7,7,59,15,10,17,60,84,74,84,62,126,113,126,64,6,5,7,67,20,20,20,
	76,3,1,4,77,72,62,72,78,98,88,98,81,74,66,74,84,85,76,85,86,3,0,5,88,18,18,18,118,0,10,10,8,56,119,20,0,0,8,8,33,18,18,18,50,1,2,1,52,91,79,91,53,4,2,5,58,12,11,13,59,18,10,20,60,105,94,105,62,140,
	125,139,63,56,47,57,64,5,4,5,65,21,21,21,76,10,9,11,78,84,75,84,79,95,85,95,81,46,41,46,82,92,82,92,85,85,76,85,87,6,4,7,118,0,10,10,8,57,119,20,0,0,9,9,32,19,19,19,50,5,0,6,51,98,88,98,52,82,71,82,
	53,5,3,6,57,17,17,17,58,4,2,5,60,109,98,109,62,135,121,135,64,8,6,9,76,10,11,10,77,18,14,19,78,92,82,92,81,100,89,100,86,87,78,86,87,28,21,29,88,3,2,3,90,18,18,18,118,0,10,10,8,58,119,20,0,0,10,10,32,
	21,21,21,49,8,5,9,51,113,102,113,52,90,79,91,53,9,6,9,58,8,3,9,60,120,108,120,62,132,118,132,63,121,108,121,64,22,16,23,65,15,15,15,77,14,11,15,79,97,87,97,86,80,71,80,87,67,59,68,88,11,4,12,89,7,7,8,
	91,22,22,22,118,0,10,10,8,59,59,12,0,0,10,10,28,8,8,8,31,24,24,24,48,4,4,5,49,25,17,26,50,112,101,111,51,116,104,116,52,75,65,76,53,7,4,7,54,20,20,20,57,6,6,7,58,34,27,36,67,59,60,16,0,109,98,109,2,
	134,120,134,4,120,107,120,5,21,15,22,6,15,15,15,12,9,10,8,13,15,11,15,14,53,43,53,15,7,5,7,18,3,3,4,20,98,88,98,28,82,73,82,29,68,60,69,30,10,5,12,31,7,7,7,59,0,10,12,8,60,59,9,0,0,11,11,48,15,11,17,
	49,89,78,90,51,136,122,135,52,34,25,36,53,3,1,4,54,19,19,19,57,6,4,7,58,82,71,82,67,60,60,15,0,110,99,110,1,129,116,129,4,129,116,129,6,8,6,8,13,13,10,15,14,54,45,55,16,10,11,10,18,12,12,11,19,20,15,
	21,20,90,78,90,21,94,83,93,29,84,74,84,30,68,59,69,31,11,7,12,59,0,12,12,8,61,59,10,0,0,12,12,46,20,21,20,47,8,5,8,49,114,103,114,51,140,125,140,52,35,28,37,53,8,8,8,56,11,11,11,57,14,9,16,58,93,83,
	94,67,61,60,14,0,113,102,113,4,139,125,139,6,4,2,4,7,19,19,18,13,13,13,13,15,40,32,41,16,7,5,8,19,7,5,7,21,97,87,97,28,101,91,102,30,79,71,79,32,0,0,0,33,15,15,14,59,0,12,12,8,62,59,8,0,0,13,13,47,12,
	5,12,48,102,89,100,51,139,124,139,52,36,29,37,53,11,12,11,56,0,1,1,58,111,100,111,67,62,60,17,0,120,107,120,4,137,123,136,5,89,77,89,6,8,6,8,13,8,8,8,15,75,66,76,16,10,7,11,19,7,7,7,20,36,30,37,21,
	103,91,102,25,38,42,48,28,42,36,40,30,15,13,15,32,27,22,27,33,0,0,0,42,15,15,15,59,0,12,12,8,63,59,13,0,0,14,14,1,0,0,0,28,18,18,18,45,18,18,17,46,3,4,9,47,70,66,78,48,106,102,114,49,105,102,113,51,
	146,129,144,52,38,30,39,53,13,13,13,56,7,5,9,58,112,101,112,67,63,30,18,0,125,112,125,5,130,116,130,6,37,29,38,7,9,10,10,13,6,6,6,14,29,23,31,15,90,80,89,16,35,27,36,17,6,6,6,20,13,8,13,21,61,53,62,
	22,26,33,36,24,68,10,11,25,88,29,31,26,156,20,20,27,135,12,11,28,70,2,1,29,76,1,0,97,63,30,7,0,79,33,37,1,85,81,91,2,89,78,87,3,25,22,25,4,0,0,0,13,16,16,16,29,0,12,12,8,64,59,12,0,0,14,14,1,0,0,0,28,
	17,17,17,45,2,3,4,47,59,27,29,49,62,25,28,51,103,102,114,52,28,23,29,55,6,7,6,56,13,9,14,57,107,95,107,58,110,99,110,67,64,30,17,0,134,120,134,5,133,118,132,6,38,30,39,7,10,10,10,13,6,6,7,14,30,23,31,
	15,87,77,86,16,72,62,72,17,6,6,6,20,2,2,3,21,27,17,19,22,135,35,35,24,184,28,28,26,176,25,25,27,154,21,21,28,85,10,10,29,88,11,11,97,64,30,7,0,89,8,8,1,94,64,72,2,94,88,99,3,90,80,90,4,18,13,20,5,6,7,
	7,29,0,7,10,8,65,59,13,0,0,15,15,1,0,0,0,44,20,19,19,45,0,2,11,46,137,16,19,47,178,21,20,48,167,62,61,49,176,24,23,51,85,8,9,52,13,2,2,56,9,5,10,57,81,72,81,58,124,112,124,67,65,30,16,0,132,118,132,5,
	132,119,132,6,39,33,40,7,8,9,9,13,5,5,6,14,33,26,34,15,87,78,87,18,3,3,3,20,5,14,14,21,48,6,11,22,189,59,58,23,167,129,129,25,165,17,17,27,153,19,19,28,79,8,8,29,89,11,11,97,65,30,6,0,67,0,0,2,95,87,
	97,3,96,85,95,4,67,57,68,5,7,3,8,29,1,0,1,8,66,60,15,0,0,15,15,1,1,0,0,31,19,19,19,36,4,4,4,43,21,20,19,44,3,6,12,46,176,23,23,48,168,29,29,50,183,124,123,51,150,74,76,52,17,0,4,55,1,1,1,56,71,60,73,
	57,111,100,111,59,133,119,133,68,66,30,16,0,132,118,132,4,137,123,137,5,100,87,100,6,13,10,14,12,6,6,6,14,63,55,64,15,60,54,60,17,1,0,2,20,23,1,4,21,142,74,75,22,171,135,134,24,166,17,17,25,173,24,24,
	27,79,8,8,28,93,11,11,29,57,0,0,98,66,30,6,0,50,51,57,1,101,88,99,3,100,91,100,5,0,1,1,14,16,16,16,29,0,0,0,8,67,60,18,0,0,15,15,1,1,0,0,31,18,18,18,36,1,1,1,43,10,15,18,44,35,3,9,46,173,23,23,48,166,
	14,14,49,164,92,93,50,175,130,129,51,111,59,62,52,5,1,6,53,18,18,18,55,3,2,3,56,10,9,10,57,92,83,92,58,133,119,133,59,131,117,131,68,67,30,15,0,132,118,132,4,138,123,138,5,102,89,101,6,5,3,6,13,0,0,2,
	15,71,64,71,18,8,9,8,20,0,11,13,22,184,45,44,23,165,22,22,24,176,22,22,25,150,18,18,26,83,8,8,28,88,9,8,29,62,12,13,98,67,30,6,0,80,75,83,4,93,82,93,5,9,8,10,6,4,5,4,14,17,17,17,29,0,0,0,8,68,60,16,0,
	0,15,15,1,1,0,0,30,18,18,18,36,1,1,1,41,18,18,17,43,17,4,10,44,76,9,10,45,80,8,8,47,167,22,22,50,187,51,50,51,109,10,14,52,0,5,13,53,20,17,17,55,6,4,6,58,135,120,135,59,131,118,131,68,68,60,19,0,132,
	118,132,5,125,111,125,6,37,30,38,7,11,11,11,13,5,3,6,14,62,54,63,18,12,10,13,20,4,10,10,21,52,8,13,22,168,18,18,23,166,26,25,25,91,9,9,28,78,0,0,29,66,51,57,30,94,87,97,33,95,84,95,35,21,18,21,36,9,6,
	10,59,0,0,0,8,69,60,18,0,0,15,15,1,1,0,0,29,16,16,16,37,0,0,0,41,19,18,18,42,2,4,9,44,94,8,8,46,81,9,9,47,90,9,9,48,130,17,17,50,142,12,12,52,3,6,15,53,23,21,20,54,3,3,3,55,26,20,28,56,116,103,116,57,
	137,122,137,59,132,118,132,68,69,60,19,0,132,118,132,5,140,125,140,7,6,6,6,13,4,1,5,14,69,59,69,15,93,83,93,16,83,74,83,18,4,1,5,21,13,8,13,22,115,14,15,27,65,6,5,29,85,78,88,31,99,88,99,32,84,75,84,
	33,16,14,16,35,34,31,34,36,6,5,7,43,18,18,18,59,0,0,0,8,70,60,16,0,0,14,14,1,1,0,0,35,16,16,16,38,0,0,0,40,20,20,19,41,9,7,10,43,120,97,108,44,66,11,12,46,88,8,9,50,82,11,10,52,7,8,15,53,22,21,21,54,
	7,6,7,55,26,19,28,56,115,104,115,59,132,118,132,68,70,60,19,0,132,118,132,5,136,122,136,7,5,3,6,13,4,1,4,14,70,61,70,15,98,88,97,17,84,75,84,19,5,4,5,21,5,6,8,23,63,3,2,25,66,4,4,27,59,55,61,28,105,
	98,110,31,33,30,33,32,27,24,27,34,91,81,91,36,0,1,0,43,18,18,18,59,1,1,1,8,71,60,15,0,0,14,14,1,1,0,0,35,17,17,17,41,4,0,5,42,123,110,123,43,154,141,157,44,105,96,108,45,39,16,18,46,74,11,12,50,98,9,
	8,52,5,10,12,54,9,6,9,55,31,23,33,56,127,114,127,59,132,118,132,68,71,30,17,0,132,118,132,5,131,117,131,6,100,89,101,7,21,15,22,8,13,13,13,13,4,2,5,14,74,65,75,15,98,88,98,18,77,67,77,19,14,9,15,21,2,
	2,2,23,45,45,50,25,37,43,48,26,72,76,85,27,85,76,84,28,39,34,38,29,42,38,42,98,71,30,6,0,13,11,13,2,91,80,91,4,97,87,97,6,1,1,1,12,16,16,16,29,1,1,1,8,72,60,15,0,0,13,13,40,4,1,4,43,79,70,79,44,139,
	123,138,46,117,111,125,47,67,58,65,48,104,59,65,49,102,52,57,50,63,16,17,51,57,28,32,52,3,5,6,54,9,6,9,55,87,77,88,56,132,118,131,59,132,118,132,68,72,60,20,0,132,118,132,6,120,107,121,7,17,13,19,8,
	11,11,11,13,5,4,6,15,96,86,96,18,80,71,80,20,6,5,6,22,7,4,7,23,46,38,44,24,50,50,56,26,75,27,29,27,63,61,68,28,87,76,86,29,70,63,70,31,102,91,102,34,96,86,96,36,1,1,1,42,17,17,17,59,1,1,1,8,73,60,17,
	0,0,13,13,29,19,19,19,39,5,3,5,41,111,99,111,44,34,31,35,45,51,40,44,46,111,68,75,47,126,113,126,48,138,129,145,49,138,128,143,50,72,70,78,52,9,8,9,53,18,18,18,54,1,0,2,55,93,82,93,56,139,125,139,59,
	132,118,132,68,73,60,20,0,132,118,132,6,121,108,121,7,35,28,36,8,7,7,7,13,3,4,4,14,17,11,18,15,94,84,94,18,84,75,84,19,64,55,64,20,11,9,12,22,5,3,5,23,37,29,38,24,102,94,105,26,111,81,90,27,53,45,51,
	31,92,82,93,34,96,86,96,36,1,1,1,42,16,16,16,59,1,1,1,8,74,60,18,0,0,13,13,38,9,8,9,39,32,25,33,40,107,96,108,41,130,117,130,42,140,125,140,44,101,91,102,45,129,110,123,46,128,79,87,47,106,94,105,48,
	135,120,134,50,149,132,147,52,0,0,0,53,21,20,20,54,8,4,10,55,97,86,97,56,137,123,137,59,132,118,132,68,74,60,17,0,132,118,132,6,127,113,127,8,5,3,6,13,4,5,4,14,23,17,24,15,94,84,94,19,83,74,83,21,7,5,
	8,22,10,11,10,23,19,14,21,24,90,80,89,26,94,89,100,28,0,0,0,30,83,73,82,34,96,86,96,36,1,1,1,59,1,1,1,8,75,60,10,0,0,12,12,38,6,1,8,39,94,83,94,40,129,116,129,50,140,126,140,52,0,0,1,53,11,11,11,54,
	48,40,49,55,135,121,135,59,132,118,132,68,75,60,17,0,132,118,132,6,140,124,138,8,1,0,2,13,6,7,6,14,23,17,24,15,94,84,94,20,71,61,71,21,14,9,15,23,3,1,4,25,99,88,98,27,96,86,97,28,73,64,72,30,97,87,98,
	34,96,86,96,36,0,1,0,42,15,15,15,59,1,1,1,8,76,60,11,0,0,11,11,31,17,17,17,37,3,2,4,39,119,107,119,40,131,117,131,50,141,127,141,52,4,4,5,53,8,6,8,54,42,34,43,55,135,121,135,59,133,118,132,68,76,60,
	16,0,133,118,132,6,135,120,134,7,100,88,100,8,21,15,23,9,9,8,9,13,6,7,6,14,23,17,24,15,94,83,94,20,82,73,81,22,8,7,8,23,8,8,8,25,95,84,95,34,96,86,96,36,0,1,0,42,15,15,15,59,1,1,1,8,77,60,10,0,0,10,
	10,36,8,7,9,38,122,110,122,39,134,119,134,50,141,127,141,52,3,3,4,53,13,9,14,54,93,81,94,55,137,121,135,59,133,118,132,68,77,60,15,0,133,118,132,7,120,107,120,8,38,30,39,9,5,4,4,14,23,17,24,15,95,83,
	95,21,77,68,78,22,19,14,20,23,8,10,8,24,13,9,14,25,91,80,91,34,96,86,96,36,0,1,0,42,15,15,15,59,1,1,1,8,78,60,12,0,0,9,9,33,19,19,19,35,0,0,0,36,35,26,36,37,116,104,115,39,133,119,133,50,139,123,137,
	52,5,4,5,53,18,15,19,54,115,102,115,55,137,122,136,59,133,119,132,68,78,60,14,0,133,119,132,7,132,119,131,8,36,28,37,9,4,3,5,14,23,17,24,15,95,84,95,21,85,75,85,23,6,4,6,24,14,11,14,26,98,87,98,34,96,
	86,96,36,0,1,0,41,16,16,16,59,1,1,1,8,79,60,12,0,0,8,8,33,19,20,20,34,5,5,6,35,20,13,22,36,95,84,95,37,127,114,127,50,139,123,137,52,3,2,4,53,14,9,16,54,116,103,115,55,136,121,135,59,133,119,132,68,
	79,60,15,0,133,119,132,7,128,115,127,8,87,77,88,9,10,7,11,14,24,19,26,15,96,85,96,22,79,69,79,23,21,15,22,24,5,5,5,25,29,22,31,26,92,81,93,34,96,86,96,36,0,1,0,41,18,18,18,59,1,1,1,8,80,60,10,0,0,8,8,
	33,6,6,6,34,9,5,10,35,92,81,92,37,134,120,134,50,139,124,137,52,1,0,2,53,25,18,27,54,131,117,130,59,133,119,132,68,80,60,16,0,133,119,132,7,130,117,129,8,94,83,94,9,3,1,4,14,21,16,22,15,89,78,89,16,
	94,84,94,22,86,76,85,24,6,4,6,25,8,5,10,26,79,69,80,27,97,86,98,34,96,86,96,36,1,2,1,42,19,19,19,59,1,1,1,8,81,60,9,0,0,7,7,31,17,16,17,33,0,0,2,35,118,106,117,36,130,116,130,50,139,124,137,52,0,0,0,
	54,139,125,138,59,133,119,132,68,81,60,15,0,133,119,132,7,136,122,135,8,113,101,113,9,31,26,32,10,9,9,10,13,16,17,16,14,2,0,2,16,100,90,100,23,78,69,79,24,21,17,22,25,4,3,3,27,97,87,96,34,95,85,95,36,
	5,5,5,59,1,1,1,8,82,120,19,0,0,7,7,32,2,1,3,34,118,106,118,35,131,118,132,50,139,124,137,52,0,0,0,54,139,125,138,67,133,119,132,68,123,111,123,70,2,2,2,74,0,0,0,76,100,90,100,83,87,78,87,85,1,0,1,86,
	25,19,27,87,99,88,99,94,96,85,96,96,7,8,7,119,1,1,1,8,83,60,10,0,0,7,7,30,18,18,17,31,0,0,0,32,38,31,40,33,112,100,112,34,132,119,133,50,138,124,137,52,0,0,0,54,140,125,138,59,133,119,132,68,83,60,15,
	0,133,119,132,8,134,120,133,10,1,0,1,11,17,16,17,14,5,5,6,16,100,90,100,24,80,71,80,25,18,12,19,26,6,5,6,27,75,66,76,28,97,87,97,34,85,74,85,35,22,19,22,36,9,9,9,59,1,1,1,8,84,60,12,0,0,6,6,30,3,3,3,
	31,13,9,16,33,128,115,129,34,92,77,87,35,127,112,125,36,133,118,132,42,137,123,136,50,136,122,135,52,0,0,0,54,144,129,142,59,134,119,133,68,84,60,18,0,134,119,133,8,134,119,132,9,96,84,97,10,17,11,19,
	11,13,13,13,14,7,7,8,16,101,90,101,24,84,75,84,25,71,62,71,26,8,6,9,27,35,29,35,28,98,87,98,33,95,85,95,34,80,71,80,35,14,13,14,36,10,9,10,40,23,8,8,59,1,1,1,8,85,60,17,0,0,8,8,29,7,9,7,30,16,14,18,
	31,66,54,63,32,32,22,25,35,131,116,130,36,140,125,139,39,137,123,136,40,117,104,115,41,8,1,2,42,101,89,98,43,138,124,137,50,139,124,137,52,6,4,7,53,102,89,101,54,141,125,139,59,134,119,133,68,85,60,
	17,0,134,119,133,8,130,115,129,9,108,96,108,10,17,13,18,11,9,9,9,14,6,5,7,16,101,90,101,25,86,76,86,27,3,1,4,28,76,66,77,29,97,87,97,33,94,84,94,34,79,70,79,35,17,16,17,36,9,9,9,41,25,15,15,59,1,1,1,
	8,86,60,17,0,0,10,10,29,5,3,7,30,33,20,25,32,7,0,0,33,31,16,19,34,131,117,130,36,73,58,64,37,84,70,77,38,138,124,138,40,130,116,128,41,103,91,101,43,135,121,134,50,139,124,138,51,58,47,58,52,19,12,21,
	53,131,116,129,59,134,119,133,68,86,60,18,0,134,119,133,8,132,117,131,9,110,99,110,10,29,23,30,11,8,9,8,14,7,7,9,16,101,90,101,25,87,78,87,26,76,66,75,27,7,3,9,28,34,28,35,29,97,87,97,33,96,85,96,35,
	8,7,8,39,13,13,15,41,49,35,35,42,8,6,6,59,1,1,1,151,86,2,2,0,109,103,103,1,30,23,23,8,87,60,15,0,0,10,10,29,4,2,5,31,47,32,36,32,7,1,1,33,45,31,34,34,132,118,130,35,52,38,42,36,13,6,7,38,137,123,136,
	41,140,126,139,50,139,124,138,51,58,48,59,52,18,11,20,53,127,114,126,59,134,119,134,68,87,60,14,0,134,119,134,9,128,115,127,11,7,5,8,14,8,7,9,16,101,91,101,26,84,74,84,27,61,53,61,28,2,0,4,29,76,67,
	76,30,97,86,96,33,85,75,85,35,6,6,6,41,29,16,17,59,1,1,1,150,87,4,4,0,72,64,64,1,104,99,99,2,87,81,81,3,16,16,16,8,88,60,9,0,0,11,11,32,10,0,0,34,142,128,142,36,126,113,125,50,139,124,138,51,58,48,59,
	52,20,13,22,53,128,115,128,59,134,119,134,68,88,60,17,0,134,119,134,9,127,114,128,11,2,0,3,14,8,7,8,16,101,91,101,27,82,73,83,28,22,17,24,29,30,24,31,30,99,88,99,32,94,83,94,33,66,58,66,34,9,9,9,39,5,
	3,3,40,46,1,0,41,52,25,25,44,11,12,12,59,0,0,0,150,88,4,4,0,39,32,32,1,106,102,102,2,50,35,35,3,4,2,2,8,89,60,11,0,0,12,12,32,14,7,7,34,108,95,105,36,136,122,135,38,111,97,108,40,134,120,133,50,140,
	124,139,51,59,48,59,52,15,7,17,53,130,116,130,59,134,119,134,68,89,60,17,0,134,119,134,8,136,121,135,10,91,80,91,11,20,14,22,14,8,7,9,16,101,91,101,27,88,79,88,29,5,2,5,30,76,66,76,31,98,88,98,32,87,
	77,87,34,6,6,6,38,17,15,15,39,0,2,2,40,68,3,1,42,10,1,1,59,0,0,1,151,89,2,2,0,75,66,66,1,56,44,44,8,90,60,12,0,0,13,13,32,9,10,10,34,53,41,45,35,38,26,29,36,92,79,88,38,13,6,6,39,132,116,130,50,140,
	124,139,51,59,48,59,52,56,47,57,53,130,116,129,59,135,120,134,68,90,60,18,0,135,120,134,9,128,114,127,10,117,104,117,11,40,32,41,12,10,9,10,14,5,3,6,16,101,91,101,28,85,76,85,29,29,21,30,30,28,20,30,
	31,102,90,102,33,10,10,10,38,10,14,14,39,60,3,2,40,9,2,2,41,26,16,16,43,9,0,0,59,1,1,1,150,90,2,2,0,110,107,107,1,65,55,55,8,91,60,8,0,0,14,14,34,6,2,2,38,71,57,65,40,138,123,138,50,137,122,136,51,58,
	47,58,53,130,117,130,59,135,120,134,68,91,60,19,0,135,120,134,9,135,120,134,10,118,105,118,11,34,27,35,12,8,7,8,14,3,2,3,16,101,91,101,27,94,84,94,29,73,65,72,30,15,8,17,31,63,54,63,33,2,3,2,38,6,14,
	13,39,104,5,2,40,29,2,1,42,15,1,1,43,40,30,30,45,7,7,8,59,1,1,1,149,91,3,3,0,64,61,61,1,113,110,110,2,43,31,31,8,92,60,13,0,0,15,15,1,0,0,0,34,5,6,6,38,48,36,41,39,116,102,114,41,131,117,130,47,137,
	122,137,49,101,90,101,50,152,136,151,51,63,54,64,52,77,67,78,53,130,116,129,59,135,120,134,68,92,60,18,0,135,120,134,9,134,119,133,11,84,73,85,12,16,12,17,14,3,2,3,16,105,94,105,18,101,89,100,20,21,
	16,19,22,96,86,97,27,94,84,94,29,85,78,85,31,6,1,8,38,4,12,12,39,100,5,2,40,25,2,1,43,37,25,25,46,6,5,6,59,1,1,1,150,92,2,2,0,88,81,81,1,63,50,50,8,93,60,13,0,0,15,15,1,0,0,0,24,18,18,18,37,19,6,7,38,
	0,0,0,40,67,55,61,41,133,118,133,47,139,125,140,48,36,25,27,50,71,63,71,52,73,66,75,53,138,124,138,59,135,119,134,68,93,30,13,0,134,118,133,9,138,122,136,11,95,82,96,12,10,5,11,14,9,7,9,15,29,22,30,
	16,89,77,89,17,43,38,43,18,45,39,44,19,76,67,76,21,62,51,58,22,92,81,92,29,79,70,79,98,93,30,7,0,49,44,49,1,9,2,11,8,11,13,13,10,48,1,0,11,97,19,17,12,15,11,11,29,1,1,1,150,93,7,7,0,108,101,101,1,111,
	108,108,2,42,26,26,3,69,60,60,4,59,37,36,5,114,107,107,6,27,38,38,8,94,60,19,0,0,15,15,1,0,0,0,24,20,19,20,36,2,3,3,37,56,50,56,38,75,64,71,39,32,21,24,40,126,112,125,46,138,123,137,47,115,100,112,48,
	36,23,26,49,32,21,23,50,121,105,119,51,72,47,64,52,97,74,91,54,104,91,103,55,143,128,143,56,127,116,128,59,142,127,142,68,94,60,18,0,147,130,146,10,123,112,124,11,100,90,101,12,37,30,38,13,12,11,12,
	15,6,2,7,18,89,78,89,21,101,90,102,28,87,78,88,30,17,16,17,31,8,5,9,38,10,12,13,39,75,5,3,41,150,23,19,42,46,52,53,43,25,12,11,46,5,6,6,59,0,0,0,150,94,7,5,0,96,90,89,1,118,115,116,4,135,132,132,5,
	107,103,103,6,5,11,11,8,95,60,16,0,0,16,16,1,0,0,0,24,19,19,19,37,6,6,6,38,29,27,30,40,134,118,133,47,126,111,124,49,40,35,38,50,123,106,119,52,69,54,67,54,90,58,78,55,115,90,108,56,70,51,64,57,142,
	115,136,58,144,118,138,59,108,93,107,68,95,30,16,0,89,81,90,4,89,81,90,6,146,119,140,7,135,108,129,8,75,56,69,12,58,38,53,13,13,13,14,15,16,11,17,16,87,76,87,17,106,94,106,24,96,85,97,25,88,76,87,26,
	28,20,23,27,47,34,38,28,73,82,89,29,12,19,20,98,95,30,8,0,7,4,5,9,16,3,2,10,67,2,0,11,87,7,5,12,31,25,26,13,18,3,3,15,8,6,6,29,0,0,0,150,95,6,6,0,71,52,50,1,122,120,120,2,127,123,123,3,157,155,155,4,
	132,130,130,5,49,50,50,8,96,60,20,0,0,16,16,1,0,0,0,24,17,17,17,38,1,0,1,39,13,11,13,40,89,81,89,41,134,120,134,47,138,122,137,48,112,97,109,49,145,129,145,50,145,129,144,51,77,66,77,52,77,68,78,53,
	135,122,136,54,89,81,90,55,138,112,132,56,93,71,87,57,94,63,83,58,163,110,143,59,112,76,99,68,96,30,15,0,94,64,84,4,93,63,82,6,151,111,138,7,74,54,68,9,69,48,62,10,141,112,133,11,128,104,122,12,38,32,
	39,13,13,11,13,15,10,7,11,17,100,88,100,24,99,87,99,26,50,43,48,27,53,44,50,29,8,7,8,98,96,30,10,0,12,11,12,8,5,11,11,10,60,4,2,11,67,79,80,12,32,16,16,13,11,0,0,14,26,11,11,15,56,52,52,16,6,7,7,29,0,
	0,0,150,96,6,5,0,66,25,23,1,116,114,114,3,158,157,157,4,110,108,108,5,2,0,0,8,97,60,17,0,0,16,16,1,0,0,0,39,5,4,5,40,13,12,13,41,90,81,91,42,139,124,138,45,140,124,140,47,110,95,106,48,146,130,146,49,
	131,116,130,50,145,129,145,51,78,66,78,52,78,67,78,53,132,118,131,54,148,131,147,56,127,116,128,59,144,126,142,68,97,60,17,0,142,123,140,10,135,121,135,12,103,91,103,13,21,14,22,15,8,7,7,16,38,30,39,
	17,103,92,103,24,96,84,96,29,11,10,11,38,4,10,10,39,36,13,12,40,124,4,3,41,71,58,58,44,35,22,22,45,80,77,77,46,7,8,8,59,0,0,0,150,97,6,5,0,70,29,26,1,116,114,114,3,151,149,149,4,114,110,109,5,25,5,3,
	8,98,60,14,0,0,16,16,1,0,0,0,41,15,14,15,42,49,44,49,43,124,110,124,44,150,133,150,45,100,85,95,46,3,0,0,48,145,129,145,50,145,130,145,51,79,67,79,52,79,69,80,53,133,119,133,59,131,115,130,68,98,60,
	20,0,63,51,57,1,125,110,123,2,138,123,137,10,140,123,139,12,107,95,107,13,22,16,23,15,11,10,11,16,46,37,47,17,106,94,106,23,96,85,96,27,10,10,10,39,7,12,12,40,102,7,4,41,57,3,3,42,62,39,39,43,122,122,
	123,44,35,22,22,45,96,89,89,47,0,0,0,59,0,0,0,150,98,6,5,0,54,28,26,1,118,115,115,3,143,141,141,4,110,108,108,5,0,3,3,8,99,60,12,0,0,16,16,1,0,0,0,42,8,8,8,43,26,24,26,45,130,114,129,46,100,86,97,48,
	138,123,139,50,147,131,146,51,73,61,74,52,75,65,76,53,134,120,134,59,138,122,137,68,99,60,19,0,143,126,142,10,139,123,138,12,114,101,114,14,8,6,9,16,20,15,21,17,84,73,84,18,100,89,100,22,96,86,96,25,
	20,18,20,26,16,16,16,39,2,15,16,40,84,17,14,41,34,0,0,42,30,30,31,43,87,77,78,44,7,0,0,46,38,32,32,47,8,9,9,59,0,0,0,150,99,6,5,0,25,26,26,1,118,115,115,3,142,139,139,4,108,105,105,5,3,3,3,8,100,59,9,
	0,0,16,16,1,0,0,0,44,12,11,12,46,125,111,126,47,142,127,142,50,141,125,140,52,95,84,95,54,140,123,139,58,138,122,137,67,100,60,19,0,138,122,137,12,134,118,133,14,80,68,81,15,7,4,7,16,23,22,23,17,9,6,
	10,18,80,67,80,19,103,91,103,22,99,87,99,26,13,12,13,40,2,16,17,41,98,15,12,42,127,3,0,43,0,5,5,45,17,5,5,47,94,88,88,48,15,17,17,49,3,3,3,59,1,1,3,150,100,6,5,0,26,26,26,1,118,115,115,3,136,133,133,
	4,108,105,105,5,3,3,3,8,101,59,10,0,0,15,15,1,0,0,0,41,19,18,19,45,5,5,5,46,28,25,28,47,116,103,116,48,141,124,140,51,144,127,143,52,125,110,124,58,138,122,138,67,101,59,18,0,138,122,138,12,133,117,
	133,14,91,79,91,15,19,14,20,17,15,12,15,19,103,91,103,21,93,82,93,24,14,12,14,40,15,16,16,41,22,15,16,42,112,8,4,43,52,0,0,45,121,123,124,46,135,130,132,47,123,121,122,48,31,31,31,49,3,3,3,58,2,2,2,
	150,101,6,5,0,29,26,26,1,120,117,117,3,132,129,129,4,109,107,107,5,3,3,3,8,102,59,8,0,0,15,15,1,0,0,0,25,21,20,21,46,12,11,12,47,20,16,20,49,120,106,120,50,140,124,139,58,139,123,138,67,102,60,16,0,
	139,123,138,12,139,124,138,14,120,106,119,15,38,30,40,16,14,13,14,18,19,13,20,19,94,83,94,22,19,18,19,23,13,13,13,41,9,15,16,43,80,1,1,44,135,60,56,45,126,132,133,47,133,130,131,49,1,1,1,59,0,12,14,
	150,102,6,5,0,31,28,28,1,118,115,115,3,132,129,129,4,109,107,107,5,5,5,5,8,103,59,7,0,0,15,15,2,0,0,0,25,22,22,22,48,7,5,7,49,23,19,23,51,132,118,132,58,139,123,138,67,103,60,18,0,140,123,139,12,142,
	125,141,14,115,101,115,16,6,3,7,19,44,39,44,21,6,5,6,40,12,14,15,41,30,14,13,42,12,11,12,43,36,6,6,44,164,6,1,45,129,113,112,46,128,129,130,47,133,129,130,48,108,106,106,49,16,16,16,58,3,1,2,59,2,17,
	17,151,103,5,4,0,112,109,109,2,132,129,129,3,108,106,106,4,0,0,0,8,104,119,19,0,0,14,14,2,0,0,0,25,22,21,22,50,11,8,11,53,137,122,137,54,142,125,141,71,142,125,141,74,101,87,101,75,37,28,38,79,8,8,8,
	101,9,13,13,103,99,4,1,104,90,71,70,105,128,129,129,107,133,131,131,108,51,51,51,109,5,5,5,117,3,1,2,118,2,17,17,151,104,5,5,0,78,77,77,1,125,122,122,2,130,126,126,3,114,112,112,4,32,31,31,8,105,119,
	20,0,0,12,12,34,24,22,24,51,14,11,14,52,17,13,17,55,136,121,136,56,148,125,142,72,146,128,146,73,125,110,125,75,33,25,34,77,14,11,14,101,10,13,13,102,27,13,13,103,99,1,0,104,38,22,22,105,101,99,99,
	107,134,132,132,108,107,105,106,109,16,15,16,117,3,2,3,118,2,20,22,151,105,5,5,0,83,83,83,1,125,122,122,2,129,126,126,3,122,119,119,4,58,57,57,8,106,59,8,0,0,11,11,18,5,5,5,20,20,20,20,54,15,13,16,55,
	56,43,51,56,68,101,109,57,130,122,138,58,147,120,137,67,106,60,16,0,143,126,143,11,144,127,143,13,60,52,60,14,52,45,52,15,13,11,13,42,9,13,14,43,32,12,12,44,157,9,4,45,33,1,1,46,66,61,61,47,130,129,
	129,49,134,132,132,50,55,54,54,51,4,4,5,58,3,2,3,59,2,20,25,151,106,5,4,0,87,87,87,2,129,126,126,3,109,107,107,4,0,0,0,8,107,59,9,0,0,10,10,18,4,4,4,20,21,20,21,48,14,12,14,52,37,31,37,55,14,3,8,56,3,
	52,54,57,54,56,65,58,86,113,123,67,107,60,18,0,116,101,115,1,147,129,146,8,142,126,142,9,130,115,130,12,30,25,30,14,41,35,41,16,12,7,13,31,24,22,24,43,2,11,12,44,87,9,7,45,67,2,0,46,116,76,76,47,127,
	128,128,49,133,131,131,50,108,106,106,51,13,13,13,58,4,2,3,59,2,22,25,151,107,5,3,0,96,94,94,3,112,110,110,4,3,3,3,8,108,59,11,0,0,9,9,41,12,11,12,44,28,26,28,48,14,12,14,50,19,14,19,51,64,54,64,52,
	74,64,74,55,31,22,29,56,32,49,55,57,15,16,20,58,1,26,28,67,108,60,19,0,18,15,18,4,148,131,148,7,103,91,103,8,59,50,59,10,42,36,42,13,80,70,80,14,70,61,70,15,22,18,22,16,15,11,15,41,9,15,17,42,47,11,
	10,44,39,10,9,45,89,4,2,46,48,12,12,47,112,111,112,50,133,130,130,52,0,0,0,58,4,2,3,59,2,25,27,151,108,5,5,0,89,86,86,1,98,93,93,2,74,68,68,3,117,115,115,4,1,1,1,8,109,59,8,0,0,8,8,27,11,9,11,28,25,
	24,25,48,15,12,15,49,17,12,17,51,74,64,74,55,75,66,75,58,55,41,49,67,109,60,18,0,51,43,51,2,39,33,39,3,64,55,64,5,69,60,69,6,39,33,39,11,80,70,81,14,67,58,67,16,16,14,16,33,22,20,22,46,16,0,0,47,69,
	41,42,48,128,130,131,50,135,133,133,51,113,111,112,52,20,19,19,53,4,4,4,58,3,1,3,59,5,27,30,150,109,6,5,0,0,0,0,2,124,121,121,3,137,134,134,4,115,113,113,5,1,1,1,8,110,119,19,0,0,7,7,35,27,26,27,49,
	14,10,14,51,76,66,76,61,80,69,80,63,62,53,62,66,80,69,80,70,56,46,55,73,75,64,75,75,16,15,16,104,5,10,12,105,63,9,7,106,55,3,2,107,119,83,83,108,147,146,147,109,158,155,155,113,6,6,6,117,4,0,4,118,5,
	27,30,150,110,6,6,0,1,0,0,1,87,84,84,2,129,126,126,3,141,139,139,4,111,110,110,5,1,1,1,8,111,119,20,0,0,6,6,35,28,26,28,48,19,17,19,49,21,17,21,50,66,57,66,51,73,63,73,63,79,69,80,70,64,54,63,73,77,
	66,77,75,13,10,12,104,9,12,12,106,56,1,0,107,70,32,31,108,127,130,132,109,148,145,145,110,75,66,66,112,111,107,108,113,7,6,6,117,7,2,5,118,2,30,32,150,111,6,5,0,7,5,5,1,94,91,91,3,164,162,162,4,125,
	122,122,5,0,0,0,8,112,59,6,0,0,6,6,26,26,25,26,48,20,18,20,49,22,18,22,50,71,62,71,58,74,64,74,67,112,60,18,0,74,64,74,4,55,44,52,5,75,64,75,14,76,66,76,17,18,15,18,44,10,15,16,45,44,10,9,46,21,9,9,
	47,76,8,6,48,76,8,8,49,94,93,95,50,100,91,92,51,39,26,27,52,114,109,109,53,106,101,101,55,3,3,3,58,7,2,6,59,2,30,32,150,112,6,4,0,15,14,14,1,100,97,97,3,165,163,163,5,0,0,0,8,113,59,4,0,0,6,6,49,22,
	19,22,50,69,59,69,58,74,64,74,67,113,60,18,0,75,64,75,3,77,67,77,4,57,47,55,6,77,66,77,14,76,65,76,17,16,14,16,46,11,10,11,47,52,9,9,48,32,8,8,49,80,4,2,50,48,42,43,51,137,133,134,52,138,136,136,54,
	133,129,130,55,26,25,25,56,0,0,0,58,6,2,5,59,0,32,32,150,113,5,4,0,23,22,22,1,116,114,114,3,145,142,142,4,40,38,38,8,114,119,16,0,0,6,6,19,6,6,6,20,21,20,21,49,17,13,17,51,80,69,80,73,77,67,77,76,21,
	18,21,107,4,13,14,108,102,9,6,109,100,55,54,110,26,21,22,112,134,131,131,114,102,99,100,115,13,12,12,117,7,3,5,118,0,35,32,150,114,5,5,0,18,18,18,1,99,96,96,2,143,140,140,3,136,133,133,4,49,46,46,8,
	115,119,19,0,0,6,6,19,6,6,6,20,21,20,21,32,11,9,11,35,27,25,27,49,17,14,17,53,76,65,76,73,77,66,77,74,72,62,72,75,28,23,28,77,21,16,22,108,19,8,8,109,85,54,55,110,81,78,79,112,135,133,133,113,118,116,
	116,114,135,131,131,116,0,0,0,118,0,35,32,150,115,5,5,0,18,16,16,1,101,98,98,2,138,135,135,3,132,128,128,4,46,46,46,8,116,119,19,0,0,6,6,24,23,23,23,32,11,9,11,35,29,27,29,49,17,14,17,50,42,35,42,51,
	16,9,13,53,80,70,80,73,79,68,79,76,27,22,27,78,18,11,19,109,7,12,12,110,87,84,84,111,130,127,128,113,132,129,129,115,127,122,123,116,44,41,42,117,3,0,2,118,4,39,39,150,116,5,4,0,30,28,28,1,125,122,
	122,3,136,132,132,4,50,48,48,8,117,59,11,0,0,7,7,29,26,24,26,32,13,12,13,36,33,31,33,41,16,10,18,48,30,27,30,49,16,13,16,50,46,39,46,51,21,13,17,53,70,59,70,58,76,65,76,67,117,59,14,0,77,65,77,13,78,
	67,78,19,22,15,23,23,16,13,16,46,14,13,14,48,42,8,8,49,12,14,14,51,9,8,8,52,83,80,80,53,126,121,122,54,131,127,127,56,128,123,124,57,105,102,103,58,2,1,2,150,117,5,5,0,28,25,25,1,121,117,117,2,133,
	129,129,3,124,120,120,4,35,35,35,8,118,119,19,0,0,8,8,19,6,6,6,36,32,30,32,45,18,15,18,48,22,19,22,50,68,58,68,51,21,13,17,54,77,66,77,72,80,68,79,73,29,18,24,77,73,62,72,79,20,10,23,80,38,30,38,83,
	15,12,15,110,13,12,12,111,23,21,21,112,116,112,113,116,133,128,129,118,0,20,18,150,118,5,5,0,25,22,22,1,118,113,113,2,138,134,134,3,88,85,85,4,0,0,0,8,119,59,7,0,0,8,8,40,28,25,28,46,14,12,14,48,51,
	43,51,52,57,46,54,53,78,68,79,58,78,67,78,67,119,60,16,0,78,67,78,13,77,66,77,15,21,10,14,16,29,21,26,17,77,66,78,18,78,67,78,19,76,65,76,20,23,14,24,22,65,55,65,25,17,13,17,52,12,11,11,53,46,43,44,
	54,120,116,117,56,135,130,131,58,124,114,114,59,27,81,81,150,119,5,4,0,2,2,2,2,143,140,140,3,87,84,84,4,2,2,2,8,120,60,10,0,1,8,8,27,24,24,24,44,14,12,14,46,27,23,27,48,76,66,76,50,54,44,52,51,75,65,
	75,52,56,45,54,53,77,65,77,59,78,67,78,68,120,60,15,0,78,67,78,13,83,72,84,16,57,49,57,18,80,68,80,20,26,15,28,21,81,70,81,27,18,15,18,50,19,17,18,52,0,0,0,54,137,132,133,55,86,82,82,56,65,62,62,57,
	138,133,132,58,117,121,121,59,0,0,0,149,120,6,4,0,0,0,0,3,131,126,126,4,96,93,93,5,0,0,0,8,121,60,9,0,1,8,8,36,30,28,30,44,16,14,16,47,78,67,78,50,83,72,83,51,46,37,44,52,49,38,47,53,81,70,82,59,79,
	67,79,68,121,61,18,0,79,67,79,14,80,69,80,16,64,55,64,18,82,70,81,20,30,19,31,21,78,67,78,24,77,67,77,27,49,39,46,28,41,49,56,29,21,22,31,52,11,9,9,53,16,14,14,54,102,97,98,55,98,93,93,56,8,4,6,57,
	102,97,99,58,133,127,127,60,0,0,0,149,121,6,5,0,0,0,0,2,137,133,133,3,131,126,126,4,43,40,40,5,0,0,0,8,122,61,7,0,1,8,8,30,13,11,12,36,30,27,30,42,15,10,16,46,117,103,117,51,65,54,64,60,80,67,80,69,
	122,61,15,0,80,68,80,18,78,67,78,19,43,32,44,20,76,64,76,26,78,68,78,27,71,62,72,28,26,19,28,50,26,23,24,52,8,5,6,53,17,14,15,54,108,102,102,56,45,40,45,57,129,118,119,58,137,131,131,60,0,0,0,149,122,
	6,6,0,0,0,0,1,91,87,87,2,138,133,133,3,136,132,132,4,15,13,13,5,0,0,0,8,123,61,8,0,1,8,8,30,12,10,11,37,30,27,30,42,14,9,14,45,114,100,114,48,117,102,117,51,79,68,79,60,80,68,80,69,123,62,17,0,80,69,
	80,18,82,71,82,19,37,26,38,21,81,69,81,27,78,67,78,28,32,23,32,29,25,21,24,50,27,24,25,53,9,5,7,54,54,50,51,55,141,136,136,56,86,78,79,57,53,71,71,58,132,131,130,59,122,115,115,60,13,12,12,61,6,6,6,
	149,123,5,4,0,0,0,0,2,150,146,146,3,134,128,128,4,22,19,19,8,124,61,9,0,1,8,8,42,18,13,19,43,33,22,34,44,20,11,14,45,107,93,107,46,114,99,114,50,117,102,117,53,77,66,77,60,81,69,81,69,124,62,16,0,82,
	69,82,18,82,70,81,20,52,41,53,21,82,70,82,25,72,62,72,26,48,38,44,27,75,63,73,28,34,25,34,29,20,17,20,54,12,9,10,56,128,116,115,57,43,99,99,58,109,114,114,59,134,125,125,60,105,98,98,61,0,0,0,149,124,
	5,5,0,9,7,7,1,98,93,93,2,137,130,130,3,125,119,119,4,32,28,28,8,125,62,8,0,1,8,8,42,19,15,19,43,25,16,26,44,102,89,101,45,116,101,116,52,118,103,118,56,77,66,77,61,82,69,82,70,125,62,14,0,82,69,82,17,
	82,70,81,19,54,43,55,20,82,71,82,26,76,65,75,27,34,25,35,28,23,19,22,49,28,25,25,54,2,0,0,56,134,125,124,57,66,60,60,59,132,125,125,60,47,42,42,61,3,1,1,149,125,5,4,0,50,46,46,1,128,122,122,2,133,127,
	127,4,16,15,15,8,126,62,7,0,1,8,8,42,17,14,17,43,37,29,38,44,119,104,119,54,120,104,120,58,79,66,79,61,82,69,82,70,126,63,15,0,83,69,83,18,81,70,81,19,47,36,48,21,80,68,80,26,77,66,76,27,34,25,35,28,
	24,20,23,43,13,9,11,49,29,26,26,54,11,5,8,55,15,10,13,56,110,100,99,60,132,125,125,61,17,13,13,62,0,0,0,149,126,4,4,0,51,46,46,1,131,124,124,2,141,134,134,3,71,66,66,8,127,125,20,0,1,7,7,37,31,28,30,
	42,19,15,19,43,35,27,36,44,116,101,116,56,121,105,121,59,81,68,81,80,82,65,76,81,54,43,55,83,80,69,80,88,77,66,76,89,35,26,35,91,21,18,20,111,31,27,27,117,5,0,0,118,19,62,62,119,112,113,113,121,156,
	149,149,123,89,82,82,124,8,7,7,148,127,5,5,0,0,0,0,1,39,34,34,2,131,124,124,3,135,128,128,4,62,57,57,8,128,63,7,0,1,6,6,35,29,26,29,43,20,11,21,44,87,72,88,45,122,106,122,58,123,106,123,62,85,71,85,
	71,128,63,16,0,83,70,83,14,77,74,87,15,105,49,55,17,79,69,83,25,77,66,77,26,35,26,35,28,21,17,20,48,29,25,25,54,10,0,1,55,2,61,61,56,22,27,27,57,116,105,105,58,141,136,136,60,142,134,134,61,51,45,45,
	62,0,0,0,148,128,5,4,0,3,1,1,2,139,131,131,3,113,106,106,4,5,1,1,8,129,63,5,0,2,6,6,42,28,24,27,43,12,7,12,45,118,103,117,62,120,104,120,71,129,63,18,0,110,94,110,3,84,70,84,13,75,73,88,14,110,50,59,
	15,96,32,38,16,75,70,83,25,75,64,75,26,35,26,35,28,22,17,20,36,16,8,15,48,26,21,23,54,8,0,0,55,10,65,64,56,0,4,4,58,126,118,118,60,138,129,129,61,116,108,108,62,33,27,27,148,129,5,5,0,8,5,5,1,113,106,
	106,2,140,132,132,3,118,111,111,4,12,7,7,8,130,63,5,0,2,5,5,38,26,23,26,43,13,7,12,45,118,102,118,62,123,105,123,71,130,64,19,0,125,107,125,4,116,99,116,7,82,68,82,12,74,71,85,13,117,51,60,14,119,20,
	22,15,65,64,75,25,85,73,85,26,37,27,37,27,28,23,26,33,18,14,16,48,27,20,22,54,6,0,0,55,8,61,61,56,9,12,12,57,3,0,0,59,134,125,125,61,134,126,126,63,0,4,4,148,130,5,5,0,11,3,3,1,109,101,101,2,140,131,
	131,3,101,94,94,4,8,5,5,8,131,64,4,0,2,4,4,43,17,13,17,45,116,100,115,63,123,105,123,72,131,64,17,0,122,105,122,10,106,97,114,11,110,77,89,12,131,17,19,13,96,70,82,14,107,95,110,24,123,107,122,25,43,
	33,43,27,23,17,21,50,31,25,26,53,22,0,0,54,6,65,65,55,8,13,13,57,2,0,0,59,137,127,127,61,131,118,118,63,0,21,21,148,131,5,5,0,9,1,1,1,109,101,101,2,141,132,132,3,44,38,38,4,0,0,0,8,132,64,6,0,3,4,4,
	43,24,19,24,44,29,18,31,45,108,93,107,46,115,99,114,63,123,106,123,72,132,65,20,0,124,106,124,9,122,106,124,10,122,99,115,11,127,39,44,12,99,71,83,13,128,116,135,24,122,105,121,25,43,33,43,27,23,18,
	22,50,31,23,24,52,12,5,8,53,57,3,4,54,33,38,38,55,12,7,7,58,2,0,0,60,137,127,127,61,139,126,126,62,116,116,116,63,13,15,16,64,2,0,0,147,132,6,6,0,0,0,0,1,51,44,44,2,129,120,120,3,143,133,133,4,51,44,
	44,5,0,0,0,8,133,129,20,0,3,4,4,44,23,13,23,45,113,96,112,46,124,107,123,48,108,93,107,73,123,108,126,75,92,57,68,76,125,114,131,88,122,105,121,89,43,33,44,90,23,19,21,114,31,22,23,116,12,4,7,118,64,
	2,2,120,16,1,2,123,2,0,0,125,135,125,125,126,142,130,130,127,105,91,92,128,15,9,9,147,133,6,5,0,0,0,0,2,142,131,131,3,126,117,117,4,39,33,33,5,2,0,0,8,134,131,18,0,3,4,4,44,25,16,25,45,116,98,115,46,
	123,107,122,75,128,113,131,88,121,104,120,89,43,33,44,90,21,17,20,114,31,22,23,116,12,4,7,118,63,8,8,124,0,0,0,125,85,76,75,126,139,128,128,127,141,128,129,128,88,76,77,129,3,0,0,130,11,4,4,147,134,5,
	4,0,2,2,2,2,145,134,134,3,96,86,86,4,0,0,0,7,135,133,20,0,3,5,5,45,21,12,21,46,98,82,98,47,125,109,124,74,128,110,128,89,124,107,123,90,45,34,45,91,22,17,20,115,30,21,22,117,12,4,7,118,55,6,8,119,63,
	7,7,123,44,4,4,125,12,2,2,126,41,24,24,127,122,110,110,129,138,124,125,130,48,36,36,131,0,0,0,132,15,6,6,147,135,5,5,0,35,27,27,1,124,112,112,2,140,129,129,3,99,89,89,4,2,0,0,7,136,66,6,0,4,4,4,40,28,
	23,26,45,16,8,15,46,58,45,58,47,129,113,128,65,127,109,127,73,136,67,15,0,128,109,128,22,122,105,121,23,112,95,111,24,39,28,38,25,24,19,22,49,29,19,19,51,13,3,7,52,57,6,8,53,64,7,7,60,31,0,0,61,55,31,
	31,62,122,109,110,64,139,125,125,65,51,39,39,66,1,0,0,147,136,5,5,0,34,24,24,1,128,116,116,2,146,134,134,3,105,94,94,4,0,0,0,6,137,134,17,0,4,0,0,46,20,13,20,47,56,43,56,48,130,113,129,89,130,112,128,
	91,18,8,18,94,35,29,32,97,18,12,14,118,15,4,7,119,58,6,8,120,64,7,7,128,28,0,0,129,55,30,31,130,128,114,115,131,141,126,127,132,131,116,116,133,57,41,41,147,137,5,5,0,36,24,24,1,127,115,115,2,141,129,
	129,3,55,45,45,4,0,0,0,6,138,135,19,0,4,2,2,46,20,11,20,47,57,44,57,48,130,113,129,74,129,111,129,89,128,111,127,91,22,11,21,94,36,30,34,101,22,8,18,116,29,18,19,118,14,4,7,119,58,6,8,120,64,7,7,129,
	25,0,0,130,53,28,29,131,126,112,112,132,146,131,131,133,94,76,76,134,0,0,0,147,138,5,5,0,28,17,17,1,132,118,118,2,138,123,123,3,26,15,15,4,0,0,0,6,139,137,15,0,4,0,0,46,20,13,18,47,57,44,57,48,130,
	113,129,89,125,107,123,90,100,83,98,91,31,20,30,92,28,21,25,118,15,3,7,119,58,6,8,120,65,7,7,130,24,0,0,132,142,129,129,135,18,3,3,136,8,2,2,146,139,6,5,0,0,0,0,2,139,124,124,3,137,123,123,4,32,21,21,
	5,0,0,0,6,140,137,19,0,4,0,0,37,33,26,29,46,21,15,19,47,57,44,57,48,130,112,129,90,119,101,117,91,40,27,38,92,21,15,19,94,37,30,33,102,20,5,15,104,28,19,21,118,16,3,7,119,59,6,8,120,66,7,6,130,32,4,5,
	131,29,6,6,132,110,93,93,134,164,148,148,136,10,3,3,146,140,5,5,0,4,0,0,1,99,85,85,2,145,130,130,3,140,127,127,4,35,23,23,6,141,138,19,0,6,2,2,46,19,13,17,47,58,44,57,48,129,112,128,72,130,111,130,90,
	125,107,123,91,41,28,39,92,19,13,16,94,37,29,32,100,18,8,13,101,61,45,55,103,19,9,12,118,17,3,8,119,59,6,8,120,67,6,6,131,23,0,0,133,131,115,115,135,151,133,133,137,5,0,0,146,141,5,5,0,4,0,0,1,95,81,
	81,2,149,133,133,3,107,92,92,4,22,15,15,6,142,69,6,0,6,2,2,37,31,24,27,46,18,11,16,47,59,45,58,48,130,112,128,68,131,111,130,75,142,69,18,0,131,112,130,21,124,106,122,22,40,28,39,23,19,13,16,25,36,28,
	31,31,18,6,13,32,66,49,60,33,55,39,50,34,16,6,10,35,30,21,23,49,18,2,9,50,60,6,8,51,68,6,6,63,17,0,0,64,99,77,77,65,139,122,122,67,158,141,141,68,57,42,42,146,142,4,4,0,4,0,0,1,95,79,79,2,152,136,136,
	3,78,64,64,6,143,69,8,0,6,2,2,6,7,0,0,10,32,3,3,14,10,4,5,46,21,14,19,47,60,46,58,48,130,112,128,68,130,111,130,75,143,70,19,0,130,111,130,21,124,106,122,22,40,28,38,23,19,13,16,25,34,27,31,31,24,10,
	20,32,71,54,64,34,18,7,11,47,31,17,17,49,19,2,8,50,61,6,8,51,69,7,7,63,29,1,1,64,47,20,20,65,124,104,104,66,132,114,114,67,103,93,93,68,52,38,38,69,54,39,39,146,143,4,4,0,48,33,33,1,130,113,113,2,149,
	132,132,3,86,71,71,6,144,72,8,0,13,4,4,6,15,4,5,12,48,4,5,15,14,3,7,46,21,14,18,47,61,45,59,48,130,112,128,71,129,110,128,78,144,36,9,0,129,110,128,18,125,106,122,19,41,27,38,20,20,13,16,27,24,16,18,
	28,41,26,35,29,86,69,78,31,18,4,12,35,24,12,14,114,144,36,15,0,24,12,13,10,20,2,8,11,63,6,7,12,71,7,7,25,19,0,0,26,65,39,39,27,148,130,130,28,123,105,105,29,57,40,40,30,93,75,75,31,47,34,34,32,54,38,
	38,33,144,126,126,34,150,132,132,35,86,72,72,6,145,72,9,0,13,4,4,14,61,5,6,15,59,6,7,17,11,5,7,26,30,20,21,46,21,14,18,47,60,44,57,48,129,111,126,71,128,110,128,78,145,36,10,0,128,110,128,18,125,106,
	122,19,41,27,38,20,21,14,17,27,22,13,14,28,38,21,31,29,83,66,76,30,75,60,70,31,27,12,20,35,24,12,14,114,145,36,13,0,28,15,17,10,20,2,8,11,64,6,8,12,72,6,7,26,29,4,4,28,144,125,125,29,137,118,118,30,
	63,46,46,31,76,57,57,32,59,42,42,33,144,125,125,34,131,113,113,35,35,20,20,6,146,72,8,0,8,0,0,15,67,7,7,19,17,7,8,24,33,22,23,46,21,13,17,47,64,48,61,48,133,114,130,71,128,109,127,78,146,72,19,0,128,
	109,127,18,126,106,122,19,40,27,37,20,24,16,19,27,27,15,19,29,80,64,73,30,73,36,43,31,27,8,14,46,25,2,9,47,67,6,7,48,72,6,7,62,29,0,0,63,32,9,9,64,146,124,124,65,143,121,121,67,33,16,16,69,144,123,
	123,70,129,109,109,71,20,1,1,6,147,72,8,0,11,2,2,17,81,8,8,19,16,5,8,45,24,16,20,47,39,24,37,48,114,95,110,49,125,107,122,71,127,109,126,78,147,72,20,0,127,109,126,18,126,106,122,19,40,27,37,20,22,15,
	18,27,30,16,24,28,70,47,56,29,81,18,20,32,22,12,14,45,22,10,12,47,81,8,7,62,35,3,3,63,16,1,1,64,51,39,39,65,146,126,126,66,147,125,125,67,62,43,43,68,45,27,27,69,149,129,129,70,129,109,109,71,25,10,
	10,6,148,72,10,0,10,2,2,18,84,9,9,19,35,6,9,20,16,7,8,24,36,24,25,46,29,20,24,47,16,2,14,48,97,79,94,49,129,110,126,71,127,109,126,78,148,72,19,0,127,109,126,18,126,106,121,19,41,26,38,20,21,10,17,27,
	24,13,19,28,89,13,17,29,101,12,14,31,29,7,16,32,22,10,14,45,23,10,11,47,83,8,7,62,34,2,2,64,10,7,7,65,114,97,97,66,151,127,127,68,97,77,77,69,143,121,121,70,111,91,91,71,20,5,5,7,149,71,9,0,9,8,8,18,
	85,9,9,19,27,6,10,20,20,11,11,44,31,22,26,46,20,6,17,47,101,82,97,48,129,109,124,70,126,109,125,78,149,72,16,0,126,109,125,18,125,106,120,19,41,26,38,20,20,10,16,26,35,25,27,27,28,6,16,28,96,13,16,29,
	101,13,16,32,23,11,15,45,24,10,11,47,85,8,7,65,17,5,5,66,136,112,112,69,153,131,131,70,114,94,94,71,36,19,19,7,150,72,9,0,11,15,15,2,30,0,0,18,91,9,9,20,21,7,10,44,32,23,26,46,22,9,18,47,100,80,95,48,
	129,108,124,71,126,107,125,79,150,72,19,0,126,107,125,17,126,106,120,19,20,9,15,25,26,20,24,27,106,14,16,29,93,12,14,31,20,10,14,36,36,20,22,44,25,10,12,46,87,8,7,62,28,0,0,63,23,16,16,64,13,0,0,65,
	71,48,48,66,154,130,130,67,123,100,100,68,151,130,130,69,81,57,57,71,39,25,25,8,151,72,7,0,19,10,10,18,100,10,9,20,20,9,13,45,24,13,20,46,101,82,98,47,128,106,122,71,126,107,124,80,151,72,18,0,126,
	107,124,16,129,111,126,18,20,9,14,24,24,17,21,26,108,14,16,28,92,12,13,30,20,7,13,35,37,21,22,43,25,10,11,45,88,7,7,64,7,0,0,65,96,74,74,66,144,121,121,67,136,113,113,68,67,39,39,69,34,19,19,70,108,
	88,88,71,31,13,13,8,152,72,8,0,24,11,11,18,95,9,10,19,86,8,10,20,29,9,15,21,24,11,11,45,26,15,21,47,132,115,132,71,125,107,123,80,152,73,18,0,125,107,123,11,129,113,130,14,102,74,85,15,77,29,34,16,89,
	34,40,18,21,12,19,24,20,11,19,26,109,14,16,28,95,12,13,30,25,6,15,43,26,9,11,45,89,7,7,64,15,1,1,66,152,129,129,68,115,91,91,70,165,143,143,71,103,82,82,72,9,0,0,8,153,72,12,0,28,13,13,19,97,9,10,20,
	35,7,14,21,24,9,11,43,26,16,19,45,29,19,26,46,61,15,21,47,95,51,59,49,94,58,68,50,122,101,116,52,128,110,125,71,124,105,121,80,153,36,15,0,124,105,121,7,128,112,129,9,116,96,111,10,88,51,60,11,93,52,
	61,13,70,7,10,16,105,13,14,17,84,14,19,18,20,13,19,24,27,10,18,25,81,11,16,26,106,13,15,28,102,13,14,31,27,16,17,35,33,15,17,116,153,37,10,0,32,15,15,7,27,9,12,9,92,8,8,26,29,15,15,28,16,0,0,30,156,
	132,132,32,138,116,116,34,161,138,138,35,157,134,134,36,67,47,47,8,154,73,10,0,26,13,13,19,104,10,10,21,23,12,16,45,27,19,26,46,83,14,19,47,101,10,12,48,78,8,10,51,68,15,20,54,124,106,122,72,128,110,
	127,81,154,36,15,0,129,110,127,3,126,111,128,4,106,78,90,6,101,71,83,7,79,30,35,9,77,10,13,15,106,18,20,16,83,14,18,17,21,13,19,20,25,14,17,23,37,11,19,24,103,12,15,27,102,13,14,30,26,13,16,35,34,16,
	17,117,154,37,11,0,32,14,15,6,25,4,9,8,93,7,8,24,40,1,1,25,32,16,16,27,22,1,1,29,159,133,133,32,138,115,115,34,160,137,137,35,124,104,104,36,50,32,32,8,155,37,9,0,26,16,16,1,43,0,0,19,105,10,10,20,81,
	9,12,21,28,7,13,30,22,6,15,31,61,8,15,32,37,13,20,36,34,20,22,45,155,37,13,0,31,17,20,1,22,14,17,3,50,12,20,4,24,18,21,8,27,18,25,9,86,14,20,10,108,20,22,16,79,9,13,17,86,31,38,20,76,30,36,21,105,76,
	89,22,112,88,102,36,111,89,103,82,155,37,11,0,85,45,54,4,89,8,11,14,105,17,18,15,83,14,18,16,20,13,19,21,25,15,17,22,35,10,17,23,103,12,15,26,102,13,14,29,24,8,14,36,38,18,18,119,155,37,12,0,31,10,11,
	4,23,4,9,6,96,7,8,24,26,2,2,25,45,20,20,26,136,110,110,30,159,135,135,31,135,111,111,32,148,125,125,33,123,98,98,35,69,50,50,36,0,0,0,8,156,74,18,0,18,17,17,2,49,4,4,20,107,10,10,21,44,9,16,22,24,11,
	13,28,36,20,22,30,23,4,14,31,74,10,15,32,33,10,16,34,26,13,14,38,20,12,17,39,57,11,19,41,26,18,24,45,26,17,24,46,81,14,20,47,107,17,20,65,70,11,15,73,87,13,17,82,156,37,11,0,88,13,17,14,106,16,18,15,
	83,13,18,16,21,13,19,19,22,10,13,22,33,8,15,23,103,13,15,26,104,13,14,28,71,8,12,29,27,8,13,36,38,19,19,119,156,38,13,0,31,10,11,4,30,5,9,5,79,6,8,6,95,7,8,24,30,3,3,25,45,19,19,26,151,123,123,28,166,
	140,140,29,103,78,78,30,143,118,118,34,156,134,134,35,102,81,81,37,61,51,51,8,157,78,16,0,16,17,17,2,54,4,4,20,107,11,11,22,26,9,13,29,28,16,17,30,46,7,13,31,104,13,14,32,38,7,15,35,39,24,26,38,20,9,
	16,40,71,10,18,41,24,13,22,45,27,17,23,46,41,10,21,47,107,16,20,77,103,18,22,86,157,39,10,0,102,18,21,10,106,15,18,11,83,13,18,12,22,13,18,18,33,7,17,19,103,13,14,23,98,11,12,25,24,6,13,37,36,5,10,38,
	97,8,9,125,157,39,17,0,94,7,8,18,34,3,3,19,71,45,45,20,153,126,126,22,174,148,148,23,60,35,35,24,73,48,48,25,171,146,146,26,132,108,108,29,149,126,126,31,89,70,70,32,128,109,109,33,64,46,46,34,72,59,
	59,35,27,13,13,36,3,0,0,38,3,0,0,7,158,80,16,0,13,32,32,2,46,0,0,21,110,11,11,22,93,8,11,23,27,10,16,30,30,17,18,31,45,7,14,32,116,14,14,34,32,21,25,39,22,10,17,41,108,15,17,42,33,9,19,45,25,13,16,47,
	39,9,20,48,106,16,20,79,103,17,21,87,158,40,13,0,103,17,21,9,106,15,18,10,83,13,18,11,22,11,19,16,25,14,19,18,106,13,14,21,106,13,14,23,71,8,11,24,32,4,13,25,30,12,15,36,36,5,9,37,95,8,9,39,93,7,7,
	127,158,40,17,0,90,7,7,16,37,1,1,17,122,92,92,18,164,136,136,20,173,147,147,21,77,52,52,22,22,7,7,23,126,102,102,24,157,133,133,25,137,113,113,29,158,136,136,31,133,114,114,32,157,136,136,34,107,93,
	93,35,49,34,34,37,1,0,0,39,8,0,0,5,159,82,20,0,18,23,23,2,16,17,17,3,38,29,29,4,55,0,0,23,107,10,11,24,104,10,11,25,50,6,13,26,28,11,13,32,30,16,18,33,47,8,14,34,116,13,13,36,26,14,21,41,27,13,21,42,
	45,8,17,43,116,15,16,45,27,16,22,48,25,14,19,49,40,10,19,50,107,16,19,81,103,17,20,87,159,41,12,0,103,17,20,9,106,15,17,10,83,12,17,11,22,10,20,16,21,12,17,17,81,11,15,18,108,14,14,22,101,12,13,25,28,
	14,16,36,36,5,10,37,97,8,9,40,91,7,7,128,159,41,15,0,89,7,7,2,69,5,4,15,45,7,7,16,123,92,92,17,169,142,142,19,172,147,147,20,78,53,53,21,7,0,0,22,49,26,26,23,163,137,137,25,135,112,112,33,162,145,145,
	35,136,120,120,38,15,8,8,40,0,0,0,5,160,84,19,0,17,17,17,1,17,38,38,2,22,0,0,3,52,5,5,7,71,5,5,24,115,11,11,26,27,10,14,32,31,16,17,33,49,8,14,34,113,13,13,36,37,12,20,41,29,14,21,43,110,15,16,44,102,
	13,17,45,34,11,19,48,23,13,16,49,40,10,19,50,107,16,18,83,103,16,20,89,160,42,13,0,103,16,20,7,106,14,17,8,83,12,17,9,21,9,20,14,19,9,13,15,79,11,15,16,108,14,14,20,106,12,13,23,27,13,16,31,45,22,22,
	34,37,5,10,35,99,8,9,41,74,5,5,131,160,42,17,0,73,4,5,11,43,0,0,12,79,42,42,13,156,125,125,16,171,144,144,17,77,50,50,18,19,0,0,19,20,6,6,20,75,51,51,21,159,135,135,26,131,109,109,33,158,142,142,35,
	129,116,116,38,26,13,13,39,3,4,4,40,5,81,81,41,0,0,0,5,161,36,12,0,18,20,20,1,18,41,41,2,29,0,0,3,57,5,5,8,77,5,5,24,110,10,11,25,94,8,11,26,34,9,14,32,31,17,17,33,50,8,14,34,110,12,13,35,107,11,13,
	41,161,36,10,0,42,11,17,5,33,14,21,6,100,11,15,7,107,15,16,8,106,14,16,9,46,8,16,12,25,15,17,13,42,13,20,14,107,15,18,35,104,18,21,77,161,73,20,0,105,18,21,19,105,14,17,20,90,13,16,21,31,10,19,26,20,
	9,15,27,79,10,15,28,108,14,14,32,106,12,13,35,27,7,13,43,44,20,20,46,38,5,10,47,99,8,9,48,102,8,8,51,73,5,5,65,43,0,0,66,81,43,43,67,161,130,130,70,179,152,152,71,81,54,54,72,15,0,0,152,161,25,19,0,
	84,60,60,1,32,22,22,3,143,120,120,4,146,124,124,5,137,116,116,6,40,25,25,7,41,27,27,8,96,80,80,10,86,61,61,12,152,136,136,16,145,132,132,17,114,101,101,18,109,106,106,19,45,91,91,20,47,52,52,21,28,73,
	73,22,0,0,0,23,0,0,0,24,51,12,10,5,162,72,20,0,19,21,21,1,18,44,44,2,46,0,0,3,64,6,6,20,108,9,10,25,107,10,11,26,39,5,13,30,31,10,12,33,50,8,14,34,111,12,13,35,107,12,13,36,45,7,15,39,32,16,17,41,33,
	15,20,42,95,11,15,44,111,15,16,46,24,16,22,49,42,12,20,50,106,15,18,71,105,17,21,77,162,73,17,0,104,17,20,20,110,14,16,22,23,16,18,26,22,7,17,28,109,13,14,33,97,11,12,34,81,9,9,35,34,6,12,36,31,15,15,
	46,37,4,9,47,101,8,9,65,48,4,4,66,125,90,90,67,162,131,131,69,172,144,144,71,43,12,12,72,26,5,5,154,162,25,14,0,17,0,0,1,118,95,95,3,151,129,129,4,121,100,100,5,23,9,9,6,0,0,0,7,42,26,26,11,134,118,
	118,18,145,134,134,19,112,100,100,21,86,80,80,22,13,0,0,23,125,14,8,24,42,9,7,5,163,36,10,0,18,24,24,1,24,51,51,2,59,0,0,3,68,7,7,25,114,11,11,27,31,13,16,32,31,16,16,33,51,8,15,34,110,11,13,35,111,
	13,13,41,163,36,11,0,86,9,13,1,31,15,21,5,34,15,21,6,96,11,15,8,107,14,16,9,94,12,16,10,38,11,20,12,25,14,16,13,42,11,19,14,109,14,17,35,104,17,20,77,163,73,18,0,104,17,20,20,108,14,16,22,23,15,17,25,
	24,13,15,26,42,10,17,27,101,12,14,28,104,12,13,33,103,11,12,35,33,4,12,46,38,4,9,47,99,9,9,64,52,4,4,65,54,9,9,66,145,110,110,69,166,135,135,70,150,116,116,71,53,21,21,72,23,3,3,155,163,6,5,0,48,31,
	31,1,130,107,107,3,151,130,130,4,119,100,100,5,31,18,18,164,163,16,10,0,12,0,0,1,63,51,51,2,77,63,63,3,120,107,107,10,152,142,142,11,131,122,122,12,60,56,56,13,128,17,11,14,92,7,3,15,0,9,9,5,164,36,9,
	0,18,16,16,1,43,37,37,2,71,1,1,25,114,11,11,27,31,5,12,32,31,15,16,33,52,9,15,34,110,11,13,35,111,13,13,41,164,36,11,0,85,10,14,1,25,10,17,5,35,14,20,6,97,11,14,9,113,14,16,10,46,8,16,12,30,16,18,13,
	36,9,18,14,98,13,17,15,106,14,17,35,105,16,20,77,164,73,19,0,104,16,20,20,111,14,16,22,18,10,13,25,23,14,15,26,50,11,17,27,109,12,13,33,103,11,11,35,42,4,12,36,34,13,17,46,38,4,9,47,93,7,8,64,50,2,2,
	65,76,32,32,66,56,14,14,67,133,97,97,68,166,133,133,70,174,143,143,71,77,49,49,72,11,0,0,156,164,7,6,0,50,31,31,1,137,116,116,3,146,127,127,4,117,97,97,5,30,16,16,6,14,4,4,167,164,13,10,0,25,20,20,1,
	49,38,38,2,96,88,88,3,75,64,64,4,126,111,111,5,144,134,134,8,153,145,145,10,127,112,111,11,114,47,43,12,33,0,0,5,165,72,19,0,20,0,0,1,61,1,1,2,73,5,5,18,111,9,9,26,112,10,11,27,45,5,12,32,32,15,16,33,
	53,9,15,34,111,11,12,36,100,11,13,37,39,5,14,40,32,14,15,41,35,14,20,42,98,11,14,45,108,14,15,47,31,16,22,49,19,8,15,51,111,15,17,71,104,16,19,77,165,73,19,0,104,16,19,19,105,13,15,20,89,12,15,21,27,
	8,17,22,22,10,12,25,21,11,13,26,47,8,15,27,108,12,13,33,107,11,12,34,96,10,10,36,27,9,13,46,38,5,9,47,93,7,7,64,50,1,1,66,88,49,49,67,157,123,123,70,168,136,136,71,125,94,94,72,33,10,10,157,165,7,6,0,
	87,79,79,1,143,119,119,3,147,126,126,4,115,96,96,5,16,5,5,6,13,3,3,170,165,11,8,0,30,28,28,1,71,111,111,2,117,102,102,3,139,126,126,6,152,143,143,8,129,122,122,9,55,41,41,10,0,0,0,5,166,36,11,0,33,1,
	1,1,70,6,6,2,74,5,5,12,82,5,6,14,110,8,9,26,115,10,11,28,33,14,14,32,32,14,15,33,53,9,15,34,112,11,12,35,105,11,13,41,166,36,12,0,115,12,13,1,57,8,14,2,34,19,22,5,35,14,20,6,97,11,14,9,108,13,15,10,
	97,12,16,11,28,8,17,12,39,22,23,13,21,11,15,15,111,15,16,35,104,16,18,77,166,73,20,0,104,16,18,19,104,13,15,20,96,13,15,21,35,7,16,22,22,11,13,25,24,14,16,26,46,7,13,27,109,13,13,33,107,11,12,36,28,8,
	14,46,38,5,9,47,92,7,7,48,93,7,7,64,45,0,0,66,169,135,135,67,167,133,133,68,123,91,91,70,173,141,141,71,152,121,121,72,42,15,15,158,166,7,6,0,99,78,78,1,145,125,125,3,149,129,129,4,65,48,48,5,4,0,0,6,
	17,6,6,172,166,9,6,0,22,33,33,1,73,93,93,2,117,103,103,4,144,135,135,7,125,120,121,8,45,39,39,5,167,36,11,0,47,2,2,1,76,5,5,13,88,6,6,15,113,9,9,26,115,11,10,27,97,8,10,28,32,10,14,32,31,12,14,33,53,
	8,15,34,113,11,12,35,106,11,13,41,167,36,12,0,113,11,13,1,56,8,13,2,33,18,19,5,34,13,18,6,97,11,14,10,111,13,15,12,30,18,21,13,29,13,16,14,37,8,16,15,102,14,16,16,107,14,16,35,104,15,18,77,167,73,18,
	0,104,15,18,20,111,14,14,22,20,12,14,25,26,14,18,26,47,7,13,27,109,13,13,33,106,11,11,37,33,14,15,46,39,5,8,47,99,7,8,64,51,4,4,66,163,128,128,67,161,126,126,68,64,32,32,69,137,105,105,70,177,145,145,
	71,148,117,117,72,40,15,15,158,167,7,6,0,5,0,0,1,98,78,78,2,143,124,124,4,148,130,130,5,62,48,48,6,0,0,0,174,167,8,4,0,19,12,12,2,138,129,129,5,140,135,135,7,49,15,15,4,168,36,11,0,24,1,1,1,66,4,4,2,
	77,5,5,15,92,6,6,17,117,9,9,27,115,11,10,28,98,8,11,29,35,8,12,33,33,11,14,34,54,7,13,35,114,11,11,40,168,37,11,0,107,11,12,1,115,11,12,2,56,7,13,3,34,18,20,6,29,7,13,7,99,11,14,11,113,14,14,13,28,12,
	19,15,29,8,15,16,104,13,17,36,104,15,18,77,168,73,20,0,104,15,18,20,109,14,14,22,20,12,14,25,28,13,19,26,49,6,14,27,109,12,13,34,106,11,11,37,29,10,12,46,39,5,8,47,103,8,8,63,53,0,0,64,68,21,21,65,
	157,120,120,66,171,135,135,67,120,87,87,68,34,2,2,69,147,115,115,70,176,145,145,71,151,120,120,72,44,17,17,159,168,6,5,0,18,3,3,1,116,97,97,2,142,123,123,4,157,139,139,5,64,48,50,175,168,7,6,0,11,3,3,
	1,46,40,40,2,110,104,104,3,136,129,129,5,130,124,124,6,26,24,24,3,169,36,9,0,16,0,0,2,79,6,6,17,96,6,6,19,120,9,9,29,118,11,11,30,62,6,10,31,37,17,17,34,34,9,13,35,54,5,13,39,169,37,12,0,114,11,11,2,
	115,11,12,3,55,7,12,4,31,15,16,7,29,5,13,8,99,11,14,9,109,12,13,13,106,13,14,14,37,9,16,16,28,9,16,18,109,13,15,36,103,14,17,76,169,74,19,0,105,14,18,21,109,14,14,23,20,11,14,26,29,14,19,28,108,12,13,
	35,104,10,11,38,30,10,14,47,39,5,8,48,101,8,8,49,102,8,8,64,45,0,0,66,160,124,124,67,169,134,134,68,66,33,33,69,38,6,6,70,152,122,122,71,175,148,148,72,151,121,121,73,45,17,17,159,169,11,7,0,6,0,0,1,
	51,34,34,2,136,118,118,3,164,148,147,6,92,71,78,7,121,97,108,10,94,73,85,177,169,5,5,0,48,43,43,1,127,121,121,2,133,126,126,3,132,126,126,4,65,61,61,2,170,37,8,0,15,0,0,2,76,5,5,19,97,6,7,21,121,9,9,
	30,117,11,10,32,35,15,16,35,30,7,12,36,53,5,13,39,170,37,13,0,115,12,11,2,115,12,12,3,55,6,12,4,29,13,14,7,29,5,15,8,98,11,13,9,110,12,13,13,112,14,14,15,29,15,19,16,27,14,17,17,55,8,15,18,113,14,15,
	36,104,14,17,76,170,37,8,0,104,14,17,21,109,13,14,23,20,11,14,26,28,11,16,27,93,9,13,28,106,12,12,35,106,10,11,36,89,8,9,113,170,37,17,0,69,5,8,1,33,10,14,9,33,9,8,10,39,5,9,11,101,8,9,12,102,8,8,26,
	55,3,3,27,62,13,13,28,136,97,97,29,170,134,134,30,150,115,115,31,53,21,21,32,35,4,4,33,128,99,99,34,176,159,159,35,152,126,126,36,37,9,9,161,170,9,5,0,60,46,46,1,106,83,85,3,119,95,105,7,124,101,112,
	8,94,75,84,172,170,2,2,0,115,98,107,1,75,63,68,177,170,6,6,0,7,7,7,1,96,88,88,2,132,125,125,3,139,132,132,4,99,93,93,5,0,0,0,2,171,74,19,0,21,0,0,2,77,5,5,23,119,9,9,30,114,10,9,32,34,12,13,35,29,6,
	11,36,53,5,13,37,115,12,11,39,115,12,11,40,56,6,12,41,30,13,15,43,33,15,18,45,110,12,13,50,112,14,14,52,32,11,18,53,29,16,18,54,53,8,15,55,109,14,14,73,104,14,16,76,171,74,20,0,105,14,16,21,109,13,13,
	23,20,10,12,26,24,7,12,27,93,10,13,28,106,11,12,36,100,9,10,38,30,7,11,47,39,4,9,48,102,9,10,63,50,0,0,64,82,33,33,65,161,126,126,66,165,128,128,68,21,0,0,69,28,0,0,70,75,43,43,71,172,151,151,72,172,
	150,150,73,91,62,62,162,171,13,9,0,92,67,77,1,131,105,116,2,119,96,104,3,82,58,63,4,125,108,111,8,94,76,84,10,125,105,117,11,107,86,96,12,35,14,16,178,171,5,5,0,50,45,45,1,120,114,114,2,140,132,132,3,
	97,92,92,4,17,8,8,2,172,35,9,0,25,0,0,1,61,4,4,3,78,5,5,12,105,7,7,22,98,6,6,23,116,8,8,31,105,9,10,32,38,6,8,34,43,17,18,37,172,36,15,0,30,5,11,1,55,4,13,2,116,11,11,4,115,12,11,5,55,6,11,6,31,14,15,
	7,45,21,21,8,30,14,16,10,115,11,13,16,113,13,13,17,45,7,15,19,28,9,15,20,90,11,14,21,110,13,14,35,105,14,16,73,172,71,16,0,105,14,16,24,109,13,13,26,19,9,11,29,25,8,13,30,93,9,12,31,106,11,12,38,107,
	10,11,39,98,9,9,41,31,4,12,50,38,4,8,51,101,8,10,52,102,7,8,66,51,0,0,68,162,126,126,69,157,120,120,70,55,14,14,146,172,4,4,0,80,50,50,1,168,140,140,2,173,147,147,3,108,80,80,162,172,13,10,0,104,55,
	61,1,68,44,49,2,91,78,78,3,145,129,129,5,137,123,122,6,114,96,102,8,127,105,117,10,92,74,82,11,122,103,115,12,64,48,54,179,172,4,4,0,114,106,106,1,137,129,129,2,116,115,115,3,85,46,43,2,173,71,19,0,
	20,0,0,2,71,5,5,14,112,8,8,30,111,9,9,31,104,8,10,32,36,5,10,35,32,5,10,36,97,9,12,39,116,12,11,40,56,6,11,41,32,12,15,43,30,14,16,45,114,11,13,51,111,13,13,53,33,14,19,54,29,14,18,55,91,11,14,56,111,
	13,14,70,105,13,16,73,173,71,16,0,105,13,16,24,109,12,13,26,21,11,13,29,25,7,12,30,90,9,12,31,101,10,11,39,100,9,9,42,29,12,13,50,38,4,9,51,101,7,9,65,54,0,0,66,68,18,18,67,142,106,106,68,164,129,129,
	69,129,92,92,70,50,11,11,146,173,4,4,0,79,50,50,1,164,132,132,2,168,137,137,3,100,74,74,164,173,11,11,0,0,0,0,1,89,74,74,2,142,126,127,3,149,135,135,4,103,88,87,5,83,63,71,6,126,106,119,7,68,50,56,8,
	73,57,63,9,120,102,113,10,103,86,95,178,173,5,5,0,9,5,5,1,96,87,87,2,138,129,129,3,113,115,115,4,109,46,42,2,174,70,19,0,50,28,28,1,59,5,5,15,116,8,8,24,99,6,6,31,113,9,9,33,36,14,14,35,37,10,14,36,
	100,8,11,39,116,12,11,40,58,5,12,41,33,11,17,43,30,13,16,45,115,11,12,51,110,12,13,52,96,10,13,53,27,8,15,55,56,7,14,56,110,14,14,69,105,13,15,72,174,71,15,0,105,13,15,25,109,12,13,27,22,11,15,30,25,
	5,14,31,87,9,11,32,101,10,11,40,105,9,10,43,29,10,13,51,37,3,9,52,101,7,9,66,55,3,3,67,108,65,65,68,117,78,78,69,165,130,130,70,83,44,44,146,174,4,4,0,94,67,67,1,148,116,116,2,144,107,107,3,107,81,81,
	165,174,11,9,0,36,22,22,1,107,92,92,2,147,134,134,4,46,21,25,5,111,96,106,6,71,90,92,7,76,60,66,8,118,99,111,10,61,47,54,177,174,6,5,0,67,64,64,1,54,48,48,3,147,140,139,4,105,107,107,5,115,39,34,2,
	175,70,20,0,38,15,15,2,69,5,5,12,109,7,7,31,116,10,9,33,31,9,12,35,37,10,14,36,99,8,10,37,114,11,11,39,117,11,11,40,57,4,12,41,33,12,17,42,43,19,18,43,25,7,13,45,115,12,12,52,106,12,13,53,47,6,14,54,
	24,12,14,55,46,10,16,56,112,12,13,69,105,13,14,72,175,71,16,0,105,13,14,25,109,12,13,27,23,9,16,30,31,5,14,31,90,9,11,32,100,10,11,40,101,9,9,43,28,6,11,51,38,4,8,52,98,7,9,65,56,0,0,66,72,21,21,67,
	149,115,115,68,152,118,118,69,135,100,100,70,57,17,17,147,175,3,3,0,105,65,65,1,138,105,105,2,105,79,79,166,175,10,8,0,46,33,35,1,119,106,105,3,88,68,76,4,116,102,103,5,115,105,104,6,60,54,55,8,111,
	91,102,9,74,56,63,177,175,6,5,0,38,32,32,1,112,105,105,2,138,132,132,3,134,133,133,5,75,16,14,2,176,70,19,0,20,0,0,2,69,5,5,16,119,8,8,31,110,9,9,32,97,8,9,33,43,8,11,35,37,9,14,36,99,8,10,39,117,11,
	11,41,35,13,17,43,31,3,11,44,87,9,12,45,113,12,11,52,113,12,13,54,30,11,15,55,39,9,15,56,96,10,13,57,109,12,13,69,105,13,14,72,176,71,15,0,105,13,14,25,109,12,12,26,50,5,13,27,24,9,16,29,22,10,12,31,
	100,10,11,40,102,9,9,44,28,8,8,51,37,4,8,52,94,7,7,65,50,0,0,66,122,81,81,67,148,116,116,68,148,114,114,70,38,0,0,147,176,3,3,0,64,21,21,1,139,108,108,2,100,75,75,166,176,16,12,0,91,69,80,3,139,128,
	129,4,114,96,96,7,85,97,101,8,115,93,103,9,107,91,102,10,56,47,51,11,68,62,61,12,144,136,137,13,158,152,152,14,125,122,122,15,91,28,25,2,177,70,18,0,18,0,0,2,68,5,5,16,120,8,8,32,114,9,9,33,47,4,10,
	34,37,12,12,35,38,9,14,36,100,7,10,37,114,11,10,39,116,11,11,41,38,13,18,43,44,6,11,44,114,11,12,53,107,11,13,54,34,6,12,55,25,12,16,57,114,13,13,69,105,13,14,72,177,70,15,0,105,13,14,25,108,12,12,27,
	25,9,15,29,20,9,12,31,105,10,10,41,98,9,9,43,34,5,11,44,29,8,9,51,37,4,8,52,94,7,7,64,55,1,1,65,77,27,27,66,155,123,123,68,141,106,106,69,79,39,39,147,177,4,4,0,78,45,45,1,138,109,109,2,153,128,128,3,
	44,25,25,166,177,16,5,0,113,91,102,6,138,127,126,8,93,82,84,13,142,135,135,15,15,6,5,2,178,70,16,0,24,0,0,2,66,4,4,16,120,8,8,32,112,9,9,34,37,13,14,35,38,9,14,36,100,7,10,37,115,10,10,39,114,11,10,
	41,39,12,18,43,43,9,15,44,109,10,11,53,110,11,12,55,20,8,15,57,112,12,13,69,105,12,13,72,178,70,15,0,105,12,13,26,102,10,11,27,32,11,16,29,19,8,10,31,104,10,10,41,96,9,9,43,35,5,10,44,27,6,8,51,35,4,
	7,52,93,7,7,64,57,2,2,65,128,89,89,66,151,120,120,67,147,116,116,69,60,17,17,147,178,4,3,0,93,64,64,2,104,73,73,3,50,27,27,165,178,16,7,0,105,83,93,6,132,122,122,9,85,66,75,11,119,103,115,13,71,57,62,
	14,127,121,121,15,36,32,33,2,179,70,19,0,38,1,1,1,65,4,4,17,121,8,8,32,113,10,9,33,94,7,9,34,34,10,13,35,37,8,12,36,101,7,10,37,115,9,10,40,100,8,10,41,37,11,16,43,55,9,16,44,107,9,10,53,111,11,12,54,
	96,10,13,55,34,6,14,56,36,8,15,57,104,11,13,69,106,12,13,72,179,70,15,0,106,12,13,25,106,11,11,27,28,11,16,29,19,8,10,31,104,10,10,41,98,9,9,44,25,7,9,50,26,5,3,51,36,4,7,52,95,7,7,64,59,3,3,65,144,
	111,111,67,160,130,130,68,114,81,81,69,22,0,0,148,179,1,2,0,55,21,21,0,55,21,21,165,179,16,8,0,114,92,103,6,104,86,96,7,122,102,116,8,95,76,85,9,112,94,104,13,101,89,96,14,80,76,76,15,0,0,0,1,180,70,
	19,0,18,0,0,2,64,4,4,18,119,8,8,33,112,9,9,34,97,7,10,35,40,8,9,36,31,7,11,37,98,7,10,38,116,9,10,41,103,7,10,42,38,12,15,44,48,4,13,45,109,10,11,55,115,11,12,56,47,7,13,57,30,6,13,58,101,10,13,59,
	108,11,12,69,106,12,13,71,180,70,16,0,107,12,13,26,109,12,11,27,49,4,12,28,24,10,16,30,21,9,11,32,104,10,9,42,101,9,9,43,94,8,8,45,25,6,10,52,32,4,7,53,84,6,7,54,95,7,7,64,56,0,0,66,151,122,122,68,
	148,118,118,69,68,27,27,164,180,16,8,0,109,85,96,4,121,99,111,6,61,43,48,7,128,108,121,9,83,65,73,13,111,96,108,14,91,78,87,15,6,3,3,0,181,70,17,0,18,0,0,2,57,3,3,19,118,8,8,35,116,9,9,36,61,7,10,37,
	51,10,11,38,110,8,9,41,113,9,10,42,102,7,10,43,38,11,15,44,29,7,9,45,45,3,12,46,112,10,10,56,111,11,11,58,21,2,14,60,113,12,12,69,107,11,13,70,181,71,17,0,106,11,13,27,109,11,11,28,49,4,12,29,25,10,
	17,31,20,9,11,33,104,10,9,43,100,9,9,44,93,8,8,46,26,4,10,53,25,3,8,55,98,7,7,65,61,5,5,66,83,35,35,67,141,112,112,68,158,130,130,69,143,113,113,70,54,12,12,147,181,1,2,0,84,51,56,0,84,51,56,163,181,
	17,8,0,109,86,98,5,116,96,108,6,91,67,75,8,111,93,103,10,98,80,90,14,118,102,114,15,81,68,77,16,0,0,0,0,182,70,18,0,17,0,0,2,58,3,3,19,117,8,8,35,116,9,9,36,53,5,10,37,66,8,10,38,116,9,9,41,113,10,10,
	42,102,7,10,43,40,11,16,44,30,9,11,45,87,7,10,46,114,11,10,57,108,11,11,58,38,5,13,59,57,7,13,60,115,12,12,69,107,11,13,70,182,71,14,0,107,11,13,27,107,10,11,29,29,10,17,31,21,6,13,33,104,10,9,43,101,
	9,9,45,80,7,7,47,24,7,6,53,25,3,8,55,97,7,7,65,61,3,3,67,154,127,127,68,165,137,137,70,35,0,0,146,182,5,5,0,61,26,29,1,86,53,58,2,45,9,9,3,121,93,93,4,82,61,61,162,182,18,8,0,107,83,95,7,115,97,109,9,
	76,56,63,10,111,94,106,11,120,102,114,14,90,75,84,16,103,89,99,17,25,22,25,0,183,70,17,0,31,0,0,11,94,7,7,22,116,8,8,35,114,9,9,37,34,6,9,38,99,8,10,41,113,10,9,42,102,7,9,43,42,13,17,44,30,9,11,45,
	87,6,10,46,114,10,10,57,117,12,11,59,26,3,13,60,97,10,11,61,111,11,11,69,107,11,12,70,183,70,17,0,107,11,12,27,102,10,10,28,94,7,9,29,33,10,15,31,23,6,13,33,103,10,9,43,99,9,9,45,84,6,7,46,38,3,11,47,
	23,4,7,53,24,3,8,55,97,7,7,65,68,14,14,66,140,111,111,67,157,130,130,68,155,127,127,69,86,48,48,146,183,6,5,0,116,83,92,1,103,69,78,2,59,27,29,3,148,123,123,5,4,0,0,161,183,19,7,0,102,81,92,6,118,97,
	108,8,84,66,74,11,122,104,117,15,94,80,90,17,111,96,107,18,61,50,56,0,184,70,18,0,38,2,2,12,97,7,7,22,115,8,8,36,105,9,9,37,34,4,10,38,94,8,9,41,113,9,9,42,102,7,8,43,40,12,15,44,29,8,11,45,87,6,10,
	46,114,10,10,57,111,11,11,58,91,9,11,59,24,3,13,60,92,9,11,61,113,11,11,69,107,11,11,70,184,70,18,0,107,11,11,27,100,10,9,28,90,7,9,29,31,9,15,30,29,15,14,31,32,7,14,32,86,7,9,33,99,9,9,44,99,8,9,47,
	24,4,8,49,39,19,19,53,22,4,7,55,96,7,7,64,64,4,4,66,157,132,132,67,163,137,137,68,139,110,110,69,48,0,0,145,184,7,6,0,98,66,75,1,122,90,101,2,97,67,73,4,139,117,116,5,110,90,90,6,7,0,0,160,184,20,9,0,
	96,73,83,1,117,93,104,8,107,88,99,10,124,105,117,14,69,57,64,15,112,96,108,16,92,79,88,18,108,93,104,19,54,43,50,0,185,70,17,0,49,2,2,20,115,8,8,35,109,9,9,36,101,9,9,37,35,3,11,38,96,8,9,41,113,9,9,
	42,102,7,9,43,39,10,14,44,29,7,11,45,88,6,10,46,114,10,10,58,113,11,11,59,55,5,12,60,56,5,12,61,112,10,11,69,108,11,11,70,185,70,16,0,108,11,11,27,101,10,9,28,91,7,9,29,31,9,14,30,28,14,14,31,36,8,14,
	32,96,8,8,43,98,7,8,46,72,5,7,47,24,4,8,53,21,4,6,55,96,7,7,63,70,9,9,65,91,51,51,67,168,144,144,69,50,4,4,145,185,7,5,0,128,96,108,2,67,36,40,3,132,107,107,4,147,126,126,6,6,0,2,159,185,21,9,0,86,65,
	75,1,117,94,104,10,110,93,103,13,87,68,76,14,49,37,41,16,111,95,107,17,95,80,91,19,109,95,106,20,60,49,54,0,186,70,14,0,46,2,2,20,113,8,8,36,112,8,9,37,67,6,10,39,110,9,9,41,113,9,9,42,102,7,9,43,39,
	10,14,44,28,5,12,46,114,9,9,58,117,11,11,60,39,4,13,61,116,10,11,69,109,11,11,70,186,70,17,0,109,11,11,27,101,9,9,28,91,7,9,29,31,9,14,30,27,14,13,31,35,9,13,32,96,8,8,44,95,7,7,46,67,5,7,47,24,3,11,
	53,21,5,6,55,97,7,7,63,68,8,8,65,90,53,53,66,147,118,118,67,163,147,147,69,50,4,4,144,186,7,5,0,112,82,90,2,125,94,105,4,61,34,34,5,146,126,126,6,31,13,13,158,186,22,8,0,107,82,94,9,113,94,105,12,64,
	48,53,13,107,82,93,15,55,113,119,16,115,86,98,20,98,85,96,21,42,32,37,0,187,70,14,0,46,2,2,15,104,7,7,36,113,9,9,37,79,6,10,39,110,9,9,42,103,8,9,43,32,5,12,44,49,5,11,45,107,8,9,58,110,10,10,59,101,
	9,11,60,38,4,12,62,114,11,11,69,109,10,11,70,187,70,17,0,109,10,11,26,103,9,10,28,92,8,10,29,26,5,9,30,24,12,11,31,37,10,14,32,96,8,8,44,97,7,7,46,77,6,6,48,21,5,6,53,20,5,6,55,96,7,7,64,63,9,9,66,
	160,137,137,67,161,145,145,68,77,36,36,69,46,2,2,144,187,7,5,0,118,89,99,2,125,96,107,3,100,74,77,5,154,136,136,6,48,30,31,157,187,22,7,0,113,89,100,14,114,88,98,15,36,40,43,16,91,100,110,17,111,91,
	103,20,109,95,105,21,68,58,66,0,188,69,15,0,44,2,2,20,111,8,8,37,105,8,9,38,64,4,10,39,107,8,9,41,111,9,9,42,105,8,9,43,29,3,11,44,57,5,10,45,116,9,9,59,116,10,10,60,65,6,11,61,74,7,11,62,116,11,10,
	68,109,10,11,69,188,70,18,0,109,10,11,28,99,9,9,29,92,8,10,30,25,4,8,31,24,12,11,32,36,10,15,33,95,8,8,45,96,7,7,47,80,6,6,49,19,4,6,51,38,20,20,54,19,5,6,56,95,7,7,64,67,4,4,65,82,35,35,66,139,117,
	117,68,161,139,139,69,84,47,47,144,188,35,15,0,120,90,102,1,128,98,110,3,90,61,62,4,164,146,146,5,125,105,106,9,111,85,95,10,77,50,56,12,120,96,107,15,103,81,91,26,115,103,114,27,61,92,97,28,96,75,85,
	29,114,94,106,33,99,85,95,34,28,23,25,0,189,70,15,0,46,2,2,20,110,8,8,36,106,8,8,37,103,8,8,38,63,4,10,39,108,8,9,41,108,9,9,42,102,9,9,43,29,3,11,44,55,5,10,45,113,9,9,59,113,9,10,61,45,4,11,62,109,
	10,10,69,109,10,10,70,189,70,17,0,109,10,11,27,99,9,9,28,92,8,10,29,25,4,8,31,36,10,15,32,95,8,8,44,96,7,7,46,79,6,5,48,20,3,9,50,35,18,18,53,19,5,6,55,94,7,7,63,66,5,5,64,56,20,20,66,146,124,124,67,
	135,112,112,69,56,18,18,142,189,36,15,0,65,31,36,2,123,94,105,3,112,86,93,4,57,25,26,5,105,80,80,6,125,104,104,13,110,85,95,16,121,98,110,18,87,64,72,19,120,98,110,27,116,97,108,28,89,76,85,30,113,96,
	108,34,100,86,97,35,66,56,63,0,190,88,15,0,44,2,2,19,109,8,8,37,104,8,8,38,66,4,10,39,103,8,9,41,107,8,9,42,99,8,9,43,32,3,11,44,55,5,10,45,115,9,9,60,108,9,10,61,57,5,11,62,105,8,10,63,111,9,10,87,
	105,9,10,88,190,44,14,0,105,9,10,9,99,9,9,10,92,8,9,11,27,4,9,12,25,9,11,13,34,5,12,14,96,9,9,26,95,7,7,29,68,6,7,30,25,4,9,31,21,7,6,35,19,5,6,37,94,7,7,43,71,7,7,132,190,45,17,0,69,7,7,2,67,12,12,4,
	152,134,134,6,119,94,94,7,133,112,112,9,56,20,19,10,75,45,49,11,127,106,110,14,128,104,104,15,84,60,59,16,78,55,55,17,118,92,103,32,122,102,114,37,114,97,108,38,92,77,86,43,105,90,101,44,87,74,82,0,
	191,88,13,0,44,2,2,20,108,8,8,37,110,8,8,39,74,6,9,40,111,8,8,42,104,8,9,43,42,2,11,44,48,3,11,45,114,9,9,60,117,10,9,61,65,6,11,63,115,9,10,87,105,9,9,88,191,44,13,0,105,9,9,9,99,9,9,10,92,8,9,11,27,
	3,11,12,25,8,12,13,30,2,11,14,95,9,9,27,95,7,7,29,73,6,6,30,36,3,9,35,17,5,6,37,94,7,7,43,70,6,6,132,191,45,13,0,67,6,6,3,58,6,6,4,89,59,59,6,127,106,106,7,95,67,67,8,144,124,124,13,155,137,137,14,
	100,73,73,15,86,62,63,16,126,103,111,42,101,86,97,43,88,74,85,44,25,20,21,0,192,88,10,0,44,2,2,19,107,8,8,37,110,8,8,39,80,6,9,40,110,8,8,42,106,8,8,43,53,4,10,44,63,4,11,45,110,9,9,87,106,9,9,88,192,
	44,11,0,105,9,9,10,92,8,9,11,28,4,11,13,43,4,10,14,97,8,9,27,95,7,7,29,73,6,6,31,22,4,7,35,17,6,7,37,91,7,6,43,69,5,5,132,192,44,10,0,66,4,4,6,48,15,15,7,73,45,45,8,148,130,130,12,144,126,126,14,77,
	59,61,17,118,93,103,34,120,101,114,41,100,85,96,43,61,50,58,0,193,137,18,0,44,2,2,18,105,8,8,42,108,8,8,43,64,5,10,45,107,8,9,62,112,9,9,97,99,9,9,98,91,8,9,99,29,3,11,100,26,12,17,102,101,9,9,115,94,
	7,7,118,59,5,8,119,16,3,6,120,31,14,14,123,16,6,7,125,89,7,7,136,53,5,5,139,193,7,3,0,67,35,35,5,62,35,35,6,40,10,10,149,193,26,5,0,52,36,40,2,117,93,104,10,124,102,114,23,100,85,96,25,64,53,61,0,194,
	137,20,0,44,2,2,18,105,8,8,38,108,8,8,39,59,5,10,40,97,8,8,42,109,9,8,43,69,5,9,45,107,8,8,72,113,9,9,97,98,8,9,98,91,7,9,99,29,3,11,100,25,10,15,102,101,9,8,115,94,7,7,117,77,6,6,119,17,3,8,123,16,6,
	7,125,89,7,7,136,49,3,3,151,194,23,6,0,64,47,51,2,115,93,104,9,122,101,113,18,107,92,103,21,94,81,91,22,68,61,68,0,195,137,17,0,44,2,2,18,104,8,8,38,106,8,8,39,75,6,9,41,104,8,8,70,113,9,9,97,99,8,9,
	98,90,7,9,99,27,3,11,100,23,10,14,102,101,9,8,115,93,7,7,118,63,5,7,119,24,2,9,123,16,5,6,125,88,7,7,136,50,2,2,153,195,20,4,0,99,77,88,10,121,101,114,18,97,82,92,19,64,64,71,0,196,136,15,0,44,2,2,18,
	102,8,8,70,114,9,9,97,98,8,8,98,92,7,8,99,34,4,11,100,20,8,12,102,101,8,8,115,93,7,7,118,77,6,6,120,18,7,7,121,31,15,16,123,14,4,5,125,86,7,7,135,49,4,4,153,196,19,5,0,62,45,52,2,112,91,103,8,122,102,
	114,17,102,87,98,18,72,58,66,1,197,134,14,0,47,2,2,18,102,8,8,69,115,9,9,97,102,8,8,99,15,8,12,100,74,6,9,101,101,8,8,115,88,7,7,117,75,6,6,118,30,3,10,119,17,5,7,122,13,4,5,124,84,7,7,133,51,4,4,154,
	197,18,5,0,98,79,88,1,116,97,108,15,102,86,98,16,87,77,86,17,38,75,80,2,198,132,13,0,50,3,3,18,101,8,8,70,116,9,9,96,102,8,8,98,13,4,11,99,74,6,9,100,100,8,8,113,92,7,7,116,73,6,6,118,17,4,7,121,13,4,
	5,123,82,6,6,131,52,4,4,154,198,17,3,0,106,91,101,15,98,83,94,16,51,45,51,3,199,130,13,0,52,3,3,17,99,8,8,70,117,9,9,95,102,8,8,97,11,1,11,98,72,6,9,99,100,8,8,113,85,7,7,116,62,5,7,117,15,3,6,120,12,
	4,5,122,79,6,6,129,54,4,4,154,199,16,3,0,105,88,98,11,105,90,100,15,80,67,74,4,200,128,13,0,55,3,3,16,97,7,7,68,117,9,9,94,102,9,8,96,17,2,11,97,78,7,9,98,98,8,8,111,88,7,7,115,59,5,6,116,18,2,8,119,
	11,4,5,121,77,5,5,127,54,4,4,154,200,15,4,0,92,75,86,1,110,93,103,13,104,89,100,14,71,60,67,5,201,126,11,0,57,3,3,17,96,8,8,69,113,8,8,93,103,9,8,95,32,3,11,96,96,8,8,114,73,6,5,116,14,8,8,118,13,4,5,
	120,67,4,5,125,55,4,4,154,201,15,6,0,85,69,78,1,110,93,103,10,108,93,104,12,46,32,36,13,88,76,86,14,20,13,13,6,202,124,14,0,57,3,3,20,98,8,8,68,113,8,8,92,102,9,8,94,37,3,10,95,102,9,8,110,83,7,7,112,
	61,5,5,113,71,6,5,115,11,4,6,118,12,2,8,119,55,4,6,120,66,5,5,123,55,5,5,154,202,12,3,0,106,87,97,10,103,87,98,11,41,27,30,7,203,122,13,0,57,3,3,22,98,8,8,66,113,8,8,91,102,9,8,93,36,3,10,94,100,9,8,
	109,81,7,7,112,69,6,5,114,11,3,8,117,14,1,7,118,54,4,5,119,64,5,5,121,57,5,5,154,203,11,3,0,106,90,99,9,103,88,99,10,74,60,67,8,204,120,12,0,60,5,5,23,98,8,8,67,111,8,8,90,102,9,8,92,36,3,10,93,100,9,
	8,112,67,5,6,113,18,3,7,114,16,9,8,116,13,1,7,117,52,4,5,119,54,5,5,153,204,12,5,0,102,85,96,8,103,88,100,9,97,81,92,10,41,25,28,11,50,35,40,9,205,118,11,0,59,5,5,23,97,8,8,65,111,8,8,89,103,9,8,91,
	32,3,10,92,100,9,8,111,60,5,6,112,16,1,6,115,12,1,6,116,50,4,6,117,58,5,4,153,205,11,4,0,109,93,104,7,102,87,97,8,90,75,85,10,0,0,0,10,206,116,11,0,58,5,5,21,94,8,8,62,110,8,8,88,98,8,8,90,51,4,10,91,
	97,8,8,106,74,6,6,110,62,5,5,112,11,5,7,114,11,2,6,115,44,2,5,152,206,12,5,0,98,81,91,1,113,96,107,8,102,88,99,10,53,38,43,11,72,57,64,11,207,114,7,0,55,5,5,20,93,7,7,65,108,8,8,105,72,6,6,109,61,5,5,
	111,8,3,5,113,11,2,4,152,207,12,3,0,99,83,93,1,125,108,121,11,89,76,86,12,208,113,7,0,55,5,5,23,94,7,7,65,107,8,8,105,66,5,5,108,57,5,4,110,7,3,6,112,10,2,3,152,208,12,3,0,122,104,116,10,101,86,97,11,
	69,58,66,13,209,112,7,0,53,3,3,23,93,7,7,65,106,8,8,103,66,5,5,108,52,4,5,109,16,2,6,111,9,2,3,151,209,12,4,0,48,28,32,1,105,93,104,2,115,97,109,11,80,69,77,14,210,110,5,0,53,5,5,22,91,7,7,64,105,8,8,
	107,55,5,5,109,6,5,4,148,210,13,7,0,44,33,37,2,116,90,100,3,62,2,2,4,66,49,55,5,64,47,52,6,101,87,97,12,97,83,95,15,211,108,6,0,50,3,3,23,89,7,7,63,105,8,8,91,83,7,7,106,48,4,4,107,17,2,5,147,211,13,
	8,0,22,16,19,2,122,110,124,3,130,93,103,4,94,0,0,5,17,2,3,6,47,31,34,7,112,97,108,12,97,83,94,16,212,106,5,0,51,3,3,22,87,7,7,60,104,8,8,86,89,7,7,105,44,3,3,146,212,7,5,0,37,30,34,3,130,116,132,4,61,
	32,35,5,112,43,47,6,66,54,62,154,212,5,2,0,93,80,90,4,97,84,94,17,213,104,5,0,48,5,5,22,85,7,7,61,103,8,8,84,90,7,7,103,37,2,2,145,213,7,6,0,34,27,30,1,101,87,98,2,122,107,119,4,118,110,125,5,62,18,
	19,6,93,25,27,153,213,6,3,0,108,91,101,4,106,93,104,5,90,76,85,18,214,102,5,0,47,3,3,23,84,7,7,58,103,8,8,82,89,7,7,101,34,2,2,144,214,14,8,0,36,30,33,1,104,90,101,2,123,108,121,5,122,107,120,6,64,41,
	45,7,99,81,91,8,103,90,101,13,96,83,94,19,215,100,5,0,45,3,3,39,98,8,8,60,101,8,8,81,87,7,7,99,41,3,3,144,215,14,7,0,103,90,100,1,125,110,123,4,122,108,121,5,111,97,109,6,107,36,37,7,110,98,109,13,95,
	83,95,20,216,98,4,0,44,2,2,49,100,8,8,80,84,7,7,97,44,2,2,143,216,14,5,0,97,86,96,5,128,113,127,7,70,30,32,8,108,96,107,13,96,84,96,21,217,96,4,0,41,3,3,49,103,8,8,78,86,7,7,95,45,4,4,142,217,15,7,0,
	99,88,97,2,122,107,120,5,105,103,116,6,126,38,39,8,34,21,23,9,110,97,109,14,94,83,94,22,218,94,4,0,40,3,3,42,98,8,8,64,96,8,8,93,43,4,4,141,218,8,5,0,105,91,103,4,119,107,119,5,126,98,109,6,113,43,46,
	7,71,40,45,151,218,5,2,0,110,96,107,4,100,89,99,142,219,6,4,0,81,70,81,3,76,73,82,4,76,11,11,5,96,51,53,151,219,5,2,0,71,64,71,4,64,57,62,
	]]

		local decor = new("Frame", {
			Name = "Decor",
			BackgroundTransparency = 1,
			ZIndex = 50,
			Visible = false,
			Parent = screenGui,
		})
		decor:SetAttribute("KeepColor", true)
		local decorScale = new("UIScale", { Parent = decor })
		local pixels = nil
		local appliedTransparency = nil

		local function buildPixels()
			pixels = {}
			local numbers = {}
			for value in DECOR_ROWS:gmatch("%d+") do
				numbers[#numbers + 1] = tonumber(value)
			end
			local i = 1
			while i <= #numbers - 3 do
				local x, y, length, count = numbers[i], numbers[i + 1], numbers[i + 2], numbers[i + 3]
				i += 4

				local keypoints = {}
				for k = 1, count do
					local index, r, g, b = numbers[i], numbers[i + 1], numbers[i + 2], numbers[i + 3]
					i += 4
					local time = length > 1 and index / (length - 1) or (k - 1)
					keypoints[k] = ColorSequenceKeypoint.new(math.clamp(time, 0, 1), Color3.fromRGB(r, g, b))
				end
				if #keypoints == 1 then
					keypoints[2] = ColorSequenceKeypoint.new(1, keypoints[1].Value)
				end
				keypoints[1] = ColorSequenceKeypoint.new(0, keypoints[1].Value)
				keypoints[#keypoints] = ColorSequenceKeypoint.new(1, keypoints[#keypoints].Value)

				local strip = Instance.new("Frame")
				strip.Position = UDim2.fromScale(x / DECOR_W, y / DECOR_H)
				strip.Size = UDim2.new(length / DECOR_W, 0, 1 / DECOR_H, 1)
				strip.BackgroundColor3 = Color3.new(1, 1, 1)
				strip.BorderSizePixel = 0
				strip.ZIndex = 50
				strip:SetAttribute("KeepColor", true)
				local gradient = Instance.new("UIGradient")
				gradient.Color = ColorSequence.new(keypoints)
				gradient.Parent = strip
				strip.Parent = decor
				pixels[#pixels + 1] = strip
			end
		end

		rs.RenderStepped:Connect(function()
			local visible = MENU_STYLE.Decor and screenGui.Enabled and frame.Visible
			decor.Visible = visible
			if not visible then
				return
			end
			if not pixels then
				buildPixels()
			end

			decor.ZIndex = MENU_STYLE.DecorLayer == "За меню" and 0 or 50

			local transparency = math.clamp(MENU_STYLE.DecorTransparency, 0, 0.95)
			if transparency ~= appliedTransparency then
				appliedTransparency = transparency
				for _, pixel in ipairs(pixels) do
					pixel.BackgroundTransparency = transparency
				end
			end

			local scale = windowScale.Scale
			decorScale.Scale = scale
			local height = math.clamp(MENU_STYLE.DecorSize, 40, 600)
			decor.Size = UDim2.fromOffset(height * DECOR_W / DECOR_H, height)

			local half = WINDOW_SIZE * scale / 2
			local size = height * scale
			local position = MENU_STYLE.DecorPosition
			local offset
			if position == "Сверху слева" then
				decor.AnchorPoint = Vector2.new(0, 1)
				offset = Vector2.new(-half.X + 10 * scale, -half.Y + size * 0.25)
			elseif position == "Слева от меню" then
				decor.AnchorPoint = Vector2.new(1, 0.5)
				offset = Vector2.new(-half.X - 8 * scale, 0)
			elseif position == "Снизу справа" then
				decor.AnchorPoint = Vector2.new(1, 0)
				offset = Vector2.new(half.X - 10 * scale, half.Y - size * 0.25)
			else
				decor.AnchorPoint = Vector2.new(1, 1)
				offset = Vector2.new(half.X - 10 * scale, -half.Y + size * 0.25)
			end
			decor.Position = frame.Position + UDim2.fromOffset(offset.X, offset.Y)
		end)
	end

	local openMenu, closeMenu
	do
		local SHARD_COLUMNS = 2
		local SHARD_ROWS = 1
		local CRACK_TIME = 0.12
		local CRACK_GAP = 5
		local FLY_TIME = 0.6
		local MAX_DELAY = 0.07
		local SHARD_GRAVITY = 900
		local OPEN_TIME = 0.6
		local TOTAL_TIME = MAX_DELAY + CRACK_TIME + FLY_TIME

		local shardLayer = new("Frame", {
			Name = "ShardLayer",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(WINDOW_SIZE.X, WINDOW_SIZE.Y),
			BackgroundTransparency = 1,
			Visible = false,
			ZIndex = 5,
			Parent = screenGui,
		})
		local shardScale = new("UIScale", { Parent = shardLayer })

		local shardPieces = {}
		local shardConnection = nil

		local function clearShards()
			if shardConnection then
				shardConnection:Disconnect()
				shardConnection = nil
			end
			for _, piece in ipairs(shardPieces) do
				piece.shard:Destroy()
			end
			table.clear(shardPieces)
			shardLayer.Visible = false
		end

		local function makeSnapshot()
			local snapshot = Instance.new("Frame")
			snapshot.Size = UDim2.fromOffset(WINDOW_SIZE.X, WINDOW_SIZE.Y)
			snapshot.BackgroundTransparency = 1
			snapshot.BorderSizePixel = 0

			for _, child in ipairs(frame:GetChildren()) do
				if not child:IsA("UIScale") then
					local ok, copy = pcall(function()
						return child:Clone()
					end)
					if ok and copy then
						copy.Parent = snapshot
					end
				end
			end

			for _, descendant in ipairs(snapshot:GetDescendants()) do
				if descendant.Parent and descendant:IsA("GuiObject") and not descendant.Visible then
					descendant:Destroy()
				end
			end
			return snapshot
		end

		local function randomCuts(count, jitter)
			local cuts = { 0 }
			for i = 1, count - 1 do
				table.insert(cuts, (i + (math.random() - 0.5) * jitter) / count)
			end
			table.insert(cuts, 1)
			return cuts
		end

		local function createShards()
			clearShards()
			shardLayer.Position = frame.Position
			shardScale.Scale = windowScale.Scale
			shardLayer.Visible = true

			local snapshot = makeSnapshot()
			local center = WINDOW_SIZE / 2
			local yCuts = randomCuts(SHARD_ROWS, 0.35)
			local total = SHARD_COLUMNS * SHARD_ROWS

			for row = 1, SHARD_ROWS do
				local xCuts = randomCuts(SHARD_COLUMNS, 0.25)
				for column = 1, SHARD_COLUMNS do
					local x0 = math.floor(xCuts[column] * WINDOW_SIZE.X)
					local x1 = math.floor(xCuts[column + 1] * WINDOW_SIZE.X)
					local y0 = math.floor(yCuts[row] * WINDOW_SIZE.Y)
					local y1 = math.floor(yCuts[row + 1] * WINDOW_SIZE.Y)
					local pieceSize = Vector2.new(x1 - x0, y1 - y0)
					local home = Vector2.new(x0, y0) + pieceSize / 2

					local shard = Instance.new("CanvasGroup")
					shard.AnchorPoint = Vector2.new(0.5, 0.5)
					shard.Position = UDim2.fromOffset(home.X, home.Y)
					shard.Size = UDim2.fromOffset(pieceSize.X, pieceSize.Y)
					shard.BackgroundTransparency = 1
					shard.Parent = shardLayer

					local copy = (#shardPieces == total - 1) and snapshot or snapshot:Clone()
					copy.Position = UDim2.fromOffset(-x0, -y0)
					copy.Parent = shard

					local edge = Instance.new("UIStroke")
					edge.Color = C.accent
					edge.Thickness = 1.5
					edge.Transparency = 1
					edge.Parent = shard

					local depth = Instance.new("UIScale")
					depth.Parent = shard

					local direction = home - center
					direction = direction.Magnitude > 1 and direction.Unit or Vector2.new(0, -1)

					table.insert(shardPieces, {
						shard = shard,
						edge = edge,
						depth = depth,
						home = home,
						direction = direction,
						crackRotation = (math.random() - 0.5) * 5,
						velocity = direction * (260 + math.random() * 80)
							+ Vector2.new(0, -40 - math.random() * 60),
						spin = (direction.X < 0 and -1 or 1) * (25 + math.random() * 20),
						farScale = 0.3 + math.random() * 0.25,
						delay = math.random() * MAX_DELAY,
					})
				end
			end
		end

		local function applyShard(piece, tau)
			local t = math.max(0, tau - piece.delay)
			local crack = math.clamp(t / CRACK_TIME, 0, 1)
			local fly = math.max(0, t - CRACK_TIME)
			local flyProgress = math.clamp(fly / FLY_TIME, 0, 1)

			local offset = piece.direction * CRACK_GAP * crack
				+ piece.velocity * fly
				+ Vector2.new(0, 0.5 * SHARD_GRAVITY * fly * fly)
			local position = piece.home + offset

			piece.shard.Position = UDim2.fromOffset(position.X, position.Y)
			piece.shard.Rotation = piece.crackRotation * crack + piece.spin * fly
			piece.depth.Scale = 1 - (1 - piece.farScale) * flyProgress
			piece.edge.Transparency = 1 - 0.75 * crack
			piece.shard.GroupTransparency = math.clamp((flyProgress - 0.35) / 0.65, 0, 1)
		end

		local function glitchIn(myId)
			local basePosition = frame.Position
			local baseScale = windowScale.Scale
			local overlay = Instance.new("ScreenGui")
			overlay.Name = "OpusClient_Glitch"
			overlay.ResetOnSpawn = false
			overlay.IgnoreGuiInset = screenGui.IgnoreGuiInset
			overlay.DisplayOrder = screenGui.DisplayOrder + 1
			overlay.Parent = pg

			local colors = { Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255), Color3.new(0, 0, 0), Color3.new(1, 1, 1) }
			local started = os.clock()
			while os.clock() - started < 0.6 and animationId == myId do
				overlay:ClearAllChildren()
				local progress = (os.clock() - started) / 0.6
				local strength = 1 - progress

				frame.Position = basePosition + UDim2.fromOffset(
					math.random(-12, 12) * strength, math.random(-5, 5) * strength)
				windowScale.Scale = baseScale * (1 + (math.random() - 0.5) * 0.06 * strength)
				frame.Visible = math.random() > 0.15 * strength

				local position, size = frame.AbsolutePosition, frame.AbsoluteSize
				for _ = 1, math.random(2, 6) do
					local slice = Instance.new("Frame")
					slice.BorderSizePixel = 0
					slice.BackgroundColor3 = colors[math.random(1, #colors)]
					slice.BackgroundTransparency = 0.25 + math.random() * 0.5
					local height = math.random(3, 18)
					slice.Size = UDim2.fromOffset(size.X * (0.5 + math.random() * 0.6), height)
					slice.Position = UDim2.fromOffset(
						position.X + math.random(-30, 30) * strength + math.random() * size.X * 0.3,
						position.Y + math.random() * (size.Y - height))
					slice.Parent = overlay
				end

				if math.random() < 0.25 * strength then
					local flash = Instance.new("Frame")
					flash.BorderSizePixel = 0
					flash.BackgroundColor3 = colors[math.random(1, 2)]
					flash.BackgroundTransparency = 0.75
					flash.Position = UDim2.fromOffset(position.X, position.Y)
					flash.Size = UDim2.fromOffset(size.X, size.Y)
					flash.Parent = overlay
				end
				task.wait(0.03 + math.random() * 0.03)
			end
			overlay:Destroy()
			if animationId == myId then
				frame.Position = basePosition
				windowScale.Scale = baseScale
				frame.Visible = true
			end
		end

		function openMenu(withGlitch)
			animationId += 1
			local myId = animationId
			menuOpen = true
			menuIsOpen = true
			updateMenuBlur()

			windowScale.Scale = getFitScale()
			clampWindow()
			frame.Visible = false
			screenGui.Enabled = true

			if withGlitch then
				frame.Visible = true
				task.spawn(glitchIn, myId)
				return
			end

			createShards()
			for _, piece in ipairs(shardPieces) do
				applyShard(piece, TOTAL_TIME)
			end

			local started = os.clock()
			shardConnection = rs.RenderStepped:Connect(function()
				local u = math.clamp((os.clock() - started) / OPEN_TIME, 0, 1)
				local tau = TOTAL_TIME * (1 - u) ^ 2
				for _, piece in ipairs(shardPieces) do
					applyShard(piece, tau)
				end
				if u >= 1 then
					clearShards()
					if animationId == myId then
						frame.Visible = true
					end
				end
			end)
		end

		function closeMenu()
			animationId += 1
			local myId = animationId
			menuOpen = false
			menuIsOpen = false
			updateMenuBlur()

			createShards()
			frame.Visible = false

			local started = os.clock()
			shardConnection = rs.RenderStepped:Connect(function()
				local tau = os.clock() - started
				for _, piece in ipairs(shardPieces) do
					applyShard(piece, tau)
				end
				if tau >= TOTAL_TIME then
					clearShards()
					if animationId == myId then
						screenGui.Enabled = false
						frame.Visible = true
					end
				end
			end)
		end
	end

	local introPlaying = false

	local function tween(object, time, props, style, direction)
		local t = ts:Create(
			object,
			TweenInfo.new(time, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
			props
		)
		t:Play()
		return t
	end

	local function playIntro()
		introPlaying = true

		local PINK = Color3.fromRGB(255, 0, 255)
		local INK = Color3.fromRGB(45, 0, 45)

		BOOT.started = true
		local introGui = BOOT.gui
		local screen = BOOT.screen
		local terminal = BOOT.terminal

		local seal = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(150, 150),
			BackgroundTransparency = 1,
			Parent = screen,
		})
		local ringOuter = new("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = seal,
		})
		round(ringOuter, 75)
		new("UIStroke", { Color = PINK, Thickness = 3, Parent = ringOuter })
		local ringInner = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(100, 100),
			BackgroundTransparency = 1,
			Parent = seal,
		})
		round(ringInner, 50)
		new("UIStroke", { Color = PINK, Thickness = 2, Parent = ringInner })

		local textRing = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(150, 150),
			BackgroundTransparency = 1,
			Parent = seal,
		})
		local ringText = "OPUS  CLIENT  OPUS  CLIENT  "
		local count = #ringText
		for i = 1, count do
			local angle = (i - 1) / count * math.pi * 2
			local letter = ringText:sub(i, i)
			if letter ~= " " then
				new("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, math.sin(angle) * 62, 0.5, -math.cos(angle) * 62),
					Size = UDim2.fromOffset(14, 16),
					Rotation = math.deg(angle),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBlack,
					TextSize = 13,
					TextColor3 = PINK,
					Text = letter,
					Parent = textRing,
				})
			end
		end

		local logo = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(74, 74),
			BackgroundColor3 = LOGO_BG,
			BorderSizePixel = 0,
			Parent = seal,
		})
		round(logo, 37)
		new("UIStroke", { Color = PINK, Thickness = 1, Transparency = 0.3, Parent = logo })
		drawLogoMark(logo, 74)

		for _, visible in ipairs({ true, false, true, false, true }) do
			seal.Visible = visible
			task.wait(0.03)
		end

		local spinning = true
		task.spawn(function()
			while spinning do
				local roll = math.random()
				if roll < 0.3 then
					seal.Position = UDim2.new(0.5, math.random(-9, 9), 0.5, math.random(-6, 6))
					terminal.Position = UDim2.fromOffset(18 + math.random(-4, 4), 14 + math.random(-2, 2))
				else
					seal.Position = UDim2.fromScale(0.5, 0.5)
					terminal.Position = UDim2.fromOffset(18, 14)
				end
				seal.Visible = math.random() > 0.12
				screen.BackgroundColor3 = math.random() < 0.06 and Color3.fromRGB(60, 0, 60) or Color3.new(0, 0, 0)
				task.wait(0.03 + math.random() * 0.04)
			end
		end)

		local sealShownAt = os.clock()
		while BOOT.typing or os.clock() - sealShownAt < 0.5 do
			task.wait(0.03)
		end
		task.wait(0.2)
		spinning = false

		terminal.Visible = false
		seal.Visible = false
		screen.BackgroundColor3 = Color3.new(0, 0, 0)
		task.wait(0.08)
		for _, color in ipairs({ PINK, Color3.new(0, 0, 0), PINK, Color3.new(0, 0, 0), PINK }) do
			screen.BackgroundColor3 = color
			task.wait(0.04)
		end
		playToggleSound(true)

		local SKETCH_POSITION = UDim2.fromOffset(130, 130)
		local sketch = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = SKETCH_POSITION,
			Size = UDim2.fromOffset(150, 150),
			Rotation = 45,
			BackgroundTransparency = 1,
			Parent = screen,
		})
		local tile, gap = 64, 14
		local strokes = {}
		for row = 0, 1 do
			for column = 0, 1 do
				local piece = new("Frame", {
					Position = UDim2.fromOffset(column * (tile + gap) + 4, row * (tile + gap) + 4),
					Size = UDim2.fromOffset(tile, tile),
					BackgroundTransparency = 1,
					Parent = sketch,
				})
				round(piece, 5)
				strokes[#strokes + 1] = new("UIStroke", {
					Color = INK,
					Thickness = 3,
					Transparency = 1,
					Parent = piece,
				})
			end
		end

		for _, stroke in ipairs({ strokes[1], strokes[2], strokes[4], strokes[3] }) do
			stroke.Transparency = 0
			sketch.Position = SKETCH_POSITION + UDim2.fromOffset(math.random(-6, 6), math.random(-6, 6))
			task.wait(0.06)
		end

		for _ = 1, 8 do
			sketch.Position = SKETCH_POSITION + UDim2.fromOffset(math.random(-5, 5), math.random(-5, 5))
			sketch.Rotation = 45 + math.random(-3, 3)
			task.wait(0.05)
		end
		sketch.Position = SKETCH_POSITION
		sketch.Rotation = 45
		task.wait(0.15)

		screen.BackgroundColor3 = Color3.new(0, 0, 0)
		sketch.Visible = false
		task.wait(0.05)
		introGui:Destroy()
		introPlaying = false
		openMenu(true)
	end

	uis.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or introPlaying then
			return
		end
		if input.KeyCode == CONFIG.MenuKey then
			if menuOpen then
				closeMenu()
			else
				openMenu()
			end
		end
	end)

	watermarkClicked.Event:Connect(function()
		if introPlaying then
			return
		end
		if menuOpen then
			closeMenu()
		else
			openMenu()
		end
	end)

	screenGui.Enabled = false
	task.spawn(playIntro)
end
end
function ui.styles()
local C = {
	bgTop = Color3.fromRGB(92, 32, 44),
	bgBottom = Color3.fromRGB(38, 14, 20),
	panel = Color3.fromRGB(30, 11, 16),
	card = Color3.fromRGB(80, 30, 40),
	cardHover = Color3.fromRGB(98, 38, 50),
	inner = Color3.fromRGB(52, 19, 27),
	accent = Color3.fromRGB(250, 90, 106),
	accentDim = Color3.fromRGB(140, 56, 70),
	off = Color3.fromRGB(104, 76, 82),
	text = Color3.fromRGB(255, 250, 251),
	sub = Color3.fromRGB(226, 204, 209),
	line = Color3.fromRGB(160, 88, 100),
}

local MENU_STYLE = {
	Theme = "Бордовый",
	Blur = true,
	Toasts = true,
	MenuKey = "RightControl",
	Preview = true,

	Decor = false,
	DecorPosition = "Сверху справа",
	DecorSize = 170,
	DecorTransparency = 0,
	DecorLayer = "На меню",
	Glass = true,
	GlassLevel = 0.45,
}

local DECOR_POSITIONS = { "Сверху справа", "Сверху слева", "Слева от меню", "Снизу справа" }
local DECOR_LAYERS = { "На меню", "За меню" }

local KEYBINDS = {}
return C, MENU_STYLE, DECOR_POSITIONS, DECOR_LAYERS, KEYBINDS
end
function ui.sounds()
local SoundService = game:GetService("SoundService")

local SOUNDS = {
	Enabled = true,
	Style = "Пинг",
	Volume = 0.5,
	OnPitch = 1.25,
	OffPitch = 0.85,
}

local SOUND_STYLES = { "Пинг", "Клик", "Кнопка" }

local SOUND_IDS = {
	["Пинг"] = "rbxasset://sounds/electronicpingshort.wav",
	["Клик"] = "rbxasset://sounds/clickfast.wav",
	["Кнопка"] = "rbxasset://sounds/button.wav",
}

local toggleSound = Instance.new("Sound")
toggleSound.Name = "MenuToggleSound"
toggleSound.Parent = SoundService

local function playToggleSound(on)
	if not SOUNDS.Enabled then
		return
	end
	toggleSound.SoundId = SOUND_IDS[SOUNDS.Style] or SOUND_IDS["Пинг"]
	toggleSound.Volume = SOUNDS.Volume
	toggleSound.PlaybackSpeed = on and SOUNDS.OnPitch or SOUNDS.OffPitch
	toggleSound.TimePosition = 0
	toggleSound:Play()
end
return SOUNDS, SOUND_STYLES, playToggleSound
end
function ui:CreateWindow(config)
return self.window(config.Colors, config.Style, config.Config, config.PlayerGui, config.Player)
end
function ui.bindWindow(view, addModule)
function view:AddTab(name, group)
local section = self.createSection(name, group)
function section:AddToggle(def) return addModule(self, def) end
return section
end
return view
end
function ui.espScreen(pg)
local espScreen = Instance.new("ScreenGui")
espScreen.Name = "OpusClient_ESP2D"
espScreen.IgnoreGuiInset = true
espScreen.ResetOnSpawn = false
espScreen.DisplayOrder = 5
espScreen.Parent = pg
return espScreen
end
function ui.espWidgets(head, player, espFolder, espScreen, CONFIG)
	local gui = Instance.new("BillboardGui")
	gui.Name = player.Name .. "_Label"
	gui.Adornee = head
	gui.Size = UDim2.fromOffset(200, 50)
	gui.StudsOffset = Vector3.new(0, 2.5, 0)
	gui.AlwaysOnTop = true
	gui.Enabled = false
	gui.Parent = espFolder

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 22)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextStrokeTransparency = 0.4
	label.Text = ""
	label.Parent = gui

	local barBg = Instance.new("Frame")
	barBg.AnchorPoint = Vector2.new(0.5, 0)
	barBg.Position = UDim2.new(0.5, 0, 0, 26)
	barBg.Size = UDim2.fromOffset(80, 6)
	barBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	barBg.BorderSizePixel = 0
	barBg.Parent = gui

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(1, 1)
	barFill.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg

	local box2d = Instance.new("Frame")
	box2d.Name = player.Name .. "_Box2D"
	box2d.AnchorPoint = Vector2.new(0.5, 0.5)
	box2d.BackgroundTransparency = 1
	box2d.BorderSizePixel = 0
	box2d.Visible = false
	box2d.Parent = espScreen

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Thickness = CONFIG.BoxThickness
	boxStroke.Parent = box2d

	local boxOutline = Instance.new("Frame")
	boxOutline.AnchorPoint = Vector2.new(0.5, 0.5)
	boxOutline.Position = UDim2.fromScale(0.5, 0.5)
	boxOutline.Size = UDim2.new(1, 2, 1, 2)
	boxOutline.BackgroundTransparency = 1
	boxOutline.ZIndex = 0
	boxOutline.Parent = box2d
	local outlineStroke = Instance.new("UIStroke")
	outlineStroke.Color = Color3.fromRGB(0, 0, 0)
	outlineStroke.Transparency = 0.4
	outlineStroke.Thickness = 1
	outlineStroke.Parent = boxOutline

	local tracer = Instance.new("Frame")
	tracer.Name = player.Name .. "_Tracer"
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BorderSizePixel = 0
	tracer.Visible = false
	tracer.Parent = espScreen
return gui, label, barBg, barFill, box2d, boxStroke, tracer
end
function ui.presetCard(presetsSection, index, preset, C, onApply)
local ts = game:GetService("TweenService")
		local card = new("TextButton", {
			LayoutOrder = index,
			BackgroundColor3 = C.card,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Parent = presetsSection.grid,
		})
		round(card, 8)
		local stroke = outline(card, C.line, 0.65)
		local cardScale = new("UIScale", { Parent = card })

		local icon = new("Frame", {
			Position = UDim2.fromOffset(10, 8),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = C.accent,
			BorderSizePixel = 0,
			Parent = card,
		})
		round(icon, 6)
		drawIcon(icon, preset.icon, 12)(C.text)

		new("TextLabel", {
			Position = UDim2.fromOffset(40, 8),
			Size = UDim2.new(1, -50, 0, 22),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.text,
			Text = preset.name,
			Parent = card,
		})
		local descLabel = new("TextLabel", {
			Position = UDim2.fromOffset(12, 32),
			Size = UDim2.new(1, -24, 0, 28),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = C.sub,
			Text = preset.desc,
			Parent = card,
		})

card.MouseButton1Click:Connect(function()
onApply()
descLabel.Text = "Применено"
descLabel.TextColor3 = C.accent
task.delay(1.4, function()
descLabel.Text = preset.desc
descLabel.TextColor3 = C.sub
end)
end)
		local hover = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		card.MouseEnter:Connect(function()
			ts:Create(card, hover, { BackgroundColor3 = C.cardHover }):Play()
			ts:Create(cardScale, hover, { Scale = 1.025 }):Play()
			stroke.Color = C.accent
			stroke.Transparency = 0.3
		end)
		card.MouseLeave:Connect(function()
			ts:Create(card, hover, { BackgroundColor3 = C.card }):Play()
			ts:Create(cardScale, hover, { Scale = 1 }):Play()
			stroke.Color = C.line
			stroke.Transparency = 0.65
		end)

		table.insert(presetsSection.cards, { frame = card, name = preset.name, desc = preset.desc })
end
function ui.configForm(configSection, C)
	local createCard = new("Frame", {
		LayoutOrder = 0,
		BackgroundColor3 = C.card,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Parent = configSection.grid,
	})
	round(createCard, 8)
	outline(createCard, C.accent, 0.55)

	local createTitle = new("TextLabel", {
		Position = UDim2.fromOffset(12, 6),
		Size = UDim2.new(1, -24, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.text,
		Text = "Новый конфиг",
		Parent = createCard,
	})

	local nameBox = new("TextBox", {
		Position = UDim2.fromOffset(12, 32),
		Size = UDim2.new(1, -58, 0, 24),
		BackgroundColor3 = C.inner,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		PlaceholderText = "Название...",
		PlaceholderColor3 = C.sub,
		ClearTextOnFocus = false,
		Text = "",
		Parent = createCard,
	})
	round(nameBox, 6)
	new("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = nameBox })

	local saveButton = new("TextButton", {
		Position = UDim2.new(1, -40, 0, 32),
		Size = UDim2.fromOffset(28, 24),
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		AutoButtonColor = true,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = C.text,
		Text = "+",
		Parent = createCard,
	})
	round(saveButton, 6)

	local flashId = 0
	local function flashTitle(text, color)
		flashId += 1
		local myId = flashId
		createTitle.Text = text
		createTitle.TextColor3 = color or C.text
		task.delay(1.6, function()
			if flashId == myId then
				createTitle.Text = "Новый конфиг"
				createTitle.TextColor3 = C.text
			end
		end)
	end
return nameBox, saveButton, flashTitle
end
function ui.configCard(configSection, C, index, name, descText, isAutoload)
			local card = new("TextButton", {
				LayoutOrder = index,
				BackgroundColor3 = C.card,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				Parent = configSection.grid,
			})
			round(card, 8)

			local icon = new("Frame", {
				Position = UDim2.fromOffset(12, 13),
				Size = UDim2.fromOffset(12, 12),
				BackgroundColor3 = isAutoload and C.accent or C.accentDim,
				BorderSizePixel = 0,
				Parent = card,
			})
			round(icon, 3)

			new("TextLabel", {
				Position = UDim2.fromOffset(32, 8),
				Size = UDim2.new(1, -62, 0, 22),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextColor3 = C.text,
				Text = name,
				Parent = card,
			})

			local desc = new("TextLabel", {
				Position = UDim2.fromOffset(12, 32),
				Size = UDim2.new(1, -24, 0, 28),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextSize = 11,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = C.sub,
				Text = descText,
				Parent = card,
			})

			local dots = new("TextButton", {
				Position = UDim2.new(1, -28, 0, 6),
				Size = UDim2.fromOffset(22, 22),
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = 2,
				Parent = card,
			})
			drawIcon(dots, "kebab", 14)(C.sub)

return card, desc, dots
end
function ui.configPage(name, makeScroller)
			local page = makeScroller(name .. "_Config")
			new("UIListLayout", {
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = page,
			})
return page
end
function ui.billFace(part, face, INK_GREEN)
			local gui = Instance.new("SurfaceGui")
			gui.Face = face
			gui.CanvasSize = Vector2.new(100, 46)
			gui.LightInfluence = 1
			gui.Parent = part

			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamBlack
			label.TextScaled = true
			label.TextColor3 = INK_GREEN
			label.Text = "$"
			label.Parent = gui

			local border = Instance.new("UIStroke")
			border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			border.Color = INK_GREEN
			border.Thickness = 3
			border.Transparency = 0.3
			border.Parent = label
return label, border
end
function ui.binaryDigit(attachment)
			local billboard = Instance.new("BillboardGui")
			billboard.Adornee = attachment
			billboard.LightInfluence = 0
			billboard.MaxDistance = 300
			billboard.Parent = attachment
			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.Arcade
			label.TextScaled = true
			label.TextStrokeColor3 = Color3.new(0, 0, 0)
			label.Text = math.random() < 0.5 and "0" or "1"
			label.Parent = billboard
return billboard, label
end
function ui.vignette(pg)
	local vignetteGui = Instance.new("ScreenGui")
	vignetteGui.Name = "OpusClient_Vignette"
	vignetteGui.IgnoreGuiInset = true
	vignetteGui.ResetOnSpawn = false
	vignetteGui.DisplayOrder = -10
	vignetteGui.Enabled = false
	vignetteGui.Parent = pg

	local vignetteGradients = {}
	for _, spec in ipairs({
		{ UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.22), 90 },
		{ UDim2.fromScale(0, 0.78), UDim2.fromScale(1, 0.22), -90 },
		{ UDim2.fromScale(0, 0), UDim2.fromScale(0.16, 1), 0 },
		{ UDim2.fromScale(0.84, 0), UDim2.fromScale(0.16, 1), 180 },
		}) do
		local strip = Instance.new("Frame")
		strip.Position = spec[1]
		strip.Size = spec[2]
		strip.BackgroundColor3 = Color3.new(0, 0, 0)
		strip.BorderSizePixel = 0
		strip.Parent = vignetteGui
		local gradient = Instance.new("UIGradient")
		gradient.Rotation = spec[3]
		gradient.Parent = strip
		table.insert(vignetteGradients, gradient)
	end
return vignetteGui, vignetteGradients
end
function ui.petLabel(anchorPart, s, style, textColor)
			local billboard = Instance.new("BillboardGui")
			billboard.Size = UDim2.fromOffset(140, 22)
			billboard.StudsOffset = Vector3.new(0, (style == "Кролик" and 1.8 or 0.9) * s + 0.6, 0)
			billboard.Adornee = anchorPart
			billboard.Parent = anchorPart

			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamBold
			label.TextSize = 13
			label.TextStrokeTransparency = 0.4
			label.TextColor3 = textColor
			label.Parent = billboard
return label
end
function ui.hitNumber(part, color, damage)
			local billboard = Instance.new("BillboardGui")
			billboard.Size = UDim2.fromOffset(100, 30)
			billboard.StudsOffset = Vector3.new(0, 1, 0)
			billboard.AlwaysOnTop = true
			billboard.Adornee = part
			billboard.Parent = part

			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamBlack
			label.TextSize = 20
			label.TextColor3 = color
			label.TextStrokeTransparency = 0.3
			label.Text = "-" .. tostring(math.max(1, math.floor(damage + 0.5)))
			label.Parent = billboard
return billboard, label
end
function ui.hitMarker(root, color, hitFolder)
			local billboard = Instance.new("BillboardGui")
			billboard.Size = UDim2.fromOffset(34, 34)
			billboard.AlwaysOnTop = true
			billboard.Adornee = root
			billboard.Parent = hitFolder

			local marker = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(22, 22),
				BackgroundTransparency = 1,
				Rotation = 45,
				Parent = billboard,
			})
			local scale = new("UIScale", { Scale = 1.4, Parent = marker })

			local bars = {}
			for _, spec in ipairs({
				{ UDim2.new(0.5, 0, 0, 3), UDim2.fromOffset(2, 7) },
				{ UDim2.new(0.5, 0, 1, -3), UDim2.fromOffset(2, 7) },
				{ UDim2.new(0, 3, 0.5, 0), UDim2.fromOffset(7, 2) },
				{ UDim2.new(1, -3, 0.5, 0), UDim2.fromOffset(7, 2) },
				}) do
				local bar = new("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = spec[1],
					Size = spec[2],
					BackgroundColor3 = color,
					BorderSizePixel = 0,
					Parent = marker,
				})
				new("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Transparency = 0.4, Parent = bar })
				table.insert(bars, bar)
			end
return billboard, scale, bars
end
return ui