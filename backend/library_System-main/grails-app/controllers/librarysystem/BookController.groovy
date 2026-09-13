package librarysystem

import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured
import grails.validation.ValidationException
import grails.converters.JSON
import org.springframework.web.multipart.MultipartFile

import static org.springframework.http.HttpStatus.*

class BookController {

    BookService bookService
    DigitalAccessService digitalAccessService
    MembershipService membershipService
    BookMetadataService bookMetadataService
    SpringSecurityService springSecurityService

    static allowedMethods = [
        save  : 'POST',
        update: 'PUT',
        delete: 'DELETE'
    ]


    @Secured(['permitAll'])
    def index(Integer max) {

        int pageSize =
            Math.min(Math.max(max ?: 12, 1), 100)

        int offset =
            Math.max(params.int('offset') ?: 0, 0)

        String search =
            params.search?.trim()

        User currentUser =
            springSecurityService.currentUser as User

        boolean admin =
            isAdmin(currentUser)

        Map catalogResult =
            bookService.searchCatalog(
                search,
                admin,
                pageSize,
                offset
            )

        List<Book> bookList =
            catalogResult.books as List<Book>

        Long bookCount =
            catalogResult.total as Long


        respond bookList,
            model: [
                bookCount: bookCount,
                search   : search,
                pageSize : pageSize,
                isAdmin  : admin
            ]
    }


    /*
     * =========================================================
     * LIVE SEARCH
     *
     * Used by JavaScript while the user is typing.
     *
     * It uses the SAME BookService search used by index(),
     * so title / ISBN / author / category searching stays
     * in one place.
     * =========================================================
     */

    @Secured(['permitAll'])
    def liveSearch(Integer max) {

        int pageSize =
            Math.min(
                Math.max(max ?: 12, 1),
                100
            )

        String search =
            params.search?.trim()

        User currentUser =
            springSecurityService.currentUser as User

        boolean admin =
            isAdmin(currentUser)


        Map catalogResult =
            bookService.searchCatalog(
                search,
                admin,
                pageSize,
                0
            )


        List<Book> bookList =
            catalogResult.books as List<Book>

        Long bookCount =
            catalogResult.total as Long


        render template: 'bookResults',
            model: [
                bookList : bookList,
                bookCount: bookCount,
                search   : search,
                isAdmin  : admin
            ]
    }


    @Secured(['permitAll'])
    def show(Long id) {

        Book book =
            bookService.get(id)

        if (!book) {
            notFound()
            return
        }


        User currentUser =
            springSecurityService.currentUser as User

        boolean admin =
            isAdmin(currentUser)

        boolean libraryUser =
            currentUser &&
            !admin &&
            isLibraryUser(currentUser)


        if (
            book.active != true &&
            !admin
        ) {
            notFound()
            return
        }


        List<BookCopy> availableCopies =
            BookCopy.findAllByBookAndStatus(
                book,
                'AVAILABLE',
                [
                    sort : 'copyCode',
                    order: 'asc'
                ]
            )


        int physicalCopyCount =
            BookCopy.countByBook(book)


        boolean canReadDigital = false
        boolean ownsDigital = false
        boolean hasActiveMembership = false
        Reservation currentReservation = null


        if (libraryUser) {

            hasActiveMembership =
                membershipService
                    .hasActiveMembership(currentUser)


            currentReservation =
                Reservation.findAllByUserAndBook(
                    currentUser,
                    book,
                    [
                        sort : 'reservationDate',
                        order: 'desc'
                    ]
                ).find { Reservation reservation ->

                    reservation.status in [
                        'WAITING',
                        'READY',
                        'PAID',
                        'CONFIRMED'
                    ]
                }


            if (book.digitalAvailable) {

                digitalAccessService
                    .expireOldRentals()


                canReadDigital =
                    digitalAccessService
                        .canAccessBook(
                            currentUser,
                            book
                        )


                ownsDigital =
                    Purchase.findAllByUserAndBook(
                        currentUser,
                        book
                    ).any { Purchase purchase ->

                        purchase.purchaseType == 'DIGITAL' &&
                        purchase.status == 'COMPLETED'
                    }


                if (!ownsDigital) {

                    ownsDigital =
                        DigitalAccess
                            .findAllByUserAndBook(
                                currentUser,
                                book
                            )
                            .any { DigitalAccess access ->

                                access.accessType == 'PURCHASE' &&
                                access.status == 'ACTIVE'
                            }
                }
            }
        }


        respond book,
            model: [
                availableCopies    : availableCopies,
                physicalCopyCount  : physicalCopyCount,
                canReadDigital     : canReadDigital,
                ownsDigital        : ownsDigital,
                currentReservation : currentReservation,
                hasActiveMembership: hasActiveMembership,
                libraryUser        : libraryUser,
                isAdmin            : admin
            ]
    }


    @Secured(['ROLE_ADMIN'])
    def create() {

        respond new Book(params),
            model: [
                authorList:
                    Author.list(
                        sort: 'name',
                        order: 'asc'
                    ),

                categoryList:
                    Category.list(
                        sort: 'name',
                        order: 'asc'
                    )
            ]
    }


    @Secured(['ROLE_ADMIN'])
    def save() {

        Book book =
            new Book()


        try {

            bindBookForm(
                book
            )

            MultipartFile coverFile =
                request.getFile('coverFile')


            if (
                coverFile &&
                !coverFile.empty
            ) {

                if (!coverFile.contentType?.startsWith('image/')) {

                    throw new IllegalArgumentException(
                        'الغلاف يجب أن يكون ملف صورة.'
                    )
                }

                if (coverFile.size > 5 * 1024 * 1024) {

                    throw new IllegalArgumentException(
                        'حجم الغلاف يجب ألا يتجاوز 5MB.'
                    )
                }

                book.coverData =
                    coverFile.bytes

                book.coverContentType =
                    coverFile.contentType
            }


            Book.withTransaction {

                applyBookAuthor(
                    book
                )

                applyBookPriceFields(
                    book
                )

                bookService.save(
                    book
                )
            }

        } catch (
            ValidationException |
            IllegalArgumentException e
        ) {

            println '===== BOOK SAVE ERROR ====='
            println "Exception: ${e.message}"

            book.errors.allErrors.each { error ->
                println error
            }

            flash.message =
                'تعذر إضافة الكتاب. راجع الأخطاء الظاهرة أدناه.'


            render view: 'create',
                model: [
                    book: book,

                    authorList:
                        Author.list(
                            sort: 'name',
                            order: 'asc'
                        ),

                    categoryList:
                        Category.list(
                            sort: 'name',
                            order: 'asc'
                        )
                ]

            return
        }


        flash.message =
            'تمت إضافة الكتاب بنجاح.'


        redirect action: 'show',
                 id: book.id
    }


    @Secured(['ROLE_ADMIN'])
    def edit(Long id) {

        Book book =
            bookService.get(id)

        if (!book) {
            notFound()
            return
        }


        respond book,
            model: [
                authorList:
                    Author.list(
                        sort: 'name',
                        order: 'asc'
                    ),

                categoryList:
                    Category.list(
                        sort: 'name',
                        order: 'asc'
                    )
            ]
    }


    @Secured(['ROLE_ADMIN'])
    def update(Long id) {

        Book book =
            bookService.get(id)


        if (!book) {
            notFound()
            return
        }


        try {

            bindBookForm(
                book
            )

            MultipartFile coverFile =
                request.getFile('coverFile')


            if (
                coverFile &&
                !coverFile.empty
            ) {

                if (!coverFile.contentType?.startsWith('image/')) {

                    throw new IllegalArgumentException(
                        'الغلاف يجب أن يكون ملف صورة.'
                    )
                }

                if (coverFile.size > 5 * 1024 * 1024) {

                    throw new IllegalArgumentException(
                        'حجم الغلاف يجب ألا يتجاوز 5MB.'
                    )
                }

                book.coverData =
                    coverFile.bytes

                book.coverContentType =
                    coverFile.contentType
            }


            Book.withTransaction {

                applyBookAuthor(
                    book
                )

                applyBookPriceFields(
                    book
                )

                bookService.save(
                    book
                )
            }

        } catch (
            ValidationException |
            IllegalArgumentException e
        ) {

            flash.message =
                'تعذر تحديث الكتاب. راجع الحقول المطلوبة.'


            render view: 'edit',
                model: [
                    book: book,

                    authorList:
                        Author.list(
                            sort: 'name',
                            order: 'asc'
                        ),

                    categoryList:
                        Category.list(
                            sort: 'name',
                            order: 'asc'
                        )
                ]

            return
        }


        flash.message =
            'تم تحديث الكتاب بنجاح.'


        redirect action: 'show',
                 id: book.id
    }


    @Secured(['ROLE_ADMIN'])
    def delete(Long id) {

        Map result

        try {

            result =
                bookService.deleteOrDeactivate(id)

        } catch (
            ValidationException |
            IllegalArgumentException e
        ) {

            flash.message =
                e.message ?:
                'تعذر حذف أو تعطيل الكتاب.'

            redirect action: 'show',
                     id: id

            return
        }


        if (!result.found) {
            notFound()
            return
        }


        flash.message =
            result.deleted ?
                'تم حذف الكتاب بنجاح.' :
                'للكتاب سجل عمليات سابق، لذلك تم تعطيله بدل حذفه نهائيًا.'


        redirect action: 'index'
    }


    @Secured(['ROLE_ADMIN'])
    def lookupMetadata(String isbn) {

        try {

            render bookMetadataService
                .lookupByIsbn(isbn) as JSON

        } catch (Exception e) {

            response.status = 422

            render(
                [
                    error: e.message
                ] as JSON
            )
        }
    }


    @Secured(['permitAll'])
    def cover(Long id) {

        Book book =
            bookService.get(id)


        if (!book) {

            render status: NOT_FOUND
            return
        }


        User currentUser =
            springSecurityService.currentUser as User


        if (
            book.active != true &&
            !isAdmin(currentUser)
        ) {

            render status: NOT_FOUND
            return
        }


        if (
            !book.coverData &&
            book.externalCoverUrl
        ) {

            redirect url: book.externalCoverUrl
            return
        }


        if (!book.coverData) {

            render status: NOT_FOUND
            return
        }


        response.contentType =
            book.coverContentType ?: 'image/jpeg'

        response.contentLength =
            book.coverData.length


        response.outputStream.write(
            book.coverData
        )

        response.outputStream.flush()
    }



    /**
     * Binds the normal Book form fields.
     *
     * Author and money fields are handled separately.
     */
    private void bindBookForm(
        Book book
    ) {

        bindData(
            book,
            params,
            [
                include: [
                    'title',
                    'isbn',
                    'description',
                    'publishYear',
                    'publisher',
                    'pageCount',
                    'language',
                    'externalCoverUrl',
                    'physicalSaleStock',
                    'digitalContent'
                ]
            ]
        )


        Long categoryId =
            params.long(
                'category.id'
            )


        if (categoryId) {

            Category category =
                Category.get(
                    categoryId
                )


            if (!category) {

                throw new IllegalArgumentException(
                    'القسم المحدد غير موجود.'
                )
            }


            book.category =
                category

        } else {

            book.category =
                null
        }


        book.digitalAvailable =
            params.digitalAvailable ==
                'true'


        book.membershipIncluded =
            params.membershipIncluded ==
                'true'


        book.active =
            params.active ==
                'true'
    }



    /**
     * Resolves the author for the Book.
     *
     * Existing author:
     * use the selected Author.
     *
     * New author:
     * reuse it if it already exists,
     * otherwise create it.
     */
    private void applyBookAuthor(
        Book book
    ) {

        Long selectedAuthorId =
            params.long(
                'author.id'
            )


        /*
         * دعم existingAuthorId أيضًا
         * إذا غيرنا اسم الحقل لاحقًا.
         */
        if (!selectedAuthorId) {

            selectedAuthorId =
                params.long(
                    'existingAuthorId'
                )
        }


        String newAuthorName =
            params.newAuthorName
                ?.toString()
                ?.trim()


        if (newAuthorName) {

            newAuthorName =
                newAuthorName
                    .replaceAll(
                        /\s+/,
                        ' '
                    )
        }


        /*
         * لا نقبل الاثنين معًا.
         */
        if (
            selectedAuthorId &&
            newAuthorName
        ) {

            throw new IllegalArgumentException(
                'اختر مؤلفًا موجودًا أو أدخل مؤلفًا جديدًا، وليس الاثنين معًا.'
            )
        }


        Author author = null


        /*
         * مؤلف موجود.
         */
        if (selectedAuthorId) {

            author =
                Author.get(
                    selectedAuthorId
                )


            if (!author) {

                throw new IllegalArgumentException(
                    'المؤلف المحدد غير موجود.'
                )
            }
        }


        /*
         * مؤلف مكتوب يدويًا أو جاي من API.
         */
        else if (newAuthorName) {

            author =
                Author.findByNameIlike(
                    newAuthorName
                )


            /*
             * إذا غير موجود ننشئه.
             */
            if (!author) {

                author =
                    new Author(
                        name:
                            newAuthorName
                    )


                author.save(
                    flush: true,
                    failOnError: true
                )
            }
        }


        /*
         * لا Dropdown ولا اسم جديد.
         */
        if (!author) {

            throw new IllegalArgumentException(
                'اختر مؤلفًا موجودًا أو أدخل اسم مؤلف جديد.'
            )
        }


        /*
         * أهم سطر:
         * ربط المؤلف بالكتاب.
         */
        book.author =
            author
    }



    /**
     * Handles Book money fields manually.
     *
     * We intentionally do not let Grails automatically
     * bind these values to BigDecimal because decimal
     * parsing depends on locale.
     */
    private void applyBookPriceFields(
        Book book
    ) {

        book.physicalSalePrice =
            parseBookDecimal(
                'physicalSalePriceInput',
                null
            )

        book.borrowingFee =
            parseBookDecimal(
                'borrowingFeeInput',
                3.00G
            )

        book.digitalPurchasePrice =
            parseBookDecimal(
                'digitalPurchasePriceInput',
                null
            )

        book.digitalRentalPrice =
            parseBookDecimal(
                'digitalRentalPriceInput',
                null
            )
    }


    /**
     * Accepts:
     *
     * 3
     * 3.5
     * 3.50
     * 3,50
     * 3٫50
     *
     * and Arabic digits too.
     */
    private BigDecimal parseBookDecimal(
        String parameterName,
        BigDecimal defaultValue = null
    ) {

        String raw =
            params[parameterName]
                ?.toString()
                ?.trim()


        if (!raw) {
            return defaultValue
        }


        raw =
            raw
                .tr(
                    '٠١٢٣٤٥٦٧٨٩',
                    '0123456789'
                )
                .tr(
                    '۰۱۲۳۴۵۶۷۸۹',
                    '0123456789'
                )
                .replace('٬', '')
                .replace('٫', '.')
                .replace(',', '.')


        try {

            return new BigDecimal(raw)

        } catch (
            NumberFormatException ignored
        ) {

            throw new IllegalArgumentException(
                'أدخل قيمة مالية صحيحة، مثل 3 أو 3.50.'
            )
        }
    }


    private boolean isAdmin(
        User user
    ) {

        if (user == null) {
            return false
        }


        for (def role : user.authorities) {

            if (
                role.authority ==
                'ROLE_ADMIN'
            ) {

                return true
            }
        }


        return false
    }


    private boolean isLibraryUser(
        User user
    ) {

        if (user == null) {
            return false
        }


        for (def role : user.authorities) {

            if (
                role.authority ==
                'ROLE_USER'
            ) {

                return true
            }
        }


        return false
    }


    protected void notFound() {

        request.withFormat {

            form multipartForm {

                flash.message =
                    'الكتاب غير موجود.'

                redirect action: 'index'
            }


            '*' {

                render status: NOT_FOUND
            }
        }
    }
}