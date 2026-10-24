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