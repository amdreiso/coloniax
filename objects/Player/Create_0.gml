
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
	
	if (mouse_check_button(mb_left) && focus != noone && !holdingGun) {
		focus.hit();
		swing = min(1, swing + 0.1);
		
	} else {
		swing = max(0, swing - 0.1);
		
	}
}

// Movement
canMove = true;
moving = false;
defaultSpd = 1;
spd = 1;
hsp = 0;
vsp = 0;
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

planetTilePosition = new Vec2();

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

	var dx = x - planet.x;
	var dy = y - planet.y;

	planetTilePosition.x = floor(dx / TILE_WIDTH + planet.size / 2);
	planetTilePosition.y = floor(dy / (TILE_HEIGHT / 2) + planet.size / 2);
	var pp = planetTilePosition;

	var tile = planet.grid[# pp.x, pp.y];
	if (tile != undefined) {
	}
}

// Gun
gunCooldown = 0;
gunRecoil = 0;

handleGun = function(item) {
	var c = item.components;
	var auto = (c.automatic) ? mouse_check_button(mb_left) : mouse_check_button_pressed(mb_left);
	var shooting = (auto);
	var canShoot = (!gunCooldown && controlling && !Paused);

	gunCooldown = max(0, gunCooldown - 1);
	gunRecoil = lerp(gunRecoil, 0, 0.2);

	if (shooting && canShoot) {
		gunCooldown = c.firerate;
		gunRecoil = c.recoil;

		SOUND.PlayCameraRelative(eSoundType.SFX, snd_plasma_gun, false, 0.5, [0.90, 1.10]);
		Camera.shake(c.cameraShake, 1);
	}
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
inPoison = false;
placeDirection = 1;
swing = false;

handlePlacingProps = function(item) {
	if (Paused) return;
	if (item.components.type != eItemType.PROP) return;
	if (!planet.inBoundary(mouse_x, mouse_y)) return;

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

	var propx = planet.x + pos.x;
	var propy = planet.y + pos.y;
	var propspr = item.components.sprite;
			
	draw_sprite_ext(
		propspr, 0, 
		planet.x + pos.x, planet.y + pos.y, 
		placeDirection, 1, 0, color, 0.25
	);
			
	if (mouse_check_button_pressed(mb_right)) {
		if (t != undefined && t.canPlaceProps) {
			var thisprop = t.CreateProp(planet, prop, {
				image_xscale : placeDirection,
				size : item.components.size, // Grid tile size
			}, false, true); 

			if (thisprop) {
				inventory.Remove(slotIndex, 1);
			}
		}
	}
}

drawHandGun = function(item) {
	var icon = item.components.icon;
	var angle = point_direction(x, y, mouse_x, mouse_y);
	var recoilMultiplier = 0.01;
	var xx = x - lengthdir_x(gunRecoil, angle);
	var yy = y - lengthdir_y(gunRecoil, angle);
	var yscale = 1;
	draw_text(x, y-64, gunRecoil);

	if (mouse_x < x) {
		yscale = -1;
	}
	
	handleGun(item);
	draw_sprite_ext(icon, 1, xx, yy, 1, yscale, angle, c_white, 1);
}

holdingGun = false;

drawHandItem = function(item) {
	var icon = item.components.icon;
	var type = item.components.type;

	holdingGun = (type == eItemType.GUN);

	if (holdingGun) {
		drawHandGun(item);
		return;
	}

	if (icon == -1) return;

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
	var swingForce = 100;
	var swingAngle = power(swingValue, 2) * swingForce - swingForce / 2;
	var handAngle = swingAngle * swing;
		
	draw_sprite_ext(icon, 1, x + righthand.x * xscale, y - righthand.y, xscale, 1, handAngle, c_white, 1);
}

appearance = new CharacterAppearance();

draw = function() {
	var spr = sPlayer_Idle;
	var spd = 500;
	var wasInWater = inWater;
	state = ePlayerState.IDLE;
	inWater = false;
	onLava = false;
	inPoison = true;

	var eye = appearance.eye;
	var hair = appearance.hair;

	var head = appearance.head;
	var headx = x;
	var heady = y;

	var currentItem = -1;
	var hand = inventory.Get(slotIndex);
	if (hand.itemID != -1) {
		currentItem = ITEM.Get(hand.itemID);
	}

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
				
			} else if (tile.tileID == eTileID.POISON) {
				state = ePlayerState.SWIM;
				spr = sPlayer_Swim;
				spd = 140;
				inPoison = true;

			}
		}
	} 
	else if (moving) {
		state = ePlayerState.WALK;
		spr = sPlayer_Move;
		spd = 150;

		if (floor(frame) == 1) {
			heady = y + 1;
		}
	}

	if (state = ePlayerState.SWIM) {
		heady = y + 2;
		if (floor(frame) == 1) {
			heady = y + 1;
		}
	}

	frame = (current_time / spd) % 2;
	angle = (moving) ? sin(current_time * 0.015) * 4 : 0;
	if (hsp != 0) xscale = sign(hsp);
		
	sprite = spr;
	
	if (!inWater) then draw_sprite_ext(sPlayer_Shadow, frame, x, y, xscale, image_yscale, angle, c_white, 0.5);
	draw_sprite_ext(sprite, frame, x, y, xscale, image_yscale, angle, appearance.shirtColor, 1);

	// Draw item sprite in hand
	if (currentItem != -1) then drawHandItem(currentItem);

	var blink = (floor(current_time/100) % 30 == 0)

	draw_sprite_ext(head, frame, x, heady-sprite_get_height(sprite), xscale, image_yscale, angle, appearance.skinColor, 1);
	draw_sprite_ext(hair, frame, x, heady-sprite_get_height(sprite), xscale, image_yscale, angle, appearance.hairColor, 1);
	draw_sprite_ext(eye, 0, x, heady-sprite_get_height(sprite), xscale, image_yscale, angle, (blink) ? appearance.skinColor : c_white, 1);

	var hy = heady - sprite_get_height(sprite)

	if (sprite_get_number(eye) >= 2 && !blink) {
		draw_sprite_ext(eye, 1, x, hy, xscale, image_yscale, angle, appearance.eyeColor, 1);
	}
	
	// Placing Props
	if (currentItem != -1) then handlePlacingProps(currentItem);

	if (keyboard_check_pressed(ord("L"))) {
		appearance = new CharacterAppearance();
	}
}

// Inventory
inventory = new Inventory(20);
inventory.Add(eItemID.BASIC_PICKAXE, 1);
inventory.Add(eItemID.BASIC_SOLAR_PANEL, 99);
inventory.Add(eItemID.BASIC_MINING_DRILL, 99);
inventory.Add(eItemID.WOOD, 99);
inventory.Add(eItemID.STEEL, 99);
inventory.Add(eItemID.URANIUM, 99);
inventory.Add(eItemID.PISTOL, 1);
inventory.Add(eItemID.LMG, 1);

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

characterCustomizationUI = ui_create_character_customization();

GUI.Register(function(){
	characterCustomizationUI.Draw();
});
GUI.Register(drawHotbar);


// Crafting system
G RECIPE;
RECIPE = {};

RECIPE.data = {};

RECIPE.Register = function(result) {
	var recipe = {};
	recipe.result = result;
	recipe.ingredients = [];
	for (var i = 1; i < argument_count; i++) {
		array_push(recipe.ingredients, argument[i]);
	}
	RECIPE.data[$ result] = recipe;
}

RECIPE.Find = function(itemID) {
	var r = RECIPE.data[$ itemID];
	if (r == undefined) return -1;
	return r;
}

// RECIPE.Register(
// 	eItemID.PISTOL, 
// 	new ItemStack(eItemID.WOOD, 	2),
// 	new ItemStack(eItemID.URANIUM, 	2),
// );
 
// RECIPE.Register(
// 	eItemID.LMG,
// 	new ItemStack(eItemID.URANIUM, 30),
// 	new ItemStack(eItemID.BASIC_MINING_DRILL, 2),
// 	new ItemStack(eItemID.BASIC_SOLAR_PANEL, 5),
// 	new ItemStack(eItemID.STEEL, 99),
// );

//inventory.Craft(eItemID.LMG);

