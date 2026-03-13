import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ui_config_provider.dart';

class UIConfigPage extends ConsumerStatefulWidget {
  const UIConfigPage({super.key});

  @override
  ConsumerState<UIConfigPage> createState() => _UIConfigPageState();
}

class _UIConfigPageState extends ConsumerState<UIConfigPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _relieverController;
  late TextEditingController _pillController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {})); // タブ切り替えでFABを制御
    
    final config = ref.read(uiConfigProvider);
    _relieverController = TextEditingController(text: config.relieverName);
    _pillController = TextEditingController(text: config.pillName);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _relieverController.dispose();
    _pillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(uiConfigProvider);
    const primaryBlue = Color(0xFF0056D2); // 鮮やかな青

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text('表示項目の編集', style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryBlue),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryBlue,
          tabs: const [Tab(text: '症状'), Tab(text: '誘因'), Tab(text: '薬剤')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConfigList('症状', config.symptoms, primaryBlue),
          _buildConfigList('誘因', config.triggers, primaryBlue),
          _buildMedicineSettings(primaryBlue),
        ],
      ),
      // ① 追加ボタンを常に表示
      floatingActionButton: _tabController.index != 2 
        ? FloatingActionButton(
            onPressed: () => _showAddDialog(['症状', '誘因'][_tabController.index]),
            backgroundColor: primaryBlue,
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
    );
  }

  Widget _buildMedicineSettings(Color blue) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildMedicineInput('リリーバー（4回まで）', _relieverController, blue),
          const SizedBox(height: 24),
          _buildMedicineInput('頓服（2回まで）', _pillController, blue),
        ],
      ),
    );
  }

  Widget _buildMedicineInput(String label, TextEditingController controller, Color blue) {
    return TextField(
      controller: controller,
      style: TextStyle(color: blue, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        // ignore: deprecated_member_use
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: blue.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blue, width: 2)),
      ),
      onChanged: (_) => ref.read(uiConfigProvider.notifier).updateMedicineNames(
        reliever: _relieverController.text,
        pill: _pillController.text,
      ),
    );
  }

  Widget _buildConfigList(String category, List<String> items, Color blue) {
    return ReorderableListView(
      padding: const EdgeInsets.all(16),
      onReorder: (oldIdx, newIdx) {
        final list = List<String>.from(items);
        if (oldIdx < newIdx) newIdx -= 1;
        final item = list.removeAt(oldIdx);
        list.insert(newIdx, item);
        ref.read(uiConfigProvider.notifier).updateItems(category, list);
      },
      children: [
        for (int i = 0; i < items.length; i++)
          Card(
            key: ValueKey('$category-${items[i]}'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(items[i], style: TextStyle(color: blue, fontWeight: FontWeight.bold)),
              // ignore: deprecated_member_use
              leading: Icon(Icons.drag_handle, color: blue.withOpacity(0.5)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  final list = List<String>.from(items)..removeAt(i);
                  ref.read(uiConfigProvider.notifier).updateItems(category, list);
                },
              ),
            ),
          ),
      ],
    );
  }

  void _showAddDialog(String category) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$categoryの追加', style: const TextStyle(color: Color(0xFF0056D2))),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: '項目名を入力')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2)),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final config = ref.read(uiConfigProvider);
                final List<String> currentList = category == '症状' 
                    ? List<String>.from(config.symptoms) 
                    : List<String>.from(config.triggers);
                ref.read(uiConfigProvider.notifier).updateItems(category, [...currentList, controller.text]);
                Navigator.pop(ctx);
              }
            },
            child: const Text('追加', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}