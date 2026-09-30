
depth = parent.depth - tileIndex.y + 5;

if (sprite == -1) return;
sprite_index = sprite;
draw_sprite_ext(sprite, image_index, x, y, image_xscale, 1, 0, c_white, 1);
