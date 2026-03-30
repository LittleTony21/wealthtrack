class MilestoneDefinition {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String category;
  final int coinReward;

  const MilestoneDefinition({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.category,
    required this.coinReward,
  });
}

const List<MilestoneDefinition> kMilestones = [
  // ── Net Worth (base 1, +1 per level) ──────────────────────────────────────
  MilestoneDefinition(
    id: 'nw_positive',
    name: 'In The Black',
    emoji: '✅',
    description: 'Net worth above \$0',
    category: 'Net Worth',
    coinReward: 1,
  ),
  MilestoneDefinition(
    id: 'nw_1k',
    name: 'Four Digits',
    emoji: '💰',
    description: 'Net worth ≥ \$1,000',
    category: 'Net Worth',
    coinReward: 2,
  ),
  MilestoneDefinition(
    id: 'nw_10k',
    name: 'Five Digits',
    emoji: '🏠',
    description: 'Net worth ≥ \$10,000',
    category: 'Net Worth',
    coinReward: 3,
  ),
  MilestoneDefinition(
    id: 'nw_100k',
    name: 'Six Digits',
    emoji: '💎',
    description: 'Net worth ≥ \$100,000',
    category: 'Net Worth',
    coinReward: 4,
  ),
  MilestoneDefinition(
    id: 'nw_1m',
    name: 'Millionaire',
    emoji: '🚀',
    description: 'Net worth ≥ \$1,000,000',
    category: 'Net Worth',
    coinReward: 5,
  ),

  // ── Streak (base 1, +1 per level) ─────────────────────────────────────────
  MilestoneDefinition(
    id: 'streak_7',
    name: 'Week Warrior',
    emoji: '📅',
    description: '7-day check-in streak',
    category: 'Streak',
    coinReward: 1,
  ),
  MilestoneDefinition(
    id: 'streak_30',
    name: 'Monthly Grind',
    emoji: '🔥',
    description: '30-day check-in streak',
    category: 'Streak',
    coinReward: 2,
  ),
  MilestoneDefinition(
    id: 'streak_100',
    name: 'Century',
    emoji: '💯',
    description: '100-day check-in streak',
    category: 'Streak',
    coinReward: 3,
  ),

  // ── Assets Tracked (base 1, +1 per level) ─────────────────────────────────
  MilestoneDefinition(
    id: 'assets_1',
    name: 'First Steps',
    emoji: '🌱',
    description: 'Added your first asset',
    category: 'Tracking',
    coinReward: 1,
  ),
  MilestoneDefinition(
    id: 'assets_5',
    name: 'Collector',
    emoji: '📦',
    description: '5 assets tracked',
    category: 'Tracking',
    coinReward: 2,
  ),
  MilestoneDefinition(
    id: 'assets_10',
    name: 'Power Tracker',
    emoji: '📊',
    description: '10 assets tracked',
    category: 'Tracking',
    coinReward: 3,
  ),

  // ── Special (1 coin each) ──────────────────────────────────────────────────
  MilestoneDefinition(
    id: 'first_liability',
    name: 'Debt Aware',
    emoji: '💳',
    description: 'Added your first liability',
    category: 'Special',
    coinReward: 1,
  ),
  MilestoneDefinition(
    id: 'first_coin',
    name: 'First Coin',
    emoji: '🪙',
    description: 'Collected your first check-in coin',
    category: 'Special',
    coinReward: 1,
  ),
  MilestoneDefinition(
    id: 'completionist',
    name: 'Completionist',
    emoji: '🎯',
    description: 'Completed onboarding',
    category: 'Special',
    coinReward: 1,
  ),
  MilestoneDefinition(
    id: 'premium_taste',
    name: 'Premium Taste',
    emoji: '⭐',
    description: 'Unlocked a premium feature',
    category: 'Special',
    coinReward: 1,
  ),
  MilestoneDefinition(
    id: 'go_premium',
    name: 'Go Premium',
    emoji: '👑',
    description: 'Upgraded to Premium',
    category: 'Special',
    coinReward: 1,
  ),
];
