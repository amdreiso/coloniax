
var xx = input.cursor.x;
var yy = input.cursor.y;
var cl = input.cursorLength;
var lw = input.lines[input.cursor.y].len;
var num = array_length(input.lines);
stats.text = $"x:{xx} y:{yy} clen:{cl} lc:{num} lw:{lw} sl:{string_length(input.text)}";

