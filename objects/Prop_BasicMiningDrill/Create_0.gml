
event_inherited();

tiltMultiplier = 0.1;

hp.UpdateValue(1000);
dropTable.Set(new ItemStack(eItemID.BASIC_MINING_DRILL, 1), 100);

working = true;
offsetDefault = offset;

sound = SOUND.PlayOn(emitter, eSoundType.SFX, snd_drilling, true, 1, 1);
audio_emitter_falloff(emitter, SOUND.distance, SOUND.dropoff, SOUND.multiplier);

sprite_index = sProp_BasicMiningDrill;

