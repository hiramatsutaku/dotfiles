local colors = require("colors")
local settings = require("settings")

-- Register custom event for AeroSpace workspace change
sbar.add("event", "aerospace_workspace_change")

local spaces = {}

local colors_spaces = {
	[1] = colors.cmap_1,
	[2] = colors.cmap_2,
	[3] = colors.cmap_3,
	[4] = colors.cmap_4,
	[5] = colors.cmap_5,
	[6] = colors.cmap_6,
	[7] = colors.cmap_7,
	[8] = colors.cmap_8,
	[9] = colors.cmap_9,
}

for i = 1, 9, 1 do
	local space = sbar.add("item", "space." .. i, {
		icon = {
			font = {
				family = settings.font.numbers,
				size = 14,
			},
			string = i,
			padding_left = 8,
			padding_right = 8,
			color = colors_spaces[i],
			highlight_color = colors.tn_black3,
		},
		label = { drawing = false },
		padding_right = 2,
		padding_left = 2,
		background = {
			color = colors.transparent,
			height = 22,
			corner_radius = 6,
		},
	})

	spaces[i] = space

	space:subscribe("aerospace_workspace_change", function(env)
		local focused = env.FOCUSED_WORKSPACE == tostring(i)
		space:set({
			icon = { highlight = focused },
			background = {
				color = focused and colors_spaces[i] or colors.transparent,
			},
		})
	end)

	space:subscribe("mouse.clicked", function(_)
		sbar.exec("aerospace workspace " .. i)
	end)
end

sbar.add("bracket", {
	spaces[1].name,
	spaces[2].name,
	spaces[3].name,
	spaces[4].name,
	spaces[5].name,
	spaces[6].name,
	spaces[7].name,
	spaces[8].name,
	spaces[9].name,
}, {
	background = {
		color = colors.background,
		border_color = colors.accent3,
		border_width = 2,
	},
})

sbar.add("item", { width = 6 })

-- Initialize with current workspace
sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
	local focused = focused_workspace:gsub("%s+", "")
	for i = 1, 9, 1 do
		local is_focused = focused == tostring(i)
		spaces[i]:set({
			icon = { highlight = is_focused },
			background = {
				color = is_focused and colors_spaces[i] or colors.transparent,
			},
		})
	end
end)
