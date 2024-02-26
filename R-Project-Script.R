library(tidyverse)
library(sf)
library(terra)
library(colorspace)


if(!require("install.load")){
  install.packages("install.load")
}

install.load::install_load(c("tidyverse", "sf", "terra"))


set.seed(1234)

# Vector Data

cholera <- st_read("Cholera-data-reshaped/cholera_modified.shp")

stack <- rast("Cholera-data-reshaped/stacked band.tif")

names(stack) = c('Aspect', 'builtuparea', 'Elevation', 'LST', 'LULCC', 'PopDensity', 'Poverty', 'Precipitation', 'Slope')

stacked <- spatSample(stack, 50000, method = "random", as.raster = TRUE)

extr <- extract(stack, cholera)

new_data <-  extr %>% 
  left_join(cholera, by = "ID")

analysis_data <- new_data %>% 
  slice_sample(prop = 0.02)
  
analysis_data %>% 
  write_rds("analysis_data.rds")
  

analysis_data <- read_rds("analysis_data.rds")

analysis_data_ <- analysis_data %>%
  group_by(ward_name) %>%
  group_split() %>%
  map_df(fill_missing_values, selected_variables = c("LULCC", "Aspect", "Slope", "builtuparea"))



analysis_data__ <- analysis_data_ %>%  
  mutate(LULCC = if_else(is.na(LULCC), 1.85, LULCC))

analysis_data__ %>% 
  write_rds("analysis_data_set2.rds")

analysis_data__ %>% 
  st_write("data-analysis/analysis_data.shp")



