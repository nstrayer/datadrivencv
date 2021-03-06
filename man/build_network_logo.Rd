% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build_network_logo.R
\name{build_network_logo}
\alias{build_network_logo}
\title{Build interactive network logo}
\usage{
build_network_logo(position_data)
}
\arguments{
\item{position_data}{position data from your \code{CV_Printer} class.}
}
\value{
Interactive force-directed layout network of your CV data
}
\description{
Constructs a network based on your position data to be used as a logo.
Interactive in HTML version and static in the PDF version. Notes are entries,
colored by section and connected if they occurred in the same year
}
