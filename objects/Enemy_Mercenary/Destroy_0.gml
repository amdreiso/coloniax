
var p = spawn(x, y, "Sun", Particle);

p.setLifetime(3);
p.setAmount(10);
p.setParticle(World.particleExplosion)
p.setRange(sprite_width*2, sprite_height*2);

SOUND.PlayAt(eSoundType.SFX, snd_explosion, x, y, false, 1, [0.95, 1.05]);
