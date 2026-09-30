
event_inherited();

controlling = false;

sun = instance_nearest(x, y, Sun);
planet = noone;
planetPosition = new Vec2();
planetDistance = 0;
planetAngle = 0;

reach = 5;
offset = new Vec2();

focus = noone;
focusInstanceSize = 1;

focusCheck = function() {
	focus = noone;
	
	if (instance_exists(Prop)) {
		var inst = instance_nearest(x, y, Prop);
		if (distance_to_object(inst) < reach) {
			focus = inst;
		}
	}
	
	if (instance_exists(Mineral) && Camera.zoom <= 2) {
		var list = ds_list_create();
		var insts = collision_circle_list(x, y, reach, Mineral, false, false, list, false);
		
		for (var i = 0; i < ds_list_size(list); i++) {
			var inst = ds_list_find_value(list, i);
			var c = mouse_box_collision(inst.bbox_left, inst.bbox_right, inst.bbox_top, inst.bbox_bottom);
			
			if (distance_to_object(inst) < reach && c) {
				focus = inst;
				with (inst) draw_boundaries(1, 1, 0.25);
			}
		}
	}
	
	if (mouse_check_button(mb_left) && focus != noone) {
		focus.hit();
		swing = min(1, swing + 0.1);
		
	} else {
		swing = max(0, swing - 0.1);
		
	}
}

// Movement
canMove = true;
moving = false;
spd = 1;
knockback = new Vec2();

getMultiplier = function() {
	var m = {
		spd : 1,
		knockback : 1,
		reach : 1,
	}
	return m;
}
multiplier = getMultiplier();

getInput = function() {
	var up		= keyboard_check(ord("W"));
	var left	= keyboard_check(ord("A"));
	var down	= keyboard_check(ord("S"));
	var right	= keyboard_check(ord("D"));
	
	var dir = point_direction(0, 0, right - left, down - up);
	var len = (right - left != 0 || down - up != 0);
	
	hsp = lengthdir_x(spd * len, dir);
	vsp = lengthdir_y(spd * len, dir);
	
}

applyCollisions = function() {
	var drop = collision_circle(x, y, reach * multiplier.reach, ItemDrop, false, true);
	
	if (drop != noone) {
		audio_play_sound(snd_item_picked_up, 0, false, 0.25, 0, random_range(0.80, 1.00));
		inventory.Add(drop.itemID);
		instance_destroy(drop);
	}
}

applyMovement = function() {
	if (canMove) {
		x += hsp;
		y += vsp;
	}
	
	var cx = planet.x;
	var cy = planet.y;
	var dx = x - cx;
	var dy = y - cy;
	var radius = planet.radius - 10;
	var rx = radius;
	var ry = radius / 2;
	var dist = (dx * dx) / (rx * rx) + (dy * dy) / (ry * ry);
	
	if (dist > 1) {
	    var scale = 1 / sqrt(dist);
	    x = cx + dx * scale;
	    y = cy + dy * scale;
	}
}

syncToPlanet = function() {
	if (planet == noone) return;
	x = planet.x + planetPosition.x;
	y = planet.y + planetPosition.y;
}

// Effects
effect = new EFFECT.State(self);

// Draw
image_speed = 7/60;
xscale = 1;
angle = 0;
frame = 0;

enum ePlayerState {
	IDLE,
	WALK,
	SWIM,
}

state = ePlayerState.IDLE;
sprite = sPlayer_Idle;
sprite_index = sPlayer_Idle;

inWater = false;
onLava = false;
placeDirection = 1;
swing = false;

handlePlacingProps = function(item) {
	if (item.components.type == eItemType.PROP && planet.inBoundary(mouse_x, mouse_y)) {
		var color = c_white;
		var half = TILE_HEIGHT / 2;
		var prop = item.components.prop;
		var size = item.components.size;
		var mx = (mouse_x + TILE_WIDTH/2) - planet.x;
		var my = mouse_y - planet.y;
		var xx, yy, tx, ty;
		var hh = floor(TILE_HEIGHT / 2);
		ty = floor(my / hh);
		var xoff = (ty % 2 == 0) ? TILE_WIDTH / 2 : 0;
		tx = floor((mx - xoff) / TILE_WIDTH);
		var pos = isometric_position(tx, ty);
		var s = planet.size / 2;
		var t = planet.grid[# tx + s, ty + s];
		
		if (t != undefined) {
			color = (t.canPlaceProps && !t.occupied) ? c_white : c_red;
		}
				
		if (keyboard_check_pressed(ord("R"))) {
			placeDirection *= -1; 
		}
				
		draw_sprite_ext(
			object_get_sprite(prop), 0, 
			planet.x + pos.x, planet.y + pos.y, 
			placeDirection, 1, 0, color, 0.25
		);
				
		if (mouse_check_button_pressed(mb_right)) {
			if (t != undefined && t.canPlaceProps) {
				if (t.CreateProp(planet, prop, {
					image_xscale : placeDirection,
					size : item.components.size, // Grid tile size
					
				}, false, true)) then inventory.Remove(slotIndex, 1);
			}
		}
	}
}

drawHandItem = function(icon) {
	if (icon != -1) {
		var righthand = new Vec2(3, 1);
		var lefthand = new Vec2(-2, 1);
			
		if (state == ePlayerState.SWIM) {
			righthand = new Vec2(4, 1);
		}
			
		if (floor(frame) % 2 == 0) {
			switch (state) {
				case ePlayerState.WALK:
					righthand = new Vec2(4, 3);
					lefthand = new Vec2(-3, 3);
					break;
					
				case ePlayerState.SWIM:
					righthand = new Vec2(4, 2);
					break;
			}
		}
			
		var swingValue = (sin(current_time * 0.03) + 1) * 0.5;
		var swingAngle = power(swingValue, 2) * 40 - 20;
		var handAngle = swingAngle * swing;
			
		draw_sprite_ext(icon, 1, x + righthand.x * xscale, y - righthand.y, xscale, 1, handAngle, c_white, 1);
	}
}

draw = function() {
	var spr = sPlayer_Idle;
	var spd = 500;
	var wasInWater = inWater;
	state = ePlayerState.IDLE;
	inWater = false;
	onLava = false;
	
	moving = (hsp != 0 || vsp != 0);
	
	// Check for tile specific sprite states
	if (place_meeting(x, y, Tile)) {
		var tile = instance_nearest(x, y, Tile);
		TILE.Get(tile.tileID).components.onEntityCollision(self);
		if (tile.isLiquid) {
			if (tile.tileID == eTileID.WATER) {
				state = ePlayerState.SWIM;
				spr = sPlayer_Swim;
				spd = 100;
				
				inWater = true;
				
				if (!wasInWater) {
					SOUND.Play(eSoundType.SFX, snd_splash, false, 0.5, [0.95, 1.00]);
				}
				
				var part = instance_create_depth(x, y, -999, Particle);
				part.setParticle(World.particleFoam);
				part.setRange(1, 1);
				
				if (irandom(5) > 4) {
					part = instance_create_depth(x, y, -9999, Particle);
					part.setAmount(irandom(3));
					part.setParticle(World.particleSplash);
					part.setRange(2, 2);
				}
				
			} else if (tile.tileID == eTileID.LAVA) {
				onLava = true;
				state = (moving) ? ePlayerState.WALK : ePlayerState.IDLE;
				spr = (moving) ? sPlayer_Move : sPlayer_Idle;
				spd = 700;
				
			}
			
		}
	} 
	else if (moving) {
		state = ePlayerState.WALK;
		spr = sPlayer_Move;
		spd = 150;
	}
	
	frame = (current_time / spd) % 2;
	
	angle = (moving) ? sin(current_time * 0.015) * 4 : 0;
	
	if (hsp != 0) xscale = sign(hsp);
	
	// Item Holding
	var hand = inventory.Get(slotIndex);
	if (hand.itemID != -1) {
		var item = ITEM.Get(hand.itemID);
		var icon = item.components.icon;
		
		// Draw item sprite in hand
		drawHandItem(icon);
		
		// Placing Propr
		handlePlacingProps(item);
	}
	
	sprite = spr;
	
	if (!inWater) then draw_sprite_ext(sPlayer_Shadow, frame, x, y, xscale, image_yscale, angle, c_white, 0.5);
	draw_sprite_ext(sprite, frame, x, y, xscale, image_yscale, angle, c_white, 1);
}

// Inventory
inventory = new Inventory(20);
inventory.Add(eItemID.BASIC_PICKAXE, 1);
inventory.Add(eItemID.BASIC_SOLAR_PANEL, 99);
inventory.Add(eItemID.BASIC_MINING_DRILL, 99);
inventory.Add(eItemID.WOOD, 99);
inventory.Add(eItemID.STEEL, 99);

slotIndex = 0;
slotSet = function(index){
	slotIndex = index;
};

getHand = function() {
	return inventory.Get(slotIndex).itemID;
}

Input.Bind.Set(ord("1"), , , function(){slotSet(0)});
Input.Bind.Set(ord("2"), , , function(){slotSet(1)});
Input.Bind.Set(ord("3"), , , function(){slotSet(2)});
Input.Bind.Set(ord("4"), , , function(){slotSet(3)});
Input.Bind.Set(ord("5"), , , function(){slotSet(4)});
Input.Bind.Set(ord("6"), , , function(){slotSet(5)});
Input.Bind.Set(ord("7"), , , function(){slotSet(6)});
Input.Bind.Set(ord("8"), , , function(){slotSet(7)});
Input.Bind.Set(ord("9"), , , function(){slotSet(8)});
Input.Bind.Set(ord("0"), , , function(){slotSet(9)});

// Draw hotbar
drawHotbar = function() {
	if (!controlling || Paused) return;
	
	var scale = 1;
	var spacing = 1.1;
	var size = (64) * scale;
	var size2 = (64 * spacing) * scale;
	var num = 10;
	var half = (num * size2) / 2;
	var yy = HEIGHT - size2 / 2;
	
	for (var i = 0; i < num; i++) {
		var xx = WIDTH / 2 + (i * size2) - half;
		rect(xx, yy, size, size, #202020, false);
		
		if (slotIndex == i) {
			var o = 1.1;
			rect(xx, yy, size/o, size/o, #aaaaaa, true, 1, 2);
		} else {
			rect(xx, yy, size, size, #303030, true);
		}
		
		var inv			= inventory.Get(i);
		var item		= inv.itemID;
		var quantity	= inv.quantity;
		
		if (item != -1) {
			var icon = ITEM.Get(item).components.icon;
			if (icon != -1) {
				draw_sprite_ext(icon, 0, xx, yy, scale*2, scale*2, 0, c_white, 1);
				ALIGN_BOTTOM_RIGHT;
				if (quantity > 1) draw_text(xx + size/2 - 5, yy + size/2, quantity);
			}
		}
	}
}

GUI.Register(drawHotbar);
