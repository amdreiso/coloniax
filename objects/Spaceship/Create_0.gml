
event_inherited();

sun = instance_nearest(x, y, Sun);
orbitRadius = point_distance(sun.x, sun.y, x, y);
orbitAngle  = point_direction(sun.x, sun.y, x, y);
controlling = true;

shadowSurface = surface_create(64, 64);
visionDistance = 512;

// Camera
cam = instance_create_depth(x, y, depth, Camera);
cam.target = self;

// Modules
modules = {
	turret:			eItemID.BASIC_TURRET,
	gyro:			eItemID.IMPROVED_GYRO,
	propeller:		eItemID.IMPROVED_PROPELLER,
};

// Player
player = {
	ejected: false,
}

// Health
hp = new Stat();

// Turret
turretSprite = sTurret_Canon;
turretSpriteShooting = sTurret_Canon_Shooting;
turretSpriteShootingCooldown = 0;
turretAngle = 0;
turretProjectileOffset = 16;

// Movement
canMove = true;
dir = irandom(360);

acceleration = 0.025;
deceleration = 0.005;
maxTurnSpeed = 1.05;
turnSpeed = 0;
turnForce = 0.085;
maxSpeed = 5;

// Gyro
gyroIndependent = false;
gyroMinimumSpeed = 0;

applyModules = function() {
	// propeller
	acceleration = 0.025;
	deceleration = 0.005;
	maxSpeed = 5;
	
	// gyro stuff
	maxTurnSpeed	= 0;
	turnForce		= 0;
	
	// Turret
	if (modules.turret != undefined) {
		var turret = ITEM.Get(modules.turret).components;
		turretSprite = turret.sprite;
		turretFirerate = turret.firerate;
	}
	
	// Gyro
	if (modules.gyro != undefined) {
		var gyro = ITEM.Get(modules.gyro).components;
		turnForce = gyro.turnForce;
		maxTurnSpeed = gyro.maxTurnSpeed;
		gyroIndependent = gyro.independent;
		gyroMinimumSpeed = gyro.minSpeed;
	}
	
	// Propeller
	if (modules.propeller != undefined) {
		var propeller = ITEM.Get(modules.propeller).components;
		acceleration	= propeller.acceleration;
		deceleration	= propeller.deceleration;
		maxSpeed		= propeller.maxSpeed;
	}
}

applyModules();

onPlanet = false;
spd = 0;
hsp = 0;
vsp = 0;
knockback = new Vec2();

stationed = false;

onPlayerEnter = function() {
	SOUND.PlayCameraRelative(eSoundType.SFX, snd_door, false, 1);
}

isPlayerEjectable = function() {
	return (spd < 0.05 && onPlanet);
}

ejectPlayer = function() {
	var con = isPlayerEjectable();
	if (!con) return;
	
	Player.controlling = true;
	Camera.target = Player;
	player.ejected = true;
	
	var planet = instance_nearest(x, y, Planet);
	planet.riderPush(id);
	planet.riderPush(Player);
	
	Player.planet = planet;
	Player.planetPosition = new Vec2(
		Player.x - planet.x,
		Player.y - planet.y,
	);
	
	stationed = true;
	menuOpen = false;
	controlling = false;
	
	onPlayerEnter();
	
	ACHIEVEMENT.Find(eAchievementType.ON_PLANET_LANDING);
}

boardPlayer = function() {
	var con = (distance_to_object(Player) < 32);
	if (!con) return;
	
	Camera.target = Spaceship;
	player.ejected = false;
	
	stationed = false;
	
	Player.controlling = false;
	Player.planet.riderRemove(id);
	Player.planet.riderRemove(Player);
	Player.planet = noone;
	
	controlling = true;
	
	onPlayerEnter();
}

createJetParticles = function(xoff, yoff, val) {
	var xx, yy;
	var r = 4;
	xx = x - lengthdir_x(22, angle) + xoff;
	yy = y - lengthdir_y(22, angle) + yoff;
	
	var n = ceil(val * (spd / maxSpeed));
	
	var emitter = part_emitter_create(World.ps);
	part_emitter_region(World.ps, emitter, xx - r, xx + r, yy - r, yy + r, ps_shape_rectangle, ps_distr_gaussian);
	part_emitter_burst(World.ps, emitter, World.particleFire, n);
}

propellerSound = -1;

pilot = function() {
	if (keyboard_check(ord("W")) && canMove) {
		spd = min(maxSpeed, spd + acceleration);
		var offset = 15;
		createJetParticles(0, 0, 16);
		
		var gain = SOUND.GetRelativeGain(1) * Settings.audio.sfx * Settings.audio.volume;
		
		if (propellerSound == -1 || !audio_is_playing(snd_propeller_0)) {
			propellerSound = SOUND.Play(eSoundType.SFX, snd_propeller_0, false, gain, 1);
		} else {
			audio_sound_gain(propellerSound, gain, 200);
		}
		
	} else {
		spd = max(0, spd - deceleration);
		if (propellerSound != -1) {
			audio_sound_gain(propellerSound, 0, 100);
			if (audio_sound_get_gain(propellerSound) <= 0.1) {
				propellerSound = -1;
			}
		}
	}
	steer();
}

steer = function() {
	if (!controlling) return;

	var left = keyboard_check(ord("A"));
	var right = keyboard_check(ord("D"));
	
	var speedFactor = (spd / maxSpeed);
	var turnSpeedModifier = 1;
	if (gyroIndependent) {
		speedFactor = max(gyroMinimumSpeed, (spd / maxSpeed));
		turnSpeedModifier = 1;
	}
	
	if (left) {
		turnSpeed = min(maxTurnSpeed, turnSpeed + turnForce * turnSpeedModifier) * speedFactor;
		
	} else if (right) {
		turnSpeed = max(-maxTurnSpeed, turnSpeed - turnForce * turnSpeedModifier) * speedFactor;
		
	} else {
		turnSpeed = lerp(turnSpeed, 0, 0.025);
		
	}
	
	dir += turnSpeed;
}

shoot = function() {
	if (!controlling || isPlayerEjectable() || KeyboardBusy) return;
	var projectileID = eItemID.BASIC_PROJECTILE;
	
	if (keyboard_check_pressed(vk_space) && turretSpriteShootingCooldown == 0) {
		var xx = x + lengthdir_x(turretProjectileOffset, mouseAngle);
		var yy = y + lengthdir_y(turretProjectileOffset, mouseAngle);
		var inst = instance_create_depth(xx, yy, depth + 100, Projectile);
		var proj = ITEM.Get(projectileID).components;
		
		inst.sprite = proj.sprite;
		inst.spd = proj.spd + spd;
		inst.dir = mouseAngle;
		
		knockback.x -= lengthdir_x(proj.knockback, mouseAngle);
		knockback.y -= lengthdir_y(proj.knockback, mouseAngle);
		
		turretSpriteShootingCooldown = turretFirerate;
		
		SOUND.PlayCameraRelative(eSoundType.SFX, snd_plasma_gun, false, 0.5, [0.90, 1.00]);
		
		var part = instance_create_depth(xx, yy, depth, Particle);
		part.setAmount(6);
		part.setLifetime(1);
		part.setParticle(World.particleSmoke);
		part.setRange(6, 6);
		
		Camera.shake(2, 1);
	}
}

x = room_width  / 2;
y = room_height / 2;

// Draw
spaceship = sSpaceship_Default;
sprite_index = spaceship;
angle = 0;
scale = 1;
color = c_white;
alpha = 1;
mouseAngle = 0;

drawSpaceship = function(spr, x, y, scale, angle, color, alpha, offsetFactor = 1) {
	var s = scale;
	var c = c_red;
	
	var ty = y+4;
	if (controlling && !Paused && point_distance(x, y, mouse_x, mouse_y) > 5) {
		turretAngle = point_direction(x, y, mouse_x, mouse_y);
	}
	
	var ts = (turretSpriteShootingCooldown) ? turretSpriteShooting : turretSprite;
	
	// drop shadow
	if (onPlanet) {
		if (!surface_exists(shadowSurface)) {
			shadowSurface = surface_create(64, 64);
		} else {
			surface_set_target(shadowSurface);
			draw_clear_alpha(c_black, 0);
			draw_sprite_stacked(ts, 32, 32, SPRITE_STACKED_OFFSET, scale, scale, turretAngle, c_black, alpha);
			draw_sprite_stacked(spr, 32, 32, SPRITE_STACKED_OFFSET * offsetFactor, scale, scale, angle, c_black, alpha);
			surface_reset_target();
		}
	
		draw_surface_ext(shadowSurface, x - 32, y - 32 + 4, 1, 1, 0, c_white, 0.33);
	}
	
	draw_sprite_stacked(ts, x, ty, SPRITE_STACKED_OFFSET, s, s, turretAngle, color, alpha);
	draw_sprite_stacked(spr, x, y, SPRITE_STACKED_OFFSET * offsetFactor, s, s, angle, color, alpha);
	
	if (hp.value < 20) {
		var a = sin(current_time / 300) * 0.25;
		draw_set_alpha(a);
		draw_sprite_stacked(spr, x, y, SPRITE_STACKED_OFFSET * offsetFactor, s, s, angle, c_red, a);
		draw_set_alpha(1);
	}
}

drawSpeedometer = function(x, y, height) {
	var speedometerMaxSpeed = 50;
	var percentage = (spd / speedometerMaxSpeed);
	var scale = 2;
	var len = 25 * scale;
	
	var offset = -(90 + 22.5) - ((360 - 45) * percentage);
	var dir = offset;
	
	if (percentage > 0) {
		var range = 1.50 * (spd / maxSpeed);
		dir += random_range(-range, range);
	}
	
	var xx = lengthdir_x(len, dir);
	var yy = lengthdir_y(len, dir);
	
	draw_sprite_ext(sUI_SpaceshipSpeedometer, 0, x, y, scale, scale, 0, c_white, 1);
	draw_line_width_color(x, y, x + xx, y + yy, 2, c_red, c_red);
}

// Inventory
inventory = new Inventory();

// Spaceship Menu
menuOpen = false;

Input.Bind.Set(ord("E"), {}, , function(){
	if (!controlling) return;
	menuOpen = !menuOpen;
});

main = new v_Panel(200, 200, {
	direction: eNodeDirection.COLUMN,
	draggable: true,
});

main.Push(new v_Text("==============", {color: c_gray}));
main.Push(new v_InputBox("Spaceship"));
main.Push(new v_Text("==============", {color: c_gray}));

// surface
section0 = new v_Panel(0, 0, {
	border: false, 
	backgroundColor: #141414,
	direction: eNodeDirection.COLUMN,
});
section0.Push(new v_Surface(100, 100, function(xx, yy, width, height){
	var theta = -current_time / 30;
	drawSpaceship(spaceship, xx, yy, 1.5, theta, color, alpha, 3);
}));

main.Push(section0);

// buttons
section1 = new v_Panel(0, 0, {
	direction: eNodeDirection.ROW,
	border: false,
});
section1.PushDefaultChildrenStyle({
	padding: new Dim(10, 0),
});

section1.Push(new v_Button("button1", function(){
	menuOpen = false;
}));
section1.Push(new v_Button("button2"));

section1.Push(new v_Button("button3", function(){
	window_set_fullscreen(!window_get_fullscreen());
}));
section1.Push(new v_Button("false", function(){
	section1.Edit("false_button", function(e){
		var str = (e.text == "true") ? "false" : "true";
		e.text = str;
	});
}), "false_button");
main.Push(section1);
main.Push(v_Separator());

section3 = new v_Panel(0, 0, {
	direction: eNodeDirection.ROW,
	border: false,
});
section3.PushDefaultChildrenStyle({
	padding: new Dim(0, 0),
});

section3.Push(new v_Button(sUI_Switch0, function(e){
	e.spriteIndex = (e.spriteIndex == 0) ? 1 : 0;
}));
section3.Push(new v_Button(sUI_Switch0, function(e){
	e.spriteIndex = (e.spriteIndex == 0) ? 1 : 0;
}));
section3.Push(new v_Button(sUI_Switch0_Green, function(e){
	e.spriteIndex = (e.spriteIndex == 0) ? 1 : 0;
}));
section3.Push(new v_Button(sUI_Switch0_Green, function(e){
	e.spriteIndex = (e.spriteIndex == 0) ? 1 : 0;
}));
main.Push(section3);
main.Push(v_Separator());

section2 = new v_Panel(0, 0, {
	direction: eNodeDirection.ROW,
	border: false,
});
section2.Push(new v_Text("hp:     "));
section2.Push(new v_Meter(80, 8, 100, function(){return hp.value}));
main.Push(section2);
main.Push(v_Separator());

section4 = new v_Panel(0, 0, {
	direction: eNodeDirection.COLUMN,
	border: false,
});

section4.Push(new v_Surface(160, 160, function(xx, yy, width, height){
	drawSpeedometer(xx, yy, height);
}));
main.Push(section4);
main.Push(v_Separator());

GUI.Register(function(){
	if (menuOpen) then main.Draw();
	MINIMAP.Draw();
});

