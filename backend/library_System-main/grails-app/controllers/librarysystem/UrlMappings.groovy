package librarysystem

class UrlMappings {

    static mappings = {
        get "/api/me"(controller: "mobileApi", action: "me")
        get "/api/reservations"(controller: "mobileApi", action: "reservations")
        post "/api/reservations"(controller: "mobileApi", action: "reserve")

        // =========================
        // Book REST API
        // =========================

        get "/api/books"(
            controller: "bookRest",
            action: "index"
        )

        get "/api/books/$id"(
            controller: "bookRest",
            action: "show"
        )

        post "/api/books"(
            controller: "bookRest",
            action: "save"
        )

        put "/api/books/$id"(
            controller: "bookRest",
            action: "update"
        )

        delete "/api/books/$id"(
            controller: "bookRest",
            action: "delete"
        )


        // =========================
        // Normal Grails Routes
        // =========================

        "/$controller/$action?/$id?(.$format)?" {

            constraints {
                // apply constraints here
            }
        }


        // =========================
        // Home Page
        // =========================

        "/"(
            controller: "home",
            action: "index"
        )


        // =========================
        // Error Pages
        // =========================

        "500"(view: '/error')

        "404"(view: '/notFound')
    }
}
