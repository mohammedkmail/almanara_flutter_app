<!doctype html>
<html>

<head>
    <meta name="layout" content="main"/>
    <title>الكتب | المنارة</title>
</head>

<body>

<section class="mn-catalog-page mn-books-catalog">

    <div class="container">

        <header class="mn-editorial-header mn-books-header">

            <div>

                <span class="mn-editorial-kicker">
                    فهرس المنارة
                </span>

                <h1>
                    الكتب
                </h1>

                <p>
                    ابحث بالعنوان أو اسم المؤلف أو القسم، ثم افتح الكتاب لتشوف
                    الاستعارة والنسخة الرقمية والشراء من مكان واحد.
                </p>

            </div>


            <div class="mn-editorial-side">

                <span class="mn-count-stamp">

                    <b id="bookCatalogCount">
                        ${bookCount ?: 0}
                    </b>

                    كتاب

                </span>


                <sec:ifAnyGranted roles="ROLE_ADMIN">

                    <g:link
                        action="create"
                        class="mn-solid-action">

                        <i class="bi bi-plus-lg"></i>
                        إضافة كتاب

                    </g:link>

                </sec:ifAnyGranted>

            </div>

        </header>



        <!-- =====================================================
             SEARCH
             ===================================================== -->

        <div class="mn-catalog-toolbar">


            <form
                id="bookCatalogSearch"
                action="${createLink(controller: 'book', action: 'index')}"
                method="GET"
                class="mn-catalog-search"
                data-live-url="${createLink(controller: 'book', action: 'liveSearch')}">


                <i class="bi bi-search"></i>


                <input
                    id="bookCatalogSearchInput"
                    type="search"
                    name="search"
                    value="${search ?: ''}"
                    placeholder="ابحث بعنوان الكتاب، المؤلف، ISBN أو القسم..."
                    autocomplete="off"
                    dir="rtl"/>


                <button type="submit">
                    بحث
                </button>

            </form>



            <a
                id="bookCatalogClear"
                href="${createLink(controller: 'book', action: 'index')}"
                class="mn-clear-search"
                style="${search ? '' : 'display:none;'}">

                <i class="bi bi-x-lg"></i>
                مسح البحث

            </a>

        </div>



        <!-- =====================================================
             RESULTS
             يتم تغيير هذا الجزء فقط أثناء البحث.
             ===================================================== -->

        <div
            id="bookSearchResults"
            aria-live="polite"
            aria-busy="false">


            <g:render
                template="bookResults"
                model="${[
                    bookList        : bookList,
                    bookCount       : bookCount,
                    search          : search,
                    pageSize        : pageSize,
                    isAdmin         : isAdmin,
                    bookAvailability: bookAvailability,
                    offset          : params.int('offset') ?: 0
                ]}"/>


        </div>

    </div>

</section>

</body>

</html>