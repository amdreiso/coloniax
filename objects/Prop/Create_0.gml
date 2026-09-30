
parent = noone;
tileIndex = new Vec2();

tilt = 0;

alphaBypass = 0;
alpha = 1;

hp = new Stat(0);
tiltMultiplier = 1;

displayHealth = 0;
dropTable = new Table();

offset = new Vec2();

emitter = audio_emitter_create();

hitCooldown = 0;
hit = function() {
	if (!instance_exists(Player) || hitCooldown) return;
	
	tilt = min(20, tilt + irandom_range(3, 5) * 2) * choose(-1, 1) * tiltMultiplier;
	var itemID = Player.getHand(), hand = 1;
	
	if (itemID != -1) {
		hand = struct_get(ITEM.Get(itemID).components, "miningSpeed") ?? 1;
	}
	hp.Sub(hand);
	
	alphaBypass		= 2 * 60;
	displayHealth	= 5 * 60;
	hitCooldown		= 20;
	
	Camera.shake(0.3, 1);
	audio_play_sound(choose(snd_punch0, snd_punch1, snd_punch2, snd_punch3), 0, false, 0.4, 0, random_range(0.90, 1.05));
	
	if (hp.value <= 0) {
		instance_destroy();
	}
}

drawHealth = function() {
	if (!displayHealth) return;
	
	var part = hp.GetPercentage() * 100;
	var ww = 5 * Camera.zoomTo;
	var hh = 0.5 * Camera.zoomTo;
	
	draw_healthbar(x - ww, y - hh, x + ww, y + hh, part, c_black, c_red, c_white, 0, true, true);
}

DRAW_index = id;
DRAW.Register(drawHealth, DRAW_index);
