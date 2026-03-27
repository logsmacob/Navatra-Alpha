extends RefCounted

class_name ShopOfferService

const RARITY_ROLL_ORDER: Array[TrinketData.TrinketRarity] = [
	TrinketData.TrinketRarity.COMMON,
	TrinketData.TrinketRarity.UNCOMMON,
	TrinketData.TrinketRarity.RARE,
	TrinketData.TrinketRarity.EPIC,
]

var _rarity_weights: Dictionary = TrinketData.SHOP_RARITY_WEIGHTS.duplicate(true)

func set_rarity_weights(rarity_weights: Dictionary) -> void:
	if rarity_weights.is_empty():
		_rarity_weights = TrinketData.SHOP_RARITY_WEIGHTS.duplicate(true)
		return
	_rarity_weights = rarity_weights.duplicate(true)

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
	if pool.is_empty():
		return null
	var rolled_rarity := _roll_rarity_by_weight()
	var rarity_pool := _build_pool_for_rarity(pool, rolled_rarity)
	if rarity_pool.is_empty():
		rarity_pool = pool

	var total_weight: float = 0.0
	for item: TrinketData in rarity_pool:
		total_weight += item.get_shop_weight()
	if total_weight <= 0.0:
		return null

	var roll: float = randf_range(0.0, total_weight)
	var running_weight: float = 0.0
	for item: TrinketData in rarity_pool:
		running_weight += item.get_shop_weight()
		if roll <= running_weight:
			return item

	return rarity_pool.back() if not rarity_pool.is_empty() else null

func _roll_rarity_by_weight() -> TrinketData.TrinketRarity:
	var total_weight := 0.0
	for rarity in RARITY_ROLL_ORDER:
		total_weight += float(_rarity_weights.get(rarity, 0.0))
	if total_weight <= 0.0:
		return TrinketData.TrinketRarity.COMMON

	var roll := randf_range(0.0, total_weight)
	var running_weight := 0.0
	for rarity in RARITY_ROLL_ORDER:
		running_weight += float(_rarity_weights.get(rarity, 0.0))
		if roll <= running_weight:
			return rarity

	return TrinketData.TrinketRarity.COMMON

func _build_pool_for_rarity(pool: Array[TrinketData], rarity: TrinketData.TrinketRarity) -> Array[TrinketData]:
	var exact_match_pool: Array[TrinketData] = []
	for item: TrinketData in pool:
		if item.rarity == rarity:
			exact_match_pool.append(item)
	if not exact_match_pool.is_empty():
		return exact_match_pool

	var ordered_pool: Array[TrinketData] = []
	var sorted_by_distance := pool.duplicate()
	sorted_by_distance.sort_custom(func(a: TrinketData, b: TrinketData) -> bool:
		var distance_a = abs(int(a.rarity) - int(rarity))
		var distance_b = abs(int(b.rarity) - int(rarity))
		if distance_a == distance_b:
			return int(a.rarity) < int(b.rarity)
		return distance_a < distance_b
	)
	for item: TrinketData in sorted_by_distance:
		ordered_pool.append(item)
	return ordered_pool
