import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ads/ads_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../data/local/providers.dart';
import '../../data/models/models.dart';

class DietScreen extends ConsumerStatefulWidget {
  const DietScreen({super.key});

  @override
  ConsumerState<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends ConsumerState<DietScreen> {
  String _selected = 'weight_loss';

  final _categories = {
    'weight_loss': ('Fat Loss 🔥', AppTheme.error),
    'weight_gain': ('Muscle Gain 💪', AppTheme.success),
    'maintenance': ('Maintenance ⚖️', AppTheme.accent),
  };

  @override
  Widget build(BuildContext context) {
    final dietAsync = ref.watch(dietPlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Diet Plans')),
      body: Column(
        children: [
          const PPBannerAd(),

          // Category Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: _categories.entries.map((e) {
                final isSelected = _selected == e.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? e.value.$2.withOpacity(0.2)
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? e.value.$2
                              : AppTheme.cardBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        e.value.$1,
                        style: TextStyle(
                          color: isSelected
                              ? e.value.$2
                              : AppTheme.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: dietAsync.when(
              data: (plans) {
                final plan =
                plans.firstWhere((p) => p.category == _selected);
                return _DietPlanView(plan: plan);
              },
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DietPlanView extends StatelessWidget {
  final DietPlan plan;

  const _DietPlanView({required this.plan});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: plan.meals.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PPCard(
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: AppTheme.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.title,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        Text(plan.description,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${plan.totalCalories}',
                        style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 22,
                            fontWeight: FontWeight.w900),
                      ),
                      const Text('kcal/day',
                          style: TextStyle(
                              color: AppTheme.textHint, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        final meal = plan.meals[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _MealCard(meal: meal),
        );
      },
    );
  }
}

class _MealCard extends StatelessWidget {
  final DietMeal meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return PPCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meal.name,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      color: AppTheme.textHint, size: 14),
                  const SizedBox(width: 4),
                  Text(meal.time,
                      style: const TextStyle(
                          color: AppTheme.textHint, fontSize: 12)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('${meal.calories} kcal',
                        style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...meal.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle,
                    size: 5, color: AppTheme.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 13)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}