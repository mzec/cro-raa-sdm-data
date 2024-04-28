library(tidyverse)
library(readxl)
library(stringr)

source("C:/Users/mate.zec/Documents/Code/hrvatska-raa/read-input-data-f.R")

setwd("C:/Users/mate.zec/Documents/Raw Data/OPKK_SMART/G5_PTICE/")

br2022 <- lapply(get_filelist_cro("Međuizvjeće_gnjezdarice_2022/"), FUN = read_observations_cro)
br2023 <- lapply(get_filelist_cro("Međuizvješće_gnjezdarice_2023/"), FUN = read_observations_cro)
wint <- lapply(get_filelist_cro("Međuizvješće_zima_2021_2023/"), FUN = read_observations_cro)
autumn <- lapply(get_filelist_cro("Međuizvješće_jesen/"), FUN = read_observations_cro)
mig2022 <- lapply(get_filelist_cro("Međuizvješće_proljeće_2022/"), FUN = read_observations_cro)
mig2023 <- lapply(get_filelist_cro("Međuizvješće_proljeće_2023/"), FUN = read_observations_cro)

opkksmart <- bind_rows(br2022, br2023, wint, autumn, mig2022, mig2023) %>% 
  filter(!is.na(spc) & spc != "-") %>% 
  mutate(source = "OPKK_SMART")

nrow(unique(select(opkksmart, folder, file))) # total number of files parsed
length(unique(opkksmart$spc)) # total number of species recorded
sum(opkksmart$pres_abs, na.rm = TRUE) # total number of presence points

# copy input files for reference
parsed_files <- c(
  get_filelist_cro("Međuizvjeće_gnjezdarice_2022/"),
  get_filelist_cro("Međuizvješće_gnjezdarice_2023/"),
  get_filelist_cro("Međuizvješće_zima_2021_2023/"),
  get_filelist_cro("Međuizvješće_jesen/"),
  get_filelist_cro("Međuizvješće_proljeće_2022/"),
  get_filelist_cro("Međuizvješće_proljeće_2023/"))

for (i in parsed_files) {
  file.copy(from = i,
            to = "C:/Users/mate.zec/Documents/Code/hrvatska-raa/input/")
}
rm(parsed_files)

# write all the read data to csv
write_csv(opkksmart, file = "C:/Users/mate.zec/Documents/Code/hrvatska-raa/output/cleaned_table_SMART_birds.csv")

setwd("C:/Users/mate.zec/Documents/Raw Data/OPKK_MONITORING/G3_ptice/")

src_opkkmon_wetlands <- "6_Izvjesce_testiranje_RP4/Prilog 1/Program močvarice_testiranje/Opazanja_mocvarice/Monitoring_SVE_mocvarice_ne-pjevice_RP4.xlsx"
src_opkkmon_forests <- "6_Izvjesce_testiranje_RP4/Prilog 1/Program sume_testiranje/Sumske_ptice_opazanja/0_svaopazanja_sume_2023_RP4.xlsx"
src_opkkmon_reedbeds <- "6_Izvjesce_testiranje_RP4/Prilog 1/Program_mocvarice_pjev_test/Opazanja_mocv_pjevice/Pjevice_trscaka_rezultati_2023_RP4.xlsx"

opkkmon_wetlands <- read_observations_cro(src_opkkmon_wetlands)
opkkmon_forests <- read_observations_cro(src_opkkmon_forests)
opkkmon_reedbeds <- read_observations_cro(src_opkkmon_reedbeds)

opkkmon <- bind_rows(opkkmon_wetlands,
                     opkkmon_forests,
                     opkkmon_reedbeds) %>% 
  mutate(source = "OPKK_MONITORING")


nrow(unique(select(opkkmon, folder, file))) # total number of files parsed
length(unique(opkkmon$spc)) # total number of species recorded
sum(opkkmon$pres_abs, na.rm = TRUE) # total number of presence points

# copy input files for reference
parsed_files <- c(
  src_opkkmon_wetlands,
  src_opkkmon_forests,
  src_opkkmon_reedbeds
)

for (i in parsed_files) {
  file.copy(from = i,
            to = "C:/Users/mate.zec/Documents/Code/hrvatska-raa/input/")
}
rm(parsed_files)

# write all the read data to csv
write_csv(opkkmon, file = "C:/Users/mate.zec/Documents/Code/hrvatska-raa/output/cleaned_table_MONITORING_birds.csv")

