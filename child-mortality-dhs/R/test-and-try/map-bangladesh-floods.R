# DHS Bangladesh exploration

library(here)

source(here("child-mortality-dhs/R", "0-config.R"))


## Load data
# Birth recode
BDBR_2017 <- read_dta(here("data/untouched/dhs", "BD_2017-18_DHS_02082022_855_172978/BDBR7RDT", "BDBR7RFL.DTA"))
BDBR_2014 <- read_dta(here("data/untouched/dhs", "BD_2014_DHS_02082022_855_172978/BDBR72DT", "BDBR72FL.DTA"))
BDBR_2011 <- read_dta(here("data/untouched/dhs", "BD_2011_DHS_02032022_1032_172978/BDBR61DT", "BDBR61FL.DTA"))
BDBR_2007 <- read_dta(here("data/untouched/dhs", "BD_2007_DHS_02032022_1033_172978/BDBR51DT", "BDBR51FL.DTA"))
BDBR_2004 <- read_dta(here("data/untouched/dhs", "BD_2004_DHS_02032022_1033_172978/BDBR4JDT", "BDBR4JFL.DTA"))

# Cluster' s GPS
BDBR_2017_GPS <- st_read(here("data/untouched/dhs", "BD_2017-18_DHS_02082022_855_172978/BDGE7SFL", "BDGE7SFL.shp"))
BDBR_2014_GPS <- st_read(here("data/untouched/dhs", "BD_2014_DHS_02082022_855_172978/BDGE71FL", "BDGE71FL.shp"))
BDBR_2011_GPS <- st_read(here("data/untouched/dhs", "BD_2011_DHS_02032022_1032_172978/BDGE61FL", "BDGE61FL.shp"))
BDBR_2007_GPS <- st_read(here("data/untouched/dhs", "BD_2007_DHS_02032022_1033_172978/BDGE52FL", "BDGE52FL.shp"))
BDBR_2004_GPS <- st_read(here("data/untouched/dhs", "BD_2004_DHS_02032022_1033_172978/BDGE4JFL" ,"BDGE4JFL.shp"))

# Flood
flood_jul_2004 <- stack(here("data/untouched/floods", "DFO_2507_From_20040620_to_20041007", "DFO_2507_From_20040620_to_20041007.tif"))
flood_jul_2007 <- stack(here("data/untouched/floods", "DFO_3136_From_20070721_to_20071015", "DFO_3136_From_20070721_to_20071015.tif"))

# Bangladesh admin
BG_Adm <- getData("GADM", country = "BGD", level = 1, path = here("data/untouched/country-admin"))

# Extract Flood exposure
# Crop flood map
flood_jul_2004_cropped <- crop(flood_jul_2004, BG_Adm)
flood_jul_2007_cropped <- crop(flood_jul_2007, BG_Adm)

# mapping
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7") # Color blind friendly palette
scales::show_col(cbbPalette)

# create your own color palette (36 colors) based on `seedcolors`
P90 = createPalette(90,  c("#ff0000", "#00ff00", "#0000ff"))

pal_flood <- colorFactor(c("#FFFFCC", "#0C2C84"), values(flood_jul_2007_cropped[[1]]),
                         na.color = "#FFFFCC")

# pal_washB <- colorFactor(c("red", "black", "black", "black", "black", "black", "black"), levels(washB$tr))
pal_dhsyear <- colorFactor(palette = P90, unique(BDBR_GPS$DHSYEAR))


map <- leaflet() %>% 
  addProviderTiles(providers$Esri.WorldGrayCanvas, "Default") %>%
  addProviderTiles(providers$Esri.NatGeoWorldMap, group = "National Geographic") %>%
  addPolygons(data = BG_Adm,
              color = "black",
              weight = 3,
              fillOpacity = 0) %>%
  #Exposure floods
  addRasterImage(flood_jul_2004_cropped[[1]], colors = pal_flood, opacity = 0.5, project = FALSE, group = "2004 flood") %>%
  addRasterImage(flood_jul_2007_cropped[[1]], colors = pal_flood, opacity = 0.5, project = FALSE, group = "2007 flood") %>%
  
  #DHS clusters
  addCircles(data = BDBR_2004_GPS, color = "#E69F00", opacity = 0.8, group = "DHS clusters 2004") %>%
  addCircles(data = BDBR_2007_GPS, color = "#56B4E9", opacity = 0.8, group = "DHS clusters 2007") %>%
  addCircles(data = BDBR_2011_GPS, color = "#009E73", opacity = 0.8, group = "DHS clusters 2011") %>%
  addCircles(data = BDBR_2014_GPS, color = "#0072B2", opacity = 0.8, group = "DHS clusters 2014") %>%
  addCircles(data = BDBR_2017_GPS, color = "#D55E00", opacity = 0.8, group = "DHS clusters 2017") %>%
  # addCircles(data = washB, color = ~pal_washB_blocks(block))
  addLegend(colors = c("#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00"), labels = c("DHS clusters 2004", "DHS clusters 2007", "DHS clusters 2011", "DHS clusters 2014", "DHS clusters 2017")) %>%
  # Layers control
  addLayersControl(
    baseGroups = c("Default", "National Geographic"),
    overlayGroups = c("DHS clusters 2004", "DHS clusters 2007", "DHS clusters 2011", "DHS clusters 2014", "DHS clusters 2017", "2007 flood", "2004 flood"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  hideGroup(c("2007 flood", "2004 flood")) %>%
  addScaleBar()

map


