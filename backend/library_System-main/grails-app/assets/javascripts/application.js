// This is a manifest file that'll be compiled into application.js.
//
//= require webjars/jquery/3.7.1/dist/jquery.js
//= require webjars/bootstrap/5.3.7/dist/js/bootstrap.bundle
//= require_self

(function () {
    'use strict';

    const ready = function (callback) {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', callback);
        } else {
            callback();
        }
    };


    ready(function () {

        /* =========================================================
           GLOBAL SEARCH SHORTCUT
           Ctrl/Cmd + K focuses the navbar search.
           ========================================================= */

        const globalSearch =
            document.querySelector(
                '#globalLibrarySearch input[type="search"]'
            );

        document.addEventListener('keydown', function (event) {

            const shortcutPressed =
                (event.ctrlKey || event.metaKey) &&
                event.key.toLowerCase() === 'k';

            if (!shortcutPressed || !globalSearch) {
                return;
            }

            event.preventDefault();

            globalSearch.focus();
            globalSearch.select();
        });



        /* =========================================================
           BOOK CATALOG LIVE SEARCH
           Search without refreshing the page.
           ========================================================= */

        const catalogSearchForm =
            document.getElementById('bookCatalogSearch');

        const catalogSearchInput =
            document.getElementById('bookCatalogSearchInput');

        const bookSearchResults =
            document.getElementById('bookSearchResults');

        const bookCatalogCount =
            document.getElementById('bookCatalogCount');

        const bookCatalogClear =
            document.getElementById('bookCatalogClear');


        if (
            catalogSearchForm &&
            catalogSearchInput &&
            bookSearchResults
        ) {

            /*
             * Prevent the global form submit loader from locking
             * the search button during AJAX search.
             */
            catalogSearchForm.dataset.noGlobalSubmitLock = 'true';


            let searchTimer = null;
            let currentRequest = null;
            let isComposing = false;


            const performLiveSearch = function () {

                const searchValue =
                    catalogSearchInput.value.trim();

                /*
                 * Don't hit the database for only one character.
                 * Empty value is allowed so clearing the search
                 * restores all books.
                 */
                if (
                    searchValue.length === 1
                ) {
                    return;
                }


                const liveUrl =
                    catalogSearchForm.dataset.liveUrl;

                if (!liveUrl) {
                    return;
                }


                /*
                 * Cancel the previous request if the user
                 * keeps typing quickly.
                 */
                if (currentRequest) {
                    currentRequest.abort();
                }

                currentRequest =
                    new AbortController();


                bookSearchResults.setAttribute(
                    'aria-busy',
                    'true'
                );

                bookSearchResults.classList.add(
                    'is-searching'
                );


                const url =
                    new URL(
                        liveUrl,
                        window.location.origin
                    );

                url.searchParams.set(
                    'search',
                    searchValue
                );


                fetch(
                    url.toString(),
                    {
                        method: 'GET',
                        headers: {
                            'X-Requested-With':
                                'XMLHttpRequest'
                        },
                        signal:
                            currentRequest.signal
                    }
                )
                    .then(function (response) {

                        if (!response.ok) {

                            throw new Error(
                                'Live search failed'
                            );
                        }

                        return response.text();
                    })

                    .then(function (html) {

                        /*
                         * Replace ONLY the results.
                         *
                         * The search input itself is untouched,
                         * so focus and cursor stay exactly where
                         * the user is typing.
                         */
                        bookSearchResults.innerHTML =
                            html;


                        /*
                         * Update book count if the partial contains
                         * the count marker.
                         */
                        const countMarker =
                            bookSearchResults.querySelector(
                                '[data-book-search-count]'
                            );

                        if (
                            countMarker &&
                            bookCatalogCount
                        ) {

                            bookCatalogCount.textContent =
                                countMarker.getAttribute(
                                    'data-book-search-count'
                                ) || '0';
                        }


                        /*
                         * Show / hide "clear search".
                         */
                        if (bookCatalogClear) {

                            bookCatalogClear.style.display =
                                searchValue ?
                                    '' :
                                    'none';
                        }


                        /*
                         * Keep the browser URL synchronized without
                         * refreshing the page.
                         */
                        const pageUrl =
                            new URL(
                                window.location.href
                            );

                        pageUrl.searchParams.delete(
                            'offset'
                        );


                        if (searchValue) {

                            pageUrl.searchParams.set(
                                'search',
                                searchValue
                            );

                        } else {

                            pageUrl.searchParams.delete(
                                'search'
                            );
                        }


                        window.history.replaceState(
                            {},
                            '',
                            pageUrl.toString()
                        );
                    })

                    .catch(function (error) {

                        /*
                         * Abort is normal when the user types
                         * another character before the previous
                         * request finishes.
                         */
                        if (
                            error.name ===
                            'AbortError'
                        ) {
                            return;
                        }

                        console.error(
                            'Book live search error:',
                            error
                        );
                    })

                    .finally(function () {

                        bookSearchResults.setAttribute(
                            'aria-busy',
                            'false'
                        );

                        bookSearchResults.classList.remove(
                            'is-searching'
                        );
                    });
            };


            const scheduleSearch = function () {

                window.clearTimeout(
                    searchTimer
                );

                searchTimer =
                    window.setTimeout(
                        performLiveSearch,
                        300
                    );
            };


            /*
             * Important for Arabic/mobile keyboards.
             */
            catalogSearchInput.addEventListener(
                'compositionstart',
                function () {
                    isComposing = true;
                }
            );


            catalogSearchInput.addEventListener(
                'compositionend',
                function () {

                    isComposing = false;

                    scheduleSearch();
                }
            );


            catalogSearchInput.addEventListener(
                'input',
                function () {

                    if (isComposing) {
                        return;
                    }

                    scheduleSearch();
                }
            );


            /*
             * If the user presses Enter or the search button,
             * still use AJAX instead of refreshing the page.
             */
            catalogSearchForm.addEventListener(
                'submit',
                function (event) {

                    event.preventDefault();

                    window.clearTimeout(
                        searchTimer
                    );

                    performLiveSearch();
                }
            );


            /*
             * Clear search without page refresh.
             */
            if (bookCatalogClear) {

                bookCatalogClear.addEventListener(
                    'click',
                    function (event) {

                        event.preventDefault();

                        catalogSearchInput.value = '';

                        catalogSearchInput.focus();

                        performLiveSearch();
                    }
                );
            }
        }



        /* =========================================================
           HORIZONTAL HOME SCROLLERS
           ========================================================= */

        document
            .querySelectorAll(
                '[data-scroll-target]'
            )
            .forEach(function (button) {

                button.addEventListener(
                    'click',
                    function () {

                        const selector =
                            button.getAttribute(
                                'data-scroll-target'
                            );

                        const direction =
                            Number(
                                button.getAttribute(
                                    'data-scroll-direction'
                                ) || 1
                            );

                        const target =
                            document.querySelector(
                                selector
                            );

                        if (!target) {
                            return;
                        }


                        const distance =
                            Math.max(
                                target.clientWidth * 0.72,
                                320
                            );


                        const isRtl =
                            window
                                .getComputedStyle(
                                    target
                                )
                                .direction === 'rtl';


                        target.scrollBy({
                            left:
                                direction *
                                distance *
                                (isRtl ? -1 : 1),

                            behavior:
                                'smooth'
                        });
                    }
                );
            });



        /* =========================================================
           PAGE LOADER
           Shows only for normal form submissions and navigation.
           ========================================================= */

        const spinner =
            document.getElementById(
                'spinner'
            );


        const showSpinner = function () {

            if (!spinner) {
                return;
            }

            spinner.classList.add(
                'is-visible'
            );

            spinner.setAttribute(
                'aria-hidden',
                'false'
            );
        };


        const hideSpinner = function () {

            if (!spinner) {
                return;
            }

            spinner.classList.remove(
                'is-visible'
            );

            spinner.setAttribute(
                'aria-hidden',
                'true'
            );
        };


        document
            .querySelectorAll('form')
            .forEach(function (form) {

                form.addEventListener(
                    'submit',
                    function () {

                        if (
                            form.dataset
                                .noGlobalSubmitLock ===
                            'true'
                        ) {
                            return;
                        }


                        if (!form.checkValidity()) {
                            return;
                        }


                        const submitButtons =
                            form.querySelectorAll(
                                'button[type="submit"], ' +
                                'input[type="submit"]'
                            );


                        submitButtons.forEach(
                            function (button) {

                                button.setAttribute(
                                    'aria-disabled',
                                    'true'
                                );

                                button.classList.add(
                                    'is-submitting'
                                );

                                button.disabled =
                                    true;
                            }
                        );


                        showSpinner();
                    }
                );
            });


        window.addEventListener(
            'pageshow',
            hideSpinner
        );



        /* =========================================================
           FLASH MESSAGE AUTO DISMISS
           ========================================================= */

        const flashMessage =
            document.querySelector(
                '.manara-flash-message'
            );


        if (
            flashMessage &&
            window.bootstrap
        ) {

            window.setTimeout(
                function () {

                    const alert =
                        bootstrap.Alert
                            .getOrCreateInstance(
                                flashMessage
                            );

                    alert.close();

                },
                5500
            );
        }



        /* =========================================================
           GENERIC CONFIRMATION HOOK
           ========================================================= */

        document.addEventListener(
            'click',
            function (event) {

                const target =
                    event.target.closest(
                        '[data-confirm]'
                    );

                if (!target) {
                    return;
                }


                const message =
                    target.getAttribute(
                        'data-confirm'
                    );


                if (
                    message &&
                    !window.confirm(message)
                ) {

                    event.preventDefault();

                    event.stopImmediatePropagation();
                }
            }
        );



        /* =========================================================
           SUBTLE REVEAL FOR HOME SECTIONS
           ========================================================= */

        const revealItems =
            document.querySelectorAll(
                '.mn-category-card, ' +
                '.mn-book-card, ' +
                '.mn-author-card, ' +
                '.mn-dashboard-metric'
            );


        if (
            'IntersectionObserver' in window &&
            revealItems.length
        ) {

            const observer =
                new IntersectionObserver(
                    function (
                        entries,
                        currentObserver
                    ) {

                        entries.forEach(
                            function (entry) {

                                if (
                                    !entry.isIntersecting
                                ) {
                                    return;
                                }


                                entry.target
                                    .classList
                                    .add(
                                        'mn-visible'
                                    );


                                currentObserver
                                    .unobserve(
                                        entry.target
                                    );
                            }
                        );
                    },
                    {
                        threshold: 0.08,

                        rootMargin:
                            '0px 0px -24px 0px'
                    }
                );


            revealItems.forEach(
                function (item) {

                    item.classList.add(
                        'mn-reveal'
                    );

                    observer.observe(
                        item
                    );
                }
            );
        }
    });



    /* =========================================================
       Keep compatibility with existing jQuery AJAX spinner behavior.
       ========================================================= */

    if (
        typeof jQuery !==
        'undefined'
    ) {

        (function ($) {

            $(document)
                .ajaxStart(
                    function () {

                        $('#spinner')
                            .addClass(
                                'is-visible'
                            )
                            .attr(
                                'aria-hidden',
                                'false'
                            );
                    }
                )
                .ajaxStop(
                    function () {

                        $('#spinner')
                            .removeClass(
                                'is-visible'
                            )
                            .attr(
                                'aria-hidden',
                                'true'
                            );
                    }
                );

        })(jQuery);
    }

})();