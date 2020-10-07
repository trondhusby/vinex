## title: map of vinex uitleglocaties
## author: trond
## date: 02.07.2020

## house keeping
library(ggplot2)
library(sf)
library(cbsshape)
library(rgdal)

test <- readOGR(dsn = "../data/vinex_files/VierdeNotaRO_1993_VinexLoc_RPD.lyr")

test <- read_sf("../data/vinex_files/VierdeNotaRO_1993_VinexLoc_RPD.lyr.xml")

## read data
vinex_shp <- read_sf('../data/vinex_2013_shape')
bw_kaart_2013 <- cbs_shape_read(2013, level="gem")

## map
ggplot(subset(bw_kaart_2013, WATER == 'NEE')) +
    geom_sf(col = 'grey', fill = NA) + 
    geom_sf(data = vinex_shp, fill = 'forestgreen', col = 'forestgreen') +
    theme_void()
ggsave('../figs/vinex_map.png')

## end of code
