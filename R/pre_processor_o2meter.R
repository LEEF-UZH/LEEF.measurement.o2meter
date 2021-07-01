#' Preprocessor o2meter data
#'
#' Just copy from input to output
#'
#' @param input directory from which to read the data
#' @param output directory to which to write the data
#'
#' @return invisibly \code{TRUE} when completed successful
#'
#' @import loggit
#' @export

pre_processor_o2meter <- function(
  input,
  output
) {
  dir.create(
    file.path(output, "o2meter"),
    recursive = TRUE,
    showWarnings = FALSE
  )
  loggit::set_logfile(file.path(output, "flowcam", "flowcam.log"))

  message("\n########################################################\n")
  message("\nProcessing o2meter\n")
  ##
  if ( length( list.files( file.path(input, "o2meter") ) ) == 0 ) {
    message("\nEmpty or missing o2meter directory - nothing to do.\n")
    message("\ndone\n")
    message("########################################################\n")
    return(invisible(TRUE))
  }


  file.copy(
    file.path( input, "..", "00.general.parameter", "." ),
    file.path( output, "o2meter" ),
    recursive = TRUE,
    overwrite = TRUE
  )

  file.copy(
    from = file.path(input, "o2meter", "."),
    to = file.path(output, "o2meter"),
    recursive = TRUE
  )


  ##
  message("done\n")
  message("\n########################################################\n")

  invisible(TRUE)
}
