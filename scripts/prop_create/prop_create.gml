function prop_create(parent, obj, xoff, yoff, index=new Vec2()) {
	var o = instance_create_depth(x, y, -(y+yoff)-9999, obj);
	
	o.offset = new Vec2(xoff, yoff);
	o.parent = parent;
	o.tileIndex = index;
	
	return o;
}