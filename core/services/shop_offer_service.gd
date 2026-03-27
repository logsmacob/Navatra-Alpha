extends RefCounted

class_name ShopOfferService

func roll_weighted_offers(item_pool: Array[TrinketData], current_round: int, target_count: int, avoid_duplicates: bool = true, owned_item_counts: Dictionary = {}) -> Array[TrinketData]:
	if target_count <= 0:
		return []

	var rolled_offers: Array[TrinketData] = []
	var candidate_pool := get_available_items_for_round(item_pool, current_round, owned_item_counts)

	while rolled_offers.size() < target_count and not candidate_pool.is_empty():
		var picked_item := pick_weighted_item(candidate_pool)
		if picked_item == null:
			break
		rolled_offers.append(picked_item)
		if avoid_duplicates:
			candidate_pool.erase(picked_item)

	return rolled_offers

func get_available_items_for_round(item_pool: Array[TrinketData], current_round: int, owned_item_counts: Dictionary = {}) -> Array[TrinketData]:
	var available_items: Array[TrinketData] = []
	for item: TrinketData in item_pool:
		if item == null:
			continue
		if not item.is_available_for_round(current_round):
			continue
		var item_count := int(owned_item_counts.get(item.get_shop_tracking_key(), 0))
		if item.has_reached_max_quantity(item_count):
			continue
		available_items.append(item)
	return available_items

func pick_weighted_item(pool: Array[TrinketData]) -> TrinketData:
	var total_weight: float = 0.0
	for item: TrinketData in pool:
		total_weight += item.get_shop_weight()
	if total_weight <= 0.0:
		return null

	var roll: float = randf_range(0.0, total_weight)
	var running_weight: float = 0.0
	for item: TrinketData in pool:
		running_weight += item.get_shop_weight()
		if roll <= running_weight:
			return item

	return pool.back() if not pool.is_empty() else null
