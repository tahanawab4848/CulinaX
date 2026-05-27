import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/pantry_item.dart';
import '../providers/pantry_provider.dart';
import '../utils/measurement_converter.dart';
import 'ingredient_scanner_screen.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pantry = context.watch<PantryProvider>();
    final grouped = pantry.groupedByCategory;

    return Scaffold(
      backgroundColor: C.dark2,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MY PANTRY', style: T.lbl(c: C.g400)),
            Text('Kitchen Stock', style: T.head(18)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Scan ingredient photo',
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IngredientScannerScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: pantry.loading
          ? const Center(child: CircularProgressIndicator(color: C.g500))
          : pantry.activeItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🧺', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text('Pantry is empty', style: T.head(20)),
                      Text('Add your desi ingredients', style: T.body(14, c: C.white40)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (pantry.expiringSoon.isNotEmpty)
                      _AlertBanner(
                        title: '${pantry.expiringSoon.length} items expiring soon',
                        color: C.a500,
                      ),
                    ...grouped.entries.expand((e) => [
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 10),
                            child: Text(e.key.toUpperCase(), style: T.lbl(c: C.g300)),
                          ),
                          ...e.value.map((item) => _PantryTile(item: item)),
                        ]),
                  ],
                ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    String category = 'Staple';
    String unit = 'piece';
    String icon = '🥘';
    DateTime? expiry;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.dark3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add Pantry Item', style: T.head(20)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: T.body(15, c: C.white),
                  decoration: const InputDecoration(labelText: 'Item name'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        style: T.body(15, c: C.white),
                        decoration: const InputDecoration(labelText: 'Quantity'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: (MeasurementConverter.desiUnits.contains(unit)
                            ? unit
                            : (MeasurementConverter.desiUnits.isNotEmpty
                                ? MeasurementConverter.desiUnits.first
                                : 'piece')),
                        dropdownColor: C.card,
                        decoration: const InputDecoration(labelText: 'Unit'),
                        items: (MeasurementConverter.desiUnits.contains(unit)
                                ? MeasurementConverter.desiUnits
                                : [unit, ...MeasurementConverter.desiUnits])
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => setState(() => unit = v ?? 'piece'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: C.card,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: AppConstants.pantryCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => category = v ?? 'Other'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Expiry date', style: T.sub(14)),
                  subtitle: Text(
                    expiry?.toLocal().toString().split(' ').first ?? 'Not set',
                    style: T.body(12, c: C.white40),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: C.g400),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setState(() => expiry = d);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) return;
                      await context.read<PantryProvider>().addItem(
                            itemName: nameCtrl.text,
                            category: category,
                            quantity: double.tryParse(qtyCtrl.text) ?? 1,
                            unit: unit,
                            expiryDate: expiry,
                            icon: icon,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Add to Pantry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final String title;
  final Color color;
  const _AlertBanner({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: T.sub(13, c: color))),
        ],
      ),
    );
  }
}

class _PantryTile extends StatelessWidget {
  final PantryItem item;
  const _PantryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final pantry = context.read<PantryProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: D.card(r: 14),
      child: ListTile(
        leading: Text(item.icon, style: const TextStyle(fontSize: 28)),
        title: Text(item.itemName, style: T.sub(14)),
        subtitle: Text(
          '${item.quantity} ${item.unit}${item.expiryDate != null ? ' · Exp: ${item.expiryDate!.toLocal().toString().split(' ').first}' : ''}',
          style: T.body(12, c: item.isExpiringSoon ? C.a400 : C.white40),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: C.white40),
          color: C.card,
          onSelected: (v) async {
            if (v == 'used') await pantry.markAsUsed(item);
            if (v == 'restock') await pantry.restock(item);
            if (v == 'delete') await pantry.deleteItem(item.id);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'used', child: Text('Mark as used')),
            const PopupMenuItem(value: 'restock', child: Text('Restock')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
