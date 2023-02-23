client.log("Welcome back, KIRA.GG user!", color.new(145, 197, 56), "kira.gg", true)
client.log("KIRA.GG has been loaded.", color.new(145, 197, 56), "kira.gg", true)
client.log("Version: 1.0", color.new(145, 197, 56), "kira.gg", true)
client.log("build: STABLE", color.new(145, 197, 56), "kira.gg", true)
client.log("Discord: discord.gg/8DqKDa8vMv", color.new(145, 197, 56), "kira.gg", true)

ui.add_label("| kira.gg |")
ui.add_label("Made By: StefanS#2614")
ui.add_label("Discord: discord.gg/NmAWewhUer")

render.fonts = {
    tahoma_13px = render.create_font("Tahoma", 13, 500, bit.bor(font_flags.dropshadow, font_flags.antialias));
}

render.screen = {
    w = 0,
    h = 0
}

render.center_screen = {
    w = 0,
    h = 0
}

render.update = function()
    local screen_size_x, screen_size_y = render.get_screen()

    render.screen.w = screen_size_x
    render.screen.h = screen_size_y

    render.center_screen.w = screen_size_x / 2
    render.center_screen.h = screen_size_y / 2
end
-- menu elements


local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
ui.add_label("")
ui.add_label("                 > ANTI-AIM <                  ")


local enable_antiaim = ui.add_checkbox("Enable Stevens AA preset")
local roll_disable = ui.add_checkbox("Disable Roll on preset")
local enable_antiaim = ui.add_checkbox("Godmode AA Preset")
local enable_tankaa = ui.add_checkbox("Tank AA Preset")
local enable_bfreestand = ui.add_checkbox("Better freestand")
local enable_bfakeduck = ui.add_checkbox("Better Fake Duck")
local roll_disable = ui.add_checkbox("Disable Roll Angles")


local cstrike = {
    cmd = nil,
    roll = 0
}

cstrike.update = function(pdr_cmd)
    cstrike.cmd = pdr_cmd
    cstrike.roll = pdr_cmd.viewangles.z
end

local globals = {
    local_player = nil,
    alive = nil,
    weapon = nil,
    weapon_type = nil,
    view_angles = nil,
    on_ground = nil
}

globals.update = function()
    globals.local_player = entity_list.get_client_entity(engine.get_local_player())
    globals.alive = client.is_alive()
    globals.weapon = entity_list.get_client_entity(globals.local_player:get_prop("DT_BaseCombatCharacter", "m_hActiveWeapon"))
    globals.weapon_type = globals.weapon:get_prop("DT_BaseAttributableItem", "m_iItemDefinitionIndex"):get_int()
    globals.view_angles = engine.get_view_angles()
end

cstrike.weapons = {
    deagle = 1,
    duals = 2,
    fiveseven = 3,
    glock = 4,
    awp = 9,
    g3sg1 = 11,
    tect9 = 30,
    p2000 = 32,
    p250 = 36,
    scar20 = 38,
    ssg08 = 40,
    revolver = 64,
    usp = 262205
}

cstrike.get_health = function(entity)
    if entity then
        local health = entity:get_prop("DT_BasePlayer", "m_iHealth"):get_int()
        return math.round(health)
    end

    return nil
end

cstrike.get_velocity = function(entity)
	if entity then
		local x = entity:get_prop("DT_BasePlayer", "m_vecVelocity[0]"):get_float()
		local y = entity:get_prop("DT_BasePlayer", "m_vecVelocity[1]"):get_float()

		return math.round(math.sqrt(x * x + y * y))
	end
end

cstrike.is_alive = function(entity)
    if entity then
        local health = cstrike.get_health(entity)
        if health > 0 then
            return true
        end
    end

    return false
end

cstrike.is_standing = function(entity)
	if entity then
		local is_moving = cstrike.is_moving(entity)
		if not is_moving then
			return true
		end
	end

	return false
end

cstrike.is_slowwalking = function(entity)
    if entity then
		if ui.get("Misc", "General", "Movement", "Slow motion key"):get_key() then
			return true
		end
    end

    return false
end


cstrike.is_crouching = function(entity)
    if entity then
        if cstrike.cmd:has_flag(4) then
            return true
        end
    end

    return false
end

cstrike.is_fake_ducking = function(entity)
    if entity then
        local duck_speed = entity:get_prop("DT_BasePlayer", "m_flDuckSpeed"):get_float()
        local duck_amount = entity:get_prop("DT_BasePlayer", "m_flDuckAmount"):get_float()

        if duck_speed == 8 and duck_amount > 0 and not cstrike.cmd:has_flag(1) then
            return true
        end
    end

    return false
end

cstrike.is_inair = function(entity)
	if entity then
        local local_player = entity_list.get_client_entity(engine.get_local_player())
		local ground_entity = local_player:get_prop("DT_BasePlayer", "m_hGroundEntity"):get_int()

		if ground_entity == -1 then
			return true
		end
	end

	return false
end

cstrike.is_moving = function(entity)
    local local_player = entity_list.get_client_entity(engine.get_local_player())
	if entity then
        local velocity = cstrike.get_velocity(entity)
		if velocity > 4 and not cstrike.is_inair(local_player)  then
			return true
		end
	end
    return false
end

cstrike.is_scoped = function(entity)
    if entity then
        local scoped = entity:get_prop("DT_CSPlayer", "m_bIsScoped"):get_int()
        if scoped == 1 then
            return true
        end
    end

    return false
end


math.radian_to_degree = function(radian)
    return radian * 180 / math.pi
end

math.degree_to_radian = function(degree)
    return degree * math.pi / 180
end

math.round = function(x)
    return x % 1 >= 0.5 and math.ceil(x) or math.floor(x)
end

math.normalize = function(angle)
    while angle < -180 do
        angle = angle + 360
    end

    while angle > 180 do
        angle = angle - 360
    end

    return angle
end

math.angle_to_vector = function(angle)
    local pitch = angle.x
    local yaw = angle.y

    return vector.new(math.cos(math.pi / 180 * pitch) * math.cos(math.pi / 180 * yaw), math.cos(math.pi / 180 * pitch) * math.sin(math.pi / 180 * yaw), -math.sin(math.pi / 180 * pitch))
end

math.calculate_angles = function(from, to)
	local sub = { 
		x = to.x - from.x, 
		y = to.y - from.y, 
		z = to.z - from.z 
	}

	local hyp = math.sqrt( sub.x * sub.x * 2 + sub.y * sub.y * 2 )

	local yaw = math.radian_to_degree( math.atan2( sub.y, sub.x ) );
	local pitch = math.radian_to_degree( -math.atan2( sub.z, hyp ) )

    return QAngle.new(pitch, yaw, 0)
end

math.calculate_fov = function(from, to, angles)
    local calculated = math.calculate_angles(from, to)

    local yaw_delta = angles.yaw - calculated.yaw;
    local pitch_delta = angles.pitch - calculated.pitch;

    if ( yaw_delta > 180 ) then
      yaw_delta = yaw_delta - 360
    end

    if ( yaw_delta < -180 ) then
      yaw_delta = yaw_delta + 360
    end

    return math.sqrt( yaw_delta * yaw_delta * 2 + pitch_delta * pitch_delta * 2 );
end
local utils = {}

utils.clamp = function(v, min, max)
    local num = v
    num = num < min and min or num
    num = num > max and max or num
    
    return num
end

utils.fluctuate = function(min, max)
    local used = false
    local ret = 0

    if used then
        ret = math.random(min, max)
        used = false
    else
        ret = math.random(min, max)
        used = true
    end

    return ret
end

utils.get_crosshair_target = function()
    if not globals.local_player then
        return
    end

    local data = {
        target = nil,
        fov = 180
    }

    local players = entity_list.get_all("CCSPlayer")
end
local antiaim = {}

antiaim.run = function()
    if not enable_antiaim:get() then
        return
    end

    local fake_yaw_type = ui.get("Rage", "Anti-aim", "General", "Fake yaw type")
    local body_yaw_limit = ui.get("Rage", "Anti-aim", "General", "Body yaw limit")
    local fake_yaw_limit = ui.get("Rage", "Anti-aim", "General", "Fake yaw limit")

    local yaw_jitter = ui.get("Rage", "Anti-aim", "General", "Yaw jitter")
    local yaw_jitter_conditions = ui.get("Rage", "Anti-aim", "General", "Yaw jitter conditions")
    local yaw_jitter_type = ui.get("Rage", "Anti-aim", "General", "Yaw jitter type")
    local yaw_jitter_range = ui.get("Rage", "Anti-aim", "General", "Yaw jitter range")

    local fake_yaw_direction = ui.get("Rage", "Anti-aim", "General", "Fake yaw direction")
    local yaw_additive = ui.get("Rage", "Anti-aim", "General", "Yaw additive")

    local body_roll = ui.get("Rage", "Anti-aim", "General", "Body roll")
    local body_roll_amount = ui.get("Rage", "Anti-aim", "General", "Body roll amount")
    local inverter_state = ui.get("Rage", "Anti-aim", "General", "Anti-aim invert")


    if cstrike.is_standing(globals.local_player) or cstrike.is_slowwalking(globals.local_player) then

        if roll_disable:get() then
            fake_yaw_direction:set(0)
            yaw_jitter:set(true)
            yaw_jitter_conditions:set("Standing", true)
            yaw_jitter_conditions:set("Walking", true)
            yaw_jitter_type:set(2)
            yaw_jitter_range:set(-38)
            body_yaw_limit:set(23)
            fake_yaw_limit:set(24)
            fake_yaw_type:set(1)
        else
            fake_yaw_direction:set(0)
            yaw_jitter:set(false)
            body_yaw_limit:set(60)
            fake_yaw_limit:set(60)
            fake_yaw_type:set(0)
            inverter_state:set_key(false)
        end

        if roll_disable:get() then
            body_roll:set(0)
        else
            body_roll:set(4)
        end
        if roll_disable:get() then
            yaw_additive:set(0)
        else
        if inverter_state:get_key( ) == false then
            body_roll_amount:set( -50 )
        else
            body_roll_amount:set( 50 )
        end
    end
    end

    if (cstrike.is_inair(globals.local_player) and not cstrike.is_moving(globals.local_player)) then 
        yaw_additive:set(0)
        yaw_jitter:set(true)
        yaw_jitter_conditions:set("In air", true)
        yaw_jitter_type:set(2)
        yaw_jitter_range:set(-34)
        fake_yaw_type:set(1)
        body_yaw_limit:set(42)
        fake_yaw_direction:set(0)
        body_roll:set(0)
    end

    if (not cstrike.is_slowwalking(globals.local_player) and cstrike.is_moving(globals.local_player)) then        
        yaw_additive:set(0)
        yaw_jitter:set(true)
        yaw_jitter_conditions:set("Moving", true)
        yaw_jitter_type:set(2)
        yaw_jitter_range:set(-42)
        fake_yaw_type:set(1)
        body_yaw_limit:set(60)
        fake_yaw_direction:set(0)
        body_roll:set(0)
    end

    if  (not cstrike.is_inair(globals.local_player) and cstrike.is_crouching(globals.local_player)) then
        yaw_additive:set(0)
        yaw_jitter:set(true)
        yaw_jitter_conditions:set("Moving", true)
        yaw_jitter_type:set(2)
        yaw_jitter_range:set(-44)
        fake_yaw_type:set(1)
        body_yaw_limit:set(46)
        fake_yaw_direction:set(0)
        body_roll:set(0)

        if roll_disable:get() then
            body_roll:set(0)
        else
            body_roll:set(4)
        end

        if inverter_state:get_key( ) == false then
            body_roll_amount:set( -50 )
        else
            body_roll_amount:set( 50 )
        end
    end
end

antiaim.handle_visibility = function()
    local state = enable_antiaim:get()
    local rol = roll_disable:get()

end
local on_post_move = function(cmd)
    globals.update()
    cstrike.update(cmd)

    antiaim.run()
end

callbacks.register("post_move", on_post_move)

local cstrike = {
    cmd = nil,
    roll = 0
}

cstrike.update = function(pdr_cmd)
    cstrike.cmd = pdr_cmd
    cstrike.roll = pdr_cmd.viewangles.z
end

local globals = {
    local_player = nil,
    alive = nil,
    weapon = nil,
    weapon_type = nil,
    view_angles = nil,
    on_ground = nil
}

globals.update = function()
    globals.local_player = entity_list.get_client_entity(engine.get_local_player())
    globals.alive = client.is_alive()
    globals.weapon = entity_list.get_client_entity(globals.local_player:get_prop("DT_BaseCombatCharacter", "m_hActiveWeapon"))
    globals.weapon_type = globals.weapon:get_prop("DT_BaseAttributableItem", "m_iItemDefinitionIndex"):get_int()
    globals.view_angles = engine.get_view_angles()
end

cstrike.weapons = {
    deagle = 1,
    duals = 2,
    fiveseven = 3,
    glock = 4,
    awp = 9,
    g3sg1 = 11,
    tect9 = 30,
    p2000 = 32,
    p250 = 36,
    scar20 = 38,
    ssg08 = 40,
    revolver = 64,
    usp = 262205
}

cstrike.get_health = function(entity)
    if entity then
        local health = entity:get_prop("DT_BasePlayer", "m_iHealth"):get_int()
        return math.round(health)
    end

    return nil
end

cstrike.get_velocity = function(entity)
	if entity then
		local x = entity:get_prop("DT_BasePlayer", "m_vecVelocity[0]"):get_float()
		local y = entity:get_prop("DT_BasePlayer", "m_vecVelocity[1]"):get_float()

		return math.round(math.sqrt(x * x + y * y))
	end
end

cstrike.is_alive = function(entity)
    if entity then
        local health = cstrike.get_health(entity)
        if health > 0 then
            return true
        end
    end

    return false
end

cstrike.is_standing = function(entity)
	if entity then
		local is_moving = cstrike.is_moving(entity)
		if not is_moving then
			return true
		end
	end

	return false
end

cstrike.is_slowwalking = function(entity)
    if entity then
		if ui.get("Misc", "General", "Movement", "Slow motion key"):get_key() then
			return true
		end
    end

    return false
end


cstrike.is_crouching = function(entity)
    if entity then
        if cstrike.cmd:has_flag(4) then
            return true
        end
    end

    return false
end

cstrike.is_fake_ducking = function(entity)
    if entity then
        local duck_speed = entity:get_prop("DT_BasePlayer", "m_flDuckSpeed"):get_float()
        local duck_amount = entity:get_prop("DT_BasePlayer", "m_flDuckAmount"):get_float()

        if duck_speed == 8 and duck_amount > 0 and not cstrike.cmd:has_flag(1) then
            return true
        end
    end

    return false
end

cstrike.is_inair = function(entity)
	if entity then
        local local_player = entity_list.get_client_entity(engine.get_local_player())
		local ground_entity = local_player:get_prop("DT_BasePlayer", "m_hGroundEntity"):get_int()

		if ground_entity == -1 then
			return true
		end
	end

	return false
end

cstrike.is_moving = function(entity)
    local local_player = entity_list.get_client_entity(engine.get_local_player())
	if entity then
        local velocity = cstrike.get_velocity(entity)
		if velocity > 4 and not cstrike.is_inair(local_player)  then
			return true
		end
	end
    return false
end

cstrike.is_scoped = function(entity)
    if entity then
        local scoped = entity:get_prop("DT_CSPlayer", "m_bIsScoped"):get_int()
        if scoped == 1 then
            return true
        end
    end

    return false
end


math.radian_to_degree = function(radian)
    return radian * 180 / math.pi
end

math.degree_to_radian = function(degree)
    return degree * math.pi / 180
end

math.round = function(x)
    return x % 1 >= 0.5 and math.ceil(x) or math.floor(x)
end

math.normalize = function(angle)
    while angle < -180 do
        angle = angle + 360
    end

    while angle > 180 do
        angle = angle - 360
    end

    return angle
end

math.angle_to_vector = function(angle)
    local pitch = angle.x
    local yaw = angle.y

    return vector.new(math.cos(math.pi / 180 * pitch) * math.cos(math.pi / 180 * yaw), math.cos(math.pi / 180 * pitch) * math.sin(math.pi / 180 * yaw), -math.sin(math.pi / 180 * pitch))
end

math.calculate_angles = function(from, to)
	local sub = { 
		x = to.x - from.x, 
		y = to.y - from.y, 
		z = to.z - from.z 
	}

	local hyp = math.sqrt( sub.x * sub.x * 2 + sub.y * sub.y * 2 )

	local yaw = math.radian_to_degree( math.atan2( sub.y, sub.x ) );
	local pitch = math.radian_to_degree( -math.atan2( sub.z, hyp ) )

    return QAngle.new(pitch, yaw, 0)
end

math.calculate_fov = function(from, to, angles)
    local calculated = math.calculate_angles(from, to)

    local yaw_delta = angles.yaw - calculated.yaw;
    local pitch_delta = angles.pitch - calculated.pitch;

    if ( yaw_delta > 180 ) then
      yaw_delta = yaw_delta - 360
    end

    if ( yaw_delta < -180 ) then
      yaw_delta = yaw_delta + 360
    end

    return math.sqrt( yaw_delta * yaw_delta * 2 + pitch_delta * pitch_delta * 2 );
end
local utils = {}

utils.clamp = function(v, min, max)
    local num = v
    num = num < min and min or num
    num = num > max and max or num
    
    return num
end

utils.fluctuate = function(min, max)
    local used = false
    local ret = 0

    if used then
        ret = math.random(min, max)
        used = false
    else
        ret = math.random(min, max)
        used = true
    end

    return ret
end

utils.get_crosshair_target = function()
    if not globals.local_player then
        return
    end

    local data = {
        target = nil,
        fov = 180
    }

    local players = entity_list.get_all("CCSPlayer")
end
local antiaim = {}

antiaim.run = function()
    if not enable_antiaim:get() then
        return
    end

    local fake_yaw_type = ui.get("Rage", "Anti-aim", "General", "Fake yaw type")
    local body_yaw_limit = ui.get("Rage", "Anti-aim", "General", "Body yaw limit")
    local fake_yaw_limit = ui.get("Rage", "Anti-aim", "General", "Fake yaw limit")

    local yaw_jitter = ui.get("Rage", "Anti-aim", "General", "Yaw jitter")
    local yaw_jitter_conditions = ui.get("Rage", "Anti-aim", "General", "Yaw jitter conditions")
    local yaw_jitter_type = ui.get("Rage", "Anti-aim", "General", "Yaw jitter type")
    local yaw_jitter_range = ui.get("Rage", "Anti-aim", "General", "Yaw jitter range")

    local fake_yaw_direction = ui.get("Rage", "Anti-aim", "General", "Fake yaw direction")
    local yaw_additive = ui.get("Rage", "Anti-aim", "General", "Yaw additive")

    local body_roll = ui.get("Rage", "Anti-aim", "General", "Body roll")
    local body_roll_amount = ui.get("Rage", "Anti-aim", "General", "Body roll amount")
    local inverter_state = ui.get("Rage", "Anti-aim", "General", "Anti-aim invert")


    if cstrike.is_standing(globals.local_player) or cstrike.is_slowwalking(globals.local_player) then

        if roll_disable:get() then
            fake_yaw_direction:set(0)
            yaw_jitter:set(true)
            yaw_jitter_conditions:set("Standing", true)
            yaw_jitter_conditions:set("Walking", true)
            yaw_jitter_type:set(2)
            yaw_jitter_range:set(-38)
            body_yaw_limit:set(23)
            fake_yaw_limit:set(24)
            fake_yaw_type:set(1)
        else
            fake_yaw_direction:set(0)
            yaw_jitter:set(false)
            body_yaw_limit:set(60)
            fake_yaw_limit:set(60)
            fake_yaw_type:set(0)
            inverter_state:set_key(false)
        end

        if roll_disable:get() then
            body_roll:set(0)
        else
            body_roll:set(4)
        end
        if roll_disable:get() then
            yaw_additive:set(0)
        else
        if inverter_state:get_key( ) == false then
            body_roll_amount:set( -50 )
        else
            body_roll_amount:set( 50 )
        end
    end
    end

    if (cstrike.is_inair(globals.local_player) and not cstrike.is_moving(globals.local_player)) then 
        yaw_additive:set(0)
        yaw_jitter:set(true)
        yaw_jitter_conditions:set("In air", true)
        yaw_jitter_type:set(2)
        yaw_jitter_range:set(-34)
        fake_yaw_type:set(1)
        body_yaw_limit:set(42)
        fake_yaw_direction:set(0)
        body_roll:set(0)
    end

    if (not cstrike.is_slowwalking(globals.local_player) and cstrike.is_moving(globals.local_player)) then        
        yaw_additive:set(0)
        yaw_jitter:set(true)
        yaw_jitter_conditions:set("Moving", true)
        yaw_jitter_type:set(2)
        yaw_jitter_range:set(-42)
        fake_yaw_type:set(1)
        body_yaw_limit:set(60)
        fake_yaw_direction:set(0)
        body_roll:set(0)
    end

    if  (not cstrike.is_inair(globals.local_player) and cstrike.is_crouching(globals.local_player)) then
        yaw_additive:set(0)
        yaw_jitter:set(true)
        yaw_jitter_conditions:set("Moving", true)
        yaw_jitter_type:set(2)
        yaw_jitter_range:set(-44)
        fake_yaw_type:set(1)
        body_yaw_limit:set(46)
        fake_yaw_direction:set(0)
        body_roll:set(0)

        if roll_disable:get() then
            body_roll:set(0)
        else
            body_roll:set(4)
        end

        if inverter_state:get_key( ) == false then
            body_roll_amount:set( -50 )
        else
            body_roll_amount:set( 50 )
        end
    end
end

antiaim.handle_visibility = function()
    local state = enable_antiaim:get()
    local rol = roll_disable:get()

end
local on_post_move = function(cmd)
    globals.update()
    cstrike.update(cmd)

    antiaim.run()
end

callbacks.register("post_move", on_post_move)

ui.add_label("")
ui.add_label("                 > RAGEBOT <                 ")
--UI--
local tickbase_boost = ui.add_checkbox("Doubletap boost")
tickbase_boost:set(false)

local ideal_tick = ui.add_checkbox("Ideal tick")
local cmd_ticks = cvar.find_var("sv_maxusrcmdprocessticks")

callbacks.register("post_move", function()

    if ideal_tick:get() == true then
        cmd_ticks:set_value_int(19)
    end

    if ideal_tick:get() == false then
        cmd_ticks:set_value_int(16)
    end

end)

local Fake_Flip = ui.add_checkbox("Fake Flick")
local Switch_Speed = ui.add_slider("Switch Speed", 0, 100)
local Last_Time = 0
local Fliplastt_Time  = 0
local yawadd_1 = ui.get("Rage", "Anti-aim", "General", "Yaw additive")
local yawadd_2 = ui.get("Rage", "Anti-aim", "General", "Yaw additive"):get()
local Yaw = ui.get("Rage", "Anti-aim", "General", "Yaw")

local function Fake_Flip_AA(cmd)

if not Fake_Flip:get() then
        return
end
    Yaw:set(1)
    local Interval = Switch_Speed:get()/ 400 *1;

    if global_vars.realtime -Last_Time >= Interval then     
    
        if Lively then                       
            Last_Time = global_vars.realtime               
        end
    
    if global_vars.realtime - Fliplastt_Time >= 0.045 then   
    
        if anti_aim.inverted() then     
            yawadd_1:set(yawadd_2 + 97)
        else
            yawadd_1:set(yawadd_2 - 100)
        end   
            Fliplastt_Time = global_vars.realtime
        return
    end
            yawadd_1:set(yawadd_2)
    Lively = false
    end   
end   

callbacks.register("post_move", Fake_Flip_AA)


--something--
local cmd_ticks = cvar.find_var("sv_maxusrcmdprocessticks")

--function--
function TickbaseBoost()
    if tickbase_boost:get() == true then
       cmd_ticks:set_value_int(19)          
    else
          cmd_ticks:set_value_int(16)  
    end    
end

--callbacks--
callbacks.register("post_move", TickbaseBoost)

-- menu elements.
local disable_lc_checkbox = ui.add_checkbox( "Enable anti-exploit" );

-- convars.
local cl_lagcompensation = cvar.find_var( "cl_lagcompensation" );

-- constants.
local TEAM_TERRORIST = 2;
local TEAM_CT = 3;

local function get_player_team( player )
    local m_iTeamNum = player:get_prop( "DT_BaseEntity", "m_iTeamNum" );

    return m_iTeamNum:get_int( );
end

-- https://github.com/perilouswithadollarsign/cstrike15_src/blob/f82112a2388b841d72cb62ca48ab1846dfcc11c8/game/shared/cstrike15/cs_gamerules.cpp#L15238
local function IsConnectedUserInfoChangeAllowed( player )
    local team_num = get_player_team( player );

    if team_num == TEAM_TERRORIST or team_num == TEAM_CT then
        return false;
    end

    return true;
end

-- cache.
local previous_dlc_state = disable_lc_checkbox:get( );

-- team swapping.
local changing_from_team = false;
local previous_team_num = -1;
local team_swap_time = -1;

local function on_paint( )
    -- get the local player's entity index.
    local local_player_idx = engine.get_local_player( );

    -- get the local player.
    local local_player = entity_list.get_client_entity( local_player_idx );

    -- will the server acknowledge our changes to cl_lagcompensation?
    if not engine.is_connected( ) or IsConnectedUserInfoChangeAllowed( local_player ) then
        -- update cl_lagcompensation accordingly.
        cl_lagcompensation:set_value_int( disable_lc_checkbox:get( ) and 0 or 1 );

        -- if we were on a team previously, we need to join that team again.
        if changing_from_team and global_vars.curtime > team_swap_time then
            -- join the team we were previously on.
            engine.execute_client_cmd( "jointeam " .. tostring( previous_team_num ) .. " 1" );

            -- we're no longer waiting to join our previous team.
            changing_from_team = false;
        end
    else
        -- have we clicked the checkbox while we were unable to change cl_lagcompensation?
        if disable_lc_checkbox:get( ) ~= previous_dlc_state then
            -- keep track of what team we're currently on.
            previous_team_num = get_player_team( local_player );

            -- join the spectator team.
            engine.execute_client_cmd( "spectate" );

            -- wait a bit before joining our team again so we don't get kicked for
            -- executing too many commands.
            changing_from_team = true;
            team_swap_time = global_vars.curtime + 1.5;

            -- cache the value of disable_lc_checkbox:get( ).
            previous_dlc_state = disable_lc_checkbox:get( );
        end
    end
end

-- init.
local function init( )
    callbacks.register( "paint", on_paint );
end
init( );



ui.add_label("")
ui.add_label("                  > VISUAL <                  ")







local enable = ui.add_checkbox("Left hand on knife")

callbacks.register("paint", function()

    local lp_wep = entity_list.get_client_entity(entity_list.get_client_entity(engine.get_local_player()):get_prop("DT_BaseCombatCharacter", "m_hActiveWeapon"))
    local knife = lp_wep:class_id() == 107

    if enable:get() then
        if knife then
            engine.execute_client_cmd("cl_righthand 0")
        elseif not knife then
            engine.execute_client_cmd("cl_righthand 1")
        end
    end

end)








local slider = ui.add_slider("Hit Effect", 3, 20)

function on_player_death(event)
    local local_player = entity_list.get_client_entity(engine.get_local_player())

    if local_player == nil then
        return
    end

    local attacker = engine.get_player_for_user_id(event:get_int("attacker"))

    if attacker == engine.get_local_player() then
        local_player:get_prop("DT_CSPlayer", "m_flHealthShotBoostExpirationTime"):set_float(global_vars.curtime + (slider:get() * 0.1))
    end
end

callbacks.register("player_death", on_player_death)




local drop = ui.add_multi_dropdown("Kill counter", {"Round Kills", "Game Kills", "Session Kills"})
local roundKills = 0
local sesionKills = 0
local gameKills = 0
local screen = { render.get_screen() }
local x,y,spacing = ui.add_slider("x", 0, screen[1]), ui.add_slider("y", 0,screen[2]), ui.add_slider("spacing", 0,50)
x:set(800)
y:set(400)
spacing:set(20)

callbacks.register("player_death", function(e)
    -- https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events#player_death
    local event = engine.get_player_for_user_id(e:get_int("attacker"))
    local local_player = engine.get_local_player()
    if event == local_player then
        roundKills = roundKills+1
        sesionKills = sesionKills+1
        gameKills= gameKills+1
    end
end)
callbacks.register("cs_match_end_restart", function ()
-- https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events#cs_match_end_restart
roundKills = 0
gameKills = 0
end)
callbacks.register("cs_game_disconnected", function ()
    -- https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events#cs_match_end_restart
    roundKills = 0
    gameKills = 0
end)
callbacks.register("round_end", function ()
-- https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events#round_end
    roundKills = 0
end)
callbacks.register("paint", function ()
    local optionCounter = -1
    if drop:get("Round Kills") then 
    optionCounter = optionCounter+1 
    render.text(x:get(), y:get(), "Round kills: "..tostring(roundKills), color.new(255,255,255,255)) 
end
    if drop:get("Game Kills") then 
    optionCounter = optionCounter+1
    render.text(x:get(),  y:get()+spacing:get()*optionCounter, "Game kills: "..tostring(gameKills), color.new(255,255,255,255)) 
    end
    if drop:get("Session Kills") then
    optionCounter = optionCounter+1 
    render.text(x:get(),  y:get()+spacing:get()*optionCounter, "Session kills: "..tostring(sesionKills), color.new(255,255,255,255)) 
end
end)







local small_fonts = render.create_font( "Small Fonts", 9, 400, font_flags.dropshadow );
local world_hitmarker_dmg = ui.add_checkbox( "World hitmarker damage" );

local markers = { }

function on_paint( )
    if not world_hitmarker_dmg:get( ) then
        return
    end

    local step = 255.0 / 1.0 * global_vars.frametime;
    local step_move = 30.0 / 1.5 * global_vars.frametime;
    local multiplicator = 0.3;

    for idx = 1, #markers do
        local marker = markers[ idx ];

        if marker == nil then
            return
        end

        marker.moved = marker.moved - step_move;

        if marker.create_time + 0.5 <= global_vars.curtime then
            marker.alpha = marker.alpha - step;
        end

        if marker.alpha > 0 then
            local screen_position = vector2d.new( 0, 0 );

            if render.world_to_screen( marker.world_position, screen_position ) then
                small_fonts:text( screen_position.x + 8, screen_position.y - 12 + marker.moved, color.new( 255, 0, 0, marker.alpha ), "-" .. marker.dmg );
            end
        else
            table.remove( markers, idx );
        end
    end
end

function on_hitmarker( damage, position )
    table.insert( markers, {
        dmg = damage,
        world_position = vector.new( position.x, position.y, position.z ), -- lua is dumb, can't just pass position here.
        create_time = global_vars.curtime,
        moved = 0.0,
        alpha = 255.0
    } );
end

callbacks.register( "on_hitmarker", on_hitmarker );
callbacks.register( "paint", on_paint );


ui.add_label("Shadow Changer")

-- menu
local light_shadow_direction_x = ui.add_slider_float("m_envLightShadowDirection_x", -1, 1)
local light_shadow_direction_y = ui.add_slider_float("m_envLightShadowDirection_y", -1, 1)
local light_shadow_direction_z = ui.add_slider_float("m_envLightShadowDirection_z", -1, 1)
local shadow_direction_x = ui.add_slider_float("m_shadowDirection_x", -1, 1)
local shadow_direction_y = ui.add_slider_float("m_shadowDirection_y", -1, 1)
local shadow_direction_z = ui.add_slider_float("m_shadowDirection_z", -1, 1)

-- callbacks
callbacks.register("paint", function()
    if not engine.is_connected() then return end

    local cascade_light = entity_list.get_all("CCascadeLight")[1]
    local m_envLightShadowDirection = entity_list.get_client_entity(cascade_light):get_prop("DT_CascadeLight", "m_envLightShadowDirection")
    local m_shadowDirection = entity_list.get_client_entity(cascade_light):get_prop("DT_CascadeLight", "m_shadowDirection")

    m_envLightShadowDirection:set_vector(vector.new(light_shadow_direction_x:get(), light_shadow_direction_y:get(), light_shadow_direction_z:get()))
    m_shadowDirection:set_vector(vector.new(shadow_direction_x:get(), shadow_direction_y:get(), shadow_direction_z:get()))
end)









local ffi = require "ffi"
ffi.cdef[[
        typedef struct {
            float x,y,z;
        } vec3_t;
        
        struct tesla_info_t {
            vec3_t m_pos;
            vec3_t m_ang;
            int m_entindex;
            const char *m_spritename;
            float m_flbeamwidth;
            int m_nbeams;
            vec3_t m_color;
            float m_fltimevis;
            float m_flradius;
        };
        
        typedef void(__thiscall* FX_TeslaFn)(struct tesla_info_t&);
]]
local match = client.find_sig("client.dll", "55 8B EC 81 EC ?? ?? ?? ?? 56 57 8B F9 8B 47 18") or error("error match")
local fs_tesla = ffi.cast("FX_TeslaFn", match)

local Enable_Tesla = ui.add_checkbox("Thunder Beam")

local Tesla_color = ui.add_cog("Tesla color", true, false)

local int_beam_slider = ui.add_slider("Tesla beam width", 1, 100)

local int_beamw_slider = ui.add_slider("Tesla beam radius", 1, 5000)

local int_beamsa_slider = ui.add_slider("Tesla amount", 1, 500)

local int_beamsa_time = ui.add_slider_float("Tesla tmie", 0.1, 10.0)

local sprite_tesla = ui.add_checkbox("Other sprite")


callbacks.register("player_hurt", function(event)

if not Enable_Tesla:get() then
    return
end

 local me = engine.get_local_player( )
 
 local attacker = engine.get_player_for_user_id( event:get_int( "attacker" ) );

 local color = Tesla_color:get_color()
 
 local r,g,b,a = color:r() * 255, color:g() * 255, color:b() * 255, color:a() * 255
 
 local attacker_player = engine.get_player_for_user_id( event:get_int("userid") )
 
 local attacker_entity = entity_list.get_client_entity( attacker_player )
 
if attacker == me then
  
 local x = math.random(-1000, 1000)

 local y = math.random(-x, x)

 local z = math.random(-y, y)
 
 local tesla_info = ffi.new("struct tesla_info_t")           
 
 tesla_info.m_flbeamwidth = int_beam_slider:get()       
 
 tesla_info.m_flradius = int_beamw_slider:get()           
 
 tesla_info.m_entindex = attacker               
 
 tesla_info.m_color = {r / 255, g / 255, b / 255, a / 255}                 
 
 tesla_info.m_pos = { attacker_entity:hitbox_position(6).x, attacker_entity:hitbox_position(6).y, attacker_entity:hitbox_position(6).z }     
 
 tesla_info.m_fltimevis = int_beamsa_time:get()   
 
 tesla_info.m_ang = {x,y,z}
 
 tesla_info.m_nbeams = int_beamsa_slider:get()       
 
 tesla_info.m_spritename = sprite_tesla:get() and  "sprites/physbeam.vmt" or "sprites/purplelaser1.vmt"
 fs_tesla(tesla_info)   
        
   end
  
end)


local enablebloom = ui.add_checkbox("Enable Bloom")
local bloomscale = ui.add_slider("Bloom Scale", 0, 100)    


local bloomenz = cvar.find_var("mat_bloom_scalefactor_scalar") --ofc the only value that actually did anything was a fucking dev var

callbacks.register("paint", function()
    if (engine.get_local_player() ~= nil and engine.in_game() ~= nil and client.map_name() ~= nil) then
     
        if(enablebloom ~= 1) then    
bloomenz:set_value_int(bloomscale:get())
        end



    end
end)

local indic_toggle = ui.add_checkbox("Enable indicators")
--local high_dpi_font = ui.add_checkbox("High DPI")

local indicators = {
    screen        = { render.get_screen() },
    screen_center = vector2d.new(0, 0),
    font_pixel    = render.create_font("Small Fonts", 8, 300, bit.bor(font_flags.outline)),
   -- high_dpi      = render.create_font("Verdana", 12, 100, bit.bor(font_flags.dropshadow, font_flags.antialias)),
    pulse_alpha   = 255,
    font_used     = font_pixel,
    refs = {
        baim = ui.get("Rage", "Aimbot", "Accuracy", "Force body-aim key"),
        fd = ui.get("Rage", "Anti-Aim", "Fake-lag", "Fake duck key"),
        dt = ui.get("Rage", "Exploits", "General", "Double tap key"),
        freestand = ui.get("Rage", "Anti-Aim", "General", "Freestanding key"),
        os = ui.get("Rage", "Exploits", "General", "Hide shots key"),
        dmg = ui.get("Rage", "Aimbot", "General", "Minimum damage override key")
    }
}

indicators.draw = function(table)
    for key, indicator in pairs(table) do
        key = key + 1

        local actual_index = key - 1 
        local font_size = { indicators.font_used:get_size(indicator.text) }

        indicators.font_used:text(
            render.center_screen.w + -30,
            render.center_screen.h + 10 + font_size[2] * actual_index,
            indicator.color,
            indicator.text
        )
    end
end


indicators.main = function()
    
    if not globals.local_player or not client.is_alive()  then
        return
    end

    if not indic_toggle:get() then
        return
    end
  --  indicators.font_used = indicators.high_dpi
  --  if not high_dpi_font:get() then
        indicators.font_used =  indicators.font_pixel
  --  end

    indicators.pulse_alpha = math.sin(math.abs((math.pi * -1) + (global_vars.curtime * 2.5) % (math.pi * 2))) * 255
    indicators.font_used:text( render.center_screen.w + -30, render.center_screen.h + 10, color.new(197, 204, 255, math.max(indicators.pulse_alpha, 25)), "Kirayaw")


    indicators.indicators = {}


    
    if indicators.refs.dmg:get_key() then
        table.insert(
            indicators.indicators,
            {
                text = ("DMG"),
                color = color.new(197, 204, 255) 
            }
        )
    end

    if indicators.refs.freestand:get_key() then
        table.insert(
            indicators.indicators,
            {
                text = ("FREESTAND"),
                color = color.new(197, 204, 255)
            }
        )
    end

    if indicators.refs.os:get_key() then
        table.insert(
            indicators.indicators,
            {
                text = ("ONSHOT"),
                color = color.new(197, 204, 255)
            }
        )
    end


    if indicators.refs.fd:get_key() then
        table.insert(
            indicators.indicators,
            {
                text = ("DUCK"),
                color = color.new(197, 204, 255)
            }
        )
    end

    if indicators.refs.dt:get_key() then
        table.insert(
            indicators.indicators,
            {
                text = ("DT [" .. round(exploits.process_ticks() / exploits.max_process_ticks()*100, 0) .. "%]"),
                color = exploits.ready() and color.new(197, 204, 255) or color.new(255, 71, 71)
            }
        )
    end

    local body_roll_amount = ui.get("Rage", "Anti-aim", "General", "Body roll amount")

    if math.abs(cstrike.roll) > 0 then 
        table.insert(
            indicators.indicators,
            {
                text = ("ROLL"),
                color = color.new(255, 150, 255)
            }
        )
    end


    indicators.draw(indicators.indicators)
end

local ui_get, ui_set, ui_add_checkbox, ui_add_dropdown, ui_add_multi_dropdown, ui_add_label, ui_add_cog, cvar_find_var, callbacks_register, render_create_font, anti_aim_inverted, ui_add_slider, client_is_alive = ui.get, ui.set, ui.add_checkbox, ui.add_dropdown, ui.add_multi_dropdown, ui.add_label, ui.add_cog, cvar.find_var, callbacks.register, render.create_font, anti_aim.inverted, ui.add_slider, client.is_alive

local menu = {
    switch = ui_add_checkbox( 'Enable arrows' ),
    dropdown = ui_add_dropdown( ' ', { 'Manual anti-aim', 'Inverter side' } ),
    color_label = ui_add_label( 'Active arrow color' ) ,
    color_active_color = ui_add_cog( 'Color', true, false ),
    slider = ui_add_slider( 'Arrows offset', 20, 100 ),
}

menu.handle = function()
    local switch = menu.switch:get()
    menu.dropdown:set_visible( switch )
    menu.color_label:set_visible( switch )
    menu.color_active_color:set_visible( switch )
    menu.slider:set_visible( switch )
end

local arrows = {}

arrows.ref = {
    left = ui_get( 'Rage', 'Anti-aim', 'General', 'Manual left key' ),
    back = ui_get( 'Rage', 'Anti-aim', 'General', 'Manual backwards key' ),
    right = ui_get( 'Rage', 'Anti-aim', 'General', 'Manual right key' ),
    screen_size = { render.get_screen() }
}

arrows.var = {
    pos = { x = arrows.ref.screen_size[1] / 2, y = arrows.ref.screen_size[2] / 2 },
    font = render_create_font( 'verdana', 30, 900, bit.bor(font_flags.antialias) )
}

arrows.handle_manual = function()
    local text_size = { arrows.var.font:get_size('⮜') }
    local colors = {
        active = menu.color_active_color:get_color(),
        inactive = color.new(150, 150, 150, 150)
    }
    local offset = menu.slider:get()
    arrows.var.font:text( arrows.var.pos.x - offset - text_size[1], arrows.var.pos.y - text_size[2] / 2 - 2, arrows.ref.left:get_key() and colors.active or colors.inactive, '⮜' )
    arrows.var.font:text( arrows.var.pos.x - text_size[1] / 2 - 1, arrows.var.pos.y + offset - 10, arrows.ref.back:get_key() and colors.active or colors.inactive, '⮟' )
    arrows.var.font:text( arrows.var.pos.x + offset, arrows.var.pos.y  - text_size[2] / 2 - 2, arrows.ref.right:get_key() and colors.active or colors.inactive, '⮞' )
end

arrows.handle_inverter = function()
    local text_size = { arrows.var.font:get_size('⮜') }
    local colors = {
        active = menu.color_active_color:get_color(),
        inactive = color.new(150, 150, 150, 150)
    }
    local offset = menu.slider:get()
    arrows.var.font:text( arrows.var.pos.x - offset - text_size[1], arrows.var.pos.y - text_size[2] / 2 - 2, not anti_aim_inverted() and colors.active or colors.inactive, '⮜' )
    arrows.var.font:text( arrows.var.pos.x + offset, arrows.var.pos.y  - text_size[2] / 2 - 2, anti_aim_inverted() and colors.active or colors.inactive, '⮞' )
end

local all_callbacks = {}

all_callbacks.on_paint = function()
    menu.handle()

    local switch = menu.switch:get()
    if not switch then
        return
    end

    if not client_is_alive() then
        return
    end

    if menu.dropdown:get() == 0 then
        arrows.handle_manual()
    end

    if menu.dropdown:get() == 1 then
        arrows.handle_inverter()
    end
end

callbacks_register( 'paint', all_callbacks.on_paint )

local elements = {
    [1] = "Static legs",
    [2] = "Pitch 0 on land",
    [3] = "Slide legs"
}

local cstrike = {}

cstrike.is_scoped = function(entity)
    if entity then
        local scoped = entity:get_prop("DT_CSPlayer", "m_bIsScoped"):get_int()
        if scoped == 1 then
            return true
        end
    end

    return false
end

local viewmodel_in_scope = ui.add_checkbox("Viewmodel in scope")


local on_paint = function()

    local fov_cs_debug = cvar.find_var("fov_cs_debug")

    if not viewmodel_in_scope:get() then
        fov_cs_debug:set_value_int(0)
        return
    end

    local local_player = entity_list.get_client_entity(engine.get_local_player())
    if not local_player then
        return
    end

    if cstrike.is_scoped(local_player) then
        fov_cs_debug:set_value_int(90)
    else
        fov_cs_debug:set_value_int(0)
    end
end

callbacks.register("paint", on_paint)

local displayMaxSpeed = ui.add_dropdown("Slowed down indicator (sigma style)", {"Disabled", "Enabled"})
local interval = 0

local function rgb_health_based(percentage)
    local r = 124*2 - 124 * percentage
    local g = 195 * percentage
    local b = 13
    return r, g, b
end

local function remap(val, newmin, newmax, min, max, clamp)
    min = min or 0
    max = max or 1

    local pct = (val-min)/(max-min)

    if clamp ~= false then
        pct = math.min(1, math.max(0, pct))
    end

    return newmin+(newmax-newmin)*pct
end

local function rectangle_outline(x, y, w, h, r, g, b, a, s)
    s = s or 1
    render.rectangle(x, y, w, s, color.new(r, g, b, a)) -- top
    render.rectangle(x, y+h-s, w, s, color.new(r, g, b, a)) -- bottom
    render.rectangle(x, y+s, s, h-s*2, color.new(r, g, b, a)) -- left
    render.rectangle(x+w-s, y+s, s, h-s*2, color.new(r, g, b, a)) -- right
end

local function drawBar(modifier, r, g, b, a, text)
    local text_width = 95
    local sw, sh = render.get_screen()
    local x, y = sw/2-text_width, sh*0.35

    if a > 0.7 then
        render.rectangle(x+13, y+11, 8, 20, color.new(16, 16, 16, 255*a))
    end

    render.text(x+8, y+3, string.format("%s %.f", text, modifier * 100.0), color.new(255, 255, 255, 255*a))

    local rx, ry, rw, rh = x+8, y+3+17, text_width, 12
    rectangle_outline(rx, ry, rw, rh, 0, 0, 0, 255*a, 1)
    render.rectangle_filled(rx+1, ry+1, rw-2, rh-2, color.new(16, 16, 16, 180*a))
    render.rectangle_filled(rx+1, ry+1, math.floor((rw-2)*modifier), rh-2, color.new(r, g, b, 180*a))
end

callbacks.register("paint", function()
    local lp = entity_list.get_client_entity(engine.get_local_player())
    if not client.is_alive() then return end

    local modifier = lp:get_prop("DT_CSPlayer", "m_flVelocityModifier"):get_float()
    if modifier == 1 then return end

    local r, g, b = rgb_health_based(modifier)
    local a = remap(modifier, 1, 0, 0.85, 1)

    if displayMaxSpeed:get() == 1 then
        drawBar(modifier, r, g, b, a, "Slowed down")
    end
end)


local font = render.create_font("Verdana", 12, 400, bit.bor(font_flags.outline))
--Menu
local indicator_checkbox = ui.add_checkbox("Enable user panel")

-- Var
local g_col_disabled = color.new(153,124,122);
local g_col_enabled  = color.new(153,124,122);
local lag_history = {0, 0, 0, 0, 0, 0}
-- UI GET
local jitter = ui.get("Rage","Anti-Aim","General","Yaw jitter")
local exploit = ui.get("Rage", "Exploits", "General", "Enabled")
local dt = ui.get("Rage", "Exploits", "General", "Double tap key")
local dmg = ui.get_rage("General", "Minimum damage override key")
local fs = ui.get("Rage", "Anti-aim", "General", "Freestanding key")
local fd = ui.get("Rage", "Anti-aim", "Fake-lag", "Fake duck key")
local sw = ui.get("Misc", "General", "Movement", "Slow motion key")


local function drawBase()
if indicator_checkbox:get() == true then
    font:text(30, 450, color.new(153,120,92),"KIRAYAW - version 1.1")
    font:text(30, 465, color.new(132,113,145),"> anti-aim info :")
    font:text(30, 480, color.new(153,124,122),"> rage-bot info :")
    font:text(30, 495, color.new(154,156,134),"> player info : state - ")
    end 
end
local function drawFl()
        if client.choked_commands() < lag_history[6] then
            lag_history[1] = lag_history[2]
             lag_history[2] = lag_history[3]
             lag_history[3] = lag_history[4]
             lag_history[4] = lag_history[5]
             lag_history[5] = lag_history[6]
        end
        font:text(153,465, color.new(115,109,153), string.format("fl(%i-%i-%i)",lag_history[5],lag_history[4],lag_history[3],lag_history[2],lag_history[1]  ))
        lag_history[6] = client.choked_commands()
end
local function drawSide()
    if anti_aim.inverted() then
        font:text(223, 465, color.new(115,109,153), "side : > ")     
    else
        font:text(223, 465, color.new(115,109,153), "side : < ")
    end
end
local function drawAA()
    if not fs:get_key() then
        font:text(125, 465, color.new(118,109,153),"jitter")
        return
    elseif jitter:get() == true then
        font:text(125, 465, color.new(118,109,153),"fs")  -- (freestanding)
    else
        font:text(125, 465, color.new(118,109,153),"static")
    end
end

local function getMinimumDamage( var )
    local minimum_damage = var:get();
    if minimum_damage == 0 then
        return "auto";
    elseif minimum_damage > 100 then
        return string.format("hp+%d", minimum_damage - 100);
    else
        return tostring(minimum_damage);
    end
end
local function drawDmg()
    local is_overriding = dmg:get_key();
    local dmg1 = ui.get_rage("General", "Minimum damage")
    local dmg2 = ui.get_rage("General", "Minimum damage override")
    local v = getMinimumDamage(is_overriding and dmg2 or dmg1);
    font:text(123, 480, is_overriding and g_col_enabled or g_col_disabled, string.format("dmg: %s", v));
   
end
local function drawDt()
    if not exploit:get() then
        return
    end
    if not dt:get_key() then
        font:text(175, 480, color.new(153,124,122)," dt")
        return
    end
    local doubletap_value = exploits.process_ticks() / 14;
    font:text( 175, 480, color.new(153,124,122), string.format(" dt (%d%s)", math.floor(doubletap_value * 100), "%"));
end 
local function drawPlayer()
   if sw:get_key() then
    font:text(150, 495, color.new(154,156,134),"slow walk")
   end
   if fd:get_key() then
    font:text(150, 495, color.new(154,156,134),"fake duck")
   end
   if not sw:get_key() and not fd:get_key() then
    font:text(150, 495, color.new(154,156,134),"native")
   end  
end
-- end indicator 

local function onPaint()
if indicator_checkbox:get() == true then
    if not client.is_alive() then
        return
    end
   drawBase();
   drawFl();
   drawSide();
   drawAA();
   drawDmg();
   drawDt();
   drawPlayer();
end
end
callbacks.register("paint", onPaint);

local indicator_checkbox = ui.add_checkbox("Damage indicator")

-- Var
local g_col_disabled = color.new(255,255,255);
local g_col_enabled  = color.new(255,255,255);

-- Screensize
local screen_width, screen_height = render.get_screen( );
local center_x = ( screen_width / 2 );
local center_y = ( screen_height / 2);

local dmg = ui.get_rage("General", "Minimum damage override key")

local function getMinimumDamage( var )
    local minimum_damage = var:get();
    if minimum_damage == 0 then
        return "auto";
    elseif minimum_damage > 100 then
        return string.format("10%d", minimum_damage - 100);
    else
        return tostring(minimum_damage);
    end
end
local function drawDmg()
    local is_overriding = dmg:get_key();
    local dmg1 = ui.get_rage("General", "Minimum damage")
    local dmg2 = ui.get_rage("General", "Minimum damage override")
    local v = getMinimumDamage(is_overriding and dmg2 or dmg1);
    font:text(center_x - -5, center_y - 20, is_overriding and g_col_enabled or g_col_disabled, string.format("%s", v));
   
end


local function onPaint()
if indicator_checkbox:get() == true then
    if not client.is_alive() then
        return
    end
   drawDmg();
end
end
callbacks.register("paint", onPaint);



local custom_scopre = ui.add_checkbox("Custom scope")
local scope_color_label = ui.add_label("Scope color")
local scope_color = ui.add_cog("dsda", true, false)
local scope_size = ui.add_slider("Scope size", 0, 500)
local scope_padding = ui.add_slider("Scope padding", 0, 250)
local scopetype = ui.get("Visuals", "General", "Other group", "Scope effect type")
local entity_get_client_entity = entity_list.get_client_entity
local alpha = 0

function scope_on_paint()

    if custom_scopre:get() then

        scopetype:set(0)
        
        local screen_size_x, screen_size_y = render.get_screen()
        local screen_center = vector2d.new(screen_size_x / 2, screen_size_y / 2)
    
        local_player = entity_get_client_entity(engine.get_local_player())
    
        if not engine.in_game() then
            return
        end
    
        if local_player == nil then
            return
        end
        
        if local_player:get_prop("DT_BasePlayer", "m_iHealth"):get_int() <= 0 then
            return
        end

        local multiplier = (1.0 / (225/1000)) * global_vars.frametime

        if local_player:get_prop("DT_CSPlayer", "m_bIsScoped"):get_bool() then
            if alpha < 1.0 then
                alpha = alpha + multiplier
            end
        else
            if alpha > 0.0 then
                alpha = alpha - multiplier
            end
        end

        if alpha >= 1.0 then
            alpha = 1
        end
    
        if alpha <= 0.0 then
            alpha = 0
            return
        end

        local r, g, b, a = scope_color:get_color():r(), scope_color:get_color():g(), scope_color:get_color():b(), scope_color:get_color():a()

        local sizee = scope_size:get()

        -- top
        pos = vector2d.new(screen_center.x, screen_center.y - sizee)
        size = vector2d.new(1, sizee * alpha)
        pos.y = pos.y - (scope_padding:get() - 1)
        render.gradient(pos.x, pos.y, size.x, size.y, color.new(0,0,0,0), color.new(r,g,b,a * alpha), false)

        -- bottom
        pos = vector2d.new(screen_center.x, screen_center.y + (sizee * ( 1.0 - alpha ) ))
        size = vector2d.new(1, scope_size:get() - ( sizee * ( 1.0 - alpha ) ))
        pos.y = pos.y + scope_padding:get()
        render.gradient(pos.x, pos.y, size.x, size.y, color.new(r,g,b,a * alpha), color.new(0,0,0,0), false)

        -- left
        pos = vector2d.new(screen_center.x - sizee, screen_center.y)
        size = vector2d.new(sizee * alpha, 1)
        pos.x = pos.x - (scope_padding:get() - 1)
        render.gradient(pos.x, pos.y, size.x, size.y, color.new(0,0,0,0), color.new(r,g,b,a * alpha), true)

        -- right
        pos = vector2d.new(screen_center.x + (sizee * ( 1.0 - alpha ) ), screen_center.y)
        size = vector2d.new(sizee - ( sizee * ( 1.0 - alpha ) ), 1)
        pos.x = pos.x + scope_padding:get()
        render.gradient(pos.x, pos.y, size.x, size.y, color.new(r,g,b,a * alpha), color.new(0,0,0,0), true)
    end
    
    if custom_scopre:get() == false then
        scopetype:set(1)
    end
end

callbacks.register("paint", scope_on_paint)

local small_fonts = render.create_font( "Small Fonts", 9, 400, font_flags.dropshadow );
local world_hitmarker_dmg = ui.add_checkbox( "Hitmarker" );

local markers = { }

function on_paint( )
    if not world_hitmarker_dmg:get( ) then
        return
    end

    local step = 255.0 / 1.0 * global_vars.frametime;
    local step_move = 30.0 / 1.5 * global_vars.frametime;
    local multiplicator = 0.3;

    for idx = 1, #markers do
        local marker = markers[ idx ];

        if marker == nil then
            return
        end

        marker.moved = marker.moved - step_move;

        if marker.create_time + 0.5 <= global_vars.curtime then
            marker.alpha = marker.alpha - step;
        end

        if marker.alpha > 0 then
            local screen_position = vector2d.new( 0, 0 );

            if render.world_to_screen( marker.world_position, screen_position ) then
                small_fonts:text( screen_position.x + 8, screen_position.y - 12 + marker.moved, color.new( 163, 146, 255, marker.alpha ), "-" .. marker.dmg );
            end
        else
            table.remove( markers, idx );
        end
    end
end

function on_hitmarker( damage, position )
    table.insert( markers, {
        dmg = damage,
        world_position = vector.new( position.x, position.y, position.z ),
        create_time = global_vars.curtime,
        moved = 0.0,
        alpha = 255.0
    } );
end

callbacks.register( "on_hitmarker", on_hitmarker );
callbacks.register( "paint", on_paint );

local dist_ref = ui.add_slider("Thirdperson distance", 0, 200)
local get_cam_idealdist = cvar.find_var("cam_idealdist")

callbacks.register("paint", function()
   get_cam_idealdist:set_value_int(dist_ref:get())
end)

-- Sets variable viewmodel_offset_x to the cvar
local viewmodel_offset_x = cvar.find_var("viewmodel_offset_x")
-- Sets variable viewmodel_offset_y to the cvar
local viewmodel_offset_y = cvar.find_var("viewmodel_offset_y")
-- Sets variable viewmodel_offset_z to the cvar
local viewmodel_offset_z = cvar.find_var("viewmodel_offset_z")

-- Adds X slider to change "viewmodel_offset_x" cvar
local offset_x = ui.add_slider("Offset X", -20, 20)
-- Sets a default value for "viewmodel_offset_x"
offset_x:set(2)
-- Adds Y slider to change "viewmodel_offset_y" cvar
local offset_y = ui.add_slider("Offset Y", -20, 20)
-- Sets a default value for "viewmodel_offset_y"
offset_y:set(2)
-- Adds Z slider to change "viewmodel_offset_z" cvar
local offset_z = ui.add_slider("Offset Z", -20, 20)
-- Sets a default value for "viewmodel_offset_z"
offset_z:set(-2)

-- Starts function
callbacks.register("paint", function()

    -- Sets "viewmodel_offset_x" cvar to slider created above
    viewmodel_offset_x:set_value_float(offset_x:get())
    -- Sets "viewmodel_offset_y" cvar to slider created above
    viewmodel_offset_y:set_value_float(offset_y:get())
    -- Sets "viewmodel_offset_z" cvar to slider created above
    viewmodel_offset_z:set_value_float(offset_z:get())

end)



ui.add_label("")
ui.add_label("                    > MISC <                    ")


local SegoeUI = render.create_font( "Segoe UI", 13, 700, bit.bor( font_flags.dropshadow, font_flags.antialias ) );

local size_x,size_y = render.get_screen( )
ffi.cdef[[
    struct vec3_t {
        float x;
        float y;
        float z;   
    };

    typedef void( __thiscall* energy_splash_fn )( void*, const struct vec3_t& position, const struct vec3_t& direction, bool explosive );
]]

local native = { }

native.bind_argument = function( fn, arg )
    return function( ... )
        return fn( arg, ... );
    end
end

-- get the effects interface.
native.effects_interface = ffi.cast( ffi.typeof( "uintptr_t**" ), client.create_interface( "client.dll", "IEffects001" ) );

-- get the EnergySplash vfunc.
native.energy_splash = native.bind_argument( ffi.cast( "energy_splash_fn", native.effects_interface[ 0 ][ 7 ] ), native.effects_interface );

local menu_elements = {
    auto_peek_cog = ui.get( "Misc", "General", "Movement", "Auto peek key" ),
    __particle_color_label = ui.add_label( "Particle AutoPeek color" ),
    particle_color_cog = ui.add_cog( "What color the particles should be", true, false );
}

local constants = {
    PI = 3.14159265358979323846,
    RADIUS = 25.0,
    ROTATION_STEP = 0.06,
    SPARKS_MATERIAL = materials.find_material( "effects/spark", "" ),
    FL_ONGROUND = bit.lshift( 1, 0 )
}

-- we have to do these out side of the table because lua sucks.
constants.MAX_ROTATION = constants.PI * 2.0;
constants.DIRECTION_VECTOR = ffi.new( "struct vec3_t" );
constants.DIRECTION_VECTOR.x = 0;
constants.DIRECTION_VECTOR.y = 0;
constants.DIRECTION_VECTOR.z = 0;

local variables = {
    current_rotation = 0.0,
    current_peek_position = vector.new( 0, 0, 0 ),
    has_valid_peek_position = false,
    last_particle_color = menu_elements.particle_color_cog:get_color(),
    needs_to_modulate = true
}

callbacks.register( "paint", function()
    -- are we not in a game?
    if not engine.in_game() then
        -- we will need to modulate the sparks material again.
        variables.needs_to_modulate = true;
    end

    -- get the color.
    local color = menu_elements.particle_color_cog:get_color();

    -- modulate spark material if we update the color picker.
    if variables.last_particle_color ~= color or variables.needs_to_modulate then
        -- modulate the spark material.
        constants.SPARKS_MATERIAL:modulate_color( color:r() / 255.0, color:g() / 255.0, color:b() / 255.0 );
        constants.SPARKS_MATERIAL:modulate_alpha( color:a() / 255.0 );

        -- update last particle color.
        variables.last_particle_color = color;

        -- update needs to modulate.
        if variables.needs_to_modulate then
            variables.needs_to_modulate = false;
        end
    end
end)

callbacks.register( "post_move", function( cmd )
    -- reset peek position if we're not holding our auto peek key.
    if not menu_elements.auto_peek_cog:get_key() then
        variables.current_peek_position = vector.new( 0, 0, 0 );
        variables.has_valid_peek_position = false;

        return;
    end

    -- get the local player.
    local local_player = entity_list.get_client_entity( engine.get_local_player() );

    -- get the local player's origin.
    local origin = local_player:origin();

    -- get the local player's flags
    local flags = local_player:get_prop( "DT_BasePlayer", "m_fFlags" ):get_int();

    -- update our peek position to our current origin if we haven't done so already.
    if not variables.has_valid_peek_position and bit.band( flags, constants.FL_ONGROUND ) == 1 then
        variables.current_peek_position = origin;
        variables.has_valid_peek_position = true;
    end

    -- only draw if we have a valid peek position.
    if variables.has_valid_peek_position then
        -- step the rotation forward a bit.
        variables.current_rotation = variables.current_rotation + constants.ROTATION_STEP;

        -- where should the trace end.
        local end_position = vector.new( constants.RADIUS * math.cos( variables.current_rotation ) + variables.current_peek_position.x, constants.RADIUS * math.sin( variables.current_rotation ) + variables.current_peek_position.y, variables.current_peek_position.z );

        -- run the trace.
        local trace = engine_trace.trace_ray( variables.current_peek_position, end_position, local_player, 0xFFFFFFFF );

        -- convert trace endpos to our custom vec3_t struct.
        local spark_position = ffi.new( "struct vec3_t" );
        spark_position.x = trace.endpos.x;
        spark_position.y = trace.endpos.y;
        spark_position.z = trace.endpos.z;

        -- spawn the effect.
        native.energy_splash( spark_position, constants.DIRECTION_VECTOR, false );

        -- reset once we've made a full rotation.
        if variables.current_rotation > constants.MAX_ROTATION then
            variables.current_rotation = 0.0;
        end
    end
end)





local animations = {
    on_land = false,
    static_legs_on = false,
    pitch_land_on = false,
    sliding_legs_on = false,
    options =  ui.add_multi_dropdown("Custom animations", { elements[1], elements[2], elements[3] })
}

animations.main = function(ent)

    if ent:index() ~= engine.get_local_player() or not globals.local_player or not client.is_alive()  then
        return
    end

    animations.static_legs_on = animations.options:get(elements[1])
    animations.pitch_land_on = animations.options:get(elements[2])
    animations.sliding_legs_on = animations.options:get(elements[3])


    animations.sliding_legs(ent)
    animations.static_legs(ent)
    animations.pitch_land(ent)
end


animations.sliding_legs = function(ent)

    if not animations.sliding_legs_on then
        return
    end

    local m_flPoseParameter = ent:get_prop("DT_BaseAnimating", "m_flPoseParameter")
    m_flPoseParameter:set_float_index(0, 1)
end

animations.static_legs = function(ent)

    if not animations.static_legs_on then
        return
    end

    local m_flPoseParameter = ent:get_prop("DT_BaseAnimating", "m_flPoseParameter")
    m_flPoseParameter:set_float_index(6, 1)
end

animations.pitch_land = function(ent)

    if not animations.pitch_land_on then
        return
    end

    if not animations.on_land then
        return
    end
    
    local m_flPoseParameter = ent:get_prop("DT_BaseAnimating", "m_flPoseParameter")
    m_flPoseParameter:set_float_index(12, 0.45)
end

local ground_ticks = 0
local end_time = 0

animations.update_land = function()

    if not globals.local_player or not client.is_alive() then
        return
    end

    local on_ground = bit.band(globals.local_player:get_prop("DT_BasePlayer", "m_fFlags"):get_int(), 1)

    if on_ground == 1 then
        ground_ticks = ground_ticks + 1
    else
        ground_ticks = 0
        end_time = global_vars.curtime + 1
    end 

    animations.on_land = false

    if ground_ticks > 2 and end_time > global_vars.curtime then
        animations.on_land = true
    end

end

local x, y=render.get_screen()

local lua={

    menu={
        watermark=ui.add_checkbox("Enable watermark"),
        color=ui.add_cog("Watermark", true, false),
    },

    get_tickrate=function()
        if not engine.is_connected() then return 0 end
        return math.floor(1.0/global_vars.interval_per_tick)
    end,

    watermark_rect=function(x, y, w, h, color)
        render.rectangle_filled(x, y, w, 2, color)
        render.rectangle_filled(x, y, w, h-2, color.new(0, 0, 0, 120))
    end,

    font={
        segoe_ui=render.create_font("SegoUI", 13, 700, bit.bor(font_flags.dropshadow, font_flags.antialias)),
    },
    
}

function watermark()
    if not lua.menu.watermark:get() then return end
    local text=string.format("Kirayaw | %s | rate: %s | ms: %s | %s", "Kirayaw user", (lua.get_tickrate()), tostring(client.latency()+0), client.local_time("%H:%M:%S"))
    local text_size={lua.font.segoe_ui:get_size(text)}
    lua.watermark_rect(x-text_size[1]-15, 8, text_size[1]+10, text_size[2]+5, lua.menu.color:get_color())
    lua.font.segoe_ui:text(x-text_size[1]-10, 10, color.new(255, 255, 255, 255),text)
end

function on_paint()
    watermark()
end

callbacks.register("paint", on_paint)

local font = render.create_font("Verdana", 12, 250, bit.bor(font_flags.outline))

local best_killsay = ui.add_checkbox("Enable killsay")

function on_player_death(event)
    if not best_killsay:get() then
        return
    end

    local phrases = {
       "𝔼𝕦𝕘𝕖𝕟 𝔾𝕣𝕘𝕚𝕔 𝕘𝕣𝕚𝕞𝕫𝕨𝕒𝕣𝕖 𝕒𝕣𝕣𝕖𝕤𝕥𝕖𝕕 𝕒𝕗𝕥𝕖𝕣 𝕣𝕖𝕢𝕦𝕖𝕤𝕥𝕚𝕟𝕘 𝟙𝟝𝟘𝔼𝕋ℍ 𝕗𝕣𝕠𝕞 𝔸𝟙",
	"ｉ ｈｓ ｓｉｎｃｅ ｍｙ ｍｏｔｈｅｒ ｂｏｒｎｅｄ ｍｅ",
	"i live and laugh knowing u die.",
	"my spotlight is bigger then united states of 𝒦𝒪𝒮𝒪𝒱𝒪 𝑅𝐸𝒫𝒰𝐵𝐿𝐼𝒞",
	"I AM LEGEND TO MY FAMILY",
	"tommorow Nemanja Danilovic will suffer his last blow after gsense ban",
	"𝗲𝗻𝗷𝗼𝘆 𝗱𝗶𝗲 𝘁𝗼 𝗚 𝗟𝗢𝗦𝗦 𝗟𝗨𝗔",
	"𝕥𝕙𝕚𝕤 𝕠𝕟𝕖 𝕚𝕤 𝕗𝕠𝕣 𝕞𝕪 𝕄𝕌𝕄𝕄ℤ𝕐 𝕖𝕟𝕛𝕠𝕪 𝕕𝕚𝕖",
	"𝓽𝓱𝓲𝓼 𝔀𝓮𝓪𝓴 𝓭𝓸𝓰 rxzey 𝓌𝒶𝓈 𝒹𝑒𝓅𝑜𝓇𝓉𝑒𝒹 𝓉𝑜 𝒦𝐿𝒜𝒟𝒪𝒱𝒪",
	"after killing ReDD 𝕚 𝕘𝕠𝕥 𝕡𝕣𝕖𝕤𝕚𝕕𝕖𝕟𝕥 𝕠𝕗 𝕒𝕔𝕖𝕥𝕠𝕝",
	"by funny color player",
    "you think you are 𝔰𝔦𝔤𝔪𝔞 𝔭𝔯𝔢𝔡𝔦𝔠𝔱𝔦𝔬𝔫 but no.",
    "neverlose will always use as long father esotartliko has my back.",
    "after winning 1vALL i went on vacation to 𝒢𝒜𝐵𝐸𝒩 𝐻𝒪𝒰𝒮𝐸",
    "i superior resolver(selling @discord.gg/vsQTRTHE3S))",
    "ＹＯＵ ＨＡＤ ＦＵＮ ＬＡＵＧＨＩＮＧ ＵＮＴＩＬ ＮＯＷ",
    "once this game started 𝔂𝓸𝓾 𝓵𝓸𝓼𝓮𝓭 𝓪𝓵𝓻𝓮𝓭𝔂",
    "WOMANBOSS VS 𝙀𝙑𝙀𝙍𝙔𝙊𝙉𝙀(𝙌𝙏𝙍𝙐𝙀,𝙍𝙊𝙊𝙏,𝙍𝘼𝙕𝙊,𝙍𝙀𝘿𝘿,𝙍𝙓𝙕𝙀𝙔,𝘽𝙀𝘼𝙕𝙏,𝙎𝙄𝙂𝙈𝘼,𝙂𝙍𝙄𝙈𝙕𝙒𝘼𝙍𝙀)",
	"𝕖𝕤𝕠𝕥𝕒𝕣𝕥𝕝𝕚𝕜 𝔸𝕃 ℙ𝕌𝕋𝕆 𝕊𝕌𝔼𝕃𝕆!",
	"𝘨𝘢𝘮𝘦𝘴𝘯𝘴𝘦 𝘪𝘴 𝘥𝘪𝘦 𝘵𝘰 𝘶.",
	"𝙨𝙬𝙖𝙢𝙥𝙢𝙤𝙣𝙨𝙩𝙚𝙧 𝙤𝙛 𝙢𝙚 𝙞𝙨 𝙘𝙤𝙢𝙚 𝙤𝙪𝙩",
	"weak gay femboy cho is depression after lose https://gamesense.pub/forums/viewtopic.php?id=35658",
	"after ban from galaxy i go on all servers to 𝓂𝒶𝓀𝑒 𝑒𝓋𝑒𝓇𝓎𝑜𝓃𝑒 𝓅𝒶𝓎 𝒻𝑜𝓇 𝒷𝒶𝓃 𝑜𝒻 𝓂𝑒",
	"𝚠𝚎𝚊𝚔 𝚍𝚘𝚐(𝚖𝚋𝚢 𝚋𝚕𝚊𝚌𝚔) 𝚐𝚘 𝚑𝚎𝚕𝚕 𝚊𝚏𝚝𝚎𝚛 𝚔𝚒𝚕𝚕",
	"𝔻𝕠𝕟’𝕥 𝕡𝕝𝕒𝕪 𝕓𝕒𝕟𝕜 𝕧𝕤 𝕞𝕖, 𝕚𝕞 𝕝𝕚𝕧𝕖 𝕥𝕙𝕖𝕣𝕖.",
	"𝙙𝙖𝙮 666 𝙃𝙑𝙃𝙔𝘼𝙒 𝙨𝙩𝙞𝙡𝙡 𝙣𝙤 𝙧𝙞𝙫𝙖𝙡𝙨",
	"𝕌 ℂ𝔸ℕ 𝔹𝕌𝕐 𝔸 ℕ𝔼𝕎 𝔸ℂℂ𝕆𝕌ℕ𝕋 𝔹𝕌𝕋 𝕌 ℂ𝔸ℕ𝕋 𝔹𝕌𝕐 𝔸 𝕎𝕀ℕ",
	"my config better than your",
	"1 STFU NN WHO.RU $$$ UFF YA UID?",
	"𝕣𝕖𝕤𝕠𝕝𝕧𝕖𝕣 𝕁ℤ 𝕤𝕠𝕠𝕟.",
	"𝕀 𝔸𝕄 𝕃𝔸𝕍𝔸 𝕐𝕆𝕌 𝔸ℝ𝔼 𝔽ℝ𝕆𝔾",
	"game vs you is free win",
	"𝙖𝙛𝙩𝙚𝙧 𝙠𝙞𝙡𝙡𝙞𝙣𝙜 𝙜𝙧𝙞𝙢𝙯𝙬𝙖𝙧𝙚 𝙞 𝙘𝙡𝙖𝙞𝙢𝙚𝙙 𝙢𝙮 𝙥𝙡𝙖𝙘𝙚 𝙖𝙨 𝙋𝙍𝙀𝙕𝙄𝘿𝙀𝙉𝙏 𝙊𝙁 𝘾𝙍𝙊𝘼𝙏𝙄𝘼",
	"𝘴𝘩𝘰𝘱𝘱𝘺.𝘨𝘨/@𝘢𝘧𝘳𝘪𝘤𝘬𝘢𝘴𝘭𝘫𝘪𝘷𝘢 𝘵𝘰 𝘪𝘯𝘤𝘳𝘦𝘢𝘴𝘦 𝘩𝘷𝘩 𝘱𝘰𝘵𝘦𝘯𝘵𝘪𝘢𝘭",
	"𝔦 𝔰𝔱𝔬𝔭 𝔲 𝔴𝔦𝔱𝔥 𝔱𝔥𝔦𝔰 ℌ$",
	"𝔲 𝔫𝔢𝔢𝔡 𝔱𝔯𝔞𝔫𝔰𝔩𝔞𝔱𝔬𝔯 𝔱𝔬 𝔥𝔦𝔱 𝔪𝔶 𝔞𝔫𝔱𝔦 𝔞𝔦𝔪𝔟𝔬𝔱",
	"𝒻𝒶𝓃𝒸𝒾𝑒𝓈𝓉 𝒽𝓋𝒽 𝓇𝑒𝓈𝑜𝓁𝓋𝑒𝓇 𝒾𝓃 𝒾𝓃𝒹𝓊𝓈𝓉𝓇𝓎 𝑜𝒻 𝓋𝒾𝓉𝓂𝒶",
	"𝕒𝕗𝕥𝕖𝕣 𝕝𝕖𝕒𝕧𝕚𝕟𝕘 𝕣𝕠𝕞𝕒𝕟𝕚𝕒 𝕚 𝕓𝕖𝕔𝟘𝕞𝕖 = 𝕝𝕖𝕘𝕖𝕟𝕕𝕒",
	"gσ∂ вℓєѕѕ υηιтє∂ ѕтαтєѕ σƒ яσмαηι & ѕєявια",
	"ur lua cracked like egg",
	"i am america after doing u like japan in HVH",
	"winning not possibility, sry.",
	"after this ＨＥＡＤＳＨＯＲＴ i become sigma",
	"𝕘𝕠𝕕 𝕘𝕒𝕧𝕖 𝕞𝕖 𝕡𝕠𝕨𝕖𝕣 𝕠𝕗 𝕣𝕖𝕫𝕠𝕝𝕧𝕖𝕣 𝕁𝔸𝕍𝔸𝕊ℂℝ𝕀ℙ𝕋𝔸",
	"ｉ ａｍ ａｍｂａｓｓａｄｏｒ ｏｆ ｇｓｅｎｓｅ",
	"𝓼𝓴𝓮𝓮𝓽 𝓬𝓻𝓪𝓬𝓴 𝓷𝓸 𝔀𝓸𝓻𝓴 𝓪𝓷𝔂𝓶𝓸𝓻𝓮 𝔀𝓱𝓪𝓽 𝓾 𝓾𝓼𝓮 𝓷𝓸𝔀",
	"𝕡𝕠𝕠𝕣 𝕕𝟘𝕘 𝕊ℙ𝔸𝔻𝔼𝔻 𝕟𝕖𝕖𝕕 𝟚𝟘$ 𝕥𝕠 𝕓𝕦𝕪 𝕟𝕖𝕨 𝕒𝕚𝕣 𝕞𝕒𝕥𝕥𝕣𝕖𝕤𝕤.",
	"i am KING go slave for me",
	"Dont cry, say ᶠᵘᶜᵏ ʸᵒᵘ and smile.",
	"My request for 150 ETH was not filled in. It passed almost 48 hours, I gave them 72...",
    "𝒶𝒻𝓉𝑒𝓇 𝒷𝒶𝓃 𝒻𝓇𝑜𝓂 𝓈𝓀𝑒𝑒𝓉(𝑔𝓈𝑒𝓃𝓈𝑒) 𝒾 𝒷𝒶𝓃 𝓎𝑜𝓊 𝒻𝓇𝑜𝓂 𝒽𝑒𝒶𝓋𝑒𝓃.𝓁𝓊𝒶",
    "𝘨𝘰𝘥 𝘣𝘭𝘦𝘴𝘴𝘦𝘥 𝘨𝘢𝘮𝘦𝘴𝘦𝘯𝘴𝘦 𝘢𝘯𝘥 𝘳𝘦𝘨𝘦𝘭𝘦 𝘰𝘧 𝘸𝘰𝘳𝘭𝘥(𝘮𝘦)",
   	"𝕒𝕗𝕥𝕖𝕣 𝕣𝕖𝕔𝕚𝕖𝕧𝕖 𝕤𝕜𝕖𝕖𝕥𝕓𝕖𝕥𝕒 𝕚 +𝕨 𝕚𝕟𝕥𝕠 𝕪𝕠𝕦",
    "ｅｖｅｎ ｓｉｇｍａ ｃａｎｔ ｔｏｕｃｈ ｍｙ ａｎｔｉ ｒｅｓｏｌｖｅｒ",
    "𝓊 𝑔𝑜 𝓈𝓁𝑒𝑒𝓅 𝓁𝒾𝓀𝑒 𝓎𝑜𝓊𝓇 *𝒟𝐸𝒜𝒟* 𝓂𝑜𝓉𝒽𝑒𝓇𝓈",
   	"𝒾 𝓀𝒾𝓁𝓁𝑒𝒹 𝓊 𝒻𝓇𝑜𝓂 𝓂𝑜𝑜𝓃",
   	"𝕖𝕝𝕖𝕡𝕙𝕒𝕟𝕥 𝕝𝕠𝕠𝕜 𝕒𝕝𝕚𝕜𝕖 𝕎𝕀𝕊ℍ 𝕕𝕚𝕖𝕕 𝕥𝕠 𝕞𝕖 𝕤𝕠 𝕨𝕚𝕝𝕝 𝕪𝕠𝕦",
    "ᵍᵒᵒᵈ ᵈᵃʸ ᵗᵒ ʰˢ ⁿᵒⁿᵃᵐᵉˢ.",
    "𝙖𝙛𝙩𝙚𝙧 𝙘𝙖𝙧𝙙𝙞𝙣𝙜 𝙛𝙤𝙤𝙙 𝙛𝙤𝙧 𝙭𝙖𝙉𝙚 𝙞 𝙧𝙚𝙘𝙞𝙚𝙫𝙚𝙙 𝙨𝙠𝙚𝙚𝙩𝙗𝙚𝙩𝙖",
	"𝔫𝔢𝔳𝔢𝔯 𝔱𝔥𝔦𝔫𝔨 𝔶𝔬𝔲𝔯 𝔠𝔬𝔦𝔫𝔟𝔞𝔰𝔢 𝔦𝔰 𝔰𝔞𝔣𝔢",
	"𝓲 𝔀𝓲𝓵𝓵 𝓼𝓲𝓶𝓼𝔀𝓪𝓹 𝔂𝓸𝓾𝓻 𝓯𝓪𝓶𝓲𝓵𝔂",
	"𝕗𝕣𝕖𝕖 𝕙𝕧𝕙 𝕝𝕖𝕤𝕤𝕠𝕟𝕤 @discord.gg/vsQTRTHE3S",
	"(っ◔◡◔)っ ♥ enjoy this H$ and spectate me ♥",
	"𝕚 𝕒𝕞 𝕜𝕝𝕒𝕕𝕠𝕧𝕠 𝕡𝕖𝕖𝕜 (◣_◢)",
	"𝓎𝑜𝓊𝓇 𝒹𝑜𝓍 𝒾𝓈 𝒶𝓁𝓇𝑒𝒶𝒹𝓎 𝓅𝑜𝓈𝓉𝑒𝒹.",
    "𝔦 𝔥$ 𝔞𝔫𝔡 𝔰𝔪𝔦𝔩𝔢",
	"ｙｏｕ ｃｒｙ？",
	"𝙞 𝙚𝙣𝙩𝙚𝙧𝙚𝙙 𝙧𝙪𝙧𝙪𝙧𝙪 𝙨𝙩𝙖𝙩𝙚 𝙤𝙛 𝙢𝙞𝙣𝙙",
    "𝓇𝑒𝓏𝑜𝓁𝓋𝑒𝓇 𝑜𝓃 𝓎𝑜𝓊 = 𝐹𝒪𝑅𝒞𝐸 𝐻$",
	"𝔸𝔽𝕋𝔼ℝ 𝔼𝕊ℂ𝔸ℙ𝕀ℕ𝔾 𝕊𝔼ℂ𝕌ℝ𝕀𝕋𝕐 𝕀 𝕎𝔼ℕ𝕋 𝕆ℕ 𝕂𝕀𝕃𝕃𝕀ℕ𝔾 𝕊ℙℝ𝔼𝔸𝕂 𝕌ℝ 𝕀ℕ 𝕀𝕋",
	"𝘪 𝘩𝘴 𝘺𝘰𝘶. 𝘦𝘷𝘦𝘳𝘺𝘵𝘪𝘮𝘦 𝘫𝘶𝘴𝘵 𝘩𝘴. 𝘣𝘶𝘺 𝘮𝘺 𝘬𝘧𝘨.",
	"cu@gsense/spotlight section of forum by MOGYORO",
	"u die while i talk with prezident of 𝙰𝙵𝙶𝙷𝙰𝙽𝙸𝚂𝚃𝙰𝙽𝙸 making $$$",
	"my coinbase is thicker then the hs i gave u",
	"olympics every 4 years next chance to kill me is in 100",
	"stop talk u *DEAD*",
	"𝒩𝐸𝒱𝐸𝑅 𝒯𝐻𝐼𝒩𝒦 𝒴𝒪𝒰 yerebko",
	"𝕟𝕠 𝕤𝕜𝕚𝕝𝕝 𝕟𝕖𝕖𝕕 𝕥𝕠 𝕜𝕚𝕝𝕝 𝕪𝕠𝕦",
	"𝕥𝕙𝕚𝕤 𝕓𝕠𝕥𝕟𝕖𝕥 𝕨𝕚𝕝𝕝 𝕖𝕟𝕕 𝕦 𝕙𝕒𝕣𝕕𝕖𝕣 𝕥𝕙𝕖𝕟 𝕞𝕪 𝕓𝕦𝕝𝕝𝕖𝕥",
	"𝘸𝘰𝘮𝘢𝘯𝘣𝘰$$ 𝘰𝘸𝘯𝘪𝘯𝘨 𝘲𝘶𝘢𝘥𝘳𝘶𝘱𝘭𝘦𝘵 𝘪𝘯𝘥𝘪𝘢𝘯𝘴 𝘢𝘯𝘥 𝘨𝘺𝘱𝘴𝘪𝘴 𝘴𝘪𝘯𝘤𝘦 2001",
	"𝘺𝘰𝘶 𝘫𝘶𝘴𝘵 𝘨𝘰𝘵 𝘵𝘢𝘱𝘱𝘦𝘥 𝘣𝘺 𝘢 𝘴𝘶𝘱𝘦𝘳𝘪𝘰𝘳 𝘱𝘭𝘢𝘺𝘦𝘳, 𝘨𝘰 𝘤𝘰𝘮𝘮𝘪𝘵 𝘩𝘰𝘮𝘪𝘤𝘪𝘥𝘦",
	"𝕁𝕦𝕤𝕥 𝕘𝕠𝕥 𝕟𝕖𝕞𝕒𝕟𝕛𝕒𝕕 𝕤𝕥𝕒𝕪 𝕠𝕨𝕟𝕖𝕕 𝕒𝕟𝕕 𝕗𝕒𝕥",
	"𝕪𝕠𝕦 𝕒𝕦𝕥𝕠𝕨𝕒𝕝𝕝 𝕞𝕖 𝕠𝕟𝕔𝕖 , 𝕚 𝕒𝕦𝕥𝕠𝕨𝕒𝕝𝕝 𝕪𝕠𝕦 𝕥𝕨𝕚𝕔𝕖 (◣_◢) ",
	"𝓫𝔂 𝔀𝓸𝓶𝓪𝓷𝓫𝓸𝓼𝓼 𝓻𝓮𝓼𝓸𝓵𝓿𝓮𝓻 $",
	"𝘸𝘰𝘳𝘴𝘩𝘪𝘱 𝘵𝘩𝘦 𝘨𝘰𝘥𝘴, 𝘸𝘰𝘳𝘴𝘩𝘪𝘱 𝘮𝘦",
	"1",
	"𝟙,𝟚,𝟛 𝕚𝕟𝕥𝕠 𝕥𝕙𝕖 𝟜, 𝕨𝕠𝕞𝕒𝕟 𝕞𝕗𝕚𝕟𝕘 𝕓𝕠𝕤𝕤 𝕨𝕚𝕥𝕙 𝕥𝕙𝕖 𝕔𝕙𝕣𝕠𝕞𝕖 𝕥𝕠 𝕪𝕒 𝕕𝕠𝕞𝕖",
	"𝔧𝔢𝔴𝔦𝔰𝔥 𝔱𝔢𝔯𝔪𝔦𝔫𝔞𝔱𝔬𝔯",
	"𝕐𝕠𝕦 𝕜𝕚𝕝𝕝 𝕞𝕖 𝕀 𝕖𝕩𝕥𝕠𝕣𝕥 𝕪𝕠𝕦 𝕗𝕠𝕣 𝟙𝟝𝟘 𝕖𝕥𝕙",
	"𝘢𝘭𝘸𝘢𝘺𝘴 𝘩𝘴, 𝘯𝘦𝘷𝘦𝘳 𝘣𝘢𝘮𝘦.",
	"𝘒𝘪𝘉𝘪𝘛 𝘷𝘚 𝘰𝘊𝘪𝘖 (𝘨𝘖𝘖𝘥𝘌𝘭𝘌𝘴𝘴 𝘥0𝘨) 𝘰𝘞𝘯𝘌𝘥 𝘐𝘯 3𝘹3",
	"𝕪𝕠𝕦𝕣 𝕒𝕟𝕥𝕚𝕒𝕚𝕞 𝕤𝕠𝕝𝕧𝕖𝕕 𝕝𝕚𝕜𝕖 𝕒𝕝𝕘𝕖𝕓𝕣𝕒 𝕖𝕢𝕦𝕒𝕥𝕚𝕠𝕟",
	"ｗｅａｋ ｂｏｔ ｍａｌｖａ ａｌｗａｙｓ ｄｏｇ",
	"𝙥𝙧𝙞𝙫𝙖𝙩𝙚 𝙞𝙙𝙚𝙖𝙡 𝙩𝙞𝙘𝙠 𝙩𝙚𝙘𝙝𝙣𝙤𝙡𝙤𝙜𝙞𝙚𝙨 ◣_◢",
	"𝕓𝕖𝕤𝕥 𝕤𝕖𝕣𝕓𝕚𝕒𝕟 𝕝𝕠𝕘 𝕞𝕖𝕥𝕙𝕠𝕕𝕤 𝕥𝕒𝕡 𝕚𝕟",
	"so i recive KILLSEY BOOST SYSTEM and now itS dead all",
	"𝑴𝒚 𝒈𝒊𝒓𝒍𝒇𝒓𝒊𝒆𝒏𝒅𝒔 𝒂𝒏𝒅 𝑰 𝒋𝒖𝒔𝒕 𝒘𝒂𝒏𝒕𝒆𝒅 𝒕𝒐 𝒉𝒂𝒗𝒆 𝒂 𝒈𝒊𝒓𝒍𝒔 𝒏𝒊𝒈𝒉𝒕 𝒐𝒖𝒕 𝒃𝒖𝒕 𝒊𝒕 𝒕𝒖𝒓𝒏𝒆𝒅 𝒊𝒏𝒕𝒐 𝒎𝒆 𝒈𝒆𝒕𝒕𝒊𝒏𝒈 FREE HELL TIKET",
	"𝕀𝕋 𝕎𝔸𝕊 𝔸 𝕄𝕀𝕊𝕋𝔸𝕂𝔼 𝕋𝕆 𝔹𝔸ℕ ℙ𝔼𝕋ℝ𝔼ℕ𝕂𝕆 𝕋ℍ𝔼 ℂ𝔸𝕋 𝔽ℝ𝕆𝕄 𝔹ℝ𝔸ℤ𝕀𝕃 ℕ𝕆𝕎 𝔼𝕊𝕆𝕋𝕀𝕃𝔸ℝℂ𝕆 𝕊ℍ𝔸𝕃𝕃 ℙ𝔸𝕐 ⚠️",
	"𝐲𝐨𝐮 𝐤𝐢𝐥𝐥 𝐦𝐞 𝐛𝐮𝐭 𝐢 𝐤𝐢𝐥𝐥 𝐲𝐨𝐮𝐫 𝐬𝐢𝐦 𝐜𝐚𝐫𝐝",
	"𝘾𝙤𝙞𝙣𝙗𝙖𝙨𝙚: 𝘾𝙤𝙣𝙛𝙞𝙧𝙢 𝙩𝙧𝙖𝙣𝙨𝙛𝙚𝙧 𝙧𝙚𝙦𝙪𝙚𝙨𝙩. 𝘾𝙤𝙞𝙣𝙗𝙖𝙨𝙚: 𝙔𝙤𝙪 𝙨𝙚𝙣𝙩 10.244 𝙀𝙏𝙃 𝙩𝙤 𝙬𝙤𝙢𝙖𝙣𝙗𝙤𝙨𝙨.𝙚𝙩𝙝",
	"ᴊᴀʀᴠɪs: ɴɴ ᴅᴏɢ ᴛᴀᴘᴘᴇᴅ sɪʀ",
	"𝚒 𝚜𝚗𝚒𝚝𝚌𝚑𝚎𝚍 𝚘𝚗 𝚎𝚞𝚐𝚎𝚗𝚎 𝚐𝚛𝚐𝚒𝚌… ",
	"𝙜𝙖𝙢𝙚𝙨𝙚𝙣𝙨𝙚.𝙥𝙪𝙗 𝙚𝙧𝙧𝙤𝙧 404 𝙙𝙪𝙚 𝙩𝙤  𝕔𝕝𝕠𝕦𝕕𝕗𝕝𝕒𝕣𝕖 𝕓𝕪𝕡𝕒𝕤𝕤𝕖𝕤 ◣_◢",
	"game-sense is a reaaly good against nevelooss and some other",
	"the server shivers when the when 𝐰𝐨𝐦𝐚𝐧𝐛𝐨𝐬𝐬 𝐭𝐞𝐚𝐦 connect..",
	"𝕟𝕠 𝕞𝕒𝕥𝕔𝕙 𝕗𝕠𝕣 𝕜𝕦𝕣𝕒𝕔 𝕣𝕖𝕤𝕠𝕝𝕧𝕖𝕣",
	"𝕋𝕙𝕚𝕤 𝕕𝕠𝕘 𝕤𝕠𝕗𝕚 𝕥𝕙𝕚𝕟𝕜 𝕙𝕖 𝕙𝕒𝕤 𝕓𝕖𝕤𝕥 𝕙𝕒𝕔𝕜 𝕓𝕦𝕥 𝕙𝕖 𝕙𝕒𝕤𝕟”𝕥 𝕓𝕖𝕖𝕟 𝕥𝕠 𝕞𝕒𝕝𝕕𝕚𝕧𝕖𝕤 𝕌𝕊𝔸 𝕖𝕤𝕠𝕥𝕒𝕝𝕜𝕚𝕜",
	"𝕚𝕞 𝕒𝕝𝕨𝕒𝕪𝕤 𝟙𝕧𝕤𝟛𝟠 𝕤𝕥𝕒𝕔𝕜 𝕘𝕠𝕠𝕕𝕝𝕖𝕤𝕤 𝕓𝕦𝕥 𝕥𝕙𝕖𝕪 𝕚𝕥𝕤 𝕟𝕠𝕥 𝕨𝕚𝕟 𝕧𝕤 𝕄𝔼",
	"𝕚𝕞 +𝕨 𝕚𝕟𝕥𝕠 𝕪𝕠𝕦 𝕨𝕙𝕖𝕟 𝕚 𝕨𝕒𝕤 𝕣𝕖𝕔𝕚𝕧𝕖𝕕 𝕞𝕖𝕤𝕤𝕒𝕘𝕖 𝕗𝕣𝕠𝕞 𝕖𝕤𝕠𝕥𝕒𝕝𝕚𝕜",
	"𝕘𝕠𝕕 𝕟𝕚𝕘𝕙𝕥 - 𝕗𝕣𝕠𝕞 𝕥𝕙𝕖 𝕘𝕒𝕞𝕖𝕤𝕖𝕟𝕫.𝕦𝕫𝕓𝕖𝕜𝕚𝕤𝕥𝕒𝕟",
	"𝘶𝘯𝘧𝘰𝘳𝘵𝘶𝘯𝘢𝘵𝘦 𝘮𝘦𝘮𝘣𝘦𝘳 𝘬𝘯𝘦𝘦 𝘢𝘨𝘢𝘪𝘯𝘴𝘵 𝘸𝘰𝘮𝘢𝘯𝘣𝘰𝘴𝘴",
	"𝕒𝕝𝕨𝕒𝕪𝕤 𝕕𝕠𝕟𝕥 𝕘𝕠 𝕗𝕠𝕣 𝕙𝕖𝕒𝕕 𝕒𝕚𝕞 𝕠𝕟𝕝𝕪 𝕚𝕕𝕖𝕒𝕝 𝕥𝕚𝕜 𝕥𝕖𝕔𝕟𝕠𝕝𝕠𝕛𝕚𝕤 ◣_◢",
	"+𝕨 𝕨𝕚𝕥𝕙 𝕚𝕞𝕡𝕝𝕖𝕞𝕖𝕟𝕥 𝕠𝕗 𝕘𝕒𝕞𝕖𝕤𝕖𝕟𝕤.𝕤𝕖𝕣𝕓𝕚𝕒",
	"𝕦𝕟𝕗𝕠𝕣𝕥𝕦𝕟𝕒𝕥𝕪𝕝𝕪 𝕪𝕠𝕦 𝕚𝕥𝕤 𝕣𝕖𝕔𝕚𝕧𝕖 𝔽𝕣𝕖𝕖 𝕙𝕖𝕝𝕝 𝕖𝕩𝕡𝕖𝕕𝕚𝕥𝕚𝕠𝕟",
	"𝚗𝚘 𝚋𝚊𝚖𝚎𝚜 𝚠𝚒𝚝𝚑 𝚞𝚜𝚎 𝚘𝚏 𝚔𝚞𝚛𝚊𝚌 𝚛𝚎𝚣𝚘𝚕𝚟𝚎𝚛 𝚝𝚎𝚌𝚑𝚗𝚘𝚕𝚘𝚓𝚒𝚎𝚜",
	"ℕ𝕖𝕨 𝕗𝕣𝕖𝕖 +𝕨 𝕥𝕣𝕚𝕔𝕜 𝕔𝕠𝕞𝕚𝕟𝕘 𝕤𝕠𝕠𝕟 𝕚𝕟 𝕤𝕖𝕣𝕓𝕚𝕒 𝕦𝕡𝕕𝕒𝕥𝕖 𝕠𝕗 𝕥𝕙𝕖 𝕘𝕒𝕞𝕖 𝕤𝕖𝕟𝕤𝕖𝕣𝕚𝕟𝕘",
	"𝕒𝕝𝕨𝕒𝕪𝕤 𝕚 𝕘𝕠 𝟙𝕧𝟛𝟞 𝕧𝕤 𝕦𝕟𝕗𝕠𝕣𝕥𝕦𝕟𝕒𝕥𝕖 𝕞𝕖𝕞𝕓𝕖𝕣𝕤… 𝕒𝕝𝕨𝕒𝕪𝕤 𝕚 𝕒𝕞 𝕧𝕚𝕔𝕥𝕠𝕣𝕪  ◣_◢",
	"(っ◔◡◔)っ ♥ fnay”ed ♥",
	"𝕚 𝕒𝕞 𝕚𝕥”𝕤 𝕕𝕠𝕟𝕥 𝕝𝕠𝕤𝕖  ◣_◢",
	"𝕚 𝕕𝕖𝕤𝕥𝕣𝕠𝕪 𝕔𝕣𝕠𝕒𝕥𝕚𝕒 𝕡𝕠𝕨𝕖𝕣 𝕘𝕣𝕚𝕕 𝕚𝕟 𝕞𝕖𝕞𝕠𝕣𝕪 𝕠𝕗 𝕕𝕖𝕒𝕣 𝔼𝕦𝕘𝕖𝕟𝕖 𝔾𝕣𝕘𝕚𝕔",
	"𝕣𝕠𝕞𝕒𝕟𝕪 𝕓𝕖𝕘 𝕞𝕖 𝕗𝕠𝕣 𝕜𝕗𝕘 𝕓𝕦𝕥 𝕚𝕞 𝕤𝕒𝕪 𝟝 𝕡𝕖𝕤𝕠𝕤",
	"𝕚𝕞 𝕔𝕒𝕟 𝕙𝕒𝕔𝕜 𝕗𝕟𝕒𝕪 𝕒𝕟𝕕 𝕡𝕣𝕖𝕕𝕚𝕔𝕥𝕚𝕠𝕟 𝕒𝕝𝕝 𝕟𝕖𝕩𝕥 𝕣𝕠𝕦𝕟𝕕..",
	"𝕡𝕣𝕖𝕞𝕚𝕦𝕞 𝕗𝕚𝕧𝕖 𝕟𝕚𝕘𝕙𝕥𝕤 𝕒𝕥 𝕗𝕣𝕖𝕕𝕕𝕪𝕤 𝕙𝕒𝕔𝕜𝕤 @discord.gg/vsQTRTHE3S",
	"𝕀𝔾𝔸𝕄𝔼𝕊𝔼ℕ𝕊𝔼 𝔸ℕ𝕋𝕀-𝔸𝕀𝕄 ℍ𝔼𝔸𝔻𝕊ℍ𝕆𝕋 ℙℝ𝔼𝔻𝕀ℂ𝕋+𝟙𝔸ℕ𝕋𝕀-ℕ𝔼𝕎-𝕋𝔼ℂℍℕ𝕆𝕃𝕆𝔾𝕐 𝕀𝕊 ℙℝ𝔼𝕊𝔼ℕ𝕋𝔼𝔻!!𝔹𝕐 𝕄𝕌𝕊𝕋𝔸𝔹𝔸ℝ𝔹𝔸𝔸ℝ𝕀𝟙𝟛𝟛𝟟𝟙-!𝔽ℝ𝔼𝔼 𝕃𝕌𝔸 𝕋𝕆𝕄𝕆ℝℝ𝕆𝕎!𝕆𝕎ℕ𝔼𝔻 𝔸𝕃𝕃!",
	"𝕓𝕦𝕘𝕤 𝕔𝕒𝕞𝕖 𝕗𝕣𝕠𝕞 𝕤𝕚𝕘𝕞𝕒’𝕤 𝕟𝕠𝕤𝕖 𝕒𝕟𝕕 𝕙𝕚𝕤 𝕖𝕪𝕖𝕤 𝕥𝕦𝕣𝕟𝕖𝕕 𝕓𝕝𝕒𝕔𝕜 ◣_◢",
	"𝕤𝕠 𝕒 𝕨𝕖𝕒𝕜 𝕗𝕣𝕖𝕕𝕕𝕪 𝕗𝕒𝕫𝕓𝕖𝕒𝕣 𝕋𝕋 𝕤𝕠 𝕚 𝕤𝕡𝕖𝕟𝕕 𝟙𝟘 𝕟𝕚𝕘𝕙𝕥”𝕤 𝕨𝕚𝕥𝕙 𝕙𝕚𝕞 𝕞𝕠𝕥𝕙𝕖𝕣",
	"ғʀᴇᴅᴅʏ ғᴀᴢʙᴇᴀʀ ᴍɪɢʜᴛ ʙᴇ ᴘʟᴀʏɪɴɢ ᴄsɢᴏ…",
	"𝕤𝕡𝕖𝕔𝕚𝕒𝕝 𝕞𝕖𝕤𝕤𝕒𝕘𝕖 𝕥𝕠 𝕝𝕚𝕘𝕙𝕥𝕠𝕟 𝕙𝕧𝕙 𝕨𝕖 𝕨𝕚𝕝𝕝 𝕔𝕠𝕞𝕖 𝕥𝕠 𝕦𝕣 𝕙𝕠𝕦𝕤𝕖 𝕒𝕘𝕒𝕚𝕟 𝕒𝕟𝕕 𝕥𝕙𝕚𝕤 𝕥𝕚𝕞𝕖 𝕚𝕥 𝕨𝕚𝕝𝕝 𝕟𝕠𝕥 𝕓𝕖 𝕡𝕖𝕒𝕔𝕖𝕗𝕦𝕝 ◣_◢",
	"𝕒𝕔𝕔𝕠𝕣𝕕𝕚𝕟𝕘 𝕥𝕠 𝕪𝕠𝕦𝕥𝕦𝕓𝕖 𝕒𝕟𝕒𝕝𝕚𝕥𝕚𝕔𝕤, 𝟟𝟘% 𝕒𝕣𝕖 𝕟𝕠𝕥 𝕤𝕦𝕓𝕤𝕔𝕣𝕚𝕓𝕖𝕤... ◣_◢",
    }
    

    local userid = event:get_int("userid")
    local attacker = event:get_int("attacker")
    local local_player = engine.get_local_player()
    local attacker_entindex = engine.get_player_for_user_id(attacker)
    local victim_entindex = engine.get_player_for_user_id(userid)

    if attacker_entindex ~= local_player or victim_entindex == local_player then
        return
    end

    engine.execute_client_cmd("say " .. phrases[math.random(1, #phrases)])
end

callbacks.register("player_death", on_player_death)


local Names = {
	"Special Agent Ava",
	"Operator | FBI Swat",
    "Ofiice Ct Agent Helmet On",
    "Ofiice Ct Agent Helmet Off",
	"Safecracker Voltzmann",
    "Danger Zone Best Agent",
    "Sir Bloody Loudmouth Darryl",
	"Sir Bloody Miami Darryl",
	"Ballas Purple",
    "Ballas Pink",
}

local Materials = {
	"models/player/custom_player/legacy/ctm_fbi_variantb.mdl",  
	"models/player/custom_player/legacy/ctm_fbi_variantf.mdl", 
    "models/player/custom_player/legacy/ctm_gign_varianta.mdl",  
	"models/player/custom_player/legacy/ctm_gign_variantd.mdl",      
	"models/player/custom_player/legacy/tm_professional_varg.mdl", 
	"models/player/custom_player/legacy/tm_jumpsuit_varianta.mdl", 
	"models/player/custom_player/legacy/tm_professional_varf4.mdl", 
	"models/player/custom_player/legacy/tm_professional_varf.mdl",
	"models/player/custom_player/kolka/ballas/ballas.mdl",       
	"models/player/custom_player/frnchise9812/ballas1.mdl",
}

local mca = ui.add_checkbox("Enable model changer")
local mca_List = ui.add_dropdown("Models list", Names)

ffi.cdef[[
       typedef struct
    {
        void*   handle;
        char    name[260];
        int     load_flags;
        int     server_count;
        int     type;
        int     flags;
        float   mins[3];
        float   maxs[3];
        float   radius;
        char    pad[0x1C];
    } model_t;
    typedef struct _class{void** this;}aclass;
    typedef void*(__thiscall* get_client_entity_t)(void*, int);
    typedef void(__thiscall* find_or_load_model_fn_t)(void*, const char*);
    typedef const int(__thiscall* get_model_index_fn_t)(void*, const char*);
    typedef const int(__thiscall* add_string_fn_t)(void*, bool, const char*, int, const void*);
    typedef void*(__thiscall* find_table_t)(void*, const char*);
    typedef void(__thiscall* full_update_t)();
    typedef int(__thiscall* get_player_idx_t)();
    typedef void*(__thiscall* get_client_networkable_t)(void*, int);
    typedef void(__thiscall* pre_data_update_t)(void*, int);
    typedef int(__thiscall* get_model_index_t)(void*, const char*);
    typedef const model_t(__thiscall* find_or_load_model_t)(void*, const char*);
    typedef int(__thiscall* add_string_t)(void*, bool, const char*, int, const void*);
    typedef void(__thiscall* set_model_index_t)(void*, int);
    typedef int(__thiscall* precache_model_t)(void*, const char*, bool);
]]

local a = ffi.cast(ffi.typeof("void***"), client.create_interface("client.dll", "VClientEntityList003")) or error("rawientitylist is nil", 2)
local b = ffi.cast("get_client_entity_t", a[0][3]) or error("get_client_entity is nil", 2)
local c = ffi.cast(ffi.typeof("void***"), client.create_interface("engine.dll", "VModelInfoClient004")) or error("model info is nil", 2)
local d = ffi.cast("get_model_index_fn_t", c[0][2]) or error("Getmodelindex is nil", 2)
local e = ffi.cast("find_or_load_model_fn_t", c[0][43]) or error("findmodel is nil", 2)
local f = ffi.cast(ffi.typeof("void***"), client.create_interface("engine.dll","VEngineClientStringTable001")) or error("clientstring is nil", 2)
local g = ffi.cast("find_table_t", f[0][3]) or error("find table is nil", 2)

function p(pa)
    local a_p = ffi.cast(ffi.typeof("void***"), g(f, "modelprecache"))
    if a_p~= nil then
        e(c, pa)
        local ac = ffi.cast("add_string_fn_t", a_p[0][8]) or error("ac nil", 2)
        local acs = ac(a_p, false, pa, -1, nil)
        if acs == -1 then print("failed")
            return false
        end
    end
    return true
end

function smi(en, i)
    local rw = b(a, en)
    if rw then
        local gc = ffi.cast(ffi.typeof("void***"), rw)
        local se = ffi.cast("set_model_index_t", gc[0][75])
        if se == nil then
            error("smi is nil")
        end
        se(gc, i)
    end
end

function cm(ent, md)
    if md:len() > 5 then
        if p(md) == false then
            error("invalid model", 2)
        end
        local i = d(c, md)
        if i == -1 then
            return
        end
        smi(ent, i)
    end
end

function cmd1(stage)
    if stage ~= 1 then
        return
    end
    if mca:get() then
    local ip = entity_list.get_client_entity( engine.get_local_player( ))
    if ip == nil then
        return
    end
        if engine.is_connected() and client.is_alive() then

            cm(ip:index(), Materials[mca_List:get() + 1])           
        end
    end   
end

callbacks.register("pre_frame_stage", cmd1)

local on_paint = function()
    render.update()
    indicators.main()
    antiaim.handle_visibility()
    animations.update_land()
end

callbacks.register("paint", on_paint)


callbacks.register("post_anim_update", animations.main)

-- menu elements.
local party_mode_checkbox = ui.add_checkbox( "Party zeus" );

-- cvars.
local sv_party_mode = cvar.find_var( "sv_party_mode" );

-- callbacks.
local function on_paint( )
    sv_party_mode:set_value_int( ( party_mode_checkbox:get() and 1 or 0 ) );
end

-- init.
local function init( )
    callbacks.register( "paint", on_paint );
end
init( );

local bit = require("bit")

-- callbacks
callbacks.register("post_move", function(cmd)
    if not client.is_alive() then return end

    if cmd.command_number % 2 == 0 then
        cmd.buttons = bit.bor(cmd.buttons, 2^27)
    end
end)


















local signature = client.find_sig("engine.dll", "53 56 57 8B DA 8B F9 FF 15")
local call = ffi.cast("int(__fastcall*)(const char*, const char*)", signature)

local clan_tag = {
    last_tag =  0,

    set = function(tag)
        if tag == last then
            return
        end

        call(tag, tag)

        last_tag = tag
    end
}

local last_update = 0
callbacks.register("paint", function()
    if not (engine.is_connected() and engine.in_game()) then
        return
    end

    local tag = {
        "k";
        "ki";
        "kir";
        "kira";
        "kira.";
        "kira.g";
        "kira.gg";
        "kira.gg";
        "kira.gg";
        "kira.gg";
        "kira.g";
        "kira.";
        "kira";
        "kir";
        "ki";
        "k";

    }

    local time = global_vars.curtime + client.latency()
    time = math.floor(time % #tag + 0.3)

    if time ~= last_update then
        clan_tag.set(tag[time])
    end

    last_update = math.floor(time)
end)
