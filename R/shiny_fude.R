#' Prepare Leaflet Map for Fude Polygon Data
#'
#' @description
#' Prepares a Leaflet map for Fude Polygon data.
#' @param data
#'   A list or data frame containing Fude Polygon data.
#' @param community
#'   A logical value indicating whether to overlay community data on the map.
#' @return A Leaflet map object with Fude Polygon data with an HTML table.
#'
#' @export
shiny_fude <- function(data, community = FALSE) {

  if ("fude" %in% names(data)) {
      data_fude <- data$fude %>%
        dplyr::mutate(
          layerId = .data$polygon_uuid,
          label = .data$polygon_uuid
        )
    } else {
      data_fude <- data %>%
        dplyr::mutate(
          layerId = .data$polygon_uuid,
          label = .data$RCOM_NAME
        )
    }

    if (community && "community" %in% names(data)) {
      data_community <- data$community %>%
        dplyr::mutate(
          community_layerId = .data$RCOM,
          community_label = .data$RCOM_NAME
        )
    }

  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(
        shiny::HTML(
          ".leaflet-container { background: none; }
        .well { background: none;}"
        )
      )
    ),
    shiny::titlePanel("Fude Polygon"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        leaflet::leafletOutput("mapfilter", height = 250),
        shiny::actionButton("clear_selection", "Clear")
      ),
      shiny::mainPanel(
        DT::DTOutput("table")
      )
    )
  )

  server <- function(input, output, session) {
    rv <- shiny::reactiveValues(selected_fude = NULL, filtered_data = data_fude)

    shiny::observeEvent(input$mapfilter_shape_click, {
      click <- input$mapfilter_shape_click

      if (click$id %in% rv$selected_fude) {
        rv$selected_fude <- rv$selected_fude[rv$selected_fude != click$id]
      } else if (click$id == "selected") {
        rv$selected_fude <- rv$selected_fude[rv$selected_fude != utils::tail(rv$selected_fude, n = 1)]
      } else {
        rv$selected_fude <- c(rv$selected_fude, click$id)
      }

      proxy <- leaflet::leafletProxy("mapfilter", session) %>%
        leaflet::clearShapes()

      if (community) {
        proxy %>%
          leaflet::addPolygons(
            data = data_community,
            layerId = ~community_layerId,
            label = ~community_label,
            fillColor = "gray",
            color = "black",
            weight = 2,
            fillOpacity = 0
          )
      }

      proxy %>%
        leaflet::addPolygons(
          data = data_fude,
          layerId = ~layerId,
          label = ~label,
          fillColor = "steelblue",
          color = "black",
          weight = 2,
          fillOpacity = ifelse(data_fude$polygon_uuid %in% rv$selected_fude, 1, 0.1),
          highlightOptions = leaflet::highlightOptions(
            fillOpacity = 1,
            bringToFront = TRUE
          )
        )

    })

    output$mapfilter <- leaflet::renderLeaflet({
      proxy <- leaflet::leaflet(
        data_fude,
        options = leaflet::leafletOptions(
          zoomControl = TRUE,
          dragging = TRUE,
          minZoom = 6,
          maxZoom = 18
        )
      )

      if (community) {
        proxy <- proxy %>%
          leaflet::addPolygons(
            data = data_community,
            layerId = ~community_layerId,
            label = ~community_label,
            fillColor = "gray",
            color = "black",
            weight = 2,
            fillOpacity = 0
          )
      }

      proxy %>%
        leaflet::addPolygons(
          layerId = ~layerId,
          label = ~label,
          color = "black",
          fillColor = "steelblue",
          weight = 2,
          fillOpacity = .1,
          highlightOptions = leaflet::highlightOptions(
            fillOpacity = 1,
            bringToFront = TRUE
          )
        )
    })

    output$table <- DT::renderDT({
      rv$filtered_data %>%
        sf::st_set_geometry(NULL) %>%
        dplyr::mutate_if(~inherits(.x, "units"), as.numeric) %>%
        DT::datatable(
          selection = 'single',  # Allow single row selection
          filter = 'top',
          extensions = 'Buttons',
          options = list(
            pageLength = 25,
            dom = 'Blfrtip',
            buttons = list(
              c('csv', 'excel'),
              I('colvis')
            )
          )
        )
    })

    shiny::observe({
      if (!is.null(rv$selected_fude) && length(rv$selected_fude) > 0) {
        rv$filtered_data <- data_fude %>%
          dplyr::filter(layerId %in% rv$selected_fude)
      } else {
        rv$filtered_data <- data_fude
      }
    })

    shiny::observeEvent(input$table_rows_selected, {
      selected_row <- input$table_rows_selected
      if (length(selected_row) > 0) {
        selected_polygon_uuid <- rv$filtered_data$polygon_uuid[selected_row]
        rv$selected_fude <- selected_polygon_uuid

        proxy <- leaflet::leafletProxy("mapfilter", session) %>%
          leaflet::clearShapes()

        if (community) {
          proxy %>%
            leaflet::addPolygons(
              data = data_community,
              layerId = ~community_layerId,
              label = ~community_label,
              fillColor = "gray",
              color = "black",
              weight = 2,
              fillOpacity = 0
            )
        }

        proxy %>%
          leaflet::addPolygons(
            data = data_fude,
            layerId = ~layerId,
            label = ~label,
            fillColor = "steelblue",
            color = "black",
            weight = 2,
            fillOpacity = ifelse(data_fude$polygon_uuid %in% rv$selected_fude, 1, 0.1),
            highlightOptions = leaflet::highlightOptions(
              fillOpacity = 1,
              bringToFront = TRUE
            )
          )

      }
    })

    shiny::observeEvent(input$clear_selection, {
      rv$selected_fude <- NULL
      rv$filtered_data <- data_fude

      proxy <- leaflet::leafletProxy("mapfilter", session) %>%
        leaflet::clearShapes()

      if (community) {
        proxy %>%
          leaflet::addPolygons(
            data = data_community,
            layerId = ~community_layerId,
            label = ~community_label,
            fillColor = "gray",
            color = "black",
            weight = 2,
            fillOpacity = 0
          )
      }

      proxy %>%
        leaflet::addPolygons(
          data = data_fude,
          layerId = ~layerId,
          label = ~label,
          fillColor = "steelblue",
          color = "black",
          weight = 2,
          fillOpacity = .1,
          highlightOptions = leaflet::highlightOptions(
            fillOpacity = 1,
            bringToFront = TRUE
          )
        )

    })
   }

  return(list(ui = ui, server = server))

}

utils::globalVariables(c("layerId", "label", "community_layerId", "community_label"))
