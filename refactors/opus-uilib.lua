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