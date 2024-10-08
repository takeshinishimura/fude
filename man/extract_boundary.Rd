% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract_boundary.R
\name{extract_boundary}
\alias{extract_boundary}
\title{Extract specified agricultural community boundary data}
\usage{
extract_boundary(boundary, city, old_village = "", community = "", all = FALSE)
}
\arguments{
\item{boundary}{List of one or more agricultural community boundary data provided by
the MAFF.}

\item{city}{A local government name in Japanese to be extracted. In the case of
overlapping local government names, this must contain the prefecture name
in Japanese and the prefecture code in romaji (e.g., "Fuchu-shi, 13",
"fuchu 13",  "34 fuchu-shi",  "34, FUCHU-CHO"). Alternatively, it could be
a 6-digit local government code.}

\item{old_village}{String by regular expression. One or more old village name in Japanese to
be extracted.}

\item{community}{String by regular expression. One or more agricultural community name in
Japanese to be extracted.}

\item{all}{logical.}
}
\value{
A list of \code{\link[sf:sf]{sf::sf()}} object(s).
}
\description{
\code{extract_boundary()} extracts the specified data from the list returned by
\code{\link[=get_boundary]{get_boundary()}}.
}
\seealso{
\code{\link[=read_fude]{read_fude()}}.
}
