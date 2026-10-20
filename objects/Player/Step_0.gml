
if (Paused) return;

if (!controlling) return;

event_inherited();

canMove = (!Debug.console && !CHAT.open);

getInput();
applyCollisions();

multiplier = getMultiplier();

multiplier.spd = max(0, 1 - (0.5 * onLava));
spd = defaultSpd * multiplier.spd;

applyMovement();

planetPosition = new Vec2(
	x - planet.x,
	y - planet.y,
);
syncToPlanet();

if (planet != noone) {
}

var yy = planet.top - y;
depth = planet.depth + floor(yy / floor(TILE_HEIGHT / 2));

effect.Call("update");
effect.Apply();

SOUND.ListenerPosition(x, y);

if (keyboard_check_pressed(ord("H"))) {
	planet.createStructure(planetTilePosition.x, planetTilePosition.y, eStructureID.RUINS_0);
}

