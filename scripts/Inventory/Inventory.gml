
// Crafting system
G RECIPE;
RECIPE = {};
RECIPE.data = {};
RECIPE.Register = function(result, amount=1) {
	var recipe = {};
	recipe.result = result;
	recipe.amount = amount;
	recipe.ingredients = [];
	for (var i = 2; i < argument_count; i++) {
		array_push(recipe.ingredients, argument[i]);
	}
	RECIPE.data[$ result] = recipe;
}
RECIPE.Find = function(itemID) {
	var r = RECIPE.data[$ itemID];
	if (r == undefined) return -1;
	return r;
}

RECIPE.Register(
	eItemID.PISTOL, 1,
	inventory_slot(eItemID.WOOD, 2),
	inventory_slot(eItemID.URANIUM, 2),
);

#macro INVENTORY_MAX_AMOUNT 100

function inventory_create(slots) {
	var inv = {};
	inv.slots = array_create(slots);
	inv.length = slots;
	return inv;
}

function inventory_slot(itemID = -1, amount = 0) {
	return {
		itemID: itemID,
		amount: amount,
	};
}

function inventory_find_free_slot(inv) {
	var freeSlot = -1;
	for (var i = 0; i < inv.length; i++) {
		var slot = inv.slots[i];
		if (!slot) {
			if (freeSlot == -1) then freeSlot = i;
			continue;
		}
	}
	return freeSlot;
}

function inventory_add(inv, itemID, amount) {
	if (inv.length <= 0) return;

	var freeSlot = inventory_find_free_slot(inv);

	for (var i = 0; i < inv.length; i++) {
		var slot = inv.slots[i];
		if (!slot) continue;

		if (slot.itemID == itemID && slot.amount < INVENTORY_MAX_AMOUNT) {
			slot.amount += amount;

			if (slot.amount > INVENTORY_MAX_AMOUNT) {
				var overflow = (slot.amount - INVENTORY_MAX_AMOUNT);
				slot.amount = INVENTORY_MAX_AMOUNT;
				
				inventory_add(inv, itemID, overflow);
			}
			return true;
		}
	}

	if (freeSlot != -1) {
		if (amount > INVENTORY_MAX_AMOUNT) {
			// adding more than 99
			var overflow = (amount - INVENTORY_MAX_AMOUNT);
			inv.slots[freeSlot] = inventory_slot(itemID, INVENTORY_MAX_AMOUNT);

			inventory_add(inv, itemID, overflow);

		} else {
			inv.slots[freeSlot] = inventory_slot(itemID, amount);
		}

		return true;
	}
	return false;
}

function inventory_has_amount(inv, itemID, amount) {
	var finalAmount = 0;
	for (var i = 0; i < inv.length; i++) {
		var slot = inv.slots[i];
		if (!slot) continue;
		if (slot.itemID == itemID) {
			finalAmount += slot.amount;
		}
	}
	return (finalAmount >= amount);
}

function inventory_has(inv, itemID) {
	if (inv.length <= 0) return;

	for (var i = 0; i < inv.length; i++) {
		var slot = inv.slots[i];
		if (!slot) continue;
		if (slot.itemID == slot.itemID) {
			return i;
		}
	}

	return -1;
}

function inventory_remove_by_index(inv, index, amount) {
	if (index > inv.length-1) return;
	if (!inv.slots[index]) return;
	if (inv.slots[index].amount < amount) return;

	inv.slots[index].amount -= amount;
	if (inv.slots[index].amount == 0) then inv.slots[index] = 0;
	return true;
}

function inventory_remove(inv, itemID, amount) {
	if (inv.length <= 0) return;

	if (!inventory_has_amount(inv, itemID, amount)) return;

	var amt = amount;

	for (var i = 0; i < inv.length; i++) {
		var slot = inv.slots[i];
		if (!slot) continue;
		if (slot.itemID == itemID && amt > 0) {
			var value = min(amt, INVENTORY_MAX_AMOUNT);
			slot.amount -= value;
			amt -= value;

			if (slot.amount == 0) then inv.slots[i] = 0;
		}
	}
	return true;
}

function inventory_get(inv, index) {
	return inv.slots[index];
}

function inventory_craft(inv, itemID) {
	var recipe = RECIPE.Find(itemID);
	if (recipe == -1) return;

	for (var i = 0; i < array_length(recipe.ingredients); i++) {
		var ingredient = recipe.ingredients[i];
		var has = inventory_has_amount(inv, ingredient.itemID, ingredient.amount);

		if (!has) {
			CHAT.Send("You don't have enough items to craft this.");
			return;
		}
	}

	for (var i = 0; i < array_length(recipe.ingredients); i++) {
		var ingredient = recipe.ingredients[i];
		inventory_remove(inv, ingredient.itemID, ingredient.amount);
	}

	inventory_add(inv, itemID, recipe.amount);
}

