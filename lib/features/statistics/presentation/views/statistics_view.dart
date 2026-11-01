import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/helpers.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../../domain/entities/spending_summary.dart';

List<SpendingSummary> summarizeTransactionsByCategory(
  List<Map<String, dynamic>> transactions,
  String type,
) {
  final normalizedType = type.toLowerCase();
  final grouped = <String, double>{};

  for (final transaction in transactions) {
    final txType = (transaction['type'] as String?)?.toLowerCase() ?? '';
    if (txType != normalizedType) {
      continue;
    }

    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
    final category = transaction['categories'];
    final categoryName = category is Map<String, dynamic>
      ? category['name'] as String?
      : category is Map
        ? category['name'] as String?
        : null;
    final rawLabel = categoryName ??
      (transaction['merchant_name'] as String?) ??
      'Other';
    final label = rawLabel.trim();
    if (label.isEmpty) {
      continue;
    }

    grouped[label] = (grouped[label] ?? 0) + amount;
  }

  final items = grouped.entries
      .map((entry) => SpendingSummary(label: entry.key, value: entry.value))
      .toList();

  items.sort((a, b) => b.value.compareTo(a.value));
  return items;
}

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  int _selectedPeriodIndex = 2; // Default to 'Month'
  String _selectedType = 'Expense';

  final List<String> _periods = ['Day', 'Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    final transactionState = context.watch<TransactionCubit>().state;
    final transactions = transactionState is TransactionLoaded
        ? transactionState.transactions
        : <Map<String, dynamic>>[];

    final summaries = summarizeTransactionsByCategory(
      transactions,
      _selectedType.toLowerCase(),
    );
    final chartValues = summaries.take(6).map((item) => item.value).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overview',
                        style: AppStyles.headingMedium.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      _buildTypeDropdown(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildChartSection(chartValues, summaries),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedType == 'Expense'
                            ? 'Top Expenses'
                            : 'Top Income',
                        style: AppStyles.headingMedium.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Icons.swap_vert_rounded,
                          color: Color(0xFF64748B),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (summaries.isEmpty)
                    _buildEmptyState()
                  else
                    ...List.generate(summaries.take(6).length, (index) {
                      final item = summaries[index];
                      final isTopSpender = index == 0;
                      final totalSum = summaries.fold<double>(
                        0.0,
                        (sum, elem) => sum + elem.value,
                      );
                      final percentage = totalSum > 0
                          ? ((item.value / totalSum) * 100).toStringAsFixed(1)
                          : '0.0';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SpendingTile(
                          title: item.label,
                          subtitle: '$percentage% of total ${_selectedType.toLowerCase()}',
                          amount: '${_selectedType == 'Expense' ? '-' : '+'} \$${item.value.toStringAsFixed(2)}',
                          isExpense: _selectedType == 'Expense',
                          isHighlighted: isTopSpender,
                        ),
                      );
                    }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D9488),
            Color(0xFF115E59),
            Color(0xFF0F766E),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const Text(
                'Analytics & Stats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.showPremiumSnackBar(
                    'Statistics report downloaded successfully.',
                    icon: Icons.file_download_done_rounded,
                    backgroundColor: const Color(0xFF0D9488),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriodIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriodIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _periods[index],
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0D9488), size: 20),
          isDense: true,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedType = newValue);
            }
          },
          items: <String>['Expense', 'Income']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChartSection(List<double> values, List<SpendingSummary> summaries) {
    final safeValues = values.isEmpty ? [0.0, 0.0, 0.0, 0.0, 0.0] : values;
    final labels = summaries.take(6).map((item) => item.label).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: CustomPaint(
              size: Size.infinite,
              painter: _ChartPainter(values: safeValues),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.isEmpty
                ? List.generate(
                    5,
                    (index) => Text(
                      'P${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  )
                : List.generate(labels.length, (index) {
                    final label = labels[index];
                    final isSelected = index == labels.length - 1;
                    return Expanded(
                      child: Center(
                        child: Text(
                          label.length > 6 ? '${label.substring(0, 5)}…' : label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    );
                  }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 44,
            color: const Color(0xFF0D9488).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Data Available',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'No transactions found for the selected period.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingTile extends StatelessWidget {
  const _SpendingTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
    required this.isHighlighted,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isExpense;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final activeColor = isExpense ? const Color(0xFFF43F5E) : const Color(0xFF0D9488);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? const Color(0xFF0D9488).withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
          width: isHighlighted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                // ignore: deprecated_member_use
                ? const Color(0xFF0D9488).withValues(alpha: 0.08)
                : const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isExpense ? Icons.local_offer_rounded : Icons.trending_up_rounded,
              color: activeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: activeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final safeValues = values.isEmpty ? [0.0, 0.0, 0.0, 0.0, 0.0] : values;
    final maxRaw = safeValues.fold<double>(0.0, math.max);
    final maxValue = maxRaw == 0 ? 1.0 : maxRaw;

    final linePaint = Paint()
      ..color = const Color(0xFF0D9488)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0D9488).withValues(alpha: 0.22),
          const Color(0xFF0D9488).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final points = <Offset>[];
    for (var i = 0; i < safeValues.length; i++) {
      final x = size.width * ((i + 0.5) / safeValues.length);
      final y = size.height - ((safeValues[i] / maxValue) * (size.height * 0.65)) - 24;
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    final path = Path()..moveTo(points[0].dx, points[0].dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY1 = p0.dy;
      final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY2 = p1.dy;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final activeIndex = points.length - 1;
    final activePoint = points[activeIndex];

    final dashPaint = Paint()
      ..color = const Color(0xFF0D9488).withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double startY = activePoint.dy + 10;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(activePoint.dx, startY),
        Offset(activePoint.dx, startY + 4),
        dashPaint,
      );
      startY += 8;
    }

    canvas.drawCircle(
      activePoint,
      10,
      Paint()..color = const Color(0xFF0D9488).withValues(alpha: 0.18),
    );

    canvas.drawCircle(
      activePoint,
      5,
      Paint()..color = const Color(0xFF0D9488),
    );

    _drawTooltip(
      canvas,
      Offset(activePoint.dx, activePoint.dy - 32),
      '\$${safeValues[activeIndex].toStringAsFixed(0)}',
    );
  }

  void _drawTooltip(Canvas canvas, Offset center, String text) {
    const textStyle = TextStyle(
      color: Color(0xFF0D9488),
      fontWeight: FontWeight.w800,
      fontSize: 13,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final rectWidth = textPainter.width + 20;
    const rectHeight = 28.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: rectWidth, height: rectHeight),
      const Radius.circular(8),
    );

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF0D9488).withValues(alpha: 0.3)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rect, bgPaint);
    canvas.drawRRect(rect, borderPaint);

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}