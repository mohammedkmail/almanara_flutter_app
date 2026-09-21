import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../models/library_book.dart';
import '../services/auth_service.dart';
import '../services/library_service.dart';
import '../services/notification_inbox_service.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import '../widgets/manara_components.dart';
import 'api_reservations_screen.dart';
import 'book_details_screen.dart';
import 'books_screen.dart';
import 'membership_screen.dart';
import 'my_library_screen.dart';
import 'notifications_screen.dart';
import 'study_rooms_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _reload();
    _loadUnreadNotifications();
  }

  void _reload() => _future = _fetch();

  Future<void> _loadUnreadNotifications() async {
    try {
      final inbox =
      await NotificationInboxService.instance.getNotifications(
        max: 1,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _unreadNotifications = inbox.unreadCount;
      });
    } catch (_) {
      // لا نخلي فشل الإشعارات يمنع الصفحة الرئيسية من العمل.
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadUnreadNotifications();
  }

  Future<_HomeData> _fetch() async {
    final results = await Future.wait([
      LibraryService.instance.dashboard(),
      LibraryService.instance.books(),
      LibraryService.instance.categories(),
      LibraryService.instance.borrowings(),
      LibraryService.instance.digitalAccess(),
      LibraryService.instance.holidays(limit: 3),
    ]);

    return _HomeData(
      dashboard: results[0] as DashboardSummary,
      books: results[1] as List<LibraryBook>,
      categories: results[2] as List<CategoryItem>,
      borrowings: results[3] as List<BorrowingItem>,
      digital: results[4] as List<DigitalAccessItem>,
      holidays: results[5] as List<Map<String, dynamic>>,
    );
  }

  Future<void> _refresh() async {
    setState(_reload);

    await Future.wait([
      _future,
      _loadUnreadNotifications(),
    ]);
  }

  void _push(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user.value;

    final firstName =
    (user?.fullName.trim().isNotEmpty ?? false)
        ? user!.fullName.trim().split(' ').first
        : 'قارئ';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFE4E9E7),
        body: FutureBuilder<_HomeData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ApiErrorView(
                error: snapshot.error!,
                retry: () => setState(_reload),
              );
            }

            final data = snapshot.data!;

            final membership =
            data.dashboard.map('membership');

            BorrowingItem? activeBorrowing;

            for (final item in data.borrowings) {
              if (item.open) {
                activeBorrowing = item;
                break;
              }
            }

            final featured = data.books
                .where((book) => book.active)
                .take(8)
                .toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // HERO
                  SliverToBoxAdapter(
                    child: _Hero(
                      firstName: firstName,
                      unreadNotifications:
                      _unreadNotifications,
                      onNotifications: _openNotifications,
                      onSearch: () {
                        _push(const BooksScreen());
                      },
                    ),
                  ),

                  // DASHBOARD METRICS
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      2,
                      18,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        childAspectRatio: .78,
                        children: [
                          _DashboardMetric(
                            value:
                            '${data.dashboard.count('activeBorrowings')}',
                            label: 'استعاراتي',
                            icon:
                            Icons.import_contacts_outlined,
                            tone: AppTheme.teal,
                          ),
                          _DashboardMetric(
                            value:
                            '${data.dashboard.count('activeReservations')}',
                            label: 'حجوزاتي',
                            icon:
                            Icons.bookmark_outline,
                            tone:
                            const Color(0xFF8E6A31),
                          ),
                          _DashboardMetric(
                            value:
                            '${data.dashboard.count('upcomingRoomReservations')}',
                            label: 'الغرف',
                            icon:
                            Icons.meeting_room_outlined,
                            tone:
                            const Color(0xFF416D80),
                          ),
                          _DashboardMetric(
                            value:
                            '${data.dashboard.count('digitalAccess')}',
                            label: 'رقمية',
                            icon:
                            Icons.tablet_mac_outlined,
                            tone:
                            const Color(0xFF865A6B),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // WHAT DO YOU WANT TO DO?
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      25,
                      18,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'ماذا تريد أن تفعل؟',
                        subtitle:
                        'كل ما تحتاجه في المنارة من مكان واحد',
                        onTap: null,
                      ),
                    ),
                  ),

                  // COLORED SERVICES
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      13,
                      18,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _ServiceRow(
                            title: 'اكتشف الكتب',
                            subtitle:
                            'تصفح الكتب وابحث بالعنوان أو المؤلف أو ISBN',
                            icon:
                            Icons.menu_book_rounded,
                            tone: AppTheme.teal,
                            onTap: () {
                              _push(const BooksScreen());
                            },
                          ),

                          const SizedBox(height: 9),

                          _ServiceRow(
                            title: 'احجز غرفة دراسة',
                            subtitle:
                            'اختر الغرفة والوقت المناسب لك',
                            icon:
                            Icons.meeting_room_rounded,
                            tone:
                            const Color(0xFF416D80),
                            onTap: () {
                              _push(
                                const StudyRoomsScreen(),
                              );
                            },
                          ),

                          const SizedBox(height: 9),

                          _ServiceRow(
                            title: 'مكتبتي',
                            subtitle:
                            'استعاراتك وحجوزاتك وكتبك الرقمية',
                            icon:
                            Icons.collections_bookmark_rounded,
                            tone:
                            const Color(0xFF7A5D3A),
                            onTap: () {
                              _push(
                                const MyLibraryScreen(),
                              );
                            },
                          ),

                          const SizedBox(height: 9),

                          _ServiceRow(
                            title: membership == null
                                ? 'انضم للعضوية'
                                : 'عضويتي',
                            subtitle: membership == null
                                ? 'مزايا أكثر واستعارات أسهل'
                                : 'عضويتك فعالة — استفد من مزاياها',
                            icon:
                            Icons.workspace_premium_rounded,
                            tone:
                            const Color(0xFF9C7835),
                            onTap: () {
                              _push(
                                const MembershipScreen(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // LAST BORROWING
                  if (activeBorrowing != null)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        25,
                        18,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _ContinueCard(
                          borrowing: activeBorrowing,
                          onTap: () {
                            _push(
                              const ApiReservationsScreen(),
                            );
                          },
                        ),
                      ),
                    ),

                  // FEATURED BOOKS
                  if (featured.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        30,
                        18,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 28,
                              decoration:
                              BoxDecoration(
                                color:
                                AppTheme.gold,
                                borderRadius:
                                BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'على الرف الآن',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight:
                                FontWeight.w900,
                                color:
                                AppTheme.darkTeal,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 1.5,
                                color:
                                AppTheme.gold
                                    .withValues(
                                  alpha: .30,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _push(
                                  const BooksScreen(),
                                );
                              },
                              child: const Text(
                                'عرض الكل',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w800,
                                  color:
                                  AppTheme.teal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 255,
                        child: ListView.separated(
                          padding:
                          const EdgeInsets.fromLTRB(
                            18,
                            12,
                            18,
                            0,
                          ),
                          scrollDirection:
                          Axis.horizontal,
                          itemCount:
                          featured.length,
                          separatorBuilder:
                              (_, __) =>
                          const SizedBox(
                            width: 14,
                          ),
                          itemBuilder: (_, index) {
                            final book =
                            featured[index];

                            return _BookFeature(
                              book: book,
                              onTap: () {
                                _push(
                                  BookDetailsScreen(
                                    book: book,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // MEMBERSHIP
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      28,
                      18,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _MembershipStrip(
                        active:
                        membership != null,
                        onTap: () {
                          _push(
                            const MembershipScreen(),
                          );
                        },
                      ),
                    ),
                  ),

                  // HOLIDAYS
                  if (data.holidays.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        24,
                        18,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _HolidayCalendar(
                          holidays:
                          data.holidays,
                          holidayDate:
                          _holidayDate,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 28),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _holidayDate(dynamic value) {
    final millis = asInt(value);

    if (millis == null) {
      return value?.toString() ?? '';
    }

    return formatDate(
      DateTime.fromMillisecondsSinceEpoch(
        millis,
      ),
    );
  }
}

// HOME DATA
class _HomeData {
  final DashboardSummary dashboard;
  final List<LibraryBook> books;
  final List<CategoryItem> categories;
  final List<BorrowingItem> borrowings;
  final List<DigitalAccessItem> digital;
  final List<Map<String, dynamic>> holidays;

  const _HomeData({
    required this.dashboard,
    required this.books,
    required this.categories,
    required this.borrowings,
    required this.digital,
    required this.holidays,
  });
}

// HERO
class _Hero extends StatelessWidget {
  final String firstName;
  final int unreadNotifications;
  final VoidCallback onNotifications;
  final VoidCallback onSearch;

  const _Hero({
    required this.firstName,
    required this.unreadNotifications,
    required this.onNotifications,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home_hero_img.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    AppTheme.darkTeal.withValues(
                      alpha: .94,
                    ),
                    AppTheme.darkTeal.withValues(
                      alpha: .72,
                    ),
                    AppTheme.darkTeal.withValues(
                      alpha: .30,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding:
              const EdgeInsets.fromLTRB(
                22,
                22,
                22,
                24,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, 6),
                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons
                                  .auto_awesome_rounded,
                              color:
                              AppTheme.gold,
                              size: 15,
                            ),
                            const SizedBox(
                                width: 6),
                            const Text(
                              'المنارة',
                              style:
                              TextStyle(
                                color:
                                Colors.white,
                                fontSize: 28,
                                fontWeight:
                                FontWeight.w900,
                                letterSpacing: .7,
                                shadows: [
                                  Shadow(
                                    color:
                                    Colors.black54,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                width: 6),
                            const Icon(
                              Icons
                                  .auto_awesome_rounded,
                              color:
                              AppTheme.gold,
                              size: 15,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      Material(
                        color: Colors.black
                            .withValues(
                          alpha: .20,
                        ),
                        shape:
                        const CircleBorder(),
                        child: InkWell(
                          onTap:
                          onNotifications,
                          customBorder:
                          const CircleBorder(),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Stack(
                              clipBehavior:
                              Clip.none,
                              children: [
                                const Center(
                                  child: Icon(
                                    Icons
                                        .notifications_none_rounded,
                                    color:
                                    Colors.white,
                                    size: 28,
                                  ),
                                ),

                                if (unreadNotifications >
                                    0)
                                  Positioned(
                                    top: -3,
                                    left: -3,
                                    child:
                                    Container(
                                      constraints:
                                      const BoxConstraints(
                                        minWidth:
                                        19,
                                        minHeight:
                                        19,
                                      ),
                                      padding:
                                      const EdgeInsets
                                          .symmetric(
                                        horizontal:
                                        5,
                                      ),
                                      decoration:
                                      BoxDecoration(
                                        color:
                                        AppTheme
                                            .gold,
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          999,
                                        ),
                                        border:
                                        Border.all(
                                          color:
                                          Colors
                                              .white,
                                          width:
                                          1.5,
                                        ),
                                      ),
                                      alignment:
                                      Alignment
                                          .center,
                                      child: Text(
                                        unreadNotifications >
                                            99
                                            ? '99+'
                                            : '$unreadNotifications',
                                        style:
                                        const TextStyle(
                                          color:
                                          AppTheme
                                              .darkTeal,
                                          fontSize:
                                          9,
                                          fontWeight:
                                          FontWeight
                                              .w900,
                                          height:
                                          1,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    'أهلاً $firstName',
                    style:
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight:
                      FontWeight.w900,
                      shadows: [
                        Shadow(
                          color:
                          Colors.black54,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'كتاب، غرفة هادئة، أو قراءة رقمية — ابدأ من مكان واحد.',
                    style: TextStyle(
                      color: Colors.white
                          .withValues(
                        alpha: .94,
                      ),
                      fontSize: 17,
                      height: 1.5,
                      shadows: const [
                        Shadow(
                          color:
                          Colors.black54,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Material(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),
                    child: InkWell(
                      onTap: onSearch,
                      borderRadius:
                      BorderRadius.circular(
                        15,
                      ),
                      child: const SizedBox(
                        height: 62,
                        child: Row(
                          children: [
                            SizedBox(width: 17),
                            Icon(
                              Icons
                                  .search_rounded,
                              color:
                              AppTheme.teal,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'ابحث بالعنوان، المؤلف، القسم أو ISBN',
                                style:
                                TextStyle(
                                  color:
                                  Color(
                                    0xFF596865,
                                  ),
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsets.only(
                                left: 16,
                              ),
                              child: Icon(
                                Icons
                                    .arrow_back_rounded,
                                color:
                                AppTheme
                                    .gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// DASHBOARD METRIC
class _DashboardMetric
    extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color tone;

  const _DashboardMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color:
          tone.withValues(alpha: .12),
        ),
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 8,
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration:
            BoxDecoration(
              color:
              tone.withValues(
                alpha: .10,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: tone,
              size: 19,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.w900,
              color: tone,
              height: 1,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            textAlign:
            TextAlign.center,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w800,
              color:
              Color(0xFF4F5F5B),
            ),
          ),
        ],
      ),
    );
  }
}

// SECTION HEADER
class _SectionHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Container(
          width: 5,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.gold,
            borderRadius:
            BorderRadius.circular(
              10,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                const TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w900,
                  color:
                  AppTheme.darkTeal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style:
                const TextStyle(
                  fontSize: 11.5,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Color(0xFF596865),
                ),
              ),
            ],
          ),
        ),

        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text(
              'عرض الكل',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight:
                FontWeight.w800,
                color:
                AppTheme.teal,
              ),
            ),
          ),
      ],
    );
  }
}

// COLORED SERVICE ROW
class _ServiceRow
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tone;
  final VoidCallback onTap;

  const _ServiceRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tone.withValues(
        alpha: .12,
      ),
      borderRadius:
      BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Container(
          height: 78,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color:
              tone.withValues(
                alpha: .22,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration:
                BoxDecoration(
                  color:
                  tone.withValues(
                    alpha: .18,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
                child: Icon(
                  icon,
                  color: tone,
                  size: 26,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      title,
                      style:
                      const TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w900,
                        color:
                        AppTheme.darkTeal,
                      ),
                    ),
                    const SizedBox(
                        height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        Color(
                          0xFF596865,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 32,
                height: 32,
                decoration:
                BoxDecoration(
                  color:
                  Colors.white
                      .withValues(
                    alpha: .65,
                  ),
                  shape:
                  BoxShape.circle,
                ),
                child: Icon(
                  Icons
                      .arrow_back_rounded,
                  color: tone,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// LAST BORROWING CARD
class _ContinueCard
    extends StatelessWidget {
  final BorrowingItem borrowing;
  final VoidCallback onTap;

  const _ContinueCard({
    required this.borrowing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        borrowing.status == 'OVERDUE';

    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(22),
        child: Container(
          padding:
          const EdgeInsets.all(14),
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              22,
            ),
            border: Border.all(
              color: isOverdue
                  ? const Color(
                0xFFD98B78,
              ).withValues(
                alpha: .35,
              )
                  : AppTheme.teal
                  .withValues(
                alpha: .14,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black
                    .withValues(
                  alpha: .045,
                ),
                blurRadius: 14,
                offset:
                const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration:
                    BoxDecoration(
                      color: isOverdue
                          ? const Color(
                        0xFFF8E8E3,
                      )
                          : const Color(
                        0xFFE7F0EE,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        11,
                      ),
                    ),
                    child: Icon(
                      isOverdue
                          ? Icons
                          .priority_high_rounded
                          : Icons
                          .auto_stories_rounded,
                      color: isOverdue
                          ? const Color(
                        0xFFB85D49,
                      )
                          : AppTheme
                          .teal,
                      size: 21,
                    ),
                  ),

                  const SizedBox(
                      width: 10),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          'آخر استعارة',
                          style:
                          TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight
                                .w900,
                            color:
                            AppTheme
                                .darkTeal,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'الكتاب الموجود معك حاليًا',
                          style:
                          TextStyle(
                            fontSize: 11.5,
                            color:
                            Color(
                              0xFF596865,
                            ),
                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration:
                    BoxDecoration(
                      color: isOverdue
                          ? const Color(
                        0xFFF8E8E3,
                      )
                          : const Color(
                        0xFFE8F1ED,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        10,
                      ),
                    ),
                    child: Text(
                      isOverdue
                          ? 'متأخر'
                          : 'مستعار',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                        FontWeight
                            .w900,
                        color: isOverdue
                            ? const Color(
                          0xFFB85D49,
                        )
                            : AppTheme
                            .teal,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 14),

              Row(
                children: [
                  ManaraImage(
                    url: borrowing
                        .bookCoverUrl,
                    width: 76,
                    height: 96,
                    borderRadius:
                    BorderRadius
                        .circular(
                      13,
                    ),
                  ),

                  const SizedBox(
                      width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          borrowing
                              .bookTitle,
                          maxLines: 2,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            color:
                            AppTheme
                                .darkTeal,
                            fontSize: 16,
                            height: 1.3,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),

                        const SizedBox(
                            height: 9),

                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xFFF3F6F4,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              11,
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                            MainAxisSize
                                .min,
                            children: [
                              Icon(
                                Icons
                                    .event_outlined,
                                size: 17,
                                color: isOverdue
                                    ? const Color(
                                  0xFFB85D49,
                                )
                                    : AppTheme
                                    .teal,
                              ),
                              const SizedBox(
                                  width: 7),
                              Text(
                                'الإرجاع: ${formatDate(borrowing.dueDate)}',
                                style:
                                TextStyle(
                                  fontSize:
                                  11.5,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                  color: isOverdue
                                      ? const Color(
                                    0xFF9D4F3D,
                                  )
                                      : const Color(
                                    0xFF405651,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 13),

              Container(
                height: 43,
                decoration:
                BoxDecoration(
                  color:
                  AppTheme.darkTeal,
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: const [
                    Text(
                      'عرض تفاصيل الاستعارة',
                      style:
                      TextStyle(
                        color:
                        Colors.white,
                        fontSize: 12.5,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons
                          .arrow_back_rounded,
                      color:
                      AppTheme.gold,
                      size: 19,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FEATURED BOOK
class _BookFeature
    extends StatelessWidget {
  final LibraryBook book;
  final VoidCallback onTap;

  const _BookFeature({
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 175,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: ManaraImage(
          url: book.coverUrl,
          width: 175,
          height: 240,
          borderRadius:
          BorderRadius.circular(18),
        ),
      ),
    );
  }
}

// HOLIDAY CALENDAR
class _HolidayCalendar
    extends StatelessWidget {
  final List<Map<String, dynamic>> holidays;
  final String Function(dynamic)
  holidayDate;

  const _HolidayCalendar({
    required this.holidays,
    required this.holidayDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.teal
              .withValues(alpha: .12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: .05),
            blurRadius: 12,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                13,
                16,
                13,
              ),
              color:
              AppTheme.darkTeal,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration:
                    BoxDecoration(
                      color: AppTheme.gold
                          .withValues(
                        alpha: .95,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        12,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .calendar_month_rounded,
                      color:
                      AppTheme.darkTeal,
                      size: 24,
                    ),
                  ),

                  const SizedBox(
                      width: 11),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          'مواعيد المكتبة',
                          style:
                          TextStyle(
                            color:
                            Colors.white,
                            fontSize: 16,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'العطل والإغلاقات القادمة',
                          style:
                          TextStyle(
                            color:
                            Color(
                              0xB3FFFFFF,
                            ),
                            fontSize: 11.5,
                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons
                        .event_available_rounded,
                    color:
                    Colors.white70,
                    size: 22,
                  ),
                ],
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.all(
                12,
              ),
              child: Column(
                children: [
                  for (int i = 0;
                  i < holidays.length;
                  i++) ...[
                    _HolidayCalendarRow(
                      holiday:
                      holidays[i],
                      dateText:
                      holidayDate(
                        holidays[i]
                        ['date'],
                      ),
                    ),
                    if (i !=
                        holidays.length -
                            1)
                      const SizedBox(
                          height: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// HOLIDAY ROW
class _HolidayCalendarRow
    extends StatelessWidget {
  final Map<String, dynamic>
  holiday;
  final String dateText;

  const _HolidayCalendarRow({
    required this.holiday,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration:
      BoxDecoration(
        color:
        const Color(0xFFF3F6F4),
        borderRadius:
        BorderRadius.circular(
          13,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: double.infinity,
            decoration:
            const BoxDecoration(
              color:
              AppTheme.gold,
              borderRadius:
              BorderRadius.horizontal(
                right:
                Radius.circular(
                  13,
                ),
              ),
            ),
          ),

          const SizedBox(
              width: 10),

          Container(
            width: 36,
            height: 36,
            decoration:
            BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              border: Border.all(
                color: AppTheme.teal
                    .withValues(
                  alpha: .12,
                ),
              ),
            ),
            child: const Icon(
              Icons.event_outlined,
              color:
              AppTheme.teal,
              size: 19,
            ),
          ),

          const SizedBox(
              width: 10),

          Expanded(
            child: Text(
              (holiday['name'] ??
                  'موعد')
                  .toString(),
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                fontSize: 13.5,
                fontWeight:
                FontWeight.w800,
                color:
                AppTheme.darkTeal,
              ),
            ),
          ),

          Container(
            margin:
            const EdgeInsets.only(
              left: 9,
            ),
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration:
            BoxDecoration(
              color: AppTheme.darkTeal
                  .withValues(
                alpha: .08,
              ),
              borderRadius:
              BorderRadius.circular(
                9,
              ),
            ),
            child: Text(
              dateText,
              style:
              const TextStyle(
                fontSize: 11,
                fontWeight:
                FontWeight.w800,
                color:
                AppTheme.darkTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MEMBERSHIP STRIP
class _MembershipStrip
    extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _MembershipStrip({
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
      const Color(0xFFF0E5CD),
      borderRadius:
      BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(22),
        child: Container(
          padding:
          const EdgeInsets.all(18),
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              22,
            ),
            border: Border.all(
              color: AppTheme.gold
                  .withValues(
                alpha: .35,
              ),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -18,
                bottom: -28,
                child: Icon(
                  Icons
                      .auto_awesome_rounded,
                  size: 105,
                  color: AppTheme.gold
                      .withValues(
                    alpha: .10,
                  ),
                ),
              ),

              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration:
                    const BoxDecoration(
                      color:
                      Color(0xFFE1BF79),
                      shape:
                      BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons
                          .workspace_premium_rounded,
                      color:
                      AppTheme.darkTeal,
                      size: 30,
                    ),
                  ),

                  const SizedBox(
                      width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          active
                              ? 'عضويتك تعمل لصالحك'
                              : 'اشترك واقرأ أكثر',
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight
                                .w900,
                            fontSize: 17,
                            color:
                            AppTheme
                                .darkTeal,
                          ),
                        ),

                        const SizedBox(
                            height: 5),

                        Text(
                          active
                              ? 'استعر كتبك الورقية بدون رسوم أثناء العضوية.'
                              : 'مزايا أكثر، استعارات أسهل، وتجربة قراءة أوسع.',
                          maxLines: 2,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            fontWeight:
                            FontWeight
                                .w600,
                            color:
                            Color(
                              0xFF4F5F5B,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      width: 8),

                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration:
                    BoxDecoration(
                      color: AppTheme
                          .darkTeal,
                      borderRadius:
                      BorderRadius
                          .circular(
                        12,
                      ),
                    ),
                    child: Text(
                      active
                          ? 'التفاصيل'
                          : 'اشترك',
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize: 11.5,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}