
if (Paused) return;

orbit_set();

lookForTargets();
checkProjectileCollision();
checkDeath();

enemy_apply_ai(self);

x += hsp;
y += vsp;
moving = (hsp != 0 || vsp != 0);

if (moving) {
	onMove.Call();
}

