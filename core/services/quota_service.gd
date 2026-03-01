class_name QuotaService

static func get_quota_for_round(round_index: int) -> int:
	var normalized_round := max(1, round_index)
	var quota := float(GameBalanceConfig.BASE_QUOTA) * pow(GameBalanceConfig.QUOTA_GROWTH_RATE, normalized_round - 1)
	return int(round(quota))
