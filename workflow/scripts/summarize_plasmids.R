import_plasmid <- function(plasmid_file){
  
  logger::log_debug(glue::glue("Importing result file: {plasmid_file}"))
  plasmid_raw <- readr::read_tsv(
    file = plasmid_file, col_types = readr::cols(),
    name_repair = janitor::make_clean_names, id = "sample"
  )
  
  logger::log_debug(glue::glue("Separating query and calculating coverage"))
  plasmid_coverage <- dplyr::mutate(
    .data = tidyr::separate_wider_delim(
      data = plasmid_raw,
      cols = query_template_length, delim = " / ",
      names = c("query_size", "query_length")
    ),
    sample = dirname(sample) |> basename(),
    coverage = as.numeric(query_size) / as.numeric(query_length) * 100,
    .before = identity
  )
  
  # Provide relevant columns
  plasmid <- dplyr::select(
    plasmid_coverage,
    sample, plasmid, coverage, identity, accession_number, database
  )
  
  logger::log_debug(glue::glue("Result_file successfully imported!"))
  return(plasmid)
}


summarize_plasmids <- function(plasmid_files, threshold, summary_file){
  logger::log_info("Importing plasmid files")
  plasmids <- purrr::map_dfr(plasmid_files, import_plasmid)
  
  logger::log_info(glue::glue("Filtering percentages to threshold: {threshold}"))
  plasmids_filtered <- dplyr::filter(plasmids, coverage >= threshold, identity >= threshold)
  
  logger::log_info("Writing plasmid summary")
  readr::write_tsv(x = plasmids_filtered, file = summary_file)
}

logger::log_threshold(level = logger::INFO)

plasmid_files <- unique(snakemake@input[["plasmid_files"]])
threshold <- snakemake@params[["threshold"]]
dbg <- snakemake@params[["debug"]]
summary_file <- snakemake@output[["summary_file"]]

if (dbg){
  logger::log_threshold(level = logger::DEBUG)
  save(
    snakemake,
    file = file.path(dirname(summary_file), "summarize_plasmids.RData")
  )
}

summarize_plasmids(plasmid_files, threshold, summary_file)
