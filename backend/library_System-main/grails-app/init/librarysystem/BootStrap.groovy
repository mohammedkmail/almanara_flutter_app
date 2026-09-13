package librarysystem

import grails.util.Environment

class BootStrap {

    def init = { servletContext ->

        // Demo seed data is intentionally disabled in production.
        if (Environment.current == Environment.PRODUCTION) {
            return
        }

        User.withTransaction {

            // =====================================================
            // ROLES
            // =====================================================

            Role adminRole = Role.findByAuthority('ROLE_ADMIN')

            if (!adminRole) {
                adminRole = new Role(
                    authority: 'ROLE_ADMIN'
                ).save(
                    flush: true,
                    failOnError: true
                )
            }

            Role userRole = Role.findByAuthority('ROLE_USER')

            if (!userRole) {
                userRole = new Role(
                    authority: 'ROLE_USER'
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // USERS
            // =====================================================

            User admin =
                User.findByUsername('mohammad@library.com')

            if (!admin) {
                admin = new User(
                    username: 'mohammad@library.com',
                    fullName: 'محمد - مدير المكتبة',
                    password: '123456',
                    enabled: true
                ).save(
                    flush: true,
                    failOnError: true
                )
            }

            if (!UserRole.exists(admin.id, adminRole.id)) {
                UserRole.create(
                    admin,
                    adminRole,
                    true
                )
            }


            User regularUser =
                User.findByUsername('ahmad@library.com')

            if (!regularUser) {
                regularUser = new User(
                    username: 'ahmad@library.com',
                    fullName: 'أحمد محمود',
                    password: '123456',
                    enabled: true
                ).save(
                    flush: true,
                    failOnError: true
                )
            }

            if (!UserRole.exists(regularUser.id, userRole.id)) {
                UserRole.create(
                    regularUser,
                    userRole,
                    true
                )
            }


            // =====================================================
            // CATEGORIES
            // =====================================================

            Category programming =
                (Category.findByName('Programming') ?: Category.findByName('البرمجة'))

            if (!programming) {
                programming = new Category(
                    name: 'البرمجة',
                    description: 'كتب البرمجة وتطوير البرمجيات وهندسة الأنظمة والممارسات المهنية.',
                    active: true
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            Category science =
                (Category.findByName('Science') ?: Category.findByName('العلوم'))

            if (!science) {
                science = new Category(
                    name: 'العلوم',
                    description: 'كتب العلوم والفيزياء والتقنية والاكتشافات العلمية.',
                    active: true
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            Category fiction =
                (Category.findByName('Fiction') ?: Category.findByName('الروايات'))

            if (!fiction) {
                fiction = new Category(
                    name: 'الروايات',
                    description: 'الروايات والأعمال الأدبية والقصص التي تبني عوالم وتجارب إنسانية متنوعة.',
                    active: true
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            Category classics =
                (Category.findByName('Classics') ?: Category.findByName('الكلاسيكيات'))

            if (!classics) {
                classics = new Category(
                    name: 'الكلاسيكيات',
                    description: 'الأعمال الأدبية الكلاسيكية والكتب المؤثرة التي حافظت على حضورها عبر الزمن.',
                    active: true
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // AUTHORS
            // =====================================================

            Author robertMartin =
                findOrCreateAuthor(
                    'Robert C. Martin',
                    'مهندس برمجيات وكاتب أمريكي، عُرف بأعماله حول الحرفية البرمجية وكتابة الشيفرة النظيفة والقابلة للصيانة.'
                )


            Author joshuaBloch =
                findOrCreateAuthor(
                    'Joshua Bloch',
                    'مهندس برمجيات وكاتب عُرف بإسهاماته في منصة Java وكتاباته حول تصميم واجهات البرمجة وأفضل ممارسات اللغة.'
                )


            Author andrewHunt =
                findOrCreateAuthor(
                    'Andrew Hunt',
                    'مطور برمجيات وكاتب، اشتهر بمشاركته في تأليف The Pragmatic Programmer وبأفكاره حول الممارسة المهنية للتطوير.'
                )


            Author erichGamma =
                findOrCreateAuthor(
                    'Erich Gamma',
                    'عالم حاسوب ومهندس برمجيات سويسري، عُرف بإسهاماته في أنماط تصميم البرمجيات وأدوات التطوير.'
                )


            Author martinFowler =
                findOrCreateAuthor(
                    'Martin Fowler',
                    'مطور برمجيات وكاتب ومتحدث بريطاني، عُرف بكتاباته في معمارية البرمجيات وإعادة الهيكلة والتصميم.'
                )


            Author georgeOrwell =
                findOrCreateAuthor(
                    'George Orwell',
                    'روائي وكاتب مقالات إنجليزي، عُرف بأعماله الأدبية التي تناولت السلطة والمجتمع واللغة والنقد السياسي.'
                )


            Author fitzgerald =
                findOrCreateAuthor(
                    'F. Scott Fitzgerald',
                    'روائي وكاتب أمريكي ارتبط اسمه بعصر الجاز، وكتب عن الطموح والطبقة الاجتماعية والحلم الأمريكي.'
                )


            Author janeAusten =
                findOrCreateAuthor(
                    'Jane Austen',
                    'روائية إنجليزية عُرفت بأعمالها التي تناولت المجتمع والعلاقات والطبقات الاجتماعية بأسلوب ساخر ودقيق.'
                )


            Author maryShelley =
                findOrCreateAuthor(
                    'Mary Shelley',
                    'روائية إنجليزية اشتهرت برواية Frankenstein، وتُعد من الأسماء المبكرة والمؤثرة في أدب الخيال العلمي.'
                )


            Author stephenHawking =
                findOrCreateAuthor(
                    'Stephen Hawking',
                    'فيزيائي نظري وعالم كونيات بريطاني، عُرف بأبحاثه حول الثقوب السوداء والكون وبقدرته على تبسيط العلوم للجمهور.'
                )


            // =====================================================
            // BOOK 1 - CLEAN CODE
            // =====================================================

            Book cleanCode = Book.findByIsbn('9780132350884')

            if (!cleanCode) {

                cleanCode = new Book(
                    title: 'Clean Code',
                    isbn: '9780132350884',

                    description:
                        'كتاب عملي في هندسة البرمجيات يركز على كتابة شيفرة واضحة، قابلة للصيانة، وتناسب العمل المهني ضمن الفرق.',

                    publishYear: 2008,

                    physicalSaleStock: 10,
                    physicalSalePrice: 25.00,

                    digitalAvailable: true,
                    digitalPurchasePrice: 15.00,
                    digitalRentalPrice: 5.00,

                    membershipIncluded: true,

                    digitalContent: '''
Clean Code

معاينة رقمية

البرمجيات الجيدة لا تكتفي بأن تعمل؛ بل يجب أن تكون مفهومة، قابلة للصيانة، وسهلة التطوير من قبل أعضاء الفريق.

هذه صفحة تدريبية لعرض محتوى رقمي محمي داخل نظام المكتبة.
''',

                    active: true,

                    category: programming,
                    author: robertMartin
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // BOOK 2 - EFFECTIVE JAVA
            // =====================================================

            Book effectiveJava = Book.findByIsbn('9780134685991')

            if (!effectiveJava) {

                effectiveJava = new Book(
                    title: 'Effective Java',
                    isbn: '9780134685991',

                    description:
                        'دليل عملي لأفضل ممارسات Java وتصميم الكائنات وواجهات البرمجة والاستخدام الفعال للغة في المشاريع الحقيقية.',

                    publishYear: 2018,

                    physicalSaleStock: 8,
                    physicalSalePrice: 30.00,

                    digitalAvailable: true,
                    digitalPurchasePrice: 18.00,
                    digitalRentalPrice: 6.00,

                    membershipIncluded: false,

                    digitalContent: '''
Effective Java

معاينة رقمية

هذه نسخة تدريبية تمثل كتابًا رقميًا داخل نظام المنارة.

يتحقق التطبيق من صلاحية المستخدم قبل السماح بفتح هذا المحتوى.
''',

                    active: true,

                    category: programming,
                    author: joshuaBloch
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // BOOK 3 - THE PRAGMATIC PROGRAMMER
            // =====================================================

            Book pragmaticProgrammer =
                Book.findByIsbn('9780135957059')

            if (!pragmaticProgrammer) {

                pragmaticProgrammer = new Book(
                    title: 'The Pragmatic Programmer',
                    isbn: '9780135957059',

                    description:
                        'كتاب عن التفكير العملي والعادات المهنية للمطور وبناء برمجيات قابلة للتطوير والصيانة على المدى الطويل.',

                    publishYear: 2019,

                    physicalSaleStock: 6,
                    physicalSalePrice: 32.00,

                    digitalAvailable: true,
                    digitalPurchasePrice: 20.00,
                    digitalRentalPrice: 7.00,

                    membershipIncluded: true,

                    digitalContent: '''
The Pragmatic Programmer

معاينة رقمية

تطوير البرمجيات يتجاوز كتابة الصياغة البرمجية؛ فالمطور المحترف يطور أدواته ومهاراته وطريقته في حل المشكلات باستمرار.
''',

                    active: true,

                    category: programming,
                    author: andrewHunt
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // BOOK 4 - DESIGN PATTERNS
            // =====================================================

            Book designPatterns =
                Book.findByIsbn('9780201633610')

            if (!designPatterns) {

                designPatterns = new Book(
                    title: 'Design Patterns',
                    isbn: '9780201633610',

                    description:
                        'مرجع أساسي في هندسة البرمجيات يشرح حلولًا قابلة لإعادة الاستخدام لمشكلات متكررة في التصميم الكائني.',

                    publishYear: 1994,

                    physicalSaleStock: 5,
                    physicalSalePrice: 35.00,

                    digitalAvailable: false,

                    digitalPurchasePrice: null,
                    digitalRentalPrice: null,

                    membershipIncluded: false,
                    digitalContent: null,

                    active: true,

                    category: programming,
                    author: erichGamma
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // BOOK 5 - REFACTORING
            // =====================================================

            Book refactoring =
                Book.findByIsbn('9780134757599')

            if (!refactoring) {

                refactoring = new Book(
                    title: 'Refactoring',
                    isbn: '9780134757599',

                    description:
                        'كتاب في هندسة البرمجيات يشرح تحسين البنية الداخلية للشيفرة الموجودة دون تغيير سلوكها الظاهر.',

                    publishYear: 2018,

                    physicalSaleStock: 7,
                    physicalSalePrice: 34.00,

                    digitalAvailable: true,
                    digitalPurchasePrice: 19.00,
                    digitalRentalPrice: 6.50,

                    membershipIncluded: true,

                    digitalContent: '''
Refactoring

معاينة رقمية

إعادة الهيكلة تحسن التصميم الداخلي للبرمجيات مع الحفاظ على السلوك الظاهر للمستخدم.

هذه صفحة نموذجية ضمن نظام القراءة الرقمي التدريبي.
''',

                    active: true,

                    category: programming,
                    author: martinFowler
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // BOOK 6 - 1984
            // =====================================================

            Book nineteenEightyFour =
                Book.findByIsbn('9780451524935')

            if (!nineteenEightyFour) {

                nineteenEightyFour = new Book(
                    title: '1984',
                    isbn: '9780451524935',

                    description:
                        'رواية ديستوبية لجورج أورويل تتناول المراقبة والسلطة والحقيقة وحدود الحرية الفردية.',

                    publishYear: 1949,

                    physicalSaleStock: 12,
                    physicalSalePrice: 14.00,

                    digitalAvailable: true,
                    digitalPurchasePrice: 8.00,
                    digitalRentalPrice: 3.00,

                    membershipIncluded: true,

                    digitalContent: '''
1984

نموذج القراءة الرقمية

تعرض هذه الصفحة مثالًا لطريقة تقديم المحتوى الأدبي داخل قارئ المنارة الرقمي.

يتحقق التطبيق من حق الوصول قبل عرض المحتوى.
''',

                    active: true,

                    category: fiction,
                    author: georgeOrwell
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // BOOK 7 - THE GREAT GATSBY
            // =====================================================

            Book greatGatsby =
                Book.findByIsbn('9780743273565')

            if (!greatGatsby) {

                greatGatsby = new Book(
                    title: 'The Great Gatsby',
                    isbn: '9780743273565',

                    description:
                        'رواية أمريكية كلاسيكية تستكشف الطموح والثروة والعلاقات الاجتماعية وفكرة الحلم الأمريكي.',

                    publishYear: 1925,

                    physicalSaleStock: 9,
                    physicalSalePrice: 13.00,

                    digitalAvailable: true,
                    digitalPurchasePrice: 7.00,
                    digitalRentalPrice: 2.50,

                    membershipIncluded: true,

                    digitalContent: '''
The Great Gatsby

نموذج القراءة الرقمية

يمثل هذا المحتوى صفحة قراءة إلكترونية تدريبية، ولا يظهر القارئ المحتوى إلا للمستخدم الذي يملك صلاحية وصول فعالة.
''',

                    active: true,

                    category: classics,
                    author: fitzgerald
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // BOOK 8 - PRIDE AND PREJUDICE
            // =====================================================

            Book prideAndPrejudice =
                Book.findByIsbn('9780141439518')

            if (!prideAndPrejudice) {

                prideAndPrejudice = new Book(
                    title: 'Pride and Prejudice',
                    isbn: '9780141439518',

                    description:
                        'رواية كلاسيكية لجين أوستن تتناول الأسرة والمجتمع والعلاقات والتوقعات الاجتماعية بأسلوب ساخر ودقيق.',

                    publishYear: 1813,

                    physicalSaleStock: 10,
                    physicalSalePrice: 12.00,

                    digitalAvailable: true,
                    digitalPurchasePrice: 6.00,
                    digitalRentalPrice: 2.00,

                    membershipIncluded: true,

                    digitalContent: '''
Pride and Prejudice

نموذج القراءة الرقمية

مرحبًا بك في قارئ المنارة الرقمي.

توضح هذه الصفحة كيف يمكن تقسيم الكتاب إلى فصول وتنسيقه لقراءة مريحة عبر النظام.
''',

                    active: true,

                    category: classics,
                    author: janeAusten
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // BOOK 9 - FRANKENSTEIN
            // =====================================================

            Book frankenstein =
                Book.findByIsbn('9780141439471')

            if (!frankenstein) {

                frankenstein = new Book(
                    title: 'Frankenstein',
                    isbn: '9780141439471',

                    description:
                        'رواية مؤثرة لماري شيلي تستكشف العلم والمسؤولية والخلق والطبيعة الإنسانية وعواقب الطموح غير المنضبط.',

                    publishYear: 1818,

                    physicalSaleStock: 8,
                    physicalSalePrice: 12.50,

                    digitalAvailable: true,
                    digitalPurchasePrice: 6.00,
                    digitalRentalPrice: 2.00,

                    membershipIncluded: true,

                    digitalContent: '''
Frankenstein

نموذج القراءة الرقمية

هذا محتوى رقمي تجريبي لتطبيق المكتبة.

يعتمد فتحه على سجل الوصول الرقمي الفعال الخاص بالمستخدم.
''',

                    active: true,

                    category: classics,
                    author: maryShelley
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // BOOK 10 - A BRIEF HISTORY OF TIME
            // =====================================================

            Book briefHistoryOfTime =
                Book.findByIsbn('9780553380163')

            if (!briefHistoryOfTime) {

                briefHistoryOfTime = new Book(
                    title: 'A Brief History of Time',
                    isbn: '9780553380163',

                    description:
                        'كتاب علمي مبسط يقدم أفكارًا رئيسية في علم الكون والفضاء والزمن وطبيعة الكون بلغة موجهة للقارئ العام.',

                    publishYear: 1988,

                    physicalSaleStock: 6,
                    physicalSalePrice: 20.00,

                    digitalAvailable: false,

                    digitalPurchasePrice: null,
                    digitalRentalPrice: null,

                    membershipIncluded: false,
                    digitalContent: null,

                    active: true,

                    category: science,
                    author: stephenHawking
                ).save(
                    flush: true,
                    failOnError: true
                )
            }


            // =====================================================
            // BORROWING COPIES
            // =====================================================

            createCopy('CC-001', cleanCode)
            createCopy('CC-002', cleanCode)

            createCopy('EJ-001', effectiveJava)
            createCopy('EJ-002', effectiveJava)

            createCopy('PP-001', pragmaticProgrammer)
            createCopy('PP-002', pragmaticProgrammer)

            createCopy('DP-001', designPatterns)

            createCopy('RF-001', refactoring)
            createCopy('RF-002', refactoring)

            createCopy('1984-001', nineteenEightyFour)
            createCopy('1984-002', nineteenEightyFour)

            createCopy('GG-001', greatGatsby)

            createCopy('PPJ-001', prideAndPrejudice)
            createCopy('PPJ-002', prideAndPrejudice)

            createCopy('FR-001', frankenstein)
            createCopy('FR-002', frankenstein)

            createCopy('BHT-001', briefHistoryOfTime)


            // =====================================================
            // STUDY ROOMS
            // =====================================================

            createStudyRoom(
                'ROOM-101',
                4,
                5.00
            )

            createStudyRoom(
                'ROOM-102',
                6,
                7.00
            )

            createStudyRoom(
                'ROOM-201',
                8,
                9.00
            )

            createStudyRoom(
                'ROOM-202',
                12,
                12.00
            )


            // =====================================================
            // ROOM DISCOUNT RULES
            // Editable later from the admin dashboard.
            // =====================================================
            createDiscountRule('حجز قصير', 0, 23, 0.0, 10)
            createDiscountRule('حجز يوم إلى أقل من 3 أيام', 24, 71, 5.0, 20)
            createDiscountRule('حجز 3 أيام إلى أقل من أسبوع', 72, 167, 10.0, 30)
            createDiscountRule('حجز أسبوع إلى أقل من أسبوعين', 168, 335, 15.0, 40)
            createDiscountRule('حجز أسبوعين فأكثر', 336, null, 20.0, 50)
        }
    }


    // =========================================================
    // AUTHOR HELPER
    // =========================================================

    private Author findOrCreateAuthor(
        String name,
        String biography
    ) {

        Author author =
            Author.findByName(name)

        if (!author) {

            author = new Author(
                name: name,
                biography: biography
            ).save(
                flush: true,
                failOnError: true
            )
        }

        author
    }


    // =========================================================
    // BOOK COPY HELPER
    // =========================================================

    private void createCopy(
        String copyCode,
        Book book
    ) {

        if (!BookCopy.findByCopyCode(copyCode)) {

            new BookCopy(
                copyCode: copyCode,
                status: 'AVAILABLE',
                book: book
            ).save(
                flush: true,
                failOnError: true
            )
        }
    }


    // =========================================================
    // STUDY ROOM HELPER
    // =========================================================

    private void createStudyRoom(
        String roomNumber,
        Integer capacity,
        BigDecimal pricePerHour
    ) {

        if (!StudyRoom.findByRoomNumber(roomNumber)) {

            Map roomProfiles = [
                'ROOM-101': [name: 'غرفة الزيتونة', location: 'الطابق الأول', features: 'شاشة عرض\nسبورة بيضاء\nمقابس كهرباء\nWi-Fi', description: 'غرفة هادئة للمذاكرة الفردية أو للمجموعات الصغيرة.'],
                'ROOM-102': [name: 'غرفة القدس', location: 'الطابق الأول', features: 'شاشة عرض\nسبورة\nتكييف\nWi-Fi', description: 'مساحة مرنة للاجتماعات الدراسية والعمل الجماعي.'],
                'ROOM-201': [name: 'غرفة المنارة', location: 'الطابق الثاني', features: 'شاشة كبيرة\nسبورة ذكية\nمقابس كهرباء\nWi-Fi', description: 'غرفة واسعة للمجموعات ومراجعات المشاريع والعروض.'],
                'ROOM-202': [name: 'قاعة المعرفة', location: 'الطابق الثاني', features: 'شاشة عرض\nسبورة ذكية\nطاولة اجتماعات\nتكييف\nWi-Fi', description: 'أكبر مساحة دراسة في المكتبة ومناسبة للفرق والجلسات الطويلة.']
            ]
            Map profile = roomProfiles[roomNumber] ?: [:]

            new StudyRoom(
                roomNumber: roomNumber,
                name: profile.name,
                description: profile.description,
                location: profile.location,
                features: profile.features,
                capacity: capacity,
                pricePerHour: pricePerHour,
                active: true
            ).save(
                flush: true,
                failOnError: true
            )
        }
    }


    private void createDiscountRule(String name, Integer minHours, Integer maxHours,
                                    BigDecimal percentage, Integer priority) {
        if (!DiscountRule.findByName(name)) {
            new DiscountRule(
                name: name,
                minHours: minHours,
                maxHours: maxHours,
                percentage: percentage,
                priority: priority,
                active: true
            ).save(flush: true, failOnError: true)
        }
    }


    def destroy = {
    }
}