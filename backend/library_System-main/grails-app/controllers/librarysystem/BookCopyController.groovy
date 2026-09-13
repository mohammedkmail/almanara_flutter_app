package librarysystem

import grails.plugin.springsecurity.annotation.Secured
import grails.validation.ValidationException

@Secured(['ROLE_ADMIN'])
class BookCopyController {

    BookCopyService bookCopyService
    ReservationService reservationService

    static allowedMethods = [
        save  : 'POST',
        update: 'PUT',
        delete: 'DELETE'
    ]


    def index(Integer max) {

        int pageSize =
            Math.min(Math.max(max ?: 20, 1), 100)

        int offset =
            Math.max(params.int('offset') ?: 0, 0)

        List<BookCopy> bookCopyList =
            bookCopyService.list(
                [
                    max   : pageSize,
                    offset: offset,
                    sort  : 'copyCode',
                    order : 'asc'
                ]
            )

        respond bookCopyList,
            model: [
                bookCopyCount:
                    bookCopyService.count(),

                pageSize:
                    pageSize
            ]
    }


    def show(Long id) {

        BookCopy bookCopy =
            bookCopyService.get(id)

        if (!bookCopy) {
            notFound()
            return
        }

        int borrowingCount =
            Borrowing.countByBookCopy(bookCopy)

        int reservationCount =
            Reservation.countByAssignedCopy(bookCopy)

        boolean hasHistory =
            borrowingCount > 0 ||
            reservationCount > 0

        boolean operationallyLocked =
            bookCopy.status in [
                'BORROWED',
                'RESERVED'
            ]

        respond bookCopy,
            model: [
                borrowingCount   : borrowingCount,
                reservationCount : reservationCount,
                hasHistory       : hasHistory,
                canDelete        :
                    !hasHistory &&
                    !operationallyLocked
            ]
    }


    def create() {

        BookCopy bookCopy =
            new BookCopy(params)

        bookCopy.status =
            'AVAILABLE'

        respond bookCopy,
            model: [
                bookList:
                    activeBookList()
            ]
    }


    def save(BookCopy bookCopy) {

        if (!bookCopy) {
            notFound()
            return
        }

        /*
         * New physical copies always start AVAILABLE.
         *
         * BORROWED and RESERVED are controlled by
         * the circulation workflow.
         */
        bookCopy.status =
            'AVAILABLE'

        Reservation assignedReservation = null

        try {

            bookCopyService.save(bookCopy)

        } catch (ValidationException e) {

            flash.message =
                'تعذر إضافة نسخة الكتاب. راجع الحقول المطلوبة.'

            render view: 'create',
                model: [
                    bookCopy:
                        bookCopy,

                    bookList:
                        activeBookList()
                ]

            return
        }

        try {
            assignedReservation = reservationService.assignCopy(bookCopy.book, bookCopy)
        } catch (IllegalArgumentException | IllegalStateException e) {
            log.warn('تمت إضافة النسخة لكن تعذر تخصيصها تلقائيًا لحجز انتظار.', e)
        }

        flash.message = assignedReservation ?
            'تمت إضافة النسخة وتخصيصها تلقائيًا لأقدم حجز بانتظار هذا الكتاب.' :
            'تمت إضافة نسخة الكتاب بنجاح.'

        redirect action: 'show',
                 id: bookCopy.id
    }


    def edit(Long id) {

        BookCopy bookCopy =
            bookCopyService.get(id)

        if (!bookCopy) {
            notFound()
            return
        }

        render view: 'edit',
            model: editModel(bookCopy)
    }


    def update(Long id) {

        BookCopy bookCopy =
            bookCopyService.get(id)

        if (!bookCopy) {
            notFound()
            return
        }

        Long submittedVersion =
            params.long('version')

        if (
            submittedVersion != null &&
            bookCopy.version > submittedVersion
        ) {

            bookCopy.errors.rejectValue(
                'version',
                'default.optimistic.locking.failure',
                [
                    message(
                        code: 'bookCopy.label',
                        default: 'نسخة الكتاب'
                    )
                ] as Object[],
                'تم تعديل نسخة الكتاب من جلسة أخرى. حدّث الصفحة وأعد المحاولة.'
            )

            render view: 'edit',
                model: editModel(bookCopy)

            return
        }


        String originalStatus = bookCopy.status
        Long originalBookId = bookCopy.book?.id

        boolean history =
            hasHistory(bookCopy)

        boolean canChangeBook =
            !history &&
            bookCopy.status == 'AVAILABLE'

        boolean operationallyLocked =
            bookCopy.status in [
                'BORROWED',
                'RESERVED'
            ]


        bookCopy.copyCode =
            params.copyCode
                ?.toString()
                ?.trim()


        /*
         * The book association can only be changed
         * before the physical copy has circulation history.
         */
        if (canChangeBook) {

            Long requestedBookId =
                params.long('book.id')

            Book requestedBook =
                requestedBookId
                    ? Book.get(requestedBookId)
                    : null

            bookCopy.book =
                requestedBook
        }


        String requestedStatus =
            params.status
                ?.toString()
                ?.trim()


        /*
         * BORROWED and RESERVED cannot be overridden
         * manually. They are controlled by borrowing
         * and reservation workflows.
         */
        if (operationallyLocked) {

            if (
                requestedStatus &&
                requestedStatus != bookCopy.status
            ) {

                flash.message =
                    'حالتا «مُعار» و«محجوز» يديرهما نظام الإعارة والحجز تلقائيًا.'

                render view: 'edit',
                    model: editModel(bookCopy)

                return
            }

        } else if (requestedStatus) {

            List<String> allowedManualStatuses = [
                'AVAILABLE',
                'LOST',
                'DAMAGED'
            ]

            if (
                !allowedManualStatuses
                    .contains(requestedStatus)
            ) {

                flash.message =
                    'حالة نسخة الكتاب غير صالحة.'

                render view: 'edit',
                    model: editModel(bookCopy)

                return
            }

            bookCopy.status =
                requestedStatus
        }


        Reservation assignedReservation = null

        try {

            bookCopyService.save(bookCopy)

        } catch (ValidationException e) {

            flash.message =
                'تعذر تحديث نسخة الكتاب. راجع الحقول المطلوبة.'

            render view: 'edit',
                model: editModel(bookCopy)

            return
        }

        boolean becameAvailable = originalStatus != 'AVAILABLE' && bookCopy.status == 'AVAILABLE'
        boolean movedWhileAvailable = bookCopy.status == 'AVAILABLE' && originalBookId != bookCopy.book?.id
        if (becameAvailable || movedWhileAvailable) {
            try {
                assignedReservation = reservationService.assignCopy(bookCopy.book, bookCopy)
            } catch (IllegalArgumentException | IllegalStateException e) {
                log.warn('تم تحديث النسخة لكن تعذر تخصيصها تلقائيًا لحجز انتظار.', e)
            }
        }

        flash.message = assignedReservation ?
            'تم تحديث النسخة وتخصيصها تلقائيًا لأقدم حجز بانتظار هذا الكتاب.' :
            'تم تحديث نسخة الكتاب بنجاح.'

        redirect action: 'show',
                 id: bookCopy.id
    }


    def delete(Long id) {

        BookCopy bookCopy =
            bookCopyService.get(id)

        if (!bookCopy) {
            notFound()
            return
        }

        if (
            hasHistory(bookCopy) ||
            bookCopy.status in [
                'BORROWED',
                'RESERVED'
            ]
        ) {

            flash.message =
                'لا يمكن حذف هذه النسخة لأنها مرتبطة بسجل إعارة أو حجز سابق.'

            redirect action: 'show',
                     id: bookCopy.id

            return
        }

        bookCopyService.delete(id)

        flash.message =
            'تم حذف نسخة الكتاب بنجاح.'

        redirect action: 'index'
    }


    private boolean hasHistory(
        BookCopy bookCopy
    ) {

        Borrowing.countByBookCopy(bookCopy) > 0 ||
        Reservation.countByAssignedCopy(bookCopy) > 0
    }


    private List<Book> activeBookList() {

        Book.findAllByActive(
            true,
            [
                sort : 'title',
                order: 'asc'
            ]
        )
    }


    private Map editModel(
        BookCopy bookCopy
    ) {

        boolean history =
            hasHistory(bookCopy)

        boolean operationallyLocked =
            bookCopy.status in [
                'BORROWED',
                'RESERVED'
            ]

        List<Book> books =
            activeBookList()

        if (
            bookCopy.book &&
            !books*.id.contains(bookCopy.book.id)
        ) {

            books.add(bookCopy.book)

            books =
                books.sort {
                    it.title?.toLowerCase()
                }
        }

        [
            bookCopy:
                bookCopy,

            bookList:
                books,

            canChangeBook:
                !history &&
                bookCopy.status == 'AVAILABLE',

            statusEditable:
                !operationallyLocked,

            statusOptions: [
                'AVAILABLE',
                'LOST',
                'DAMAGED'
            ]
        ]
    }


    protected void notFound() {

        flash.message =
            'نسخة الكتاب غير موجودة.'

        redirect action: 'index'
    }
}