import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../widgets/add_food_dialog.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int dailyGoal = 2000;

  // Local list storage (resets when the app restarts)
  final List<FoodItem> _foods = [];

  int get _totalCalories => _foods.fold(0, (sum, item) => sum + item.calories);

  int get _remainingCalories => dailyGoal - _totalCalories;

  String get _todayText {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Future<void> _openAddFoodDialog() async {
    final FoodItem? newFood = await showDialog<FoodItem>(
      context: context,
      builder: (context) => const AddFoodDialog(),
    );

    if (newFood != null) {
      setState(() => _foods.add(newFood));
    }
  }

  void _deleteFood(FoodItem item) {
    setState(() => _foods.removeWhere((f) => f.id == item.id));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${item.name} removed')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool overGoal = _remainingCalories < 0;
    final double progress = (_totalCalories / dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calorie Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(_todayText, style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),

                // Main summary card
                Card(
                  elevation: 3,
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Total Calories Consumed',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_totalCalories kcal',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            color: overGoal ? Colors.red : Colors.green,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Three info cards
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Calories',
                          value: '$_totalCalories',
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                      ),
                      const Expanded(
                        child: SummaryCard(
                          title: 'Daily Goal',
                          value: '$dailyGoal',
                          icon: Icons.flag,
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: SummaryCard(
                          title: 'Remaining Calories',
                          value: '$_remainingCalories',
                          icon: overGoal
                              ? Icons.warning_amber
                              : Icons.restaurant,
                          color: overGoal ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Food List (${_foods.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          Expanded(
            child: _foods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fastfood,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No food added yet.\nTap "Add Food" to get started.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: _foods.length,
                    itemBuilder: (context, index) {
                      final item = _foods[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.restaurant_menu,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${item.calories} kcal'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () => _deleteFood(item),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddFoodDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
      ),
    );
  }
}
