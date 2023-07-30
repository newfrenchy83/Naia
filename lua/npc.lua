--
-- Fake NPC AI logic library
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2006 - 2023 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

---
-- [npc_bird_behavior]
--     types=... # list of unit types that will be considered for movement
--     side=...  # side whose units will be considered; defaults to the current
--               # playing side
--     x1,y1=... # top left corner of the movement area
--     x2,y2=... # bottom right corner of the movement area
-- [/npc_bird_behavior]
---
function wesnoth.wml_actions.npc_bird_behavior(cfg)
	local map_w, map_h, map_border = wesnoth.get_map_size()

	local function do_error(msg)
		wml.error("[npc_bird_behavior]: " .. msg)
	end

	if map_border ~= 1 then
		do_error("maps with border_size != 1 are not supported yet")
	end

	local function on_board(x, y)
		return (x > 0 and x <= map_w) and (y > 0 and y <= map_h)
	end

	local function default(value, default_value)
		if value == nil or value == "" then
			return default_value
		else
			return value
		end
	end

	local types = cfg.types or do_error("no unit types specified")

	local side_num = cfg.side or wesnoth.current.side

	local x1 = default(cfg.x1, 1)
	local y1 = default(cfg.y1, 1)

	local x2 = default(cfg.x2, map_w)
	local y2 = default(cfg.y2, map_h)

	if not on_board(x1,y1) then
		do_error(("(x1, y1) is (%d, %d), which is not on map (%d x %d)"):format(x1, y1, map_w, map_h))
	end
	if not on_board(x2,y2) then
		do_error(("(x2, y2) is (%d, %d), which is not on map (%d x %d)"):format(x2, y2, map_w, map_h))
	end

	local function in_npc_region(x, y)
		return (x >= x1 and x <= x2) and (y >= y1 and y <= y2)
	end

	-- wesnoth.message(("moving birds in area ((%d, %d), (%d, %d))"):format(x1, y1, x2, y2))

	--
	-- Store required units
	--

	local npcs = wesnoth.units.find_on_map {
		type = types, side = side_num,
		x = ("1-%d"):format(map_w),
		y = ("1-%d"):format(map_h)
	}

	for k, npc in ipairs(npcs) do
		if not in_npc_region(npc.x, npc.y) then
			wesnoth.wml_actions.kill {
				x = npc.x, y = npc.y,
				animate = false, fire_event = true
			}
		elseif npc.moves > 0 then
			local move_steps = npc.moves
			local oob = false
			local endpoint = { x = npc.x, y = npc.y }
			local path = { x = npc.x, y = npc.y, direction = mathx.random_choice("n,s,ne,nw,se,sw") }

			-- TODO: quit the course when encountering a unit?
			--
			-- Perhaps we should also use proper pathfinding instead of
			-- blindly testing each individual hex in the chosen direction,
			-- but we'd somehow need to override movement costs for units
			-- in impassable terrain (e.g. Shaxthal Worms in cave wall,
			-- regular birds on Impassable mountains).

			for j = 0, move_steps, 1 do
				if oob then break end

				local target = wesnoth.map.find({
					{ "filter_adjacent_location", {
						adjacent = "-" .. path.direction,
						x = endpoint.x,
						y = endpoint.y
					} }
				})[1]

				if (not target) or (not in_npc_region(target[1], target[2])) then
					oob = true
				else
					path.x = ("%s,%d"):format(path.x, target[1])
					path.y = ("%s,%d"):format(path.y, target[2])

					endpoint.x = target[1]
					endpoint.y = target[2]
					npc.moves = npc.moves - 1
				end
			end

			-- Move the bird

			npc:extract()

			-- wesnoth.message(("x = %s; y = %s"):format(path.x, path.y))

			local npc_cfg = npc.__cfg

			wesnoth.wml_actions.move_unit_fake {
				type = npc_cfg.type,
				gender = npc_cfg.gender,
				variation = npc_cfg.variation,
				image_mods = npc.image_mods,
				side = npc_cfg.side,
				x = path.x,
				y = path.y
			}

			-- Birds found moving out of their movement area
			-- are not restored

			if not oob then
				npc.x, npc.y = wesnoth.paths.find_vacant_hex(endpoint.x, endpoint.y)
				npc.facing = path.direction

				npc:to_map()
			end

			-- TODO: fire moveto or death events accordingly

			wesnoth.wml_actions.redraw {}

		end
	end

end
