#' Extractor o2meter data
#'
#' Convert all \code{.cvs} files in \code{o2meter} folder to \code{data.frame} and save as \code{.rds} file.
#'
#' This function is extracting data to be added to the database (and therefore make accessible for further analysis and forecasting)
#' from \code{.csv} files.
#'
#' @param input directory from which to read the data
#' @param output directory to which to write the data
#'
#' @return invisibly \code{TRUE} when completed successful
#'
#' @importFrom utils read.delim
#' @export
#'
extractor_o2meter <- function(
  input,
  output
) {
  message("\n########################################################\n")
  message("Extracting o2meter\n")

  # Get csv file names ------------------------------------------------------

  o2meter_path <- file.path( input, "o2meter" )
  fn <- list.files(
    path = o2meter_path,
    pattern = "*.csv",
    full.names = TRUE,
    recursive = TRUE
  )

  if (length(fn) == 0) {
    message("nothing to extract\n")
    message("\n########################################################\n")
    return(invisible(FALSE))
  }

  if (length(fn) > 1) {
    message("Only one file expected - aborting\n")
    message("\n########################################################\n")
    return(invisible(FALSE))
  }

  # Read file ---------------------------------------------------------------

  dat <- read.table(
    fn,
    skip = 1,
    fill = TRUE
  )
  names(dat) <- dat[1,]
  dat <- dat[c(-1, -nrow(dat)),]

  # SAVE --------------------------------------------------------------------

  add_path <- file.path( output, "o2meter" )
  dir.create( add_path, recursive = TRUE, showWarnings = FALSE )
  names(dat) <- tolower(names(dat))
  saveRDS(
    object = dat,
    file = file.path(add_path, "o2meter.rds")
  )
  file.copy(
    from = file.path(input, "sample_metadata.yml"),
    to = file.path(output, "sample_metadata.yml")
  )

  # Finalize ----------------------------------------------------------------

  message("done\n")
  message("\n########################################################\n")

  invisible(TRUE)
}
