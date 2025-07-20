pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()

	-- map coords & size
	map_size = 16
	tile_size = 8
	map_grid = {}
	selected_x = 1
	selected_y = 1
	
 init_map()
 
	sp=7
 speed = .03
 
	gem_ammt = 0
	gem_rate = 0.01
	gem_tic = 0
	
	gem_plr_cooldown = 10
	gem_plr_rate = 0.2
	gem_by_plr = false
	
	gem = {}
	
	gold_ammt = 0
	gold_per_gem = 5
	gold_to_add = 0
	
	dwarfs_limit = 4
	dwarfs_cost = 20
	dwarfs_tic_rate = 0.001
	
	dwarfs_active = 0
	mining_dwarfs = {}
	
	trader_anim_active = false
	trader_arrival = 100
	trader_cooldown = 0.1
	trader_maxcap = 20
	
	upgrade_menu_active = false
	selected_upgrade = ""
	choosing_map_upgrade = false
	selectedoption = 1
	
	debug_menu = false
	
	
end

function _update60()

tile_selector()
upgrade_menu()
gem_tic += gem_rate

if gem_by_plr == true then
	gem_plr_cooldown -= gem_plr_rate
end

if gem_plr_cooldown <= 0 then
	gem_plr_cooldown = 10
	gem_by_plr = false
end

if btnp(🅾️) then
	if upgrade_menu_active then
		upgrade_menu_active = false
	elseif gem_plr_cooldown >= 10 then
			create_gem()
			gem_by_plr = true
		end
end

if btnp(❎) then
--	create_gem()
--	create_dwarfs()
--	gem_ammt += 1
	if not upgrade_menu_active then
			upgrade_menu_active = true
	else
			upgrade_menu_active = false
	end
--	build_upgrade(selected_x, selected_y, selected_upgrade)
end

if btnp(❎) and btnp(🅾️) and debug_menu == false then
 debug_menu = true
 elseif btnp(❎) and btnp(🅾️) and debug_menu == true then
 debug_menu = false
end

if dwarfs_active >= 1 then
	for n=0, dwarfs_active do
  gem_tic += gem_rate + dwarfs_tic_rate
 end 
end

 if gem_tic >= 10 then
  create_gem()
		gem_tic = 0
	end

	
	move_gem()
	
	if gem_ammt >= dwarfs_cost then
		create_dwarfs()
	 dwarfs_cost += 20
	end
	
	trader_logic()

	
end

function _draw()
cls()
rectfill(0, 10, 40, 120, 3)
rectfill(87, 10, 140, 120, 3)

if choosing_map_upgrade == true then
	draw_map()
end

for dwarf in all(mining_dwarfs) do	
	if sp < 9-speed then
		sp += speed
	else
	 sp = 7
	end
	
	spr(sp, 100, 100)
end

for g in all(gem) do
	circfill(g.gem_x, g.gem_y, g.gem_r, g.gem_col)
end

spr(1, 48, -4, 4, 4)

if trader_arrival < 50 then
	spr(48, 10+trader_cooldown, 120)
end

if debug_menu then
	print("gem tic rate : "..gem_tic, 0, 0, 10)
	print("gem_speed : "..gem_rate, 0, 6, 10)
	print("gems : "..gem_ammt,0, 12, 10)
	print("dwarfs : "..dwarfs_active,0 ,18, 10)
	print("plr mining : "..gem_plr_cooldown, 0, 24, 10)
	print("trader route : "..trader_arrival, 0, 30, 10)
	print("gold adding : "..gold_to_add, 0, 42, 10)
	print("total gold : "..gold_ammt, 0, 36, 10)
end 

if upgrade_menu_active == true then
	draw_upgrade_menu()
end	



end

-->8
function create_gem()
	
	local g = {
		gem_x = 52 + flr(rnd(20)),
		gem_y = 20,
		gem_r = 0.2,
		gem_col = 8 + rnd(5)
	}
	
	add(gem, g)
	gem_ammt += 1

end

function move_gem()
	for g in all(gem) do
		local can_fall = true
		local can_slide_left = true
		local can_slide_right = true
		 
		 
		-- check if gem can fall 
		 for other in all(gem) do
		 	if other != g then
		 		-- checks if gem is blocked below
		 		if abs(g.gem_x - other.gem_x) < 1 and g.gem_y + 1 == other.gem_y then		
						can_fall = false
					end
					
					-- checks left
					if abs(g.gem_x - 2 - other.gem_x) < 2 and g.gem_y + 1 == other.gem_y then		
						can_slide_left = false
					end
					
					--checks right
					if abs(g.gem_x + 2 - other.gem_x) < 2 and g.gem_y + 1 == other.gem_y then		
						can_slide_right = false
					end
				end
			end


			if g.gem_y >= 120 then
				g.gem_y = 120
			elseif can_fall then 
				g.gem_y += 1
			elseif not can_fall then
			if can_slide_left then
				g.gem_x -= 1
				g.gem_y += 1
			elseif can_slide_right then
				g.gem_x += 1
				g.gem_y += 1
			end
			end
	end
		
end

function trader_logic()
	
	local removed = 0
	trader_arrival -= trader_cooldown
	
	if trader_arrival <= 0 then
		trader_anim_active = true
	end
	
	if trader_anim_active == true then
		if gem_ammt >= 1 then
			for i = #gem, 1, -1 do
			if removed < trader_maxcap then
				gold_to_add += gold_per_gem
				del(gem, gem[i])
				removed += 1
				gem_ammt -= 1
			end
		end
		gold_ammt += gold_to_add
		gold_to_add = 0
		trader_arrival = 100
		trader_anim_active = false
	end
end

end


function create_dwarfs()
	local d = {
		cost = dwarfs_cost
		}
		add(mining_dwarfs, d)
		dwarfs_active += 1
end

function upgrade_menu()
	
	if btnp(⬆️) then
		selectedoption = selectedoption - 1
		if selectedoption < 1 then
			selectedoption = 3
		end
		
	elseif btnp(⬇️) then
	 selectedoption = selectedoption + 1
	 if selectedoption > 3 then
	  selectedoption = 1
	 end
	end

	if btnp(🅾️) then
		if selectedoption == 1 then
			selected_upgrade = "housing"
		elseif selectedoption == 2 then
			selected_upgrade = "forge"
		elseif selectedoption == 3 then
			selected_upgrade = "road"
	end
		choosing_map_upgrade = true
		tile_selector()
	end
	
end

function draw_upgrade_menu()
	rectfill(8, 10, 120, 120, 2)
	print(selectedoption)
	print("buy houses ", 10, 14, selectedoption == 1 and 10 or 7)
	print("buy forge ", 10, 26, selectedoption == 2 and 10 or 7)
	print("upgrade road ", 10, 38, selectedoption == 3 and 10 or 7)

--	rect(8, 10, 120, 120, 2)
end

-- initialize map

function init_map()

	for y=1,map_size do
		map_grid[y] = {}
		for x=1,map_size do
			map_grid[y][x] = {
				housing = false,
				forge = false,
				road = false
			}
		end
	end
	
	map_grid[3][4].housing = true
	map_grid[1][1].forge = true
	map_grid[16][16].road = true
end

function tile_selector()
	if btnp(⬅️) then selected_x = max(1, selected_x - 1) end
	if btnp(➡️) then selected_x = min(map_size, selected_x + 1) end	
    if btnp(⬆️) then selected_y = max(1, selected_y - 1) end
	if btnp(⬇️) then selected_y = min(map_size, selected_y + 1) end

	if btnp(🅾️) then
		build_upgrade(selected_x, selected_y, selected_upgrade)
	end
end

function build_upgrade(x, y, upgrade)
	if upgrade == "housing" then
		map_grid[y][x] = {
			housing = true
		}
	elseif upgrade == "forge" then
		map_grid[y][x] = {
			forge = true
		}
	elseif upgrade == "road" then
		map_grid[y][x] = {
			road = true
		}
	end

end

function draw_map()
	for y=1,map_size do
  for x=1,map_size do
   local tile = map_grid[y][x]
   local px = (x-1)*tile_size
   local py = (y-1)*tile_size

   if tile.forge then
    rectfill(px, py, px+7, py+7, 8) -- gray
   elseif tile.housing then
    rectfill(px, py, px+7, py+7, 11) -- green
   elseif tile.road then
    rectfill(px, py, px+7, py+7, 9) -- red
   else
    rectfill(px, py, px+7, py+7, 1) -- dark blue
   end
  end
  
  local sel_px = (selected_x - 1)*tile_size
  local sel_py = (selected_y - 1)*tile_size
		rect(sel_px, sel_py, sel_px+7, sel_py+7, 10)
end
end

-->8
-- animations

__gfx__
00000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000ff00000011000000000000000000000000000000000000000000000000000000000000000000000000000
007007000000000000000000000000000000000000000000000ff000000ff000000ff00000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000f0000f000f00f00000000000011110000000000000000000000000000000000000000000000000000000000
0007700000449999999999999999999999994400f004400f0f0110f00011110000f11f0000000000000000000000000000000000000000000000000000000000
0070070000449999999999999999999999994400000110000004400000f00f000004400000000000000000000000000000000000000000000000000000000000
0000000000449999aaa9999999999aaa999944000000000000011000000440000000000000000000000000000000000000000000000000000000000000000000
000000000004999999aaaaa99aaaaaaa999940000010010000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000499aa99aaa9999999aaaa999940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000004999a99a99aa999aaaaa9999940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000444999999a9a9aaaaaa99994440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000044499aaa9aaa9aaaaa9aa994440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000044444aaaaaaa9aaaaaaa9444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000044444a9aaaaa9aaaaaaa9444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000444449a99aaa9aaaaaaaa444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000444449aaaaaa9aaa99999444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000044444444aaaaaaa999999444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000004444444444aaaaaa44444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000044444444444aaaa444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000044444444444aa04444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000004444444404440444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000044444044444044444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40400044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55500555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56500565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55500555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
