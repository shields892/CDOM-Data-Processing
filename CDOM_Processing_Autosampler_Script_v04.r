rm(list = ls())

library(tidyverse)
library(readxl)
library(writexl)
library(purrr)
library(lemon)

{
  base_font_size = 8 #Default Font size in points.
  base_font_family = "serif" #Default font family.
  unit <- function(...,units="mm"){grid::unit(...,units=units)} #Set default units to mm
  margin <- function(...,unit="mm"){ggplot2::margin(...,unit=unit)} #Same as above, but for the margin comment.
  
  theme_set(theme(line = element_line(color="black",linewidth =0.25,linetype=1,lineend="butt",arrow=F,inherit.blank=T),
                  rect = element_rect(fill=NA,color="black",linewidth=0.25,linetype=1,inherit.blank=T),
                  text = element_text(family="serif",face="plain",color="black",size=base_font_size,hjust=0.5,vjust=0.5,
                                      angle=0,lineheight=0.9,margin=margin(0,0,0,0),debug=F),
                  axis.title.x = element_text(margin=margin(2.75,0,0,0),inherit.blank = T),
                  axis.title.x.top = element_text(margin=margin(0,0,2.75,0),inherit.blank = T),
                  axis.title.y = element_text(vjust = 1,angle=90,margin=margin(0,2.75,0,0),inherit.blank = T),
                  axis.title.y.right = element_text(vjust = 0,angle=-90,margin=margin(0,0,0,2.75),inherit.blank = T),
                  axis.text = element_text(inherit.blank = T),
                  axis.text.x = element_text(margin=margin(0.75,0,0,0),inherit.blank = T),
                  axis.text.x.top = element_text(vjust=0,margin=margin(0,0,0.75,0),inherit.blank = T),
                  axis.text.y = element_text(hjust=1,margin=margin(0,0.75,0,0),inherit.blank = T),
                  axis.text.y.right = element_text(hjust=0,margin=margin(0,0,0,0.75),inherit.blank = T),
                  axis.ticks = element_line(linewidth=0.2,inherit.blank = T),
                  axis.ticks.x = element_line(linewidth=0.2,inherit.blank = T),
                  axis.ticks.y = element_line(linewidth=0.2,inherit.blank = T),
                  axis.ticks.length = unit(1),
                  axis.line = element_line(inherit.blank = T),
                  axis.line.x = element_line(inherit.blank = T),
                  axis.line.y = element_line(inherit.blank = T),
                  legend.background = element_blank(), #default is element_rect()
                  legend.margin = margin(2,2,2,2),
                  legend.spacing = unit(4),
                  legend.spacing.x = unit(4),
                  legend.spacing.y = unit(4),
                  legend.key = element_blank(), #default is element_rect()
                  legend.key.size = unit(2.5),
                  legend.key.height = unit(2.5),
                  legend.key.width = unit(2.5),
                  legend.text = element_text(inherit.blank = T,hjust = 0),
                  legend.title = element_text(hjust=0.5,inherit.blank = T),
                  legend.position = "top", # the position of legends ("none", "left", "right", "bottom", "top", or two-element numeric vector)
                  legend.direction = "horizontal", # layout of items in legends ("horizontal" or "vertical")
                  legend.justification = "center", #anchor point for positioning legend inside plot, default is "center"
                  legend.box = "horizontal", #arrangment of multiple legends ("horizontal" or "vertical")
                  legend.box.just = "left", # justification of each legend within the overall bounding box, when there are multiple legends ("top", "bottom", "left", or "right")
                  legend.box.margin = margin(0,0,0,0),
                  legend.box.background = element_blank(), #background of box around multiple legends
                  legend.box.spacing = unit(4),
                  panel.background = element_rect(fill="white",color=NA,inherit.blank = T),
                  panel.border = element_rect(fill=NA,color="black",inherit.blank = T),
                  panel.spacing = unit(2), #Space between facets
                  panel.spacing.x = unit(2), #Space between facets
                  panel.spacing.y = unit(2), #Space between facets
                  panel.grid = element_blank(),
                  panel.grid.major = element_line(inherit.blank = T),
                  panel.grid.minor = element_line(inherit.blank = T),
                  panel.grid.major.x = element_line(inherit.blank = T),
                  panel.grid.major.y = element_line(inherit.blank = T),
                  panel.grid.minor.x = element_line(inherit.blank = T),
                  panel.grid.minor.y = element_line(inherit.blank = T),
                  panel.ontop = F, #Place the panel on top of the plot? Not sure why this is here.
                  plot.background = element_rect(color=NA),
                  plot.title = element_text(hjust=0,vjust=1,margin=margin(0,0,2.75,0),inherit.blank = T),
                  plot.subtitle = element_text(hjust=0,vjust=1,margin=margin(0,0,1.5,0),inherit.blank = T),
                  plot.caption = element_text(hjust=1,vjust=1,margin=margin(1.5,0,0,0),inherit.blank = T),
                  plot.margin = margin(1.5,1.5,1,1),
                  strip.background = element_rect(color=NA,inherit.blank = T),
                  strip.placement = "inside", #'inside' or 'outside' relative to the axis ticks/text
                  strip.text = element_text(inherit.blank = T),
                  strip.text.x = element_text(margin=margin(2,0,2,0),inherit.blank = T),
                  strip.text.y = element_text(margin=margin(0,2,0,2),inherit.blank = T),
                  strip.switch.pad.grid = unit(1),
                  strip.switch.pad.wrap = unit(1),
                  complete = T,
                  validate = T))
}

Horiba_file_path <- "2024_09_25_02_VAD_photoOX"

files_pct <- list.files(path = Horiba_file_path,pattern = 'PCT.dat', full.names = TRUE) # Identify the percent transmittance (PCT) data files.  Note they must be in a folder titled "Horiba DAT data".
files_eem <- list.files(path = Horiba_file_path,pattern = "PEM.dat",full.names = TRUE) # Identify the processed EEM (PEM) data files.  Note they must be in a folder titled "Horiba DAT data".

# Read in the "PCT" data, trim the file column into a reasonable sample ID, and add new columns to fill in later.
sampleIDs_for_info_table <-
  map_df(files_pct, ~read.delim(.x, sep = "\t",header = F) %>% 
           mutate(File = basename(.x))) %>%
  separate(File,into = c("Sample_id",NA),sep = -7) %>%
  select(Sample_id) %>%
  unique(.) %>%
  mutate(Unique_id = "",
         Group01 = "",
         Group02 = "",
         Group03 = "")

write_xlsx(sampleIDs_for_info_table,"sample_info_template.xlsx")

# Specify the name of the worksheet containing your sample information that you have completed.
sample_info_path <- "sample_info.xlsx"

# Read in the sample information excel sheet.
sample_info <- read_excel(sample_info_path)

abs_data <- map_df(files_pct, ~read.delim(.x, sep = "\t",header = F) %>% 
                     mutate(File = basename(.x))) %>%
  separate(File,into = c("Sample_id",NA),sep = -7) %>%
  rename("Wavelength" = "V1",
         "Percent.T" = "V2") %>%
  full_join(sample_info) %>%
  mutate(Wavelength = as.numeric(Wavelength),
         Percent.T = as.numeric(Percent.T),
         Abs = 2 - log10(Percent.T)) %>%
  group_by(Sample_id) %>%
  mutate(abs_baseline = Abs[which(Wavelength == max(Wavelength))],
         abs_corrected = Abs - abs_baseline)

# Filter for the absorbance at 254 (find the closest wavelength to 254 nm first), convert to per meter, join in the DOC data and calculate SUVA254.
a254 <- 
  abs_data %>%
  filter(Wavelength == Wavelength[which.min(abs(Wavelength - 254))]) %>%
  mutate(a254_m1 = abs_corrected * 100) # %>%
# full_join(doc_data %>% filter(Analysis == "NPOC") %>% 
#             rename("Unique_id" = "Sample ID") %>% 
#             select(Unique_id,Concentration_mg.L)) %>%
# mutate(SUVA_254 = a254_m1/Concentration_mg.L)

# Filter the data and ln transform for calculating the S275-295 parameter
S275_295 <-
  abs_data %>%
  filter(Wavelength >= 275 & Wavelength <= 295) %>%
  mutate(abs_m1 = abs_corrected * 100,
         ln_abs_m1 = log(abs_m1),
         variable = "S275_295") 
# na.omit(.)

# Filter the data and ln transform for calculating the S350-400 parameter
S350_400 <-
  abs_data %>%
  filter(Wavelength >= 350 & Wavelength <= 400) %>%
  mutate(abs_m1 = abs_corrected * 100,
         ln_abs_m1 = log(abs_m1),
         variable = "S350_400") 
# na.omit(.)

# Join the two slope data tables
slope_data_joined <-
  full_join(S275_295,S350_400)

head(slope_data_joined)

# Calculate the slope parameters for the above plots and calculate the slope ration (SR)
slope_equation_parameters <-
  slope_data_joined %>%
  group_by(Sample_id,Unique_id,Group01,Group02,variable) %>%
  group_modify(~ broom::tidy(lm(ln_abs_m1 ~ Wavelength, data = .))) %>%
  filter(term == "Wavelength") %>%
  rename("slope" = estimate) %>%
  select(Sample_id,variable,slope) %>%
  pivot_wider(names_from = variable,values_from = slope) %>%
  mutate(Slope_ratio = S275_295/S350_400)

write_xlsx(slope_equation_parameters,"Slope_parameters.xlsx")

abs_plots <-
  abs_data %>% 
  filter(Wavelength >= 275 & Wavelength <= 500) %>%
  ggplot(aes(x = Wavelength,y = abs_corrected,color = Unique_id)) +
  geom_point(size = 0.5) +
  geom_path(linewidth = 0.5) +
  scale_x_continuous(n.breaks = 10) +
  xlab("Wavelength (nm)") +
  ylab("Absorbance (ODU)")+
  facet_wrap(~Group02,scales = "free_y") +
  guides(color = guide_legend(title = "Sample",title.position = "top"))

a254_plot <-
  a254 %>%
  ggplot(aes(Unique_id,a254_m1)) +
  geom_col(position = position_dodge2()) +
  theme(axis.text.x = element_text(angle = 90))

SUVA254_plot <-
  a254 %>%
  ggplot(aes(Unique_id,SUVA_254)) +
  geom_col(position = position_dodge2())

# Show the slope data in plots. 
slope_plots <-
  slope_data_joined %>%
  ggplot(aes(x = Wavelength,y = ln_abs_m1,color = Unique_id)) +
  geom_point(size = 0.5) +
  geom_smooth(linewidth = 0.5,method = "lm") +
  facet_rep_wrap(variable~Group01,scales = "free",nrow = 2) +
  xlab("Wavelength (nm)") +
  ylab("Log-transformed Absorbance (m-1)")

# Bar plot of the slope parameters
slope_parameter_plots <-
  slope_equation_parameters %>%
  pivot_longer(cols = S275_295:Slope_ratio,names_to = "variable",values_to = "value") %>%
  ggplot(aes(Unique_id,value,fill = Group01)) +
  geom_col(position = position_dodge2()) +
  facet_rep_wrap(~variable,scales = "free") +
  theme(axis.text.x = element_text(angle = 90))

# Read in the "PEM" files, rename the columns, 
eem_data <- map_df(files_eem, ~read.delim(.x, sep = "\t",header = T) %>% 
                     filter(!row_number() %in% c(1,2)) %>%
                     pivot_longer(2:length(.),names_to = "EX") %>%
                     mutate(File = basename(.x))) %>%
  separate(File,into = c("Sample_id",NA),sep = -7) %>%
  separate(EX,into = c(NA,"EX"),sep = 1) %>%
  rename("EM" = "Sample...Blank",
         "X" = value) %>%
  mutate(EX = as.numeric(EX),
         EM = as.numeric(EM),
         X = as.numeric(X)) %>%
  filter(EX >= 240 & EX <= 440) %>%
  filter(EM >= 280 & EM <= 600) %>%
  full_join(sample_info) %>%
  mutate(X = ifelse(X < 0,0,X)) #Added to eliminate whitespace from EEM plots

# Humification index
HIX <-
  eem_data %>%
  mutate(HIX_region = ifelse(EM >= 300 & EM <= 345,"region_300_345",
                             ifelse(EM >= 400 & EM <= 480,"region_435_480",F))) %>%
  filter(HIX_region != F) %>%
  group_by(Sample_id,Unique_id,Group01,Group02,HIX_region) %>%
  summarise(sum_intensity = sum(X)) %>%
  pivot_wider(names_from = HIX_region,values_from = sum_intensity) %>%
  mutate(HIX = region_435_480 / (region_300_345 + region_435_480)) 

write_xlsx(HIX,"HIX_data.xlsx")

HIX_at_EX254nm <- 
  eem_data %>%
  mutate(HIX_region = ifelse(EM >= 300 & EM <= 345,"region_300_345",
                             ifelse(EM >= 400 & EM <= 480,"region_435_480",F))) %>%
  filter(HIX_region != F) %>%
  group_by(Sample_id,Unique_id,Group01,Group02,HIX_region) %>%
  filter(EX == EX[which.min(abs(EX - 254))]) %>%
  summarise(sum_intensity = sum(X)) %>%
  pivot_wider(names_from = HIX_region,values_from = sum_intensity) %>%
  mutate(HIX = region_435_480 / (region_300_345 + region_435_480))

write_xlsx(HIX_at_EX254nm,"HIX_at_EX254nm_data.xlsx")

# Biological index
BIX <-
  eem_data %>%
  mutate(BIX_peak = ifelse(EM == EM[which.min(abs(EM - 380))],"F_380",
                           ifelse(EM == EM[which.min(abs(EM-430))],"F_430",F))) %>%
  filter(BIX_peak != F) %>%
  group_by(Sample_id,Unique_id,Group01,Group02,BIX_peak) %>%
  summarise(sum_intensity = sum(X)) %>%
  pivot_wider(names_from = BIX_peak,values_from = sum_intensity) %>%
  mutate(BIX = F_380 / F_430)  

write_xlsx(BIX,"BIX_data.xlsx")

# Fluorescence index (FI). The ratio of emission intensities at wavelengths 470 nm and 520 nm at excitation 370 nm.
FI <- 
  eem_data %>%
  filter(EX == EX[which.min(abs(EX - 370))]) %>%
  filter(EM == EM[which.min(abs(EM - 470))] | EM == EM[which.min(abs(EM - 520))]) %>%
  pivot_wider(names_from = EM, values_from = X) %>%
  rename("EM_470" = "470","EM_520" = "520") %>%
  mutate(FI = EM_470/EM_520)

write_xlsx(FI,"FI_data.xlsx")

# Following Table 1 from Shields et al. (2019), which is modified from Coble (2007) by Stedmon and Nelson (2015)
coble_peaks <-
  eem_data %>%
  mutate(EX_b_t_diff = abs(EX - 275),
         EX_A_diff = abs(EX - 260),
         EM_B_diff = abs(EM - 310),
         EM_T_diff = abs(EM - 340),
         EM_A_diff = abs(EM - 460)) %>%
  mutate(peak = ifelse(EX_b_t_diff == EX_b_t_diff[which.min(EX_b_t_diff)] & EM_B_diff == EM_B_diff[which.min(EM_B_diff)],"B",
                       ifelse(EX_b_t_diff == EX_b_t_diff[which.min(EX_b_t_diff)] & EM_T_diff == EM_T_diff[which.min(EM_T_diff)],"T",
                              ifelse(EX_A_diff == EX_A_diff[which.min(EX_A_diff)] & EM_A_diff == EM_A_diff[which.min(EM_A_diff)],"A",
                                     ifelse(EX >= 320 & EX <= 360 & EM <= 420 & EM >= 380,"M",
                                            ifelse(EX >= 290 & EX <= 310 & EM <= 480 & EM >= 420,"C",NA)))))) %>%
  filter(!is.na(peak))

# Find the max fluorescence value within each Coble Peak region 
coble_peaks_maxima <-
  coble_peaks %>%
  group_by(Sample_id,Unique_id,Group01,Group02,peak) %>%
  summarise(peak_maxima = max(X))

write_xlsx(coble_peaks_maxima,"Coble_Peaks.xlsx")

# Calculate additional ratios. See the USGS protocol pages 4 and 5 for descriptions and references 
coble_ratios <-
  coble_peaks_maxima %>%
  pivot_wider(names_from = peak,values_from = peak_maxima) %>%
  mutate(A_to_T = A/T,
         C_to_A = C/A,
         C_to_M = C/M,
         C_to_T = C/T)

write_xlsx(coble_ratios,"Coble_ratios.xlsx")

eem_plots <-
  eem_data  %>%
  filter(Group01 == "Sample") %>% # Filter however you want for presenting the data.
  ggplot(aes(x = EX,y = EM,z = X)) +
  geom_raster(aes(fill = X)) +
  geom_contour(color = "black",bins = 15,alpha = 0.25,linewidth = 0.1) +
  scale_fill_viridis_c(option = "H",guide = guide_colorbar(title = "Quinine Sulfate Units (QSU)",display = "raster")) +
  # guides(fill = guide_colorbar(title = "Quinine Sulfate Units (QSU)",nbin = 5)) +
  facet_rep_wrap(~Unique_id) +
  theme(legend.position = "right",
        legend.direction = "vertical") +
  xlab("Ex Wavelength (nm)") +
  ylab("Em Wavelength (nm)")

HIX_plot <-
  HIX %>%
  ggplot(aes(Unique_id,HIX,fill = Group01)) +
  geom_col(position = position_dodge2()) +
  xlab("Sample ID") +
  ylab("Humification Index (HIX)") +
  theme(axis.text.x = element_text(angle = 90))

BIX_plot <-
  BIX %>%
  filter(Group01 != "Blank") %>%
  ggplot(aes(Unique_id,BIX,fill = Group01)) +
  geom_col(position = position_dodge2()) +
  xlab("Sample ID") +
  ylab("Biological Index (BIX)")

FI_plot <-
  FI %>%
  filter(Group01 != "Blank") %>%
  ggplot(aes(Unique_id,FI,fill = Group01)) +
  geom_col(position = position_dodge2()) +
  xlab("Sample ID") +
  ylab("Fluorescence Index (FI)")

coble_peaks_max_plots <-
  coble_peaks_maxima %>%
  # filter(peak == "M") %>%
  ggplot(aes(Unique_id,peak_maxima,fill = Group01)) +
  geom_col(position = position_dodge2()) +
  facet_rep_wrap(~peak,nrow = 1) +
  xlab("Sample") +
  ylab("Fluorescence Intensity (QSU)") +
  theme(axis.text.x = element_text(angle = 90))

coble_peak_ratio_plots <-
  coble_ratios %>%
  select(-A,-C,-M,-T,-B) %>%
  pivot_longer(A_to_T:C_to_T,names_to = "variable",values_to = "value") %>%
  ggplot(aes(Unique_id,value,fill = Group01)) +
  geom_col(position = position_dodge2()) +
  facet_rep_wrap(~variable,nrow = 1) +
  xlab("Sample") +
  ylab("Ratio Value") +
  theme(axis.text.x = element_text(angle = 90))