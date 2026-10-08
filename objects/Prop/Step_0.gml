
if (Paused) return;

depth = parent.depth - tileIndex.y;

alphaBypass		= max(0, alphaBypass - 1);
displayHealth	= max(0, displayHealth - 1);
hitCooldown		= max(0, hitCooldown - 1);

if (instance_exists(Player)) {
	if (Player.controlling) { 
		var hide = (Player.y < y && place_meeting(x, y, Player)) ? 0.15 : 1;
		if (alphaBypass) hide = 1;
		alpha = lerp(alpha, hide, 0.1);
	}
}
