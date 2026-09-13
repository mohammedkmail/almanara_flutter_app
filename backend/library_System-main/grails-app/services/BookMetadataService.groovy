package librarysystem

import groovy.json.JsonSlurper

class BookMetadataService {

    Map lookupByIsbn(String rawIsbn) {
        String isbn = rawIsbn?.replaceAll(/[^0-9Xx]/, '')
        if (!isbn) throw new IllegalArgumentException('أدخل ISBN صحيحًا أولًا.')

        Map google = lookupGoogleBooks(isbn)
        if (google) return google + [source: 'Google Books']

        Map openLibrary = lookupOpenLibrary(isbn)
        if (openLibrary) return openLibrary + [source: 'Open Library']

        throw new IllegalStateException('لم يتم العثور على بيانات لهذا ISBN في المصادر الخارجية.')
    }

    private Map lookupGoogleBooks(String isbn) {
        try {
            URLConnection connection = new URL("https://www.googleapis.com/books/v1/volumes?q=isbn:${URLEncoder.encode(isbn, 'UTF-8')}").openConnection()
            connection.setRequestProperty('Accept', 'application/json')
            connection.setRequestProperty('User-Agent', 'Manara-Library/1.0')
            connection.connectTimeout = 5000
            connection.readTimeout = 7000
            def json = new JsonSlurper().parse(connection.inputStream)
            def item = json?.items ? json.items[0] : null
            def info = item?.volumeInfo
            if (!info) return null

            String publishedDate = info.publishedDate?.toString()
            Integer publishYear = publishedDate?.find(/\d{4}/) as Integer
            String cover = info.imageLinks?.thumbnail ?: info.imageLinks?.smallThumbnail
            if (cover) cover = cover.replace('http://', 'https://')

            [
                title          : info.title,
                authors        : info.authors ?: [],
                description    : info.description,
                publisher      : info.publisher,
                publishYear    : publishYear,
                pageCount      : info.pageCount,
                language       : info.language,
                categories     : info.categories ?: [],
                externalCoverUrl: cover
            ]
        } catch (Exception ignored) {
            null
        }
    }

    private Map lookupOpenLibrary(String isbn) {
        try {
            URLConnection connection = new URL("https://openlibrary.org/api/books?bibkeys=ISBN:${URLEncoder.encode(isbn, 'UTF-8')}&format=json&jscmd=data").openConnection()
            connection.setRequestProperty('Accept', 'application/json')
            connection.setRequestProperty('User-Agent', 'Manara-Library/1.0')
            connection.connectTimeout = 5000
            connection.readTimeout = 7000
            def json = new JsonSlurper().parse(connection.inputStream)
            def info = json?["ISBN:${isbn}"]
            if (!info) return null

            String dateText = info.publish_date?.toString()
            Integer publishYear = dateText?.find(/\d{4}/) as Integer
            [
                title          : info.title,
                authors        : info.authors?.collect { it.name } ?: [],
                description    : null,
                publisher      : info.publishers ? info.publishers[0]?.name : null,
                publishYear    : publishYear,
                pageCount      : info.number_of_pages,
                language       : null,
                categories     : info.subjects?.take(5)?.collect { it.name } ?: [],
                externalCoverUrl: info.cover?.large ?: info.cover?.medium ?: info.cover?.small
            ]
        } catch (Exception ignored) {
            null
        }
    }
}
