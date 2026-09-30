function draw_boundaries(outlineSize, sz=1, offsetMultiplier=1) {
	var z = Camera.zoomTo;
	var s = outlineSize * z;
	var color = c_white;
	var size = min(sz * z, sz*10);
	var len = 5 * s;
	var length = min(len, len);
	var offset = min(5 * s, 50) * offsetMultiplier;
	
	var l = left - offset;
	var r = right + offset;
	var t = top - offset;
	var b = bottom + offset;
	
	draw_line_width(l, t, l + length, t, size);
	draw_line_width(l, t, l, t + length, size);
	
	draw_line_width(r, t, r - length, t, size);
	draw_line_width(r, t, r, t + length, size);
	
	draw_line_width(l, b, l + length, b, size);
	draw_line_width(l, b, l, b - length, size);
	
	draw_line_width(r, b, r - length, b, size);
	draw_line_width(r, b, r, b - length, size);
}