
Input.Bind.Run();
Await.Run();
Process.Run();

Paused = (instance_exists(PauseMenu));

audio_group_set_gain(audiogroup_music, Settings.audio.music * Settings.audio.volume);

layer_set_visible(layer_get_id("Glow"), Settings.graphics.lighting);
