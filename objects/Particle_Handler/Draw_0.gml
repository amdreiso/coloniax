if (!instance_exists(World)) return;

depth = layer_get_depth(layer_get_id("Sun"));
part_system_drawit(World.ps);
