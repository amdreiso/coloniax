
var cooldown = particleCooldown() ?? 0;

if (cooldown == 0) return;

alarm_set(0, cooldown);
particleCreate(self);

