-- Default tracks for advtrains
-- (c) orwell96 and contributors

--flat

local function suitable_substrate(upos)
	return minetest.registered_nodes[minetest.get_node(upos).name] and (minetest.registered_nodes[minetest.get_node(upos).name].liquidtype == "source")
end

advtrains.register_tracks("waterline", {
	nodename_prefix="linetrack:watertrack",
	texture_prefix="advtrains_ltrack",
	models_prefix="advtrains_ltrack",
	models_suffix=".obj",
	shared_texture="linetrack_line.png",
	description=attrans("Water Line Track"),
	formats={},
	liquids_pointable=true,
	suitable_substrate=suitable_substrate,
	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
			groups = {
				advtrains_track=1,
				advtrains_track_waterline=1,
				save_in_at_nodedb=1,
				dig_immediate=2,
				not_in_creative_inventory=1,
				not_blocking_trains=1,
			},
			use_texture_alpha = true,
		}
	end
}, advtrains.ap.t_30deg_flat)
--slopes
advtrains.register_tracks("waterline", {
	nodename_prefix="linetrack:watertrack",
	texture_prefix="advtrains_ltrack",
	models_prefix="advtrains_ltrack",
	models_suffix=".obj",
	shared_texture="linetrack_line.png",
	description=attrans("Line Track"),
	formats={vst1={true, false, true}, vst2={true, false, true}, vst31={true}, vst32={true}, vst33={true}},
	liquids_pointable=true,
	suitable_substrate=suitable_substrate,
	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
			groups = {
				advtrains_track=1,
				advtrains_track_waterline=1,
				save_in_at_nodedb=1,
				dig_immediate=2,
				not_in_creative_inventory=1,
				not_blocking_trains=1,
			},
			use_texture_alpha = true,
		}
	end
}, advtrains.ap.t_30deg_slope)

if atlatc ~= nil then
	advtrains.register_tracks("waterline", {
		nodename_prefix="linetrack:watertrack_lua",
		texture_prefix="advtrains_ltrack_lua",
		models_prefix="advtrains_ltrack",
		models_suffix=".obj",
		shared_texture="linetrack_lua.png",
		description=atltrans("LuaAutomation ATC Line"),
		formats={},
		liquids_pointable=true,
		suitable_substrate=suitable_substrate,
		get_additional_definiton = function(def, preset, suffix, rotation)
			return {
				after_place_node = atlatc.active.after_place_node,
				after_dig_node = atlatc.active.after_dig_node,

				on_receive_fields = function(pos, ...)
					atlatc.active.on_receive_fields(pos, ...)
					
					--set arrowconn (for ATC)
					local ph=minetest.pos_to_string(pos)
					local _, conns=advtrains.get_rail_info_at(pos, advtrains.all_tracktypes)
					atlatc.active.nodes[ph].arrowconn=conns[1].c
				end,

				advtrains = {
					on_train_enter = function(pos, train_id)
						--do async. Event is fired in train steps
						atlatc.interrupt.add(0, pos, {type="train", train=true, id=train_id})
					end,
				},
				luaautomation = {
					fire_event=atlatc.rail.fire_event
				},
				digiline = {
					receptor = {},
					effector = {
						action = atlatc.active.on_digiline_receive
					},
				},
				groups = {
					advtrains_track=1,
					advtrains_track_waterline=1,
					save_in_at_nodedb=1,
					dig_immediate=2,
					not_in_creative_inventory=1,
					not_blocking_trains=1,
				},
				use_texture_alpha = true,
			}
		end,
	}, advtrains.trackpresets.t_30deg_straightonly)
end

if minetest.get_modpath("advtrains_line_automation") ~= nil then
	local adef = minetest.registered_nodes["advtrains_line_automation:dtrack_stop_st"]
	
	advtrains.register_tracks("waterline", {
		nodename_prefix="linetrack:watertrack_stn",
		texture_prefix="advtrains_ltrack_stn",
		models_prefix="advtrains_ltrack",
		models_suffix=".obj",
		shared_texture="linetrack_stn.png",
		description="Station/Stop Line",
		formats={},
		liquids_pointable=true,
		suitable_substrate=suitable_substrate,
		get_additional_definiton = function(def, preset, suffix, rotation)
			return {
				after_place_node = adef.after_place_node,
				after_dig_node = adef.after_dig_node,
				on_rightclick = adef.on_rightclick,
				advtrains = adef.advtrains,
				groups = {
					advtrains_track=1,
					advtrains_track_waterline=1,
					save_in_at_nodedb=1,
					dig_immediate=2,
					not_in_creative_inventory=1,
					not_blocking_trains=1,
				},
				use_texture_alpha = true,
			}
		end,
	}, advtrains.trackpresets.t_30deg_straightonly)
end

if minetest.get_modpath("advtrains_interlocking") ~= nil then
	dofile(minetest.get_modpath("linetrack") .. "/interlocking.lua")
end

local exhaust_particle_spawner_base = {
	amount = 10,
	time = 0,
	minpos = {x=-1, y=2.8, z=-3.4},
	maxpos = {x=-1, y=2.8, z=-3.4},
	minvel = {x=-0.2, y=1.8, z=-0.2},
	maxvel = {x=0.2, y=2, z=0.2},
	minacc = {x=0, y=-0.1, z=0},
	maxacc = {x=0, y=-0.3, z=0},
	minexptime = 1,
	maxexptime = 3,
	minsize = 1,
	maxsize = 4,
	collisiondetection = true,
	vertical = false,
	texture = "smoke_puff.png",
}

advtrains.register_wagon("boat", {
	mesh="linetrack_boat.b3d",
	textures = {
		"doors_door_steel.png",--y
		"linetrack_steel_tile_dark.png", --y(exhaust)
		"default_coal_block.png",
		"linetrack_steel_tile_light.png",--y
		"linetrack_steel_tile_dark.png",
		"linetrack_steel_tile_blue.png",--y
		"linetrack_diamond_plate_steel_blue.png",--y
		"linetrack_steel_tile_dark.png",--y(hull)
		"default_wood.png", --y
		"linetrack_lifering.png", --y
		"linetrack_boat_windows.png",
	},
	drives_on={waterline=true},
	max_speed=10,
	seats = {
		{
			name="Driver stand",
			attach_offset={x=6, y=2, z=10},
			view_offset={x=6, y=0, z=8},
			group="dstand",
		},
		{
			name="1",
			attach_offset={x=-4, y=0, z=-4},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=0, z=-4},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=0, z=4},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=0, z=4},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="5",
			attach_offset={x=-4, y=0, z=-12},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="6",
			attach_offset={x=4, y=0, z=-12},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="7",
			attach_offset={x=-4, y=0, z=-20},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="8",
			attach_offset={x=4, y=0, z=-20},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="9",
			attach_offset={x=-4, y=0, z=-28},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="10",
			attach_offset={x=4, y=0, z=-28},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
	},
	seat_groups = {
		dstand={
			name = "Driver Stand",
			access_to = {"pass"},
			require_doors_open=true,
			driving_ctrl_access=true,
		},
		pass={
			name = "Passenger area",
			access_to = {"dstand"},
			require_doors_open=true,
		},
	},
	doors={
		open={
			[-1]={frames={x=0, y=1}, time=1},
			[1]={frames={x=0, y=1}, time=1},
			sound = "doors_steel_door_open",
		},
		close={
			[-1]={frames={x=2, y=3}, time=1},
			[1]={frames={x=2, y=3}, time=1},
			sound = "doors_steel_door_close",
		}
	},
	assign_to_seat_group = {"pass", "dstand"},
	door_entry={-1, 1},
	visual_size = {x=1, y=1},
	wagon_span=2,
	collisionbox = {-2.0,-3.0,-2.0, 2.0,4.0,2.0},
	is_locomotive=true,
	wagon_width=5,
	drops={"default:steelblock 4"},
	horn_sound = "linetrack_boat_horn",
	custom_on_destroy = function(self)
		if (self.sound_loop_handle) then
			minetest.sound_stop(self.sound_loop_handle) --don't loop forever D:
		end
		return true
	end,
	custom_on_velocity_change = function(self, velocity, old_velocity, dtime)
		if not velocity or not old_velocity then return end
		if old_velocity == 0 and velocity > 0 then
			self.particlespawners = {
				minetest.add_particlespawner(advtrains.merge_tables(exhaust_particle_spawner_base,
					{minpos = {x=1, y=2.8, z=-3.4}, maxpos = {x=1, y=2.9, z=-3.4}, attached = self.object})),
				minetest.add_particlespawner(advtrains.merge_tables(exhaust_particle_spawner_base,
					{minpos = {x=-1, y=2.8, z=-3.4}, minpos = {x=-1, y=2.8, z=-3.4}, attached = self.object})),
			}
			minetest.sound_play("linetrack_boat_start", {object = self.object})
			return
		end
		if velocity == 0 then
			if self.sound_loop_handle then
				minetest.sound_stop(self.sound_loop_handle)
				self.sound_loop_handle = nil
			end
			if self.particlespawners then
				for k,v in pairs(self.particlespawners) do
					minetest.delete_particlespawner(v)
				end
			end
			if old_velocity > 0 then
				minetest.sound_play("linetrack_boat_stop", {object = self.object})
			end
			return
		end
		if self.rev_tmr then
			delta = minetest.get_us_time()- self.rev_start
			if delta >= self.rev_tmr then
				self.rev_tmr = nil
				if self.rev_high then
					self.sound_loop_handle = minetest.sound_play({name="linetrack_boat_idle_high", gain=0.3}, {object = self.object, loop=true})
				else
					self.sound_loop_handle = minetest.sound_play({name="linetrack_boat_idle_low", gain=0.3}, {object = self.object, loop=true})
				end
			end
		elseif velocity > 0 then
			if self.sound_loop_handle == nil then
				if velocity > 5 then
				self.sound_loop_handle = minetest.sound_play({name="linetrack_boat_idle_high", gain=0.3}, {object = self.object, loop=true})
				else 
					self.sound_loop_handle = minetest.sound_play({name="linetrack_boat_idle_low", gain=0.3}, {object = self.object, loop=true})
				end
				return
			end
			if velocity ~= old_velocity then
				if old_velocity < 5 and velocity > 5 then
					minetest.sound_stop(self.sound_loop_handle)
					self.sound_loop_handle = nil
					minetest.sound_play({name="linetrack_boat_revup", gain=0.3}, {object = self.object})
					self.rev_start = minetest.get_us_time()
					self.rev_tmr = 2813000
					self.rev_high = true
				elseif old_velocity > 5 and velocity < 5 then
					minetest.sound_stop(self.sound_loop_handle)
					self.sound_loop_handle = nil
					minetest.sound_play({name="linetrack_boat_revdown", gain=0.3}, {object = self.object})
					self.rev_start = minetest.get_us_time()
					self.rev_tmr = 373000
					self.rev_high = false
					
				end
			end
		end
	end,
}, "Boat", "linetrack_boat_inv.png")

minetest.register_node("linetrack:invisible_platform", {
	description = "Invisible Platform",
	groups = {cracky = 1, not_blocking_trains = 1, platform=1},
	drawtype = "airlike",
	inventory_image = "linetrack_invisible_platform.png",
	wield_image = "linetrack_invisible_platform.png",
	walkable = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.1, -0.1, 0.5,  0  , 0.5},
			{-0.5, -0.5,  0  , 0.5, -0.1, 0.5}
		},
	},
	paramtype2="facedir",
	paramtype = "light",
	sunlight_propagates = true,
})
	
