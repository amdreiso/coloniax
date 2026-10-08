function enums(){
	enum eItemType {
		BLANK,
		PICKAXE,
		PROP,
		GUN,
		SPACESHIP_MODULE_TURRET,
		SPACESHIP_MODULE_PROPELLER,
		SPACESHIP_MODULE_ARMOR,
		SPACESHIP_MODULE_GYRO,
		
		TURRET_PROJECTILE,
	}
	
	enum eItemID {
		// Blanks
		WOOD,
		STEEL,
		URANIUM,
		
		// Pickaxes
		BASIC_PICKAXE,
		
		// Props
		BASIC_SOLAR_PANEL,
		BASIC_MINING_DRILL,
		
		// Spaceship Turrets
		BASIC_TURRET,
		DOUBLE_BARREL_TURRET,
		
		// Spaceship Gyros
		BASIC_GYRO,
		IMPROVED_GYRO,
		
		// Spaceship Propellers
		BASIC_PROPELLER,
		IMPROVED_PROPELLER,
		
		// Turret Projectiles
		BASIC_PROJECTILE,
		ARMOR_PIERCING_PROJECTILE,
	}

	enum ePlanetIcon {
		DEFAULT,
		RING,
		EARTH,
	}
}
