
set.seed(123)

# Define the population size in each income group
income_group <- c(
  rep("Low", 40),
  rep("Middle", 35),
  rep("High", 25)
)

# Simulate annual expenditure for each household
population <- data.frame(
  household_id = 1:100,
  income_group = factor(
    income_group,
    levels = c("Low", "Middle", "High")
  ),
  expenditure = c(
    rnorm(40, mean = 20000, sd = 4000),
    rnorm(35, mean = 32000, sd = 5000),
    rnorm(25, mean = 48000, sd = 7000)
  )
)

# Install ggplot2 if needed
# install.packages("ggplot2")

library(ggplot2)
library(dplyr)
# Calculate the population mean
population_mean <- mean(population$expenditure)

# Calculate the mean for each stratum
strata_means <- aggregate(
  expenditure ~ income_group,
  data = population,
  FUN = mean
)

# 1. Run the ANOVA model
anova_model <- aov(expenditure ~ income_group, data = population)
anova_summary <- summary(anova_model)[[1]]

# 2. Extract Sum of Squares
# SSB (Sum of Squares Between Groups / Treatment)
SSB <- anova_summary["income_group", "Sum Sq"]

# SSW (Sum of Squares Within Groups / Error / Residuals)
SSW <- anova_summary["Residuals", "Sum Sq"]

# SST (Total Sum of Squares)
SST <- SSB + SSW

# 3. Format numbers nicely with commas for the labels
sst_label <- paste0("SST == ", sprintf("%.2f", SST / 1e9), " * 10^9")
ssb_label <- paste0("SSB == ", sprintf("%.2f", SSB / 1e9), " * 10^9")
ssw_label <- paste0("SSW == ", sprintf("%.2f", SSW / 1e9), " * 10^9")

# Add a constant y-coordinate for the horizontal line
population$y <- 1

# --------------------------------------------------
# Figure 1: Population observations and overall mean
# --------------------------------------------------

library(dplyr)
library(ggplot2)
library(ggdist) 

# Precompute overall population mean for Figure 1 and 2
population_mean <- mean(population$expenditure)

# --------------------------------------------------
# Figure 1: Population Distribution (Rectangular Violin)
# --------------------------------------------------
p1 <- ggplot(
  population,
  aes(x = "Population", y = expenditure)
) +
  stat_histinterval(
    fill = "gray80",
    color = "gray50",
    scale = 0.6,             # Controls how far the histogram bars extend out
    side = "right",          # Draws the histogram exclusively to the right side
    breaks = 20,             # Total number of histogram bins (adjust as needed)
    outline_bars = TRUE,     # Keeps the distinct, blocky histogram look
    .width = 0,             
    point_interval = NULL    
  ) +
  geom_jitter(
    width = 0.08,
    height = 0,
    color = "gray50",
    alpha = 0.35,
    size = 2
  ) +
  geom_point(
    aes(x = "Population", y = population_mean),
    color = "red",
    shape = 15,
    size = 4
  ) +
  annotate(
    "text", 
    x = 1.2,                                     # Placed slightly to the left of center
    y = max(population$expenditure) * 0.95,      # Near the top edge of your data
    label = sst_label, 
    hjust = 0, fontface = "bold", size = 4.5, color = "black"
  ) +
  labs(
    title = "Population Distribution", 
    x = "Population",
    y = "Annual Household Expenditure ($)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  )

print(p1)

# --------------------------------------------------
# Figure 2: Population observations colored by stratum
# --------------------------------------------------

# Calculate stratum means
strata_means <- aggregate(
  expenditure ~ income_group,
  data = population,
  FUN = mean
)

# Overall population mean
population_mean <- mean(population$expenditure)

p2 <- ggplot(
  population,
  aes(x = income_group, y = expenditure, fill = income_group)
) +
  stat_histinterval(
    scale = 0.45,
    side = "right",          
    color = "gray35",
    alpha = 0.45,
    breaks = 8,             # Adjust bin amounts per category if desired
    outline_bars = TRUE,     
    .width = 0,             
    point_interval = NULL    
  ) +
  geom_jitter(
    aes(color = income_group),
    width = 0.10,
    alpha = 0.35,
    size = 1
  ) +
  # Stratum means: red triangles
  geom_point(
    data = strata_means,
    aes(x = income_group, y = expenditure),
    inherit.aes = FALSE,
    color = "red",
    shape = 17,
    size = 4
  ) +
  # Population mean: red square
  geom_hline(yintercept = population_mean) +
  scale_fill_manual(
    name = "Stratum",
    values = c(
      "Low" = "#377EB8",
      "Middle" = "#4DAF4A",
      "High" = "#984EA3"
    )
  ) +
  annotate(
    "text",
    x = 0.6,                                     
    y = max(population$expenditure) * 0.95,   
    label = ssb_label,
    hjust = 0, fontface = "bold", size = 4, color = "black"
  ) +
  annotate(
    "text",
    x = 0.6,
    y = max(population$expenditure) * 0.88,
    label = ssw_label,
    hjust = 0, fontface = "bold", size = 4, color = "black"
  ) +
  scale_color_manual(
    name = "Stratum",
    values = c(
      "Low" = "#377EB8",
      "Middle" = "#4DAF4A",
      "High" = "#984EA3"
    )
  ) +
  labs(
    title = "Population Distribution by Stratum",
    x = "Income Stratum",
    y = "Annual Household Expenditure ($)"
  ) +
  guides(
    fill = "none",
    color = guide_legend(
      override.aes = list(alpha = 1, size = 3)
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "right"
  )

print(p2)

setwd("~/Work/teaching/ST531_SamplingMethods/w3_StratifiedAllocation_RatioEstimation/")
ggsave("population_mean.png", p1, width = 10, height = 4, dpi = 300)
ggsave("population_strata_means.png", p2, width = 10, height = 4, dpi = 300)
