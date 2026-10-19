
sun = instance_nearest(x, y, Sun);

orbitRadius = point_distance(sun.x, sun.y, x, y);
orbitAngle = point_direction(sun.x, sun.y, x, y);

