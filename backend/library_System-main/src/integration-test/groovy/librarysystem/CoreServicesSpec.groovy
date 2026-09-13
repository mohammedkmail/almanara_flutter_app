package librarysystem

import grails.gorm.transactions.Rollback
import grails.testing.mixin.integration.Integration
import spock.lang.Specification

@Integration
@Rollback
class CoreServicesSpec extends Specification {

    AuthorService authorService
    CategoryService categoryService
    BookService bookService
    BookCopyService bookCopyService
    StudyRoomService studyRoomService

    void 'core catalog services persist human readable entities'() {
        given:
        Author author = authorService.save(new Author(
            name: 'Test Author',
            biography: 'سيرة تجريبية'
        ))

        Category category = categoryService.save(new Category(
            name: 'قسم تجريبي',
            description: 'وصف تجريبي',
            active: true
        ))

        Book book = bookService.save(new Book(
            title: 'Test Book',
            isbn: 'TEST-ISBN-001',
            description: 'كتاب لاختبار خدمات الكتالوج',
            publishYear: 2026,
            physicalSaleStock: 2,
            physicalSalePrice: new BigDecimal('12.00'),
            borrowingFee: new BigDecimal('3.00'),
            digitalAvailable: false,
            membershipIncluded: false,
            active: true,
            author: author,
            category: category
        ))

        BookCopy copy = bookCopyService.save(new BookCopy(
            copyCode: 'TEST-COPY-001',
            status: 'AVAILABLE',
            book: book
        ))

        StudyRoom room = studyRoomService.save(new StudyRoom(
            roomNumber: 'TEST-ROOM-001',
            name: 'غرفة الاختبار',
            capacity: 4,
            pricePerHour: new BigDecimal('5.00'),
            active: true
        ))

        expect:
        author.id != null
        category.id != null
        book.id != null
        copy.id != null
        room.id != null
        book.toString() == 'Test Book'
        copy.toString().contains('Test Book')
        room.toString() == 'غرفة الاختبار'
    }
}
