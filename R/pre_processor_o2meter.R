#' Preprocessor o2meter data
#'
#' Just copy from input to output
#'
#' @param input directory from which to read the data
#' @param output directory to which to write the data
#'
#' @return invisibly \code{TRUE} when completed successful
#'
#' @export

pre_processor_o2meter <- function(
  input,
  output
) {
  message("\n########################################################\n")
  message("\nProcessing o2meter\n")
  ##
  dir.create(
    file.path(output, "o2meter"),
    recursive = TRUE,
    showWarnings = FALSE
  )
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
  file.copy(
    from = file.path(input, "sample_metadata.yml"),
    to = file.path(output, "o2meter", "sample_metadata.yml")
  )

  ##
  message("done\n")
  message("\n########################################################\n")

  invisible(TRUE)
}
