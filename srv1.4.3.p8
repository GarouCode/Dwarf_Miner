pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- space rogue v1.4.3
-- by nenga
-- last modified 1/20/25

-- changed max lvl for upgrades,
-- to lvl 10

-- changed enem_shoot_a,
-- spawn freq

-- working on barwidth for,
-- wingcanons

-- sprite for meteor turret,
-- movement logic for turret,
-- adjust movement speed for 
-- turret,

-- added shake function for
-- player dmg feedback,
-- adjust shake amount for
-- each dmg type

-- added borders to 
-- health & shields

-- added raining stars 

-- turret logic functional,
-- needs charge function,
-- movement (still or side to side?)
-- health system

-- fixed explosion effect

-- added combo system
-- explosion radius for combo,
-- needs adjust or will dissapear

-- adjusted enem_shoot_a respawn & amount on screen

-- add variants of enemies_a,
-- pre-baked enemies, shmup style

-- added start menu

-- changed enem_shoot cooldown

-- gem attractor works, adjust
-- for levels

function _init()
	t=0
	tover=0
	shake=0

 player_ship()
 
 --number of runs
 run_number = persistent_upgrades.run_num
 --weapons info
 
 bullets = {}
 bulletsdy = -2
 firecooldown_main = 18
 firecooldown_side = persistent_upgrades.upgraded_items.firecooldown_side
 cooldowntimer_main = 0
 cooldowntimer_side = 0
 cooldown_side_ready = 0
 cooldown_side_int = 6
 
 plr_bomb = {}
 bombcooldown = 120
 bombcooldowntimer = 0
 bmb_exploradi = 20
 bomb_ready_timer = 0
 bomb_ready_int = 6
 
 plr_orbs = {}
 orbit_radius = 10
 orbs_num = 0
 orbs_cooldown = {value = 100}
 orbs_cooldowntimer = 0
 
 // rain math
 pi = 3.1415927
 angle_increment = 2 * pi / orbs_num
 current_angle = 0
 start_angles = {0, pi/2, pi, 3*pi/2}

	chosenupgrades = {}
 
 enemies = {}
 enemies_shoot_a = {}
 respawn_shoot_a_timer = 0
 
 enemiesb = {}
 enemiesc = {}
 
 enemiesd = {}
 enemiesd_fire_cooldown = 40
 enemiesd_fire_timer = 0
 enemiesd_bullets = {}
 
 enem_c_respawn_timer = 0
 
 enem_b_respawn_timer = 0
 
 enem_d_respawn_timer = 0
 
 enem_fire_cooldown = 40
 enem_shoot_bullets = {}
  
 explosions = {}
 explosion_radius = 3
 bmb_explosions = {}
 
 credits = {
 num=persistent_upgrades.num_creds
 }
 
 multiplier_timer = 70
 multiplier_score = 0
 previous_multiplier_score = 0
 highest_multiplier_score = 0
 
 define_shipupgrades()
	define_shopupgrades()
 
 lvl_gems = {}
 maxlvl = 20
 barwidth = (ship.lvl / maxlvl) * 128
 
 shieldrefill = persistent_upgrades.upgraded_items.shieldrefill
 shieldpowerups = {}
 shield_spawn_int = 1600
 shield_spawn_timer = 0
 shield_spawn_timer_b = 0
  
 healthbarwidth = flr(ship.h * 28 / 4)
 shieldbarwidth = flr(ship.shields * 28 / ship.shieldmax)
 bombbarwidth = flr((bombcooldown - bombcooldowntimer) * 14 / bombcooldown)
 firecooldownwidth = flr((firecooldown_side - cooldowntimer_side) * 14 / firecooldown_side)
 
 pend_cred_indicator = {}
 
 shop_menu_check = 0
 shop_lvl_req = 0
 
 game_over_state = false
 shopscreen_active = false
 hold_to_continue = 0
	
	startmenu = persistent_upgrades.initial_bootup
 gamestate = false
 upgrademenu = false
 shopupgrade = false
 selectedoption = 1
	
 r={}
 for i=1,20 do
 	r[i]=
 		{x=rnd(256)-128,
 			y=rnd(128),v=1+flr(rnd(2))}
 end
 
 stars = {}
 for i=1,128 do
 	add(stars,{
 		x=rnd(128),
 		y=rnd(128),
 		s=rnd(2)+1
 		})
 end
 
 shine_timer=0
 shine_cooldown=70
 shine_x=-10
 shine_y=0
 shine_speed=1
 max_shine=80
 
 
 --base building variables/tables
	 
 
 if persistent_upgrades.initial_bootup == 1 then
  start_menu()
 else
 	start()
 end
 
-- start()
-- music(0, 0, 7)
end

function update_game()
 
-- if startmenu then
-- 	start_menu()
-- end
 
	if gamestate == true then
		rungame()
	end
	
	if upgrademenu then
	
	function selectrandomupgrade(upgradetable) 
  local randomindex = flr(rnd(#upgradetable)) + 1
  return upgradetable[randomindex].effect
	end
	
	 --navigate menu
	 
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
		
		elseif btnp(❎) then
			local selectedupgrade
			if selectedoption == 1 then
				selectedupgrade = selectrandomupgrade(bulletupgrades)
			elseif selectedoption == 2 then
				selectedupgrade = selectrandomupgrade(bombupgrades)
		 elseif selectedoption == 3 then
		 	selectedupgrade = selectrandomupgrade(orbupgrades)
		 end
		 
		 if selectedupgrade then
		 	selectedupgrade()
 	 end

		 
	 	upgrademenu = false
	 	gamestate = true
	 	ship.lvlgauge = 0
	
  end
 end
end


function draw_game()
 cls()

if ship.lvl > 5 then
 for i=1,#r do
 	if r[i].v==1 then
 		l=4
 	else
 	 l=2
 	end
 	line
 	(r[i].x,r[i].y,r[i].x-l,
 		r[i].y-l,6-1*(r[i].v-1))
 end
end
 
 for st in all(stars) do
 	pset(st.x,st.y,st.s)
 end

	line(0,0,40,0,3)
	line(0,0,0,20,3)

 print("SCORE: "..ship.score, 4, 3, 9)
 print("CREDS: "..credits.num, 10)
	print("COMBO: "..multiplier_score,7)
	line(shine_x, shine_y, 40, shine_y, 3)
--	print(explosion_radius)
--	print(enem_b_respawn_cooldown)
--	print(enem_b_respawn_timer)
-- print(cooldowntimer_main)
-- print(firecooldown_side)
-- print(bulletsdy)
-- print(ship.bomblvl)
-- print(bmb_exploradi)
-- print(orbs_cooldowntimer) 
-- print(credits.num == true)
-- print(ship.shieldmax)
--			print(enem_fire_timer)
--			print(enem_fire_cooldown)
--			print(enem_shoots_bullets)
--   print(ship.shields)
--		 print(ship.shields < 0.2 * ship.shieldmax)
--   print(shield_spawn_timer)
--   print(ship.speed)
--   print(shieldrefill)
--   if shieldpowerups then
--   print(shieldpowerups)
--   end
--   print(t)
--   print(respawn_shoot_a_timer)
--			print(enemiesd)
--			print(shake)
--			print(enemiesd_fire_timer)
--   print(enemiesd_bullets)
-- 		print(enem_shoot_bullets)

 
 if orbs_num >= 1 and orbs_num < 10 then
 	print(#plr_orbs, 106, 17, 10)
 	spr(7, 109, 16)
 elseif orbs_num >= 10 then
 	print(#plr_orbs, 103, 17)
 	spr(7, 109, 16)
 end
 
  
 print("level: "..ship.lvl.."", 0, 120, 7)
 rect(0, 127, barwidth, 128, 10) 
 
 if not ship.imm or t%8 < 4 then
 	spr(ship.sp,ship.x,ship.y)
 	spr(ship.animsp, ship.x, ship.y+7)
 end
 
// if ship.shielddmg == 1 then
//  circ(ship.x + 3, ship.y + 3.2, 7, 12) 
// end
 
 for ex in all(explosions) do
 	circ(ex.x,ex.y,ex.t/explosion_radius,8+ex.t%3)
 end
 
 for bmb_ex in all(bmb_explosions) do
 	circ(bmb_ex.x,bmb_ex.y,bmb_ex.radius,12 + bmb_ex.t % 3)
 end

 
 for b in all(bullets) do
--  rect(b.box.x1, b.box.y1, b.box.x2, b.box.y2, 11)
  b.flash_timer = b.flash_timer + 1

  phase_ship = flr(b.flash_timer / b.flash_interval) % 3

 if phase_ship == 0 then
  spr(b.sp,b.x,b.y)
 elseif phase_ship == 1 then
  spr(12,b.x,b.y)
 else
  spr(1,b.x,b.y)
  end
 end
 
function draw_enem_bullets(enem_bullets_list) 
	for enemy_bullets in all(enem_bullets_list) do
	  enemy_bullets.flash_timer = enemy_bullets.flash_timer + 1
	  
	  phase_enemy_bullets = flr(enemy_bullets.flash_timer / enemy_bullets.flash_interval) % 3
	
		if phase_enemy_bullets == 0 then
	  spr(enemy_bullets.sp, enemy_bullets.x, enemy_bullets.y)
	 elseif phase_enemy_bullets == 1 then
		 spr(14, enemy_bullets.x, enemy_bullets.y)
	 else
	  spr(1, enemy_bullets.x, enemy_bullets.y)
	 end
	end  
end
 
draw_enem_bullets(enem_shoot_bullets)
draw_enem_bullets(enemiesd_bullets) 

 for bmb in all(plr_bomb) do
  
  bmb.flash_timer = bmb.flash_timer + 1

 if flr(bmb.flash_timer / bmb.flash_interval) % 2 == 0 then
  spr(bmb.sp,bmb.x,bmb.y)
 else
  spr(6,bmb.x,bmb.y) 
  end
 end
 
   
 for g in all(lvl_gems) do
  spr(g.sp,g.x,g.y)
 end
 
//ok! if bomb is ready 
 if bombcooldowntimer <= 0 then
 bomb_ready_timer += 1
 if bomb_ready_timer >= bomb_ready_int * 2 then
 	bomb_ready_timer = 0
 end
 
 if bomb_ready_timer < bomb_ready_int then
 	spr(128,88,22)
 	spr(129,97,22)
	end
 else
  spr(1,109,16)
 end

//ok! if tri-shot is ready
 if cooldowntimer_side <= 0 then
 cooldown_side_ready += 1
 if cooldown_side_ready >= cooldown_side_int * 2 then
 	cooldown_side_timer = 0
 end
 
 if ship.wingcanons >= 1 then
 rectfill(87 + 28 - firecooldownwidth, 30, 87 + 28, 32, 3) 
 if cooldown_side_timer < cooldown_side_int then
 	spr(128,88,27)
 	spr(129,97,27)
	end
	end
 else
  spr(1,109,16)
 end
 
--enemy draw functions
 
 for e in all(enemies) do
--	 rect(e.box.x1, e.box.y1, e.box.x2, e.box.y2, 11)
  spr(e.sp,e.x,e.y)
 end
 
 for esa in all(enemies_shoot_a) do
  spr(esa.sp,esa.x,esa.y)
 end
 
 for eb in all(enemiesb) do
  spr(eb.sp,eb.x,eb.y)
 end
 
 for ec in all(enemiesc) do
  spr(ec.sp,ec.x,ec.y)
 end
 
 for ed in all(enemiesd) do
-- 	rect(ed.box.x1, ed.box.y1, ed.box.x2, ed.box.y2)
 	spr(ed.sp1, ed.x, ed.y)
if ed.x <= ship.x and ed.y <= ship.y then
		spr(ed.sp2, ed.x+2, ed.y+1, 1.0, 1.0, false, true)
elseif ed.x <= ship.x and ed.y >= ship.y then
		spr(ed.sp2, ed.x+2, ed.y-2, 1.0, 1.0, false, false)
elseif ed.x >= ship.x and ed.y <= ship.y then
		spr(ed.sp2, ed.x-1, ed.y+1, 1.0, 1.0, true, true)
elseif ed.x >= ship.x and ed.y >= ship.y then
		spr(ed.sp2, ed.x-1, ed.y-2, 1.0, 1.0, true, false)
end
end
 
 
-- ****** gem attract radius ***** 
-- circ(ship.x+3, ship.y+3, ship.shield_r, 2)
 
 
 for orb in all(plr_orbs) do
 	spr(orb.sp,orb.x,orb.y)
 end
 
 for pwrup in all(shieldpowerups) do
  spr(pwrup.sp, pwrup.x, pwrup.y)
  circ(pwrup.x+3,pwrup.y+4,pwrup.r,12 + pwrup.t % 3)
 end
 
 for indicator in all(pend_cred_indicator) do
  indicator.t += 1
  if indicator.t <= 13 then
			indicator.y -= 1
			print("+"..indicator.credits, indicator.x, indicator.y-6, 10) 
	 else
	 	pend_cred_indicator = {}
	 end
	end


//heatlhbar
-- top layer & bottom layer
for x = 87, 107, 8 do
	spr(57, x, 0)
	spr(57, x, 4)
end

spr(57, 109, 0)
spr(57, 109, 4)
	
-- side layer
spr(58, 82, 0)
spr(58, 112, 0)

-- health bar length
rectfill(87, 4, 87+healthbarwidth, 6, 8)


//shields
-- top layer & bottom layer
for x = 87, 107, 8 do
	spr(57, x, 6)
	spr(57, x, 10)
end

spr(57, 109, 6)
spr(57, 109, 10)
	
-- side layer
spr(58, 82, 6)
spr(58, 112, 6)

rectfill(87, 10, 87+shieldbarwidth, 12, 12)

//bomb cooldown
rectfill(87 + 28 - bombbarwidth, 25, 87 + 28, 27, 2) 
//tri-shot cooldown
--rectfill(87 + 28 - firecooldownwidth, 30, 87 + 28, 32, 3) 
 --upgrade menu

 
 if upgrademenu then
 	rectfill(-20, 40, 130, 104, 0)
 	line(0, 40, 130, 40, 8)
 	print("upgrade options:", 33, 30, 7)
 	print("bullet upgrade: "..("lvl "..ship.bulletlvl.." > "..ship.bulletlvl + 1 or ""), 6, 45, selectedoption == 1 and 10 or 7)
 	print(bulletupgrades[1].descriptionupdate(), 6, 55)
 	print("bomb upgrade: "..("lvl "..ship.bomblvl.." > "..ship.bomblvl + 1 or ""), 6, 65, selectedoption == 2 and 10 or 7)
  print(bombupgrades[1].descriptionupdate(), 6, 75) 
 	print("orb upgrade: "..("lvl "..ship.orblvl.." > "..ship.orblvl + 1 or ""), 6, 85, selectedoption == 3 and 10 or 7)
  print(orbupgrades[1].description(), 6, 95)
 	line(0, 103, 130, 103, 8)
 end
    
   
end
-->8
--enemies/players init


//player ship
function player_ship()
 
 ship = {
 	sp=2,
 	animsp=9,
 	x=60,
 	y=100,
 	radius=7,
 	speed = persistent_upgrades.ship.speed,
 	h = persistent_upgrades.ship.health,
 	shieldmax = persistent_upgrades.ship.shieldmax,
 	shields = persistent_upgrades.ship.shields,
 	shielddmg=0,
 	shield_r=persistent_upgrades.gem_radius,
 	lvl=0,
 	lvlgauge=0,
 	bulletlvl=1,
 	bomblvl=1,
 	orblvl=1,
 	wingcanons=persistent_upgrades.upgraded_items.wingcanons,
 	gem_attract_lvl = persistent_upgrades.gem_attract_lvl,
 	gem_pull_strength=persistent_upgrades.gem_pull_strength,
 	score=0,
 	t=0,
 	imm=false,
 	box = {x1=0,y1=0,x2=7,y2=7}
 }
end


--weapons, respawn, collision

function respawn()
	local n = flr(rnd(9))+2
	for i=1,n do
		local d = -1
	if rnd(1)<0.5 then 
		d=1 
	end
 
 add(enemies, {
 	sp=16,
 	gem=34,
 	creditsnum=10,
 	score=50,
 	m_x=i*16,
 	m_y=-20-i*8,
 	d=d,
 	x=-32,
 	y=-62,
 	r=10,
 	type = "original",
 	box = {x1=0,y1=0,x2=7,y2=7}
 })
  
 end
 
end
 
function respawn_shoot_a()

	 local d = -1
	 
	 add(enemies_shoot_a, {
	 sp=19,
	 gem=35,
	 creditsnum=20,
	 score=150,
	 m_x=60,
	 m_y=-20,
	 d=d,
	 x=-32,
	 y=-32,
	 r=6,
	 directionx=1,
	 directiony=1,
	 fire_timer = 0,
	 fire_cooldown = flr(rnd(20)) + enem_fire_cooldown,
	 box = {x1=0,y1=0,x2=7,y2=7}
	})
 
end

function respawnb()
--	local n = flr(rnd(4))+2
	for i=1,4 do
		local d = -2
		if rnd(1)<0.5 then d=1 end
 add(enemiesb, {
 	sp=17,
 	gem=35,
 	creditsnum=20,
 	score=100,
 	m_x=i*16,
 	m_y=-20-i*8,
 	d=d,
 	x=-32,
 	y=-32,
 	r=20,
 	box = {x1=1,y1=0,x2=6,y2=6}
 })
-- enem_b_respawn_timer = enem_b_cooldown
 end
end

function respawnc()
//	local n = flr(rnd(4))+2
	for i=-1,6 do
		local d = -2
 add(enemiesc, {
 	sp=18,
 	gem=34,
 	creditsnum=5,
 	score=100,
 	m_x=i*4+i*7,
 	m_y=-10,
 	d=d,
 	x=-28,
-- 	y=-32,
 	r=20,
 	box = {x1=0,y1=0,x2=8,y2=6}
 })
 end
 
 for i=7,14 do
		local d = -2
 add(enemiesc, {
 	sp=18,
 	gem=34,
 	creditsnum=5,
 	score=100,
 	m_x=i*4+i*7-88,
 	m_y=-20,
 	d=d,
 	x=-28,
-- 	y=-32,
 	r=20,
 	box = {x1=0,y1=0,x2=8,y2=6}
 })
 end
end


// turret enemies
function respawnd()

	local d = -1

	add(enemiesd, {
	sp1=21,
	sp2=22,
	gem=36,
	creditsnum=30,
	score=250,
	health=3,
	m_x=60,
	m_y=1,
	d=d,
	x=62,
	y=-32,
	box = {x1=-1, y1=-1, x2=10, y2=10}
	})
end

--collision tech

function abs_box(s)
	if s == nil or s.box == nil then
		return nil
	end
	
	local box = {}
	box.x1 = s.box.x1 + s.x
	box.y1 = s.box.y1 + s.y
	box.x2 = s.box.x2 + s.x
	box.y2 = s.box.y2 + s.y
	return box
	
end



--collision function

function coll(a,b)
	local box_a = abs_box(a)
	local box_b = abs_box(b)
 
	if box_a == nil or box_b == nil then
		return false
	end

 if box_a.x1 > box_b.x2 or
 			box_a.y1 > box_b.y2 or
 			box_b.x1 > box_a.x2 or
 			box_b.y1 > box_a.y2 then
 			return false
	end
	
	return true
	
end

--collision for player bullet onto enemey
function check_collision(bullets_list, enemies, weapon_type)
	for b in all(bullets_list) do
		for e in all(enemies) do
			if coll(b, e) then
			 multiplier_score += 1
				multiplier_timer = 100
				del(bullets_list, b)
			if e.health and e.health > 1 then
				e.health -= 1	
			else
				del(enemies, e)
				add(pend_cred_indicator, {x = e.x,y = e.y,credits = e.creditsnum, t = 1})
				sfx(6)
				credits.num += e.creditsnum
				ship.score += e.score
				gem_spawn(e.x, e.y, e.gem)
				explode(e.x, e.y)
				
	--			if weapon_type == "main" then
	--			 explode(e.x, e.y)
	--			end
			end
			
				if weapon_type == "bomb" then
				 bmb_explode(e.x, e.y)				
				end
				
				break
	  end
	 end
 end
end

--check coll enemy bullet onto ship

function check_enem_bullet_collision(bullets, player_ship)
	for enem_bullets in all(bullets) do
  	if coll(enem_bullets, player_ship) and not ship.imm then
  		del(bullets, enem_bullets)
  		ship.shielddmg = 10
 	  ship.shields -= 10
 	  shieldbarwidth = flr(ship.shields * 28 / ship.shieldmax)   
		 if ship.shields <= 0 and coll(enem_bullets, player_ship) and not ship.imm then
				ship.shields = 0
				shieldbarwidth = flr(ship.shields * 28 / ship.shieldmax)				
				ship.imm = true	  
	  	ship.h -= 1
 	 	healthbarwidth = flr(ship.h * 28 / 4)
    sfx(5)
		 end
		end
	end
end

-- check collision for ship and enemy
function check_ship_and_enem_coll(player_ship, enemies)
 for e in all(enemies) do
 	if coll(player_ship,e) and not player_ship.imm then
 	 shake+=0.0001
 	 shake=min(0.0001,shake)
 	 player_ship.shielddmg = 1
 	 player_ship.shields -= 1
 	 shieldbarwidth = flr(player_ship.shields * 28 / player_ship.shieldmax)
 	if player_ship.shields <= 0 and coll(player_ship,e) and not player_ship.imm then
				shake+=0.8
 	  shake=min(0.1,shake)
				player_ship.shields = 0
				shieldbarwidth = flr(player_ship.shields * 28 / player_ship.shieldmax)				
				player_ship.imm = true	  
	  	player_ship.h -= 1
 	 	healthbarwidth = flr(player_ship.h * 28 / 4)
    sfx(5)
  end
 end
  
  if e.y >= 150 then
   del(enemies,e)
  end
 end
end


function update_collisions()
	
	check_collision(bullets, enemies)
	check_collision(bullets, enemiesb)
 check_collision(bullets, enemiesc) 
 check_collision(bullets, enemiesd)
 check_collision(bullets, enemies_shoot_a)

	check_collision(plr_bomb, enemies, "bomb")
	check_collision(plr_bomb, enemiesb, "bomb")
 check_collision(plr_bomb, enemiesc, "bomb")
 check_collision(plr_bomb, enemiesd, "bomb")
 check_collision(plr_bomb, enemies_shoot_a, "bomb") 

 check_collision(plr_orbs, enemies)
 check_collision(plr_orbs, enemiesb)
 check_collision(plr_orbs, enemiesc)
 check_collision(plr_orbs, enemiesd)
 check_collision(plr_orbs, enemies_shoot_a)
 
 --collision for enemy bullets
  
	check_enem_bullet_collision(enem_shoot_bullets, ship)
 check_enem_bullet_collision(enemiesd_bullets, ship)
 
 --collision for enemy & player ship
 check_ship_and_enem_coll(ship, enemies)
	check_ship_and_enem_coll(ship, enemiesb)
 check_ship_and_enem_coll(ship, enemiesc)
 check_ship_and_enem_coll(ship, enemiesd)
 check_ship_and_enem_coll(ship, enemies_shoot_a)

end



function handle_bomb_explosion(bomb_explosion, enemies_list)
	for e in all(enemies_list) do
		local distance = sqrt((bomb_explosion.x - e.x) ^ 2 + (bomb_explosion.y - e.y) ^ 2)
		if distance <= bomb_explosion.radius then
			if e.health and e.health > 1 then
				e.health -= 1
			else
			del(enemies_list, e)
			add(pend_cred_indicator, {x = e.x, y = e.y, credits = e.creditsnum, t = 1})
			sfx(6, 3)
			multiplier_score += 1
			multiplier_timer = 100
			credits.num += e.creditsnum
			ship.score += e.score
			explode(e.x, e.y)
			gem_spawn(e.x, e.y, e.gem)  -- adjust gem type if necessary
			break
			end
		end
	end
end

-- function to update bomb explosions and check for collisions
function update_bomb_explosions()
	for bomb_explosion in all(bmb_explosions) do
		bomb_explosion.t += 1
		bomb_explosion.radius = min(bmb_exploradi, bomb_explosion.radius + 2)
		
		-- check collision with all enemy types
		handle_bomb_explosion(bomb_explosion, enemies)
		handle_bomb_explosion(bomb_explosion, enemies_shoot_a)
		handle_bomb_explosion(bomb_explosion, enemiesb)
		handle_bomb_explosion(bomb_explosion, enemiesc)
		handle_bomb_explosion(bomb_explosion, enemiesd)
		-- add more enemy lists here if needed
		
		if bomb_explosion.radius >= bmb_exploradi then
			del(bmb_explosions, bomb_explosion)
		end
	end
end

function explode(x,y)
	add(explosions,{x=x,y=y,t=0})
end

function bmb_explode(x,y)
	add(bmb_explosions,{x=x,y=y,t=0,radius = 1})
end

function fire()
	if cooldowntimer_main <= 0 then 
		local b = {
	 	sp=11,
	 	x=ship.x,
	 	y=ship.y,
	 	dx=0,
	 	dy=bulletsdy,
	 	box = {x1=1,y1=0,x2=6,y2=4},
	 	flash_timer = 0,
	 	flash_interval = 2.5
		}
		add(bullets,b)
		
		if ship.wingcanons == 1 and cooldowntimer_side <= 0 then
			local b_left = {
	 		sp=11,
	 		x=ship.x - 5,
	 		y=ship.y + 4,
	 		dx=0,
	 		dy=bulletsdy,
	 		box = {x1=2,y1=0,x2=4,y2=4},
	 		flash_timer = 0,
	 		flash_interval = 2.5
			}
		add(bullets, b_left)
		
			local b_right = {
	 		sp=11,
	 		x=ship.x + 5,
	 		y=ship.y + 4,
	 		dx=0,
	 		dy=bulletsdy,
	 		box = {x1=2,y1=0,x2=4,y2=4},
	 		flash_timer = 0,
	 		flash_interval = 2.5
			}
		add(bullets, b_right)
		cooldowntimer_side = firecooldown_side
 end		
			
		cooldowntimer_main = firecooldown_main
	 sfx(0, -1)
	end	
end

function alt_fire()
if bombcooldowntimer <= 0 then
	local bmb = {
	 sp=5,
	 x=ship.x,
	 y=ship.y,
	 dx=2,
	 dy=-2,
	 r=2,
	 box = {x1=0,y1=0,x2=5,y2=5},
	 flash_timer = 0,
	 flash_interval = 5
	}
	add(plr_bomb,bmb)
	bombcooldowntimer = bombcooldown
	sfx(2)
 
 end
end

function update_bullets() 
 for b in all(bullets) do
  b.x+=b.dx
  b.y+=b.dy
  	if b.x < -10 or b.x > 130 or
  		b.y < 0 or b.y > 140 then
  		del(bullets,b)
  end
	end
end

function update_bombs()   
 for bmb in all(plr_bomb) do
 bmb.t = 100
 bmb.x += bmb.r*sin(bmb.dx*t/16/2)
 bmb.y += bmb.r*cos(t/bmb.t) + bmb.dy
  	if bmb.x < 0 or bmb.x > 128 or
  		bmb.y < 0 or bmb.y > 140 then
  		del(plr_bomb,bmb)
  end
 end
end

// update to be modular, handle different enemies shooting
function enemy_fire(enem_type, enem_bullets_list)
-- if enem_fire_timer <= 0 then
	for enemies in all(enem_type) do
	local enem_bullet = {
	 sp=13,
	 x=enemies.x,
	 y=enemies.y,
	 dx=0,
	 dy=-2.3,
	 r=2,
	 box = {x1=0,y1=0,x2=5,y2=5},
	 flash_timer = 0,
	 flash_interval = 2.5
	}
	add(enem_bullets_list, enem_bullet) 
--	sfx(2)
--  end
 end
end 


function update_enem_bullets(enem_bullets_list) 
 for enem_bullet in all(enem_bullets_list) do
  enem_bullet.x-=enem_bullet.dx
  enem_bullet.y-=enem_bullet.dy
  	if enem_bullet.x < -10 or enem_bullet.x > 130 or
  		enem_bullet.y < 0 or enem_bullet.y > 140 then
  		del(enem_bullets_list,enem_bullet)
  end
	end
end


function enem_bullets_animupdate()
	update_enem_bullets(enem_shoot_bullets)
	update_enem_bullets(enemiesd_bullets)
end
-->8
-- gem spawn & level up

function gem_spawn(x, y, sp)
	local g = {
		sp=sp,
		m_x=x,
 	m_y=y,
 	d=-1,
		x=x,
		y=y,
		r=6,
		num=0,
		box = {x1=0,y1=0,x2=4,y2=6}}
		add(lvl_gems, g)
end


function level_up(g)
	if g.sp == 34 then
		ship.lvlgauge += 10
		barwidth = (ship.lvlgauge / maxlvl) * 128
	elseif g.sp == 35 then
		ship.lvlgauge += 25
		barwidth = (ship.lvlgauge / maxlvl) * 128
	elseif g.sp == 36 then
		ship.lvlgauge += 50
		
	barwidth = (ship.lvlgauge / maxlvl) * 128
	end
end
-->8
-- upgrade menu & shop menu
persistent_upgrades = {
	ship = { 
	speed = 1,
	shieldmax = 20,
	shields = 20,
	health = 4 -- original, 4
 },
 
 upgraded_items = {
 shieldrefill = 0,
 wingcanons = 0,
 firecooldown_side = 100
 },
 
 wingcanons_level = 0,
 shieldupgrade_level = 0,
 shieldrefill_level = 0,
 gem_attract_lvl = 0,
 gem_pull_strength = 1,
 gem_radius = 10,
 
 num_creds = 0,
 run_num = 0,
	initial_bootup = 1
}

highest_mult = {
	high_mult = 0
}


-- main ship upgrades

function define_shipupgrades()

 bulletupgrades = {
 {name = "firecooldown", 
 descriptionupdate = function()
 
 if ship.bulletlvl == 2 or ship.bulletlvl == 5 then
 return "reduce cooldown, inc. speed"
 elseif ship.bulletlvl >= 10 then
 return "max level, get 500 points!"
 else
 return "reduce cooldown"
 end
 end,
 
 effect = function() 
 if ship.bulletlvl == 3 or ship.bulletlvl == 6 then
 firecooldown_main = firecooldown_main - 1.6
 bulletsdy = bulletsdy - 0.2
 ship.bulletlvl = ship.bulletlvl + 1
 elseif ship.bulletlvl >= 10 then
 ship.score = ship.score + 500
 else
 firecooldown_main = firecooldown_main - 1.6
 ship.bulletlvl = ship.bulletlvl + 1
 end
 end},
}

	bombupgrades = {
	{name = "bombcooldown",
	descriptionupdate = function()
	
	if ship.bomblvl == 2 or ship.bomblvl == 5 then
	return "recude cooldown, inc. radius"
 elseif ship.bomblvl >= 10 then
 return "max level. get 500 points!"
 else
 return "reduce cooldown"	
	end
	end,
	
	effect = function()
	if ship.bomblvl == 2 or ship.bomblvl == 5 then
 bmb_exploradi = bmb_exploradi + 8
	bombcooldown = bombcooldown - 5
	ship.bomblvl = ship.bomblvl + 1
	elseif ship.bomblvl >= 10 then
	ship.score = ship.score + 500
	else
	bombcooldown = bombcooldown - 5
 ship.bomblvl = ship.bomblvl + 1
	end
	end},
}
 
 orbupgrades = {
 {name = "orb num increase",
 description = function()
 
 if ship.orblvl < 6 then
 return "orb that orbits the ship"
 else
 return "max level. get 500 ponints!"
 end
 end,
 
 effect = function()
 if ship.orblvl < 6 then
 orbs_num = orbs_num + 1
 ship.orblvl = ship.orblvl + 1
 else
 ship.score = ship.score + 500
 end 
 end}
}

end


-- shop menu upgrades
function define_shopupgrades()

	wingcanons = {
	name = "wing canons",
	level = persistent_upgrades.wingcanons_level,
	cost = {600, 800, 1200, 1800, 2400},
	maxlvl = 5,
	
	effect = function()
	if wingcanons.level >= wingcanons.maxlvl then
	return "max level"
	end
	
	if ship.wingcanons == 0 and credits.num >= wingcanons.cost[wingcanons.level + 1] then
	ship.wingcanons = 1
	wingcanons.level = wingcanons.level + 1
	persistent_upgrades.wingcanons_level = wingcanons.level
	persistent_upgrades.upgraded_items.wingcanons = ship.wingcanons
	else if wingcanons.level >= 1 then
	wingcanons.level = wingcanons.level + 1
	persistent_upgrades.wingcanons_level = wingcanons.level
	firecooldown_side = firecooldown_side - 10
	persistent_upgrades.upgraded_items.firecooldown_side = firecooldown_side
	else if wingcanons.level < wingcanons.max_level then
	ship.score = ship.score + 300
	   end
			end
		end
	end
	}
		
 shieldupgrade = {
 name = "shield max increase",
 level=persistent_upgrades.shieldupgrade_level, 
 cost={400, 800, 1200, 1800, 2400},
 maxlvl = 5,
  
 effect = function()
 if shieldupgrade.level >= shieldupgrade.maxlvl then
 return "max level"
 end
  
 if credits.num >= shieldupgrade.cost[shieldupgrade.level + 1] then
 ship.shieldmax = ship.shieldmax + 10
 ship.shields = ship.shields + 20
 persistent_upgrades.ship.shieldmax = ship.shieldmax
 persistent_upgrades.ship.shields = ship.shieldmax
 shieldupgrade.level = shieldupgrade.level + 1
 persistent_upgrades.shieldupgrade_level = shieldupgrade.level
  end
 end 
 }
 
 shieldrefillpwrup = {
 name = "enable shield pwrup",
 level=persistent_upgrades.shieldrefill_level,
 cost={3000},
 maxlvl = 1,
 description = "shield refills spawns",
 
 effect = function()
 if shieldrefill >= shieldrefillpwrup.maxlvl then
 return "max level"
 end 
 
 if shieldrefill == 0 and credits.num >= shieldrefillpwrup.cost[shieldrefillpwrup.level + 1] then
 shieldrefill = 1
 persistent_upgrades.upgraded_items.shieldrefill = shieldrefill 
 shieldrefillpwrup.level = shieldrefillpwrup.level + 1
 persistent_upgrades.shieldrefill_level = shieldrefillpwrup.level
 end
 end
}

	gemattractor = {
	name = "gem attractor",
	level = persistent_upgrades.gem_attract_lvl,
	cost = {400, 600, 1400},
	maxlvl = 3,
	
	effect = function()
	if credits.num >= gemattractor.cost[gemattractor.level + 1] then
		persistent_upgrades.gem_pull_strength += 1
		persistent_upgrades.gem_attract_lvl += 1
		persistent_upgrades.gem_radius += 3
	if persistent_upgrades.gem_attract_lvl >= gemattractor.maxlvl then
	ship.score = ship.score + 300
	end
	end
	end
	}

end


function upgrade_menu()
		 gamestate = false
		 upgrademenu = true
		 ship.lvlgauge = 0
		 ship.lvl += 1
		 maxlvl += 30
		 barwidth = (ship.lvlgauge / maxlvl) * 128
end



-- ****************************
-- ****** main menu code ******
-- ****************************


function start_menu()
	startmenu = true
	_update = update_start_screen 
	_draw = draw_start_screen
end

function update_start_screen()
stars_animation()
	if startmenu == true then
		if btnp(❎) then
			startmenu = false
			start() 
		end
	end
end

function draw_start_screen()
	cls()
	for st in all(stars) do
 	pset(st.x,st.y,st.s+6)
 end
	print("story",56,74,7)
	print("arcade",54,84,7)
	print("options",53,94,7)
end



function start()
	gamestate = true
	_update = update_game
	_draw = draw_game
	music(0, 0, 7)
end

function game_over()
 _update = update_over
 _draw = draw_over
end

function update_over()
 game_over_state = true
end

function draw_over()
	cls()
	music(-1)
	tover=tover+1
	print("game over",47,42,4)
	print("remaining credits: "..credits.num, 26,58,10)
	print("score: "..ship.score, 26,68,9)
	
	if tover>=120 then
	 print("press ❎ to continue", 26,90,7)
 if btnp(❎) then
   run_number = run_number + 1 
   shop_screen() 
  end 
 end
end



function shop_screen()
 _update = update_shopmenu
	_draw = draw_shopmenu
	selectedoption = 1
end

function update_shopmenu()

 for i=1, #r do
 	r[i].x+=3/r[i].v
 	r[i].y+=3/r[i].v
 	if r[i].y>=128+6 then
 		r[i]=
 		 {x=rnd(256)-128,
 		 	y=0,v=1+flr(rnd(2))}
 		end
 	end

local upgrades = {wingcanons, shieldupgrade, shieldrefillpwrup, gemattractor}

	function get_upgrade_effect(upgrade)
		return upgrade.effect
 end

	function get_upgrade_cost(upgrade)
		local next_level = upgrade.level + 1
		if next_level <= upgrade.maxlvl then
		return upgrade.cost[next_level]
 	else
 	return nil
 	end
 end

local num_options = (count(upgrades))

 if btnp(⬆️) then
	 	selectedoption = selectedoption - 1
	 if selectedoption < 1 then
	 	selectedoption = num_options
	 end
	 
	 elseif btnp(⬇️) then
	 	selectedoption = selectedoption + 1
	 if selectedoption > num_options then
	 	selectedoption = 1
		end	
		
		elseif btnp(❎) then 
--			local selectedupgrade = upgrades[selectedoption]
			local selectedupgrade_effect = get_upgrade_effect(upgrades[selectedoption])
   local selectedupgrade_cost = get_upgrade_cost(upgrades[selectedoption])
    
			if selectedupgrade_cost and credits.num >= selectedupgrade_cost then 
   
		 if selectedupgrade_effect then
		 	selectedupgrade_effect()
		 	credits.num = credits.num - selectedupgrade_cost
		 	persistent_upgrades.num_creds = credits.num
		 	persistent_upgrades.run_num = run_number
		 	highest_mult.high_mult = highest_multiplier_score
		 	persistent_upgrades.initial_bootup = 0
		 	_init()
 	  end
 	 end
 	elseif btnp(4) then
 	hold_to_continue += 1
 	sfx(8)
 	if hold_to_continue == 3 then
 	persistent_upgrades.num_creds = credits.num
 	hold_to_continue = 0
		persistent_upgrades.run_num = run_number
 	persistent_upgrades.initial_bootup = 0
 	_init()
 	 end
 	end
end

function draw_shopmenu()
	 cls()
 
 for i=1,#r do
 	if r[i].v==1 then
 		l=4
 	else
 	 l=2
 	end
 	line
 	(r[i].x,r[i].y,r[i].x-l,
 		r[i].y-l,6-1*(r[i].v-1))
 	end
	
	 
 	rect(-20, 30, 130, 114, 8)
 	
 	print("pilots k.i.a: "..run_number.."", 34, 3, 7)
 	print("highest combo: "..highest_multiplier_score.."", 32, 12, 7)
 	print("upgrade options:", 33, 21, 7)
 	
 	print("press zx3 to skip!", 6, 120)
		for i = 1, hold_to_continue do
			print("★", (i+12) * 6, 120, 10)
 	end
 	 
 	print("wing canons: "..("lvl "..wingcanons.level.." > "..wingcanons.level + 1 or ""), 6, 35, selectedoption == 1 and 10 or 7)
 	if wingcanons.level >= wingcanons.maxlvl then
 		print("max level reached!", 6, 45)
 	elseif ship.wingcanons >= 0 and wingcanons.level < wingcanons.maxlvl then
 	if credits.num < wingcanons.cost[wingcanons.level + 1] then
 		print("insufficient credits!", 6, 45)
 	else
 	 print("adds a gun on each wing: ".. wingcanons.cost[wingcanons.level + 1] .. " ¥", 6, 45)
 	end
		end
 	
 	print("shield upgrade: "..("lvl "..ship.shieldmax.." > "..ship.shieldmax + 20 or ""), 6, 55, selectedoption == 2 and 10 or 7)
  if shieldupgrade.level >= shieldupgrade.maxlvl then
  	print("max level reached!", 6, 65)
  elseif persistent_upgrades.shieldupgrade_level < shieldupgrade.maxlvl then  
  if credits.num < shieldupgrade.cost[shieldupgrade.level + 1] then
   print("insufficient credits!", 6, 65)
  else
  	print("increases shields by 20: "..shieldupgrade.cost[shieldupgrade.level + 1].. " ¥", 6, 65)  
 	end
 end
 
 if shieldrefill == 0 then
  	print("shield refill: not active ", 6, 75, selectedoption == 3 and 10 or 7)
  if credits.num < shieldrefillpwrup.cost[1] then
   print("insufficient credits!", 6, 85)
 	else 
   print("refill pwr-up: "..shieldrefillpwrup.cost[1].." ¥", 6, 85)
 	end
 	else
   print("shield refill active!", 6, 75, selectedoption == 3 and 10 or 7)
	end


	print("gem attractor: "..("lvl "..persistent_upgrades.gem_attract_lvl.." > "..persistent_upgrades.gem_attract_lvl + 1 or ""), 6, 95, selectedoption == 4 and 10 or 7)
if persistent_upgrades.gem_attract_lvl >= gemattractor.maxlvl then
	print("max level reached!", 6, 105)
elseif persistent_upgrades.gem_attract_lvl <= gemattractor.maxlvl then
if credits.num < gemattractor.cost[ship.gem_attract_lvl + 1] then
	print("insufficient credits!", 6, 105)
else
	print("gems move towards player: "..gemattractor.cost[persistent_upgrades.gem_attract_lvl + 1].." ¥", 6, 105)
end
end

end
-->8
-- main game state

function rungame()
	
 t=t+1.3
 
 if ship.imm then
 	ship.t += 1
 	if ship.t > 30 then
 		ship.imm = false
 		ship.t = 0
 	end
 end
 
 stars_animation()

-- **** particles? ****
	shine_timer += 1
if shine_timer < shine_cooldown then
	shine_x += shine_speed - 0.1
	shine_y += shine_speed
end

if shine_x > max_shine or shine_y > 20 or shine_timer >= shine_cooldown then
	shine_x=-10
	shine_y=-5
if shine_timer == 220 then
	shine_timer = 0
	end
end
 
if ship.lvl > 5 then
 for i=1, #r do
 	r[i].x+=3/r[i].v
 	r[i].y+=3/r[i].v
 	if r[i].y>=128+6 then
 		r[i]=
 		 {x=rnd(256)-128,
 		 	y=0,v=1+flr(rnd(2))}
 		end
 	end
end		 	
 
	for ex in all(explosions) do
  ex.t+=1
  if ex.t==10 then
  	del(explosions, ex)
  end
 end

doshake()

// explosion radius & timer logic

// sets combo timer & resets
if multiplier_score >= 1 and multiplier_timer > 0 then
	multiplier_timer -= 1
else
	multiplier_score = 0
	previous_multiplier_score = 0
	explosion_radius = 3
end

// explosion radius limit
if multiplier_score > previous_multiplier_score and explosion_radius > 0.5 then	
	explosion_radius -= 0.07
	previous_multiplier_score = multiplier_score
end

// updates highets multiplier
if multiplier_score > highest_multiplier_score then
	highest_multiplier_score = multiplier_score
end



-- ****************************
-- ***** enemy spawn logic ****
-- ****************************


--enemy a  
 if #enemies <= 0 then
 	respawn()
 end


--enemy a with bullets

if ship.lvl >= 3 then
	local max_enem_a = ship.lvl >= 10 and 5 or 3
	
	if ship.wingcanons >= 2 then
		max_enem_a = ship.lvl >= 8 and 7 or 4
	end
	
	if #enemies_shoot_a < max_enem_a then	
	respawn_shoot_a_timer = respawn_shoot_a_timer + 1
	
	if ship.wingcanons >= 2 and respawn_shoot_a_timer >= 60 then
		respawn_shoot_a()
		respawn_shoot_a_timer = 0
	elseif respawn_shoot_a_timer >= 100 then
		respawn_shoot_a()
		respawn_shoot_a_timer = 0
	end
	end
end


--enemy b 
 if ship.lvl >= 4 then 
	enem_b_respawn_timer = enem_b_respawn_timer + 1
	
	if enem_b_respawn_timer == 280 then
		respawnb()
		enem_b_respawn_timer = 0
	else if ship.lvl >= 10 then
		enem_b_respawn_timer = enem_b_respawn_timer + 1
	if enem_b_respawn_timer == 220 then
		respawnb()
		enem_b_respawn_timer = 0
		end
	 end
 end 
end

--enemy c 	
 if ship.lvl >= 7 and #enemiesc <= 0 then
  enem_c_respawn_timer = enem_c_respawn_timer + 1
 if enem_c_respawn_timer == 80 then
  respawnc()
 	enem_c_respawn_timer = 0
  end
 end

--enemy d
--	if ship.lvl >= 2 and #enemiesd <= 0 then
--		enem_d_respawn_timer = enem_d_respawn_timer + 1
--	if enem_d_respawn_timer == 80 then 
--		respawnd()
--		enem_d_respawn_timer = 0
--		end
--	end

update_bullets()

if cooldowntimer_main > 0 then
	cooldowntimer_main -= .50
end

if cooldowntimer_side > 0 then
	cooldowntimer_side -= .50
end

update_bombs()

function update_cooldown_bar()
  bombbarwidth = flr((bombcooldown - bombcooldowntimer) * 14 / bombcooldown)
end

if bombcooldowntimer > 0 then
	update_cooldown_bar()
	bombcooldowntimer -= .50
end

--cooldown for enemies shoot a (stupid name btw)
for e in all(enemies_shoot_a) do
if e.fire_timer > 0 and #enemies_shoot_a >= 1 then
 e.fire_timer -= .50
end
 
if e.fire_timer <= 0 then
 enemy_fire({e}, enem_shoot_bullets)
 e.fire_timer = e.fire_cooldown
end
end

--cooldown for enemies d bullets

if enemiesd_fire_timer > 0 and #enemiesd >= 1 then
	enemiesd_fire_timer -=.50
end       

if enemiesd_fire_timer <= 0 then
	enemy_fire(enemiesd, enemiesd_bullets)
	enemiesd_fire_timer = enemiesd_fire_cooldown
end

enem_bullets_animupdate()

--aoe orbs logic

if orbs_num > 0 then
	create_orb()		
end

if #plr_orbs < orbs_num then
	orbs_cooldowntimer -= .50
end

--if orbs_num != 0 then
--	if #plr_orbs == orbs_num + 1 then
--		create_orb()
-- end
--end

for orb in all(plr_orbs) do
	local angle_offset = -0.006
	orb.angle = orb.angle + angle_offset
	orb.x = ship.x + orbit_radius * cos(orb.angle)
	orb.y = ship.y + orbit_radius * sin(orb.angle)
end


--enemy movement logic
--original / 50
	for e in all(enemies) do
		e.m_y += 1.6
		if e.type == "original" then
 		e.x = e.r*sin(e.d*t/60) + e.m_x
 		e.y = e.r*cos(t/70) + e.m_y
 	elseif e.type == "variant" then
 		e.x = cos(e.d * t / 10) + e.m_x
			e.y = sin(t / 10) + e.m_y
 	end
 end
 
 for esa in all(enemies_shoot_a) do  
  if esa.y >= 80 then
   esa.directiony = -1
  elseif esa.y <= 0 then
   esa.directiony = 1
  end
  
  if esa.x >= 100 then
   esa.directionx = -1
  elseif esa.x <= 0 then
   esa.directionx = 1
  end
  
  esa.m_y += 0.5 * esa.directiony
  esa.m_x += 0.5 * esa.directionx
  esa.x = esa.r*sin(esa.d*t/50) + esa.m_x
  esa.y = esa.r*cos(t/50) + esa.m_y 
 end
 
 for eb in all(enemiesb) do
 	eb.m_y += 2.6
 	eb.x = eb.r-16*sin(eb.d*t/80) + eb.m_x
 	eb.y = -eb.r+10*cos(t/700) + eb.m_y
 end 

 for ec in all(enemiesc) do
 	ec.m_y += 0.8
 	ec.x = ec.r-25*sin(ec.d*t/200) + ec.m_x
 	ec.y = -ec.r+1*cos(t/700) + ec.m_y
 end
 
 for ed in all(enemiesd) do
-- 	ed.m_y += 1
 	ed.y += ed.m_y
 end

	if ship.h <= 0 then
		sfx(1)
 	game_over()	
 end

	
-- ****************************
-- ******** gems logic	********
-- ****************************

	for g in all(lvl_gems) do

	 local dx = ship.x - g.x
  local dy = ship.y - g.y
  local dist = sqrt(dx * dx + dy * dy)
	
		local new_x = g.r-3*sin(g.d*t/50) + g.m_x
 	local new_y = g.r*cos(t/50) + g.m_y
	
		if persistent_upgrades.gem_attract_lvl >= 1 and dist > 0 and dist <= ship.shield_r then
   pull_strength = persistent_upgrades.gem_pull_strength
   new_x = g.x + (dx / dist) * pull_strength
   new_y = g.y + (dy / dist) * pull_strength
  
  	g.m_x = g.x
  	g.m_y = g.y
  else
  
  	g.m_y += 1.0
  end
	
		g.x = new_x
		g.y = new_y
	end

--bullets & enemy collision

update_collisions()


for g in all(lvl_gems) do
	if coll(ship, g) then
		level_up(g)
		del(lvl_gems, g)
		sfx(4, 3)
		break
	end
end

if ship.lvlgauge >= maxlvl then
 upgrade_menu()
end


--bomb & enemy collision

if bombcooldowntimer == 1 then
	sfx(3)
end

update_bomb_explosions()

--powerups

if shieldrefill == 1 then
 shield_spawn_timer += 1
 if shield_spawn_timer >= shield_spawn_int and ship.shields < 0.2 * ship.shieldmax then 
 	shield_spawn_timer_b += 1
 if shield_spawn_timer_b >= 1000 then
 	shield_powerup()
 	shield_spawn_timer = 0
 	shield_spawn_timer_b = 0
 end
end
 
 for pwrup in all(shieldpowerups) do
  pwrup.y += pwrup.m_y
 	pwrup.x = pwrup.r*sin(pwrup.d*t/50) + pwrup.m_x
  pwrup.t += 0.5
	if coll(pwrup, ship) then
		sfx(7, 3)
		ship.shields = ship.shieldmax
 	shieldbarwidth = flr(ship.shields * 28 / ship.shieldmax)
  del(shieldpowerups, pwrup)
  end
 if pwrup.y > 128 then
 	del(shieldpowerups, pwrup)
 end
 
 end	 
end




 if ship.x > 123 then 
  ship.x = 123
 end
 if ship.x < -3 then
  ship.x = -3
 end
 if ship.y > 120 then
  ship.y = 120
 end
 if ship.y < 60 then
  ship.y = 60
 end
 
 if(t%6<4) then
  ship.animsp=9
 else
  ship.animsp=10
 end
 
 //bomb_anim(bmb)

	if btn(0) then ship.x-=ship.speed end
	if btn(1) then ship.x+=ship.speed end
	if btn(2) then ship.y-=ship.speed end
	if btn(3) then ship.y+=ship.speed end
 if btnp(4) then fire() end
 if btnp(5) then alt_fire(t) end

end
-->8
-- aoe weapons

function create_orb()
if orbs_num > 0 and #plr_orbs < orbs_num then
if orbs_cooldowntimer <= 0 then
		local orb = {
			sp=7,
			angle = current_angle,
			box = {x1=0,y1=0,x2=3,y2=3}
			}		
			add(plr_orbs,orb)
			current_angle = current_angle + angle_increment
			orbs_cooldowntimer = orbs_cooldown.value
	 end
	end
end

function gem_attractor(pull_strength)
		for g in all(lvl_gems) do
 	
	 local dx = ship.x - g.x
  local dy = ship.y - g.y
  local dist = sqrt(dx * dx + dy * dy)
	
		local new_x = g.r-3*sin(g.d*t/50) + g.m_x
 	local new_y = g.r*cos(t/50) + g.m_y
	
		if dist > 0 and dist <= ship.shield_r then
   pull_strength = 1
   new_x = g.x + (dx / dist) * pull_strength
   new_y = g.y + (dy / dist) * pull_strength
  
  	g.m_x = g.x
  	g.m_y = g.y
  else
  
  	g.m_y += 1.0
  end
end
end
-->8
--power ups

function shield_powerup()

local m_x_values = {20,30,40,50,60,70,80}
local index = flr(rnd(#m_x_values)) + 1


	add(shieldpowerups, {
		sp=50,
		x=64,
		y=-10,
		m_x=m_x_values[index],
 	m_y=1,
		r=3,
		d=1,
		t=0,
		box = {x1=0,y1=0,x2=4,y2=4}
		})

end

--function shield_radius(x,y)
--	add(bmb_explosions,{x=x,y=y,t=0,radius = 1})
--end


function doshake()
	local shakex=12-rnd(24)
	local shakey=12-rnd(24)
	
	shakex*=shake
	shakey*=shake
	
	camera(shakex,shakey)
	
	shake=shake*0.95
	if (shake<0.05)	shake=0
end
-->8
-- ***** draw animations *****
-- *****																	*****
-- *****																	*****

function stars_animation()
	
	for st in all(stars) do
 	st.y += st.s
 	if st.y >= 128 then
 		st.y = 0
 		st.x = rnd(128)
 	end
 end

end


__gfx__
00000000000000000008800000088000000aa0000000000000000000000000000009900000090000000090000009900000099000000000000000000000000000
00000000000000000007700000077000000aa000000660000006600000000000009aa9000000900000090000009aa900009aa900000000000000000000000000
00700700000000007008800770088007000aa0000005500000055000000aa000009aa9000000000000000000009aa900009aa90000000000000aa00000000000
00077000000000007088880770888807000aa000000550000005500000adda00009999000000000000000000009aa90000999900000aa00000aaaa0000000000
00077000000000008881188888811888000aa000006556000065560000adda00000990000000000000000000009999000009900000aaaa0000a99a0000000000
00700700000000008881188888811888000aa0000065560000655600000aa000000000000000000000000000000990000000000000a99a0000a99a0000000000
0000000000000000700880077008800700000000000900000000900000000000000000000000000000000000000000000000000000a99a0000a99a0000000000
00000000000000000000000000000000000000000000900000090000000000000000000000000000000000000000000000000000000aa000000aa00000000000
00000000030330300000000000000000000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000aa0000800008000033000003333000044440000001110663333660000000000000000000000000000000000000000000000000000000000000000
00333300003663000a0000a000333300033aa3300444444000016610631111360000000000000000000000000000000000000000000000000000000000000000
03388330000aa00083388338033aa330033aa3300644446000166610315885130000000000000000000000000000000000000000000000000000000000000000
0666666000a66a00a038830a06666660000660000444444001666100315885130000000000000000000000000000000000000000000000000000000000000000
0036630000366300030aa03000366300033663300444444001661000031111300000000000000000000000000000000000000000000000000000000000000000
3003300300033000a000000a30033003300660030044440001110000063333600000000000000000000000000000000000000000000000000000000000000000
30000003000000000000000030000003303333030000000000000000066006600000000000000000000000000000000000000000000000000000000000000000
00000000006006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0900009006666660000c0000000b0000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
098888900066660000cac00000bab000008a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009889000006600000cac00000bab000008a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0009900000000000000c0000000b0000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00988900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008dd80000dddd0000ccc00006666660066666600666666001111110011111100111111000000000000000000000000000000000000000000000000000000000
08dddd800d0000d00ccccc0006cccc6006cccc6006cccc6001088010010770100108801000000000000000000000000000000000000000000000000000000000
0dddddd00d0000d0ccc77cc000caac0000caac0000caac0001077010010cc0100107701011111111000050000000000000000000000000000000000000000000
08dddd800d0000d0ccc77cc000caac0000caac0000caac0001088010010cc0100108801000000000000050000000000000000000000000000000000000000000
008dd80000dddd00cccccc0006cccc6006cccc6006cccc6001077010010770100101101000000000000050000000000000000000000000000000000000000000
00000000000000000cccc00006666660066666600666666001111110011111100111111000000000000050000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000
00000000600066661100000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006033666111166633333366611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060333336111163311111133611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000633666311111111355555531111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006333600505001111358888531111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006333605050001111158888511111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006333650500003311155555511133000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006333605000003311311551131133000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006333650000003333333113333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006333600000003333333113333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005555500000003333666336663333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003333660660663333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006388660000663336000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006688660000668866000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006688660000668866000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006666660000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700707077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70070770077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70070770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700707077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055555555550000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005a0aaaa0a50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005aa0aa0aa50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005a0aaaa0a50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005aaaaaaaa50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00059090909050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050909090950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050909090950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00059090909050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050909090950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00059090909050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050909090950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00059090909050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00550909090955000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400003a13138131351312e1312a13126131221311e1311b131001011e1011f101211012310124101251011710117101181011a1011b1011c1011e101181011a1011b1011e1012110122101231012510126101
1010000026652325522f552276522c55229552275522555225550246502255021550215501465025500156501b650225000f6501165009650166500f6550c655000000f6001160009600166000f6000c60000000
00060000326202a620236201a6200a62001620071000010000100126001160011600116001060010600116001060022600247002560027600227003160021700217002b500000002270024700267000000000000
00060000295402454022540245402654029540275003d700000000d0000c0000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400003a5203952037520345202f5202b5200050000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002b040270402604025040240402404023040200401f0401b04018040300003500023000280002c00030000340000000000000000000000000000000000000000000000000000000000000000000000000
000400002c0402a0402804027040280402904029000291002a1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000014740107400d7400f7301574012740197301d740297500070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3902000017341193411d3411f3412034122341273412c341000013270134701000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f10000205002050040500505005050060500305002050030500405005050070500705006050050500405005000000000000000000000000000000000000000000000000000000000000000000000000000000
010f10001004300000156431360010043100001064311643100430000010643100001004300000106431104310000000001060000000100000000010600000001000000000106001000010000000001060010000
000f000010550137501475015750155501775018750187500000015750187501a7501c7501b750000001e7501f7502175023750257502a7502d7502e750000000000000000000000000000000000000000000000
000f00003655034550315502e54028520245100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f0000285502e550315503254034520365100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 14555657
00 14555657
00 14555657
00 14555657
01 14155657
00 14155657
00 14155657
00 14155657
00 14155657
00 14151657
00 14151657
00 14151657
00 14151657
00 14151658
00 14151657
00 14151658
00 14151657
00 14151658
00 14151657
00 14151658
00 14151657
00 14151657
00 14151657
00 14151657
00 14151657
00 14151657
00 14151658
00 14151657
00 14151657
00 14151658
00 14151657
00 14151658
00 14151657
00 14151658
00 14151657
00 14151658
00 54151657
00 54151657
00 14151657
00 54151657
00 14151757
00 14151857
00 14151757
00 14151857
00 54155657
02 54155657
00 54555657
00 54555657

