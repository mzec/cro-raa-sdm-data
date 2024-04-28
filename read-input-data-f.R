

get_filelist_cro <- function(inputpath) {
  filelist <- list.files(path = inputpath, 
                         pattern = "xlsx", 
                         recursive = TRUE,
                         full.names = TRUE)
  filelist <- filelist[!grepl(pattern = "~", filelist)]
  # filters out ~ (temporary?) files
  filelist <- filelist[!grepl("[Ss]tan", filelist)]
  # filter out habitat descriptions
  return(filelist)
  # OUTPUT: list of files with breeding observations
}

read_observations_cro <- function(filename) {
  sheets <- excel_sheets(filename)
  sheet_cols <- c()
  
  for (sheet in sheets) {
    # first read is just to read the first couple of rows in all sheets
    # in order to identify the sheet with the data (assumed to be the 
    # one with the most columns, because it's not always the first sheet)
    header <- read_excel(filename, sheet = sheet, n_max = 10) 
    sheet_cols <- append(sheet_cols, ncol(header))
  }
  obstable <- read_excel(filename, sheet = which.max(sheet_cols)) %>% 
    # breeding status: column name can vary slightly, 
    # so fuzzy matching is used to pick it up
    rename(status = contains("gniježđ"),
           spc = matches("^Validn.*?svojte$")) %>% 
    mutate(# species: incl. fixing capitalization on some entries 
      spc = str_to_sentence(as.character(spc)),
      # number of observed individuals
      pres_abs = as.numeric(`Broj opaženog`),
      # unit for the observation, e.g. "pair", "individual"
      unit_obs = as.character(`Jedinica opažanja`),
      status = as.character(status),
      # x coordinate (HTRS96)
      x = as.numeric(`X koordinata`),
      # y coordinate (HTRS96)
      y = as.numeric(`Y koordinata`),
      # year, month, day are picked up separately and
      # discarded after being pasted into a single date column
      year = as.numeric(`Godina opažanja`),
      month = as.numeric(`Mjesec opažanja`),
      day = as.numeric(`Dan opažanja`),
      date = paste(year, month, day, sep = '-'),
      # sampling method: point transect, haphazard, vantage point, ...
      sampling_method = as.character(`Način opažanja`),
      # source folder and file name (folder also denotes species group)
      folder = dirname(filename),
      file = basename(filename),
      .keep = "none") %>% 
    select(-year, -month, -day) %>% 
    relocate(status, .before = x)
  return(obstable)
}

