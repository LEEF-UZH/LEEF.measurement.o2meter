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
  o2meter_files <- list.files(
    path = o2meter_path,
    pattern = "*.csv",
    full.names = TRUE,
    recursive = TRUE
  )

  if (length(o2meter_files) == 0) {
    message("nothing to extract\n")
    message("\n########################################################\n")
    return(invisible(FALSE))
  }

  # Read file ---------------------------------------------------------------
  colNames <- c(
    "date", "time", "user",
    "sensorid", "sensorname",
    "delta_t", "unit_delta_t",
    "value", "unit_value",
    "mode", "phase", "unit_phase",
    "amplitude", "unit_amplitude",
    "temp", "unit_temp",
    "patm", "unit_patm",
    "salinity", "unit_salinity",
    "error",
    "cal0", "unit_cal0",
    "t0", "unit_t0",
    "o2_2nd", "unit_o2_2nd",
    "cal2nd", "unit_cal2nd",
    "t2nd", "unit_t2nd",
    "calpressure", "unit_calpressure",
    "f1", "dphi1", "dksv1",
    "dphi2", "dksv2", "m",
    "cal_mode", "signalledcurrent",
    "referenceledcurrent", "referenceamplitude",
    "deviceserial", "fwversion",
    "sensortype", "batchid",
    "calibration_date", "sensor_lot", "presens_calibrated_sensor",
    "battery_voltage", "unit_battery_voltage",
    "empty"
  )
  res <- lapply(
    o2meter_files,
    function(fn) {
      x <- read.delim(
        file = fn,
        sep = ";",
        skip = 2,
        header = FALSE,
        fill = TRUE,
        stringsAsFactors = FALSE,
        strip.white = TRUE,
        fileEncoding = "ISO-8859-1",
        col.names = colNames
      ) [-length(colNames)]
      f <- file(fn)
      attr(x, "PresensVersion") <- readLines(f, n = 1)
      close(f)
      return(x)
    }
  )
  # combine intu one large tibble
  res <- do.call(rbind, res)  ## dplyr::bind_rows(res)
  ## res <- dplyr::filter(res, date != "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

  # SAVE --------------------------------------------------------------------

  add_path <- file.path( output, "o2meter" )
  dir.create( add_path, recursive = TRUE, showWarnings = FALSE )
  names(res) <- tolower(names(res))
  saveRDS(
    object = res,
    file = file.path(add_path, "o2meter.rds")
  )

  # Finalize ----------------------------------------------------------------

  message("done\n")
  message("\n########################################################\n")

  invisible(TRUE)
}
