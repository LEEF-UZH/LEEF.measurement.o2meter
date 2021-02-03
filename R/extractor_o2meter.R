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
#' @importFrom utils read.delim write.csv
#' @importFrom yaml read_yaml
#'
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

	fn <- grep("composition|experimental_design|dilution", fn, invert = TRUE, value = TRUE)

  if (length(fn) == 0) {
    message("nothing to extract\n")
    message("\n########################################################\n")
    return(invisible(TRUE))
  }

  if (length(fn) > 1) {
    message("Only one file expected - aborting\n")
    message("\n########################################################\n")
    return(invisible(FALSE))
  }

  # Read file ---------------------------------------------------------------

  # to get possible encodings:
  # readr::guess_encoding(fn)

  dat <- utils::read.delim(
    fn,
    skip = 1,
    sep = ",",
    quote = "",
    fill = TRUE,
    fileEncoding = "ISO-8859-1"
  )

	names(dat) <- gsub("X\\.|\\.", "", names(dat))

	for (i in 1:nrow(dat)) {
	  dat[i,] <- gsub('"', '', dat[i,])
	}

  dat[dat == "µV"] <- "microV"
  dat[dat == "°C"] <- "C"

	empty_line <- which(apply(is.na(dat) | dat == "", 1, all))
	if (length(empty_line > 0)) {
	  dat <- dat[1:(empty_line - 1), ]
	}

	dat <- dat[-nrow(dat),]

  timestamp <- yaml::read_yaml(file.path(input, "o2meter", "sample_metadata.yml"))$timestamp


  ## B_01_400
  sensor_name <- strsplit(
    dat$Sensor_Name,
    split = "_"
  )
  sensor_name <- do.call(rbind, sensor_name)
  sensor_name <- data.frame(sensor_name)

	dat <- cbind(
		timestamp = timestamp,
  	bottle = as.integer(sensor_name[[2]]),
  	sensor = as.integer(sensor_name[[3]]),
  	dat
  )


  # SAVE --------------------------------------------------------------------

  add_path <- file.path( output, "o2meter" )
  dir.create( add_path, recursive = TRUE, showWarnings = FALSE )
  utils::write.csv(
    dat,
    file = file.path(add_path, "o2meter.csv"),
    row.names = FALSE
  )

  fns <- grep(
    basename(fn),
    list.files(file.path(input, "o2meter")),
    invert = TRUE,
    value = TRUE
  )
  file.copy(
    from = file.path(input, "o2meter", fns),
    to = file.path(output, "o2meter", "")
  )

  # Finalize ----------------------------------------------------------------

  message("done\n")
  message("\n########################################################\n")

  invisible(TRUE)
}
