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
  message("Extracting o2meter\n")
  if ( length( list.files( file.path(input, "o2meter") ) ) == 0 ) {
    message("\nEmpty or missing o2meter directory - nothing to do.\n")
    message("\ndone\n")
    message("########################################################\n")
    return(invisible(TRUE))
  }

  dir.create(
    file.path(output, "o2meter"),
    recursive = TRUE,
    showWarnings = FALSE
  )
  loggit::set_logfile(file.path(output, "o2meter", "o2meter.log"))

  message("\n########################################################\n")

  # Get csv file names ------------------------------------------------------

  o2meter_path <- file.path( input, "o2meter" )
  fn <- list.files(
    path = o2meter_path,
    pattern = "*.csv",
    full.names = TRUE,
    recursive = TRUE
  )


  fn <- grep("composition|experimental_design|dilution", fn, invert = TRUE, value = TRUE)
  fn <- grep(".csv", fn, value = TRUE)

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

  timestamp <- yaml::read_yaml(file.path(input, "o2meter", "sample_metadata.yml"))$timestamp

  if (grepl("3.0.3.1653", readLines(fn, n = 1))) {
    dat <- utils::read.delim(
      fn,
      skip = 1,
      sep = ",",
      quote = "\"",
      fill = TRUE,
      fileEncoding = "ISO-8859-1"
    )

    names(dat) <- gsub("X\\.|\\.", "", names(dat))

    empty_line <- which(apply(is.na(dat) | dat == "", 1, all))
    if (length(empty_line > 0)) {
      dat <- dat[1:(empty_line - 1), ]
    }

    dat <- dat[-nrow(dat),]

  } else if (grepl("Date;Time;User;SensorID;", readLines(fn, n = 1))) {
    defnames <- c(
      "Date", "Time", "Channel", "User", "SensorID", "Sensor_Name",
      "delta_t", "Time_Unit", "Value", "O2_Unit",
      "Mode", "Phase", "Phase_Unit", "Amplitude", "Amplitude_Unit", "Temp", "Temp_Unit",
      "Pressure", "Pressure_Unit", "Salinity", "Salinity_Unit", "Error",
      "Cal0", "Cal0_Unit", "T0", "T0_Unit", "O2Cal2nd", "O2_Unit1",
      "Cal2nd", "Cal2nd_Unit", "T2nd", "T2nd_Unit", "CalPressure",
      "CalPressure_Unit", "f1", "dPhi1", "dkSv1", "dPhi2", "dkSv2",
      "m", "Cal_Mode", "SignalLEDCurrent", "User_Signal_Intensity",
      "ReferenceLEDCurrent", "Reference_Amplitude", "Device_Serial",
      "FwVersion", "SwVersion", "Sensor_Type", "BatchID", "Calibration_Date",
      "Sensor_Lot", "PreSens_Calibr", "Battery_Voltage", "Battery_Voltage_Unit"
    )
    fw <- read.delim(fn, nrows=0, sep = ";", quote = "",fileEncoding = "ISO-8859-1" )[["FwVersion"]]
    fw <- unique(fw)
    fw <- trimws(fw)
    fw <- fw[fw!=""]
    if (length(fw) != 1){
      stop("Non unique Firmware version in O2 file.")
    }

    switch(
      fw,
      p1.2.0. = {
        defnames <- defnames
        dat <- utils::read.delim(
          fn,
          skip = 1,
          col.names = defnames,
          sep = ";",
          quote = "",
          fill = TRUE,
          fileEncoding = "ISO-8859-1"
        )
        dat <- dat[,-ncol(dat)]
        dat <- dat[-nrow(dat),]
      },
      p1.2.0.1 = {
        defnames <- c(defnames[-c(3, 43, 48)], "DELETE")
        dat <- utils::read.delim(
          fn,
          header = FALSE,
          skip = 1,
          col.names = defnames,
          sep = ";",
          quote = "",
          fill = TRUE,
          fileEncoding = "ISO-8859-1"
        )
        dat <- dat[-nrow(dat),]
        dat <- dat[,-ncol(dat)]
      },
      p1.2.0.6 = {
        defnames <- c(defnames[-c(3, 43, 48)], "DELETE")
        dat <- utils::read.delim(
          fn,
          header = FALSE,
          skip = 1,
          col.names = defnames,
          sep = ";",
          quote = "",
          fill = TRUE,
          fileEncoding = "ISO-8859-1"
        )
        dat <- dat[-nrow(dat),]
        dat <- dat[,-ncol(dat)]
      },
      stop("Not recognised Firmware Version in O2 file!")
    )



    # prev <- Sys.getlocale("LC_TIME")
    # Sys.setlocale("LC_TIME", "de_DE")
    ## TODO This is not nice - have to rethink other solutions!!!!!
    dat$Date <- gsub("-20$", "-2020", dat$Date)
    dat$Date <- gsub("-21$", "-2021", dat$Date)
    dat$Date <- gsub("-22$", "-2022", dat$Date)
    dat$Date <- gsub("-23$", "-2023", dat$Date)
    dat$Date <- gsub("-24$", "-2024", dat$Date)
    ## End Rethink
    dat$Date <- gsub("Jan", "Jan", dat$Date)
    dat$Date <- gsub("Feb", "Feb", dat$Date)
    dat$Date <- gsub("Mär", "Mär", dat$Date)
    dat$Date <- gsub("Apr", "Apr", dat$Date)
    dat$Date <- gsub("Mai", "Mai", dat$Date)
    dat$Date <- gsub("Jun", "Jun", dat$Date)
    dat$Date <- gsub("Jul", "Jul", dat$Date)
    dat$Date <- gsub("Aug", "Aug", dat$Date)
    dat$Date <- gsub("Sep", "Sep", dat$Date)
    dat$Date <- gsub("Okt", "Oct", dat$Date)
    dat$Date <- gsub("Nov", "Nov", dat$Date)
    dat$Date <- gsub("Dez", "Dec", dat$Date)
    dat$Date <- format(
      as.Date(
        as.character(dat$Date),
        format = "%d-%b-%Y"
      ),
      format = "%m/%d/%Y"
    )
    # Sys.setlocale("LC_TIME", prev)
  }

  # filter out the timestamp
  today_dat <- as.Date(as.character(dat$Date), format = "%m/%d/%Y") == as.Date(as.character(timestamp), format = "%Y%m%d")
  dat <- dat[today_dat,]

  for (i in 1:nrow(dat)) {
    dat[i,] <- gsub('"', '', dat[i,])
  }

  dat[dat == "ÂµV"] <- "microV"
  dat[dat == "Â°C"] <- "C"




  # dat$Value[dat$Value == "---"] <- NA
  dat <- dat[dat$Value != "---", ]
  dat$Value <- as.numeric(dat$Value)

  ## B_01_400
  sensor_name <- strsplit(
    dat$Sensor_Name,
    split = "_"
  )
  sensor_name <- do.call(rbind, sensor_name)
  sensor_name <- data.frame(sensor_name)

	dat <- cbind(
		timestamp = timestamp,
  	bottle = sprintf("b_%02d", as.integer(sensor_name[[2]])),
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
