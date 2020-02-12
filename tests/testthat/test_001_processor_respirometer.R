
# Setup -------------------------------------------------------------------

hash <- function(dir) {
  new_files <- list.files(dir, full.names = FALSE, recursive = TRUE)
  x <- lapply(
    new_files,
    function(fn) {
      fnc <- file.path( dir, fn )
      f <- file( fnc, open = "rb" )
      hash <- as.character( openssl::sha256( f ) )
      close(f)
      rm(f)
      hash <- paste(hash, fn, sep = "  ")
    }
  )
  unlist(x)
}

raw <- system.file( "0.raw.data", package = "LEEF.measurement.respirometer")
pre_processed <- tempfile(pattern = "test_processed_")
extracted <- tempfile(pattern = "test_extracted_")

# Skip if data not there --------------------------------------------------

if (!file.exists(raw)) skip("Test data not available!")

# Test pre_processor ------------------------------------------------------

context("Test pre_processor_respirometer()")

test_that(
  "pre_processor_respirometer() runs without error",
  expect_error(
    object = suppressMessages( pre_processor_respirometer( input = raw, output = pre_processed ) ),
    regexp = NA
  )
)

test_that(
  "pre_processor_respirometer() returns correct result",
  expect_known_hash(
    hash( file.path(pre_processed, "respirometer") ),
    hash = "381e24de24"
  )
)


# Test extractor ----------------------------------------------------------


context("Test extractor_respirometer()")

test_that(
  "extractor_respirometer() runs without error",
  expect_error(
    object = suppressMessages( extractor_respirometer( input = pre_processed, output = extracted) ),
    regexp = NA
  )
)

test_that(
  "extractor_respirometer() returns correct result",
  expect_known_hash(
    hash( file.path(extracted, "respirometer") ),
    hash = "5fdc0b5f85"
  )
)


# Teardown ----------------------------------------------------------------

unlink(pre_processed, recursive = TRUE, force = TRUE)
unlink(extracted, recursive = TRUE, force = TRUE)

