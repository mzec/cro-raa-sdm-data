library(tidyverse)
library(readxl)
library(stringr)

source("C:/Users/mate.zec/Documents/Code/hrvatska-raa/read-input-data-birds.R")
# reads both the OPKK_SMART and OPKK_MONITORING bird folders and stores
# the observations in 'opkkmon' and 'opkksmart' variables

setwd("C:/Users/mate.zec/Documents/Code/hrvatska-raa/")

opkkbirds <- bind_rows(opkkmon, opkksmart)

# cleaning and translation of the messy nesting/breeding status columns
opkkbirds <- opkkbirds %>% 
  filter(!is.na(spc)) %>%                # remove entries with NA values for species name
  filter(!grepl("^.* sp\\.$", spc)) %>%  # remove genus-level ("sp.") entries
  mutate(status = str_to_lower(status)) %>% 
  mutate(status_eng = case_when(
    grepl("migra", status) ~ "migration",
    grepl("zimov", status) ~ "wintering",
    grepl("ljetov", status) ~ "summering",
    grepl("negnij", status) ~ "non-breeding",
    grepl("izvan gnijezda", status) ~ "juvenile/adults outside of nest",
    grepl("\\d+", status) ~ NA,
    grepl("teritorijalno", status) ~ "territorial behavior",
    grepl("teritorij", status) ~ "territory",
    grepl("vjeroj.+gnij.+", status) ~ "probable breeding site",
    grepl("stan.+gnij.+", status) ~ "breeding habitat",
    grepl("neakt.+gnij.+", status) ~ "inactive nest",
    grepl("^akt.+gnij.+", status) ~ "active nest",
    grepl("fekal", status) ~ "fecal sac or feeding behavior",
    grepl("^gni?j.?", status) ~ "nesting",
    grepl("^grad.*gni?j.?", status) ~ "nest construction",
    grepl("^kori.*gni?j.*bez ptica", status) ~ "unoccupied former nest",
    grepl("jajima", status) ~ "nest with eggs or incubating bird",
    grepl("s mladima", status) ~ "nest with juveniles",
    grepl("par", status) ~ "pair",
    grepl("svadbeni let", status) ~ "courtship flight",
    grepl("svadbeno", status) ~ "courtship",
    grepl("udvaranje", status) ~ "courtship",
    grepl("pjevali.te", status) ~ "lek",
    grepl("pjevaju", status) ~ "singing male",
    grepl("odvra.anje", status) ~ "distraction display",
    grepl("prelet", status) ~ "flight",
    grepl("upozor", status) ~ "warning call",
    grepl("^nepoznat.*", status) ~ "undetermined",
    grepl("^nije utvr.*", status) ~ "undetermined",
    .default = status
  )) %>% 
  mutate(breeding = case_when(       # code which obs are considered breeding 
    grepl("migra", status) ~ F,      # in a logical column called 'breeding'
    grepl("zimov", status) ~ F,
    grepl("ljetov", status) ~ F,
    grepl("negnij", status) ~ F,
    grepl("izvan gnijezda", status) ~ F,
    grepl("\\d+", status) ~ F,
    grepl("teritorijalno", status) ~ TRUE,
    grepl("teritorij", status) ~ TRUE,
    grepl("vjeroj.+gnij.+", status) ~ TRUE,
    grepl("stan.+gnij.+", status) ~ TRUE,
    grepl("neakt.+gnij.+", status) ~ TRUE,
    grepl("^akt.+gnij.+", status) ~ TRUE,
    grepl("fekal", status) ~ TRUE,
    grepl("^gni?j.?", status) ~ TRUE,
    grepl("^grad.*gni?j.?", status) ~ TRUE,
    grepl("^kori.*gni?j.*bez ptica", status) ~ TRUE,
    grepl("jajima", status) ~ TRUE,
    grepl("s mladima", status) ~ TRUE,
    grepl("par", status) ~ TRUE,
    grepl("svadbeni let", status) ~ TRUE,
    grepl("svadbeno", status) ~ TRUE,
    grepl("udvaranje", status) ~ TRUE,
    grepl("pjevali.te", status) ~ TRUE,
    grepl("pjevaju", status) ~ TRUE,
    grepl("odvra.anje", status) ~ TRUE,
    grepl("prelet", status) ~ F,
    grepl("upozor", status) ~ F,
    grepl("^nepoznat.*", status) ~ F,
    grepl("^nije utvr.*", status) ~ F,
    .default = F
  ))

write_csv(opkkbirds, file = "C:/Users/mate.zec/Documents/Code/hrvatska-raa/output/cleaned_table_ALL_birds.csv")

# how many records are there?
opkkbirds %>% nrow()

# how many of them for breeding birds?
opkkbirds %>% filter(breeding) %>% nrow()

# how many breeding birds in total?
opkkbirds %>% filter(breeding) %>% pull(pres_abs) %>% sum(na.rm = TRUE)

# how many breeding records and observed breeding birds per species?
opkkbirds %>%
  filter(breeding) %>% 
  select(spc, pres_abs) %>% 
  group_by(spc) %>% 
  summarize(breeding_records = n(),
            observed_birds = sum(pres_abs, na.rm = TRUE))



