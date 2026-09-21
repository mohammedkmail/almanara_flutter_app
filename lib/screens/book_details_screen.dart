
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/api_models.dart';
import '../models/library_book.dart';
import '../services/library_service.dart';
import '../services/payment_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import '../widgets/manara_components.dart';
import 'author_details_screen.dart';
import 'digital_reader_screen.dart';

class BookDetailsScreen extends StatefulWidget {
final LibraryBook book;

const BookDetailsScreen({super.key, required this.book});

@override
State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
Future<LibraryBook>? _fresh;
bool _busy = false;

@override
void initState() {
super.initState();

if (widget.book.id != null) {
_fresh = LibraryService.instance.book(widget.book.id!);
}
}

void _snack(String message) {
if (!mounted) return;

ScaffoldMessenger.of(
context,
).showSnackBar(
SnackBar(
content: Text(
message,
style: const TextStyle(fontSize: 14),
),
),
);
}

Future<void> _run(Future<void> Function() action) async {
if (_busy) return;

setState(() => _busy = true);

try {
await action();
} catch (error) {
_snack(apiErrorMessage(error));
} finally {
if (mounted) {
setState(() => _busy = false);
}
}
}

Future<void> _refreshBook() async {
if (widget.book.id == null) return;

setState(() {
_fresh = LibraryService.instance.book(widget.book.id!);
});

await _fresh;
}

Future<void> _reserve(LibraryBook book) async {
if (book.id == null) return;

final fulfillment = await _chooseReservationFulfillment(book);

if (fulfillment == null || !mounted) {
return;
}

await _run(() async {
final reservation = await LibraryService.instance.reserve(
ReservationRequest(book.id!),
);

if (!mounted) return;

if (!reservation.readyForCustomer) {
_snack(
'تم الحجز. حالتك الآن: ${reservation.statusLabel}',
);

await _refreshBook();
return;
}

final result =
await LibraryService.instance.reservationCheckout(
reservation.id,
fulfillmentMethod: fulfillment.method,
deliveryAddress: fulfillment.deliveryAddress,
);

if (!mounted) return;

final url = result['paymentUrl']?.toString() ?? '';

if (url.isNotEmpty) {
await openPaymentUrl(url);

if (!mounted) return;

_snack(
'أكمل الدفع في الصفحة المفتوحة، ثم ارجع إلى مكتبتك.',
);
} else {
_snack(
'تم تأكيد الحجز بدون رسوم استعارة.',
);
}

await _refreshBook();
});
}

Future<({String method, String? deliveryAddress})?>
_chooseReservationFulfillment(
LibraryBook book,
) async {
String method = 'PICKUP';

final address = TextEditingController();

final confirmed =
await showModalBottomSheet<bool>(
context: context,
isScrollControlled: true,
showDragHandle: true,
builder: (sheetContext) => StatefulBuilder(
builder: (context, setSheetState) {
final bottom =
MediaQuery.viewInsetsOf(context).bottom;

return Padding(
padding: EdgeInsets.fromLTRB(
20,
8,
20,
20 + bottom,
),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const ManaraSectionTitle(
title: 'أكد طريقة الاستلام',
subtitle:
'راجع طريقة الاستلام والسعر قبل تأكيد الحجز.',
),
const SizedBox(height: 18),
SegmentedButton<String>(
segments: const [
ButtonSegment(
value: 'PICKUP',
label: Text(
'استلام من المكتبة',
style: TextStyle(fontSize: 13),
),
icon: Icon(
Icons.storefront_outlined,
),
),
ButtonSegment(
value: 'DELIVERY',
label: Text(
'توصيل',
style: TextStyle(fontSize: 13),
),
icon: Icon(
Icons.local_shipping_outlined,
),
),
],
selected: {method},
onSelectionChanged: (value) {
setSheetState(() {
method = value.first;
});
},
),
if (method == 'DELIVERY') ...[
const SizedBox(height: 14),
TextField(
controller: address,
maxLines: 2,
decoration: const InputDecoration(
labelText: 'عنوان التوصيل',
prefixIcon: Icon(
Icons.location_on_outlined,
),
),
),
],
const SizedBox(height: 18),
_PriceNotice(book: book),
const SizedBox(height: 18),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
if (method == 'DELIVERY' &&
address.text.trim().isEmpty) {
ScaffoldMessenger.of(
context,
).showSnackBar(
const SnackBar(
content: Text(
'أدخل عنوان التوصيل أولاً.',
style: TextStyle(
fontSize: 14,
),
),
),
);

return;
}

Navigator.pop(
sheetContext,
true,
);
},
child: const Text(
'تأكيد الحجز',
style: TextStyle(fontSize: 14),
),
),
),
],
),
);
},
),
);

final deliveryAddress =
method == 'DELIVERY'
? address.text.trim()
    : null;

address.dispose();

if (confirmed != true) {
return null;
}

return (
method: method,
deliveryAddress: deliveryAddress,
);
}

Future<void> _buyPhysical(
LibraryBook book,
) async {
if (book.id == null) return;

int quantity = 1;
String method = 'PICKUP';

final address = TextEditingController();

final confirmed =
await showModalBottomSheet<bool>(
context: context,
isScrollControlled: true,
showDragHandle: true,
builder: (sheetContext) => StatefulBuilder(
builder: (context, setSheetState) {
final bottom =
MediaQuery.viewInsetsOf(context).bottom;

return Padding(
padding: EdgeInsets.fromLTRB(
20,
8,
20,
20 + bottom,
),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'شراء نسخة ورقية',
style: TextStyle(
fontSize: 21,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 16),
Row(
children: [
const Expanded(
child: Text(
'الكمية',
style: TextStyle(
fontSize: 14,
),
),
),
IconButton(
onPressed: quantity <= 1
? null
    : () =>
setSheetState(
() => quantity--,
),
icon: const Icon(
Icons.remove_circle_outline,
),
),
Text(
'$quantity',
style: const TextStyle(
fontWeight: FontWeight.w900,
fontSize: 15,
),
),
IconButton(
onPressed:
quantity >=
book.physicalSaleStock
? null
    : () =>
setSheetState(
() => quantity++,
),
icon: const Icon(
Icons.add_circle_outline,
),
),
],
),
const SizedBox(height: 10),
SegmentedButton<String>(
segments: const [
ButtonSegment(
value: 'PICKUP',
label: Text(
'استلام',
style: TextStyle(
fontSize: 13,
),
),
icon: Icon(
Icons.storefront_outlined,
),
),
ButtonSegment(
value: 'DELIVERY',
label: Text(
'توصيل',
style: TextStyle(
fontSize: 13,
),
),
icon: Icon(
Icons.local_shipping_outlined,
),
),
],
selected: {method},
onSelectionChanged: (value) =>
setSheetState(
() => method = value.first,
),
),
if (method == 'DELIVERY') ...[
const SizedBox(height: 14),
TextField(
controller: address,
maxLines: 2,
decoration:
const InputDecoration(
labelText: 'عنوان التوصيل',
),
),
],
const SizedBox(height: 16),
Text(
'الإجمالي: ${((book.physicalSalePrice ?? 0) * quantity).toStringAsFixed(2)} USD',
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.w900,
color: AppTheme.teal,
),
),
const SizedBox(height: 16),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
if (method == 'DELIVERY' &&
address.text.trim().isEmpty) {
_snack(
'أدخل عنوان التوصيل.',
);

return;
}

Navigator.pop(
sheetContext,
true,
);
},
child: const Text(
'الانتقال للدفع',
style: TextStyle(
fontSize: 14,
),
),
),
),
],
),
);
},
),
);

if (confirmed != true) {
address.dispose();
return;
}

await _run(() async {
final launch =
await LibraryService.instance
    .purchaseCheckout(
bookId: book.id!,
purchaseType: 'PHYSICAL',
quantity: quantity,
fulfillmentMethod: method,
deliveryAddress: method == 'DELIVERY'
? address.text.trim()
    : null,
);

await openPaymentUrl(
launch.paymentUrl,
);

_snack(
'أكمل الدفع ثم راجع قسم المشتريات في مكتبتك.',
);
});

address.dispose();
}

Future<void> _buyDigital(
LibraryBook book,
) async {
if (book.id == null) return;

await _run(() async {
final launch =
await LibraryService.instance
    .purchaseCheckout(
bookId: book.id!,
purchaseType: 'DIGITAL',
);

await openPaymentUrl(
launch.paymentUrl,
);

_snack(
'بعد اكتمال الدفع سيظهر الكتاب في مكتبتك الرقمية.',
);
});
}

Future<void> _rentDigital(
LibraryBook book,
) async {
if (book.id == null) return;

final days =
await showModalBottomSheet<int>(
context: context,
showDragHandle: true,
builder: (context) => Padding(
padding: const EdgeInsets.fromLTRB(
20,
8,
20,
24,
),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'مدة الاستئجار الرقمي',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 12),
...[1, 3, 7, 14, 30].map(
(day) => ListTile(
contentPadding: EdgeInsets.zero,
title: Text(
'$day يوم',
style: const TextStyle(
fontSize: 14,
),
),
trailing: const Icon(
Icons.chevron_left_rounded,
),
onTap: () =>
Navigator.pop(
context,
day,
),
),
),
],
),
),
);

if (days == null) return;

await _run(() async {
final launch =
await LibraryService.instance.digitalRent(
bookId: book.id!,
days: days,
);

await openPaymentUrl(
launch.paymentUrl,
);

_snack(
'أكمل الدفع لتفعيل القراءة الرقمية.',
);
});
}

Future<void> _share(
LibraryBook book,
) async {
await SharePlus.instance.share(
ShareParams(
text: [
book.title,
if (book.author.isNotEmpty)
'المؤلف: ${book.author}',
if (book.isbn.isNotEmpty)
'ISBN: ${book.isbn}',
'متوفر في مكتبة المنارة',
].join('\n'),
),
);
}

@override
Widget build(BuildContext context) {
return Directionality(
textDirection: TextDirection.rtl,
child: Scaffold(
body: _fresh == null
? _content(widget.book)
    : FutureBuilder<LibraryBook>(
future: _fresh,
builder: (
context,
snapshot,
) {
if (snapshot.connectionState !=
ConnectionState.done) {
return _content(
widget.book,
loading: true,
);
}

if (snapshot.hasError) {
return ApiErrorView(
error: snapshot.error!,
retry: _refreshBook,
);
}

return _content(
snapshot.data!,
);
},
),
),
);
}

Widget _content(
LibraryBook book, {
bool loading = false,
}) {
final canBorrow =
book.available && book.id != null;

return CustomScrollView(
slivers: [
SliverAppBar(
pinned: true,
expandedHeight: 270,
backgroundColor:
const Color(0xFF123F3A),
foregroundColor: Colors.white,
iconTheme: const IconThemeData(
color: Colors.white,
size: 28,
),
titleTextStyle: const TextStyle(
color: Colors.white,
fontSize: 19,
fontWeight: FontWeight.w900,
),
actionsIconTheme:
const IconThemeData(
color: Colors.white,
size: 26,
),
title: const Text(
'تفاصيل الكتاب',
),
actions: [
IconButton(
tooltip: 'مشاركة',
onPressed: () => _share(book),
icon: const Icon(
Icons.ios_share_outlined,
color: Colors.white,
),
),
],
flexibleSpace:
FlexibleSpaceBar(
background: Container(
padding:
const EdgeInsets.fromLTRB(
22,
82,
22,
16,
),
decoration:
const BoxDecoration(
gradient:
LinearGradient(
begin:
Alignment.topRight,
end:
Alignment.bottomLeft,
colors: [
Color(0xFF123F3A),
Color(0xFF0A2C29),
],
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.end,
children: [
ManaraImage(
url: book.coverUrl,
width: 108,
height: 150,
borderRadius:
BorderRadius.circular(
14,
),
),
const SizedBox(
width: 16,
),
Expanded(
child: Padding(
padding:
const EdgeInsets.only(
bottom: 4,
),
child: Column(
mainAxisAlignment:
MainAxisAlignment.end,
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
if (book.category
    .isNotEmpty)
Text(
book.category,
style:
const TextStyle(
color:
AppTheme
    .gold,
fontWeight:
FontWeight
    .w800,
fontSize: 13,
),
),
const SizedBox(
height: 5,
),
Text(
book.title,
maxLines: 3,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
color:
Colors.white,
fontSize: 22,
height: 1.18,
fontWeight:
FontWeight
    .w900,
),
),
if (book.author
    .isNotEmpty) ...[
const SizedBox(
height: 6,
),
InkWell(
onTap:
book.authorId ==
null
? null
    : () =>
Navigator.push(
context,
MaterialPageRoute(
builder:
(_) =>
AuthorDetailsScreen(
authorId:
book.authorId!,
),
),
),
child: Text(
book.author,
style: TextStyle(
color: Colors
    .white
    .withValues(
alpha: .82,
),
fontWeight:
FontWeight
    .w600,
fontSize: 14,
),
),
),
],
],
),
),
),
],
),
),
),
),
SliverPadding(
padding:
const EdgeInsets.fromLTRB(
18,
20,
18,
40,
),
sliver: SliverList(
delegate:
SliverChildListDelegate([
if (loading)
const LinearProgressIndicator(
minHeight: 2,
),
Wrap(
spacing: 8,
runSpacing: 8,
children: [
ManaraStatusChip(
label: book.available
? '${book.availableCopies} نسخة متاحة'
    : 'غير متاح حالياً',
color: book.available
? AppTheme.teal
    : Colors.redAccent,
icon: book.available
? Icons
    .check_circle_outline
    : Icons
    .schedule_outlined,
),
if (book
    .digitalAvailable)
const ManaraStatusChip(
label: 'نسخة رقمية',
color:
Color(0xFF5964A7),
icon: Icons
    .tablet_android_outlined,
),
if (book
    .hasDigitalAccess)
const ManaraStatusChip(
label:
'لديك وصول رقمي',
color:
Color(0xFF6D4E8A),
icon: Icons
    .verified_outlined,
),
],
),
const SizedBox(
height: 18,
),
_BorrowPanel(
book: book,
),
const SizedBox(
height: 14,
),
if (book.hasDigitalAccess &&
book.id != null)
_PrimaryAction(
icon: Icons
    .chrome_reader_mode_outlined,
title:
'متابعة القراءة الرقمية',
subtitle:
'وصولك للنسخة الرقمية فعال الآن',
onTap: _busy
? null
    : () =>
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
DigitalReaderScreen(
bookId:
book.id!,
),
),
),
),
if (canBorrow)
_PrimaryAction(
icon: Icons
    .bookmark_add_outlined,
title: 'احجز للاستعارة',
subtitle:
book.borrowingIncluded
? '0.00 USD — الاستعارة مجانية لأن عضويتك فعالة'
    : '${book.userBorrowingFee.toStringAsFixed(2)} USD رسوم الاستعارة الحالية',
onTap: _busy
? null
    : () =>
_reserve(book),
),
if (!book.available)
const _InfoStrip(
icon: Icons
    .notifications_active_outlined,
text:
'لا توجد نسخة جاهزة الآن. عندما يصبح الكتاب متاحاً يمكنك حجزه من الفهرس.',
),
if (book.physicalSaleStock >
0 &&
book.physicalSalePrice !=
null)
_SecondaryAction(
icon: Icons
    .shopping_bag_outlined,
title:
'شراء نسخة ورقية',
subtitle:
'${book.physicalSalePrice!.toStringAsFixed(2)} USD • ${book.physicalSaleStock} في المخزون',
onTap: _busy
? null
    : () =>
_buyPhysical(
book,
),
),
if (book.digitalAvailable &&
!book.hasDigitalAccess &&
book.digitalPurchasePrice !=
null)
_SecondaryAction(
icon: Icons
    .auto_stories_outlined,
title:
'شراء النسخة الرقمية',
subtitle:
'${book.digitalPurchasePrice!.toStringAsFixed(2)} USD • وصول دائم حسب النظام',
onTap: _busy
? null
    : () =>
_buyDigital(
book,
),
),
if (book.digitalAvailable &&
!book.hasDigitalAccess &&
book.digitalRentalPrice !=
null)
_SecondaryAction(
icon: Icons
    .timelapse_outlined,
title:
'استئجار رقمي',
subtitle:
'من ${book.digitalRentalPrice!.toStringAsFixed(2)} USD حسب المدة',
onTap: _busy
? null
    : () =>
_rentDigital(
book,
),
),
if (book
    .membershipIncluded &&
!book.hasDigitalAccess)
const _InfoStrip(
icon: Icons
    .workspace_premium_outlined,
text:
'هذا الكتاب الرقمي مشمول بالعضوية. إذا كانت عضويتك فعالة سيظهر زر القراءة تلقائياً.',
),
if (_busy) ...[
const SizedBox(
height: 8,
),
const LinearProgressIndicator(),
],
if (book.description
    .trim()
    .isNotEmpty) ...[
const SizedBox(
height: 28,
),
const ManaraSectionTitle(
title: 'عن هذا الكتاب',
subtitle:
'نبذة من فهرس المكتبة',
),
const SizedBox(
height: 12,
),
Text(
book.description,
style:
const TextStyle(
fontSize: 14,
height: 1.75,
color:
AppTheme.muted,
),
),
],
const SizedBox(
height: 28,
),
const ManaraSectionTitle(
title: 'بيانات الفهرس',
subtitle:
'تفاصيل تساعدك قبل اختيار النسخة',
),
const SizedBox(
height: 12,
),
_MetadataGrid(
book: book,
),
]),
),
),
],
);
}
}

class _BorrowPanel
extends StatelessWidget {
final LibraryBook book;

const _BorrowPanel({
required this.book,
});

@override
Widget build(BuildContext context) {
final included =
book.borrowingIncluded;

return Container(
padding:
const EdgeInsets.all(17),
decoration: BoxDecoration(
color: included
? const Color(0xFFE8F3EE)
    : Colors.white,
borderRadius:
BorderRadius.circular(17),
border: Border.all(
color: included
? const Color(0xFFBCD9CF)
    : AppTheme.border,
),
),
child: Row(
children: [
Container(
width: 46,
height: 46,
decoration:
BoxDecoration(
color: included
? AppTheme.teal
    .withValues(
alpha: .10)
    : AppTheme.gold
    .withValues(
alpha: .13),
borderRadius:
BorderRadius.circular(
13,
),
),
child: Icon(
included
? Icons
    .card_membership_outlined
    : Icons
    .payments_outlined,
color: included
? AppTheme.teal
    : const Color(
0xFF8B682E,
),
size: 25,
),
),
const SizedBox(
width: 13,
),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
included
? 'الاستعارة مشمولة بعضويتك'
    : 'رسوم الاستعارة لهذا الحساب',
style:
const TextStyle(
fontWeight:
FontWeight.w900,
fontSize: 15,
),
),
const SizedBox(
height: 4,
),
Text(
included
? 'السيرفر حسبها 0.00 USD لأن عضويتك فعالة.'
    : '${book.userBorrowingFee.toStringAsFixed(2)} USD — يتم التحقق من السعر مرة أخرى عند التأكيد.',
style:
const TextStyle(
fontSize: 13,
height: 1.4,
color:
AppTheme.muted,
),
),
],
),
),
],
),
);
}
}

class _PriceNotice
extends StatelessWidget {
final LibraryBook book;

const _PriceNotice({
required this.book,
});

@override
Widget build(BuildContext context) {
return Container(
padding:
const EdgeInsets.all(14),
decoration: BoxDecoration(
color:
const Color(0xFFF3F5F0),
borderRadius:
BorderRadius.circular(14),
),
child: Row(
children: [
Icon(
book.borrowingIncluded
? Icons
    .verified_outlined
    : Icons
    .payments_outlined,
color: AppTheme.teal,
size: 24,
),
const SizedBox(
width: 10,
),
Expanded(
child: Text(
book.borrowingIncluded
? 'عضويتك فعالة: رسوم استعارة الكتاب 0.00 USD.'
    : 'رسوم الاستعارة الحالية ${book.userBorrowingFee.toStringAsFixed(2)} USD.',
style:
const TextStyle(
fontWeight:
FontWeight.w700,
fontSize: 13.5,
height: 1.4,
),
),
),
],
),
);
}
}

class _PrimaryAction
extends StatelessWidget {
final IconData icon;
final String title;
final String subtitle;
final VoidCallback? onTap;

const _PrimaryAction({
required this.icon,
required this.title,
required this.subtitle,
required this.onTap,
});

@override
Widget build(BuildContext context) {
return Padding(
padding:
const EdgeInsets.only(
bottom: 10,
),
child: Material(
color: AppTheme.darkTeal,
borderRadius:
BorderRadius.circular(16),
child: InkWell(
onTap: onTap,
borderRadius:
BorderRadius.circular(16),
child: Padding(
padding:
const EdgeInsets.all(16),
child: Row(
children: [
Icon(
icon,
color: Colors.white,
size: 27,
),
const SizedBox(
width: 13,
),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
title,
style:
const TextStyle(
color:
Colors.white,
fontWeight:
FontWeight
    .w900,
fontSize: 15,
),
),
const SizedBox(
height: 3,
),
Text(
subtitle,
style:
TextStyle(
color: Colors
    .white
    .withValues(
alpha: .72,
),
fontSize: 12,
height: 1.3,
),
),
],
),
),
const Icon(
Icons
    .arrow_back_rounded,
color:
AppTheme.gold,
size: 24,
),
],
),
),
),
),
);
}
}

class _SecondaryAction
extends StatelessWidget {
final IconData icon;
final String title;
final String subtitle;
final VoidCallback? onTap;

const _SecondaryAction({
required this.icon,
required this.title,
required this.subtitle,
required this.onTap,
});

@override
Widget build(BuildContext context) {
return Padding(
padding:
const EdgeInsets.only(
bottom: 9,
),
child: Card(
child: ListTile(
contentPadding:
const EdgeInsets.symmetric(
horizontal: 15,
vertical: 7,
),
onTap: onTap,
leading: Icon(
icon,
color: AppTheme.teal,
size: 25,
),
title: Text(
title,
style:
const TextStyle(
fontWeight:
FontWeight.w800,
fontSize: 15,
),
),
subtitle: Text(
subtitle,
style:
const TextStyle(
fontSize: 13,
height: 1.35,
),
),
trailing: const Icon(
Icons
    .chevron_left_rounded,
size: 25,
),
),
),
);
}
}

class _InfoStrip
extends StatelessWidget {
final IconData icon;
final String text;

const _InfoStrip({
required this.icon,
required this.text,
});

@override
Widget build(
BuildContext context,
) =>
Container(
margin:
const EdgeInsets.only(
bottom: 10,
),
padding:
const EdgeInsets.all(16),
decoration: BoxDecoration(
color:
const Color(0xFFE8DFC9),
borderRadius:
BorderRadius.circular(16),
border: Border.all(
color:
const Color(0xFFC9B582),
width: 1.2,
),
),
child: Row(
children: [
Container(
width: 44,
height: 44,
decoration:
BoxDecoration(
color:
const Color(
0xFFD6C69F,
),
borderRadius:
BorderRadius.circular(
13,
),
),
child: Icon(
icon,
color:
const Color(
0xFF70521D,
),
size: 25,
),
),
const SizedBox(
width: 12,
),
Expanded(
child: Text(
text,
style:
const TextStyle(
fontSize: 13.5,
height: 1.5,
fontWeight:
FontWeight.w600,
color:
Color(0xFF494333),
),
),
),
],
),
);
}

class _MetadataGrid
extends StatelessWidget {
final LibraryBook book;

const _MetadataGrid({
required this.book,
});

@override
Widget build(BuildContext context) {
final items =
<(String, String)>[
if (book.publisher
    ?.trim()
    .isNotEmpty ==
true)
(
'الناشر',
book.publisher!.trim(),
),
if (book.publishYear != null)
(
'سنة النشر',
'${book.publishYear}',
),
if (book.pageCount != null)
(
'عدد الصفحات',
'${book.pageCount}',
),
if (book.language
    ?.trim()
    .isNotEmpty ==
true)
(
'اللغة',
book.language!.trim(),
),
if (book.isbn.trim().isNotEmpty)
(
'ISBN',
book.isbn,
),
(
'إجمالي النسخ',
'${book.totalCopies}',
),
];

return LayoutBuilder(
builder:
(context, constraints) {
final width =
(constraints.maxWidth -
10) /
2;

return Wrap(
spacing: 10,
runSpacing: 10,
children: items
    .map(
(item) =>
Container(
width: width,
padding:
const EdgeInsets.all(
13,
),
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius
    .circular(
13,
),
border:
Border.all(
color:
AppTheme.border,
),
),
child:
Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
item.$1,
style:
const TextStyle(
fontSize: 12,
color:
AppTheme
    .muted,
),
),
const SizedBox(
height: 4,
),
Text(
item.$2,
maxLines: 2,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
fontWeight:
FontWeight
    .w800,
fontSize: 14,
),
),
],
),
),
)
    .toList(),
);
},
);
}
}

