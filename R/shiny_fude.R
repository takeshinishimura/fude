#' Prepare a Shiny Leaflet viewer for Fude Polygon data
#'
#' @description
#' `shiny_fude()` prepares a Shiny user interface and server function for
#' interactive visualization of Fude Polygon data with `leaflet` and `DT`.
#' The map supports polygon selection, optional agricultural community boundary
#' overlays, and a linked attribute table.
#'
#' @param data
#'   A Fude Polygon data object, or a list containing `fude` and `rcom` elements.
#'   If `rcom = TRUE`, `data` must contain both polygon data in `data$fude` and
#'   agricultural community boundary data in `data$rcom`.
#' @param height
#'   Height of the map passed to [leaflet::leafletOutput()].
#' @param rcom
#'   Logical. If `TRUE`, overlay agricultural community boundaries on the map.
#'
#' @returns
#'   A list with two elements: `ui`, a Shiny UI object, and `server`, a Shiny
#'   server function.
#'
#' @export
shiny_fude <- function(
  data,
  height = 1000,
  rcom = FALSE
) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package `shiny` is required for `shiny_fude()`.")
  }
  if (!requireNamespace("leaflet", quietly = TRUE)) {
    stop("Package `leaflet` is required for `shiny_fude()`.")
  }
  if (!requireNamespace("DT", quietly = TRUE)) {
    stop("Package `DT` is required for `shiny_fude()`.")
  }

  if (is.list(data) && "fude" %in% names(data)) {
    data_fude <- data$fude
  } else if (is.data.frame(data)) {
    data_fude <- data
  } else {
    stop("`data` must be an sf object or a list containing `fude`.")
  }

  if (!inherits(data_fude, "sf")) {
    stop("`data_fude` must be an sf object.")
  }

  if (!("polygon_uuid" %in% names(data_fude))) {
    stop("Fude polygon data must contain `polygon_uuid`.")
  }

  if (isTRUE(rcom)) {
    if (!(is.list(data) && "rcom" %in% names(data))) {
      stop("If `rcom = TRUE`, `data` must contain `rcom` boundary data.")
    }

    data_rcom <- data$rcom

    if (!inherits(data_rcom, "sf")) {
      stop("`data$rcom` must be an sf object.")
    }

    if (!("rcom" %in% names(data_rcom))) {
      stop("`data$rcom` must contain an `rcom` column.")
    }

    if (!("rcom_name" %in% names(data_rcom))) {
      data_rcom$rcom_name <- data_rcom$rcom
    }
  } else {
    data_rcom <- NULL
  }

  if (!("rcom_name" %in% names(data_fude))) {
    data_fude$rcom_name <- data_fude$polygon_uuid
  }

  data_fude <- data_fude |>
    dplyr::mutate(
      layerId = .data$polygon_uuid,
      label = .data$rcom_name
    ) |>
    sf::st_transform(crs = 4326)

  if (isTRUE(rcom)) {
    data_rcom <- data_rcom |>
      dplyr::mutate(
        rcom_layerId = .data$rcom,
        rcom_label = .data$rcom_name
      ) |>
      sf::st_transform(crs = 4326)
  }

  build_map <- function(selected_ids = NULL) {
    map <- leaflet::leaflet(
      data_fude,
      options = leaflet::leafletOptions(
        zoomControl = TRUE,
        dragging = TRUE,
        minZoom = 6,
        maxZoom = 18
      )
    )

    if (isTRUE(rcom)) {
      map <- map |>
        leaflet::addPolygons(
          data = data_rcom,
          layerId = ~rcom_layerId,
          label = ~rcom_label,
          fillColor = "gray",
          color = "black",
          weight = 2,
          fillOpacity = 0
        )
    }

    map |>
      leaflet::addPolygons(
        data = data_fude,
        layerId = ~layerId,
        label = ~label,
        color = "black",
        fillColor = "steelblue",
        weight = 2,
        fillOpacity = ifelse(data_fude$layerId %in% selected_ids, 1, 0.1),
        highlightOptions = leaflet::highlightOptions(
          fillOpacity = 1,
          bringToFront = TRUE
        )
      )
  }

  redraw_map <- function(session, selected_ids = NULL) {
    proxy <- leaflet::leafletProxy("mapfilter", session) |>
      leaflet::clearShapes()

    if (isTRUE(rcom)) {
      proxy <- proxy |>
        leaflet::addPolygons(
          data = data_rcom,
          layerId = ~rcom_layerId,
          label = ~rcom_label,
          fillColor = "gray",
          color = "black",
          weight = 2,
          fillOpacity = 0
        )
    }

    proxy |>
      leaflet::addPolygons(
        data = data_fude,
        layerId = ~layerId,
        label = ~label,
        color = "black",
        fillColor = "steelblue",
        weight = 2,
        fillOpacity = ifelse(data_fude$layerId %in% selected_ids, 1, 0.1),
        highlightOptions = leaflet::highlightOptions(
          fillOpacity = 1,
          bringToFront = TRUE
        )
      )
  }

  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(
        shiny::HTML(
          ".leaflet-container { background: none; }
          .well { background: none; }"
        )
      )
    ),
    shiny::titlePanel("Fude Polygon"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        leaflet::leafletOutput("mapfilter", height = height),
        shiny::actionButton("clear_selection", "Clear")
      ),
      shiny::mainPanel(
        DT::DTOutput("table")
      )
    )
  )

  server <- function(input, output, session) {
    rv <- shiny::reactiveValues(
      selected_fude = character(),
      filtered_data = data_fude
    )

    output$mapfilter <- leaflet::renderLeaflet({
      build_map(rv$selected_fude)
    })

    shiny::observe({
      if (length(rv$selected_fude) > 0) {
        rv$filtered_data <- data_fude |>
          dplyr::filter(.data$layerId %in% rv$selected_fude)
      } else {
        rv$filtered_data <- data_fude
      }
    })

    shiny::observeEvent(input$mapfilter_shape_click, {
      click <- input$mapfilter_shape_click
      clicked_id <- click$id

      if (is.null(clicked_id) || !(clicked_id %in% data_fude$layerId)) {
        return()
      }

      if (clicked_id %in% rv$selected_fude) {
        rv$selected_fude <- setdiff(rv$selected_fude, clicked_id)
      } else {
        rv$selected_fude <- c(rv$selected_fude, clicked_id)
      }

      redraw_map(session, rv$selected_fude)
    })

    output$table <- DT::renderDT({
      table_data <- rv$filtered_data |>
        sf::st_set_geometry(NULL) |>
        dplyr::mutate(
          dplyr::across(
            .cols = dplyr::where(~ inherits(.x, "units")),
            .fns = as.numeric
          )
        )

      DT::datatable(
        table_data,
        selection = "single",
        filter = "top",
        extensions = "Buttons",
        options = list(
          pageLength = 25,
          dom = "Blfrtip",
          buttons = list(
            c("csv", "excel"),
            I("colvis")
          )
        )
      )
    })

    shiny::observeEvent(input$table_rows_selected, {
      selected_row <- input$table_rows_selected

      if (length(selected_row) == 0) {
        return()
      }

      selected_polygon_uuid <- rv$filtered_data$layerId[selected_row]
      rv$selected_fude <- selected_polygon_uuid

      redraw_map(session, rv$selected_fude)
    })

    shiny::observeEvent(input$clear_selection, {
      rv$selected_fude <- character()
      rv$filtered_data <- data_fude

      redraw_map(session, rv$selected_fude)
    })
  }

  list(ui = ui, server = server)
}

utils::globalVariables(c(
  "layerId",
  "label",
  "rcom_layerId",
  "rcom_label"
))
