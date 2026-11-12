
Input.Bind.Run();
Await.Run();
Process.Run();

Paused = (instance_exists(Menu_Pause));

audio_group_set_gain(audiogroup_music, Settings.audio.music * Settings.audio.volume);

if (layer_exists("flow")) layer_set_visible(layer_get_id("Glow"), Settings.graphics.lighting);

debug_get_input();
