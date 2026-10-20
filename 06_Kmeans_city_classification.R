# Two-stage K-means classification of cities
# Each row represents a city-year observation.
#
# Required input: city_data
# GDP shares: GDP_primary, GDP_secondary, GDP_tertiary
# Employment: Emp_mining, Emp_manufacturing, Emp_energy, Emp_construction


# -----------------------------
#1. GDP-share clustering
# -----------------------------
gdp_vars <- c("GDP_primary", "GDP_secondary", "GDP_tertiary")
set.seed(666)
km_gdp <- kmeans(
  city_data[, gdp_vars],
  centers = 3
)
print(km_gdp$centers)

# Identify cluster types from their centers.
agriculture_id <- which.max(km_gdp$centers[, "GDP_primary"])
secondary_id <- which.max(km_gdp$centers[, "GDP_secondary"])
service_id <- which.max(km_gdp$centers[, "GDP_tertiary"])

stopifnot(
  length(unique(c(agriculture_id, secondary_id, service_id))) == 3
)

city_data$city_type <- NA_character_

city_data$city_type[km_gdp$cluster == agriculture_id] <-
  "Agriculture-dominated"

city_data$city_type[km_gdp$cluster == service_id] <-
  "Service-dominated"


# -----------------------------
#2. Employment-share clustering
# -----------------------------

secondary_rows <- which(km_gdp$cluster == secondary_id)
emp_vars <- c(
  "Emp_mining", "Emp_manufacturing",
  "Emp_energy", "Emp_construction"
)
emp_counts <- city_data[secondary_rows, emp_vars, drop = FALSE]
emp_shares <- emp_counts / rowSums(emp_counts)
set.seed(666)
km_emp <- kmeans(
  emp_shares,
  centers = 4
)
print(km_emp$centers)

resource_id <- which.max(km_emp$centers[, "Emp_mining"])
manufacturing_id <- which.max(km_emp$centers[, "Emp_manufacturing"])
energy_id <- which.max(km_emp$centers[, "Emp_energy"])
construction_id <- which.max(km_emp$centers[, "Emp_construction"])

stopifnot(
  length(unique(c(
    resource_id, manufacturing_id, energy_id, construction_id
  ))) == 4
)

labels <- character(4)
labels[resource_id] <- "Resource-dominated"
labels[manufacturing_id] <- "Manufacturing-dominated"
labels[energy_id] <- "Energy-dominated"
labels[construction_id] <- "Construction-dominated"

city_data$city_type[secondary_rows] <- labels[km_emp$cluster]
