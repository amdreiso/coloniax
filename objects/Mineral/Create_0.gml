
parent = noone;
tileIndex = new Vec2();

offset = new Vec2();
sprite = sMineral_Coal;
image_xscale = choose(-1, 1);

hp = new Stat(1000);
hp.Set(irandom(1000));
image_index = floor(hp.GetPercentage() * 5);
image_speed = 0;

top = 0;
left = 0;
bottom = 0;
right = 0;

hitCooldown = 0;
hit = function() {
	if (!instance_exists(Player) || hitCooldown) return;
	
	var itemID = Player.getHand(), hand = 1;
	
	if (itemID != -1) {
		hand = struct_get(ITEM.Get(itemID).components, "miningSpeed") ?? 1;
	}
	
	hp.Sub(hand);
	hitCooldown	= 20;
	
	Camera.shake(0.3, 1);
	//audio_play_sound(choose(snd_punch0, snd_punch1, snd_punch2, snd_punch3), 0, false, 0.4, 0, random_range(0.90, 1.05));
	
	image_index = floor(hp.GetPercentage() * 5);
	
	if (hp.value <= 0) {
		instance_destroy();
	}
}