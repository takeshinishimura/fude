% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cite_fude.R
\name{cite_fude}
\alias{cite_fude}
\title{Generate Citation Text for Fude Polygon Data}
\usage{
cite_fude(data)
}
\arguments{
\item{data}{A list or data frame containing Fude Polygon data.}
}
\value{
A list with two elements: \code{ja} for Japanese citation text and \code{en}
for English citation text.
}
\description{
Generates citation text in Japanese and English for Fude Polygon Data.
}
\examples{
data <- list(fude = data.frame(issue_year = c(2021, 2020), boundary_edit_year = c(2019, 2020)))
cite_fude(data)

}
