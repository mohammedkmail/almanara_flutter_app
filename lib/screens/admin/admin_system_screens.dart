import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/library_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/api_error_view.dart';
import '../../widgets/manara_components.dart';

// ============================================================================
// USERS
// ============================================================================

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<AdminUserItem>> _future;
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = LibraryService.instance.adminUsers();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('المستخدمون')),
      body: FutureBuilder<List<AdminUserItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ApiErrorView(
              error: snapshot.error!,
              retry: () => setState(_reload),
            );
          }
          final all = snapshot.data!;
          final q = _query.trim().toLowerCase();
          final users = q.isEmpty
              ? all
              : all
                    .where(
                      (u) =>
                          u.fullName.toLowerCase().contains(q) ||
                          u.username.toLowerCase().contains(q),
                    )
                    .toList();
          final members = all
              .where((u) => u.membership?.status == 'ACTIVE')
              .length;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
              children: [
                _SystemHero(
                  title: 'مجتمع المنارة',
                  subtitle:
                      'اعرف المستخدم وعضويته قبل تنفيذ إعارة أو بيع من الكاونتر.',
                  metric: '${all.length}',
                  metricLabel: 'مستخدم',
                  icon: Icons.people_alt_outlined,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MiniInfo(
                        value: '$members',
                        label: 'عضوية فعالة',
                        tone: AppTheme.teal,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _MiniInfo(
                        value: '${all.length - members}',
                        label: 'بدون عضوية',
                        tone: const Color(0xFF8A6A34),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _search,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'ابحث بالاسم أو البريد...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 18),
                if (users.isEmpty)
                  const ManaraEmptyState(
                    icon: Icons.person_search_outlined,
                    title: 'لا توجد نتائج',
                    message: 'غيّر عبارة البحث وحاول مرة أخرى.',
                  )
                else
                  ...users.map((user) => _UserAdminCard(user: user)),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _UserAdminCard extends StatelessWidget {
  final AdminUserItem user;
  const _UserAdminCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final active = user.membership?.status == 'ACTIVE';
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: active ? const Color(0xFFE6F1EC) : const Color(0xFFF1F2EF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              active ? Icons.workspace_premium_rounded : Icons.person_outline,
              color: active ? AppTheme.teal : AppTheme.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  user.username,
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.muted),
                ),
                const SizedBox(height: 7),
                Text(
                  active
                      ? 'عضوية فعالة حتى ${formatDate(user.membership?.endDate)} • الاستعارة بدون رسوم'
                      : 'لا توجد عضوية فعالة • تطبق رسوم الكتاب',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: active ? AppTheme.teal : const Color(0xFF8A6A34),
                  ),
                ),
              ],
            ),
          ),
          if (!user.enabled || user.accountLocked)
            const ManaraStatusChip(
              label: 'موقوف',
              color: Colors.redAccent,
              icon: Icons.block_outlined,
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// CATEGORIES
// ============================================================================

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  late Future<List<CategoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = LibraryService.instance.categories();

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  void _snack(String value) {
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _edit([CategoryItem? item]) async {
    final result = await showModalBottomSheet<_CategoryDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CategoryEditor(item: item),
    );
    if (result == null) return;
    try {
      if (item == null) {
        await LibraryService.instance.adminSaveCategory(result.toJson());
      } else {
        await LibraryService.instance.adminUpdateCategory(
          item.id,
          result.toJson(),
        );
      }
      _snack(item == null ? 'تمت إضافة القسم.' : 'تم حفظ القسم.');
      if (mounted) setState(_reload);
    } catch (error) {
      _snack(apiErrorMessage(error));
    }
  }

  Future<void> _delete(CategoryItem item) async {
    final yes = await _confirm(
      context,
      'حذف القسم؟',
      item.bookCount > 0
          ? 'هذا القسم مرتبط بـ ${item.bookCount} كتاب؛ الخادم سيرفض حذفه حتى تنقل الكتب.'
          : 'سيتم حذف القسم نهائياً.',
    );
    if (!yes) return;
    try {
      await LibraryService.instance.adminDeleteCategory(item.id);
      _snack('تم حذف القسم.');
      if (mounted) setState(_reload);
    } catch (error) {
      _snack(apiErrorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) => _AdminCollectionScaffold<CategoryItem>(
    title: 'الأقسام',
    future: _future,
    onRefresh: _refresh,
    onRetry: () => setState(_reload),
    hero: const _SystemHero(
      title: 'بنية الفهرس',
      subtitle: 'الأقسام تساعد المستخدم على التصفح بدون الحاجة للبحث النصي.',
      metric: 'CAT',
      metricLabel: 'Catalog',
      icon: Icons.category_outlined,
    ),
    emptyTitle: 'لا توجد أقسام',
    addLabel: 'إضافة قسم',
    onAdd: () => _edit(),
    itemBuilder: (item) => _ReferenceCard(
      title: item.name,
      subtitle: item.description.isEmpty
          ? 'لا يوجد وصف بعد.'
          : item.description,
      countLabel: '${item.bookCount} كتاب',
      active: item.active,
      icon: Icons.folder_copy_outlined,
      onEdit: () => _edit(item),
      onDelete: () => _delete(item),
    ),
  );
}

class _CategoryDraft {
  final String name;
  final String description;
  final bool active;
  const _CategoryDraft(this.name, this.description, this.active);
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'active': active,
  };
}

class _CategoryEditor extends StatefulWidget {
  final CategoryItem? item;
  const _CategoryEditor({this.item});

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.name ?? '');
    _description = TextEditingController(text: widget.item?.description ?? '');
    _active = widget.item?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _EditorShell(
    title: widget.item == null ? 'قسم جديد' : 'تعديل القسم',
    children: [
      TextField(
        controller: _name,
        decoration: const InputDecoration(labelText: 'اسم القسم'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _description,
        maxLines: 5,
        decoration: const InputDecoration(labelText: 'الوصف'),
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: _active,
        onChanged: (value) => setState(() => _active = value),
        title: const Text('ظاهر في الفهرس'),
      ),
      const SizedBox(height: 14),
      ElevatedButton(
        onPressed: () {
          if (_name.text.trim().isEmpty) return;
          Navigator.pop(
            context,
            _CategoryDraft(
              _name.text.trim(),
              _description.text.trim(),
              _active,
            ),
          );
        },
        child: const Text('حفظ'),
      ),
    ],
  );
}

// ============================================================================
// AUTHORS
// ============================================================================

class AdminAuthorsScreen extends StatefulWidget {
  const AdminAuthorsScreen({super.key});

  @override
  State<AdminAuthorsScreen> createState() => _AdminAuthorsScreenState();
}

class _AdminAuthorsScreenState extends State<AdminAuthorsScreen> {
  late Future<List<AuthorItem>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = LibraryService.instance.authors();

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  void _snack(String value) {
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _edit([AuthorItem? item]) async {
    final result = await showModalBottomSheet<_AuthorDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AuthorEditor(item: item),
    );
    if (result == null) return;
    try {
      if (item == null) {
        await LibraryService.instance.adminSaveAuthor(result.toJson());
      } else {
        await LibraryService.instance.adminUpdateAuthor(
          item.id,
          result.toJson(),
        );
      }
      _snack(item == null ? 'تمت إضافة المؤلف.' : 'تم حفظ المؤلف.');
      if (mounted) setState(_reload);
    } catch (error) {
      _snack(apiErrorMessage(error));
    }
  }

  Future<void> _delete(AuthorItem item) async {
    final yes = await _confirm(
      context,
      'حذف المؤلف؟',
      item.bookCount > 0
          ? 'المؤلف مرتبط بـ ${item.bookCount} كتاب؛ يجب نقل الكتب قبل الحذف.'
          : 'سيتم حذف المؤلف نهائياً.',
    );
    if (!yes) return;
    try {
      await LibraryService.instance.adminDeleteAuthor(item.id);
      _snack('تم حذف المؤلف.');
      if (mounted) setState(_reload);
    } catch (error) {
      _snack(apiErrorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) => _AdminCollectionScaffold<AuthorItem>(
    title: 'المؤلفون',
    future: _future,
    onRefresh: _refresh,
    onRetry: () => setState(_reload),
    hero: const _SystemHero(
      title: 'أصوات وراء الكتب',
      subtitle: 'اسم واضح وسيرة مختصرة وصورة من قاعدة البيانات عند توفرها.',
      metric: 'A–Z',
      metricLabel: 'Authors',
      icon: Icons.record_voice_over_outlined,
    ),
    emptyTitle: 'لا يوجد مؤلفون',
    addLabel: 'إضافة مؤلف',
    onAdd: () => _edit(),
    itemBuilder: (item) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          ManaraImage(
            url: item.imageUrl,
            width: 68,
            height: 68,
            borderRadius: BorderRadius.circular(15),
            fallbackIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (item.nationality.isNotEmpty) item.nationality,
                    '${item.bookCount} كتاب',
                  ].join(' • '),
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.muted),
                ),
                if (item.biography.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    item.biography,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.4,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _edit(item);
              if (value == 'delete') _delete(item);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('تعديل')),
              PopupMenuItem(value: 'delete', child: Text('حذف')),
            ],
          ),
        ],
      ),
    ),
  );
}

class _AuthorDraft {
  final String name;
  final String nationality;
  final String biography;
  const _AuthorDraft(this.name, this.nationality, this.biography);
  Map<String, dynamic> toJson() => {
    'name': name,
    'nationality': nationality,
    'biography': biography,
  };
}

class _AuthorEditor extends StatefulWidget {
  final AuthorItem? item;
  const _AuthorEditor({this.item});

  @override
  State<_AuthorEditor> createState() => _AuthorEditorState();
}

class _AuthorEditorState extends State<_AuthorEditor> {
  late final TextEditingController _name;
  late final TextEditingController _nationality;
  late final TextEditingController _biography;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.name ?? '');
    _nationality = TextEditingController(text: widget.item?.nationality ?? '');
    _biography = TextEditingController(text: widget.item?.biography ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _nationality.dispose();
    _biography.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _EditorShell(
    title: widget.item == null ? 'مؤلف جديد' : 'تعديل المؤلف',
    children: [
      if (widget.item != null)
        Center(
          child: ManaraImage(
            url: widget.item!.imageUrl,
            width: 92,
            height: 92,
            borderRadius: BorderRadius.circular(22),
            fallbackIcon: Icons.person_outline_rounded,
          ),
        ),
      if (widget.item != null) const SizedBox(height: 16),
      TextField(
        controller: _name,
        decoration: const InputDecoration(labelText: 'الاسم'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _nationality,
        decoration: const InputDecoration(labelText: 'الجنسية'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _biography,
        maxLines: 6,
        decoration: const InputDecoration(labelText: 'السيرة'),
      ),
      const SizedBox(height: 8),
      const Text(
        'مكان صورة المؤلف جاهز ويعرض الصورة المخزنة في الويب. رفع صورة جديدة من الموبايل يمكن إضافته لاحقاً بدون تغيير هيكل الصفحة.',
        style: TextStyle(fontSize: 10.5, height: 1.5, color: AppTheme.muted),
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          if (_name.text.trim().isEmpty) return;
          Navigator.pop(
            context,
            _AuthorDraft(
              _name.text.trim(),
              _nationality.text.trim(),
              _biography.text.trim(),
            ),
          );
        },
        child: const Text('حفظ'),
      ),
    ],
  );
}

// ============================================================================
// HOLIDAYS
// ============================================================================

class AdminHolidaysScreen extends StatefulWidget {
  const AdminHolidaysScreen({super.key});

  @override
  State<AdminHolidaysScreen> createState() => _AdminHolidaysScreenState();
}

class _AdminHolidaysScreenState extends State<AdminHolidaysScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = LibraryService.instance.adminHolidays();

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  void _snack(String value) {
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _sync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final result = await LibraryService.instance.syncHolidays();
      _snack((result['message'] ?? 'تم تحديث تقويم العطل.').toString());
      if (mounted) setState(_reload);
    } catch (error) {
      _snack(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _edit([Map<String, dynamic>? item]) async {
    final draft = await showModalBottomSheet<_HolidayDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _HolidayEditor(item: item),
    );
    if (draft == null) return;
    try {
      if (item == null) {
        await LibraryService.instance.adminSaveHoliday(draft.toJson());
      } else {
        await LibraryService.instance.adminUpdateHoliday(
          asInt(item['id']) ?? 0,
          draft.toJson(),
        );
      }
      _snack(item == null ? 'تمت إضافة اليوم.' : 'تم حفظ اليوم.');
      if (mounted) setState(_reload);
    } catch (error) {
      _snack(apiErrorMessage(error));
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final id = asInt(item['id']);
    if (id == null) return;
    if (!await _confirm(
      context,
      'حذف اليوم؟',
      'سيتم حذف هذا السجل من تقويم المكتبة.',
    ))
      return;
    try {
      await LibraryService.instance.adminDeleteHoliday(id);
      _snack('تم حذف اليوم.');
      if (mounted) setState(_reload);
    } catch (error) {
      _snack(apiErrorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('تقويم العطل'),
        actions: [
          IconButton(
            tooltip: 'مزامنة المصدر الخارجي',
            onPressed: _syncing ? null : _sync,
            icon: _syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('يوم جديد'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ApiErrorView(
              error: snapshot.error!,
              retry: () => setState(_reload),
            );
          }
          final rows = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
              children: [
                _SystemHero(
                  title: 'التقويم التشغيلي',
                  subtitle:
                      'أي يوم مغلق هنا يمنع حجز الغرف الذي يمر خلاله قبل إنشاء الدفع.',
                  metric: '${rows.where((e) => e['closed'] == true).length}',
                  metricLabel: 'يوم مغلق',
                  icon: Icons.event_busy_outlined,
                ),
                const SizedBox(height: 18),
                if (rows.isEmpty)
                  const ManaraEmptyState(
                    icon: Icons.calendar_month_outlined,
                    title: 'لا توجد أيام مسجلة',
                    message: 'أضف يوماً يدوياً أو نفّذ المزامنة.',
                  )
                else
                  ...rows.map((item) {
                    final date = asDate(item['date']);
                    final closed = item['closed'] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 58,
                            decoration: BoxDecoration(
                              color: closed
                                  ? const Color(0xFFF6E9E6)
                                  : const Color(0xFFE8F2ED),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date == null ? '—' : '${date.day}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  date == null
                                      ? ''
                                      : '${date.month}/${date.year}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppTheme.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (item['name'] ?? 'عطلة').toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item['source'] ?? 'MANUAL'} • ${closed ? 'المكتبة مغلقة' : 'المكتبة مفتوحة'}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppTheme.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _edit(item);
                              if (value == 'delete') _delete(item);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('تعديل'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('حذف'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _HolidayDraft {
  final DateTime date;
  final String name;
  final bool closed;
  final String notes;
  const _HolidayDraft(this.date, this.name, this.closed, this.notes);
  Map<String, dynamic> toJson() => {
    'date': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
    'name': name,
    'closed': closed,
    'notes': notes,
  };
}

class _HolidayEditor extends StatefulWidget {
  final Map<String, dynamic>? item;
  const _HolidayEditor({this.item});

  @override
  State<_HolidayEditor> createState() => _HolidayEditorState();
}

class _HolidayEditorState extends State<_HolidayEditor> {
  late final TextEditingController _name;
  late final TextEditingController _notes;
  late DateTime _date;
  late bool _closed;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?['name']?.toString() ?? '');
    _notes = TextEditingController(
      text: widget.item?['notes']?.toString() ?? '',
    );
    _date = asDate(widget.item?['date'])?.toLocal() ?? DateTime.now();
    _closed = widget.item?['closed'] != false;
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _EditorShell(
    title: widget.item == null ? 'إضافة يوم' : 'تعديل اليوم',
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.calendar_month_outlined),
        title: const Text('التاريخ'),
        subtitle: Text(formatDate(_date)),
        trailing: const Icon(Icons.edit_calendar_outlined),
        onTap: () async {
          final value = await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2040),
            initialDate: _date,
          );
          if (value != null) setState(() => _date = value);
        },
      ),
      TextField(
        controller: _name,
        decoration: const InputDecoration(labelText: 'اسم المناسبة'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _notes,
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'ملاحظات'),
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: _closed,
        onChanged: (value) => setState(() => _closed = value),
        title: const Text('المكتبة مغلقة'),
        subtitle: const Text('يمنع إنشاء حجز غرفة يمر بهذا اليوم.'),
      ),
      const SizedBox(height: 14),
      ElevatedButton(
        onPressed: () {
          if (_name.text.trim().isEmpty) return;
          Navigator.pop(
            context,
            _HolidayDraft(
              _date,
              _name.text.trim(),
              _closed,
              _notes.text.trim(),
            ),
          );
        },
        child: const Text('حفظ'),
      ),
    ],
  );
}

// ============================================================================
// DISCOUNT RULES
// ============================================================================

class AdminDiscountRulesScreen extends StatefulWidget {
  const AdminDiscountRulesScreen({super.key});

  @override
  State<AdminDiscountRulesScreen> createState() =>
      _AdminDiscountRulesScreenState();
}

class _AdminDiscountRulesScreenState extends State<AdminDiscountRulesScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = LibraryService.instance.adminDiscountRules();

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  void _snack(String value) {
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _edit([Map<String, dynamic>? item]) async {
    final draft = await showModalBottomSheet<_RuleDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _RuleEditor(item: item),
    );
    if (draft == null) return;
    try {
      if (item == null) {
        await LibraryService.instance.adminSaveDiscountRule(draft.toJson());
      } else {
        await LibraryService.instance.adminUpdateDiscountRule(
          asInt(item['id']) ?? 0,
          draft.toJson(),
        );
      }
      _snack(item == null ? 'تمت إضافة قاعدة الخصم.' : 'تم حفظ قاعدة الخصم.');
      if (mounted) setState(_reload);
    } catch (error) {
      _snack(apiErrorMessage(error));
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final id = asInt(item['id']);
    if (id == null) return;
    if (!await _confirm(
      context,
      'حذف قاعدة الخصم؟',
      'لن تطبق على حجوزات الغرف الجديدة بعد الحذف.',
    ))
      return;
    try {
      await LibraryService.instance.adminDeleteDiscountRule(id);
      _snack('تم حذف القاعدة.');
      if (mounted) setState(_reload);
    } catch (error) {
      _snack(apiErrorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('خصومات الغرف')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('قاعدة جديدة'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ApiErrorView(
              error: snapshot.error!,
              retry: () => setState(_reload),
            );
          }
          final rows = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
              children: [
                const _SystemHero(
                  title: 'تسعير أكثر عدلاً',
                  subtitle:
                      'الخصم يختار أول قاعدة فعالة حسب الأولوية وعدد ساعات الحجز.',
                  metric: '%',
                  metricLabel: 'Rules',
                  icon: Icons.percent_rounded,
                ),
                const SizedBox(height: 18),
                if (rows.isEmpty)
                  const ManaraEmptyState(
                    icon: Icons.discount_outlined,
                    title: 'لا توجد قواعد خصم',
                    message: 'السعر سيكون السعر الأساسي للغرفة.',
                  )
                else
                  ...rows.map((item) {
                    final min = asInt(item['minHours']) ?? 0;
                    final max = asInt(item['maxHours']);
                    final pct = asDouble(item['percentage']) ?? 0;
                    final active = item['active'] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F2ED),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${pct.toStringAsFixed(pct % 1 == 0 ? 0 : 1)}%',
                              style: const TextStyle(
                                color: AppTheme.teal,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (item['name'] ?? 'قاعدة خصم').toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  max == null
                                      ? 'من $min ساعة فأكثر'
                                      : 'من $min إلى $max ساعة',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppTheme.muted,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                ManaraStatusChip(
                                  label: active ? 'فعالة' : 'متوقفة',
                                  color: active
                                      ? AppTheme.teal
                                      : AppTheme.muted,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _edit(item);
                              if (value == 'delete') _delete(item);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('تعديل'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('حذف'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _RuleDraft {
  final String name;
  final int minHours;
  final int? maxHours;
  final double percentage;
  final int priority;
  final bool active;
  const _RuleDraft({
    required this.name,
    required this.minHours,
    required this.maxHours,
    required this.percentage,
    required this.priority,
    required this.active,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'minHours': minHours,
    'maxHours': maxHours,
    'percentage': percentage,
    'priority': priority,
    'active': active,
  };
}

class _RuleEditor extends StatefulWidget {
  final Map<String, dynamic>? item;
  const _RuleEditor({this.item});

  @override
  State<_RuleEditor> createState() => _RuleEditorState();
}

class _RuleEditorState extends State<_RuleEditor> {
  late final TextEditingController _name;
  late final TextEditingController _min;
  late final TextEditingController _max;
  late final TextEditingController _percentage;
  late final TextEditingController _priority;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?['name']?.toString() ?? '');
    _min = TextEditingController(
      text: widget.item?['minHours']?.toString() ?? '1',
    );
    _max = TextEditingController(
      text: widget.item?['maxHours']?.toString() ?? '',
    );
    _percentage = TextEditingController(
      text: widget.item?['percentage']?.toString() ?? '5',
    );
    _priority = TextEditingController(
      text: widget.item?['priority']?.toString() ?? '100',
    );
    _active = widget.item?['active'] != false;
  }

  @override
  void dispose() {
    _name.dispose();
    _min.dispose();
    _max.dispose();
    _percentage.dispose();
    _priority.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _EditorShell(
    title: widget.item == null ? 'قاعدة خصم جديدة' : 'تعديل قاعدة الخصم',
    children: [
      TextField(
        controller: _name,
        decoration: const InputDecoration(labelText: 'اسم القاعدة'),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _min,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'من ساعة'),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: _max,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'حتى ساعة (اختياري)',
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _percentage,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'الخصم %'),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: _priority,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'الأولوية'),
            ),
          ),
        ],
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: _active,
        onChanged: (value) => setState(() => _active = value),
        title: const Text('القاعدة فعالة'),
      ),
      const SizedBox(height: 14),
      ElevatedButton(
        onPressed: () {
          final min = int.tryParse(_min.text.trim());
          final max = _max.text.trim().isEmpty
              ? null
              : int.tryParse(_max.text.trim());
          final pct = double.tryParse(_percentage.text.trim());
          final priority = int.tryParse(_priority.text.trim());
          if (_name.text.trim().isEmpty ||
              min == null ||
              pct == null ||
              priority == null)
            return;
          Navigator.pop(
            context,
            _RuleDraft(
              name: _name.text.trim(),
              minHours: min,
              maxHours: max,
              percentage: pct,
              priority: priority,
              active: _active,
            ),
          );
        },
        child: const Text('حفظ'),
      ),
    ],
  );
}

// ============================================================================
// SHARED SYSTEM UI
// ============================================================================

class _AdminCollectionScaffold<T> extends StatelessWidget {
  final String title;
  final Future<List<T>> future;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final Widget hero;
  final String emptyTitle;
  final String addLabel;
  final VoidCallback onAdd;
  final Widget Function(T item) itemBuilder;

  const _AdminCollectionScaffold({
    required this.title,
    required this.future,
    required this.onRefresh,
    required this.onRetry,
    required this.hero,
    required this.emptyTitle,
    required this.addLabel,
    required this.onAdd,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: Text(addLabel),
      ),
      body: FutureBuilder<List<T>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ApiErrorView(error: snapshot.error!, retry: onRetry);
          }
          final rows = snapshot.data!;
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
              children: [
                hero,
                const SizedBox(height: 18),
                if (rows.isEmpty)
                  ManaraEmptyState(
                    icon: Icons.inbox_outlined,
                    title: emptyTitle,
                    message: 'ابدأ بإضافة أول سجل من الزر بالأسفل.',
                  )
                else
                  ...rows.map(itemBuilder),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _SystemHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final String metric;
  final String metricLabel;
  final IconData icon;

  const _SystemHero({
    required this.title,
    required this.subtitle,
    required this.metric,
    required this.metricLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.darkTeal,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .70),
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 74,
          height: 82,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.gold, size: 23),
              const SizedBox(height: 5),
              Text(
                metric,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              Text(
                metricLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .60),
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MiniInfo extends StatelessWidget {
  final String value;
  final String label;
  final Color tone;
  const _MiniInfo({
    required this.value,
    required this.label,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: tone,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 10.5, color: AppTheme.muted),
          ),
        ),
      ],
    ),
  );
}

class _ReferenceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String countLabel;
  final bool active;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReferenceCard({
    required this.title,
    required this.subtitle,
    required this.countLabel,
    required this.active,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F2ED),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppTheme.teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  ManaraStatusChip(
                    label: active ? 'فعال' : 'مخفي',
                    color: active ? AppTheme.teal : AppTheme.muted,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  height: 1.4,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                countLabel,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.teal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('تعديل')),
            PopupMenuItem(value: 'delete', child: Text('حذف')),
          ],
        ),
      ],
    ),
  );
}

class _EditorShell extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _EditorShell({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    ),
  );
}

Future<bool> _confirm(
  BuildContext context,
  String title,
  String message,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('رجوع'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ) ??
      false;
}
