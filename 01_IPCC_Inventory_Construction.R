# City-level CO2 emission inventory: simplified calculation functions

# 1. Energy-related emissions
# Inputs include city energy balance tables, industrial subsector energy consumption and emission factors. City statistics are used where available; otherwise, estimated data are used following the methods described in the article.
# Statistical yearbook references and access links are provided in Supplementary Table 14; fossil-fuel emission factors are provided in Supplementary Table 16.

# Matrices use sectors as rows and fuels as columns, in matching order.
# industry_total: named fuel totals from the city energy balance table.
# industrial_data: industrial subsector energy consumption used for allocation.
# nonindustrial_data: energy consumption of non-industrial sectors.
build_energy_matrix <- function(industry_total, industrial_data,
                                nonindustrial_data) {
  industrial_data <- as.matrix(industrial_data)
  nonindustrial_data <- as.matrix(nonindustrial_data)
  stopifnot(
    identical(colnames(industrial_data), colnames(nonindustrial_data)),
    all(colnames(industrial_data) %in% names(industry_total)),
    all(is.finite(industrial_data)), all(industrial_data >= 0)
  )

  totals <- industry_total[colnames(industrial_data)]
  structure_totals <- colSums(industrial_data)
  if (any(structure_totals == 0 & totals != 0)) {
    stop("Industrial subsector data are required for each fuel with a nonzero industrial total.")
  }
  allocation_scale <- numeric(length(totals))
  available <- structure_totals > 0
  allocation_scale[available] <- totals[available] / structure_totals[available]

  # Allocate industrial fuel totals across subsectors and add non-industrial sectors.
  industrial_energy <- sweep(industrial_data, 2, allocation_scale, "*")
  rbind(industrial_energy, nonindustrial_data)
}

# Account for fuel inputs to electricity and heat production, exclude non-energy use, and avoid double-counting transformation inputs.
calculate_energy_emissions <- function(energy_consumption, transformation_inputs,
                                       nonenergy_use, power_heat_inputs,
                                       co2_factors) {
  energy_consumption <- as.matrix(energy_consumption)
  inputs <- list(transformation_inputs, nonenergy_use, power_heat_inputs, co2_factors)
  for (x in inputs) {
    stopifnot(identical(dimnames(as.matrix(x)), dimnames(energy_consumption)),
              all(is.finite(as.matrix(x))), all(as.matrix(x) >= 0))
  }
  stopifnot(all(is.finite(energy_consumption)), all(energy_consumption >= 0))

  # Exclude transformation feedstocks and non-energy use, then include generation fuels.
  combustion_energy <- pmax(energy_consumption - transformation_inputs - nonenergy_use, 0)
  combustion_energy <- combustion_energy + power_heat_inputs

  # Calculate energy-related CO2 emissions by sector and fuel.
  combustion_energy * co2_factors
}

# 2. Process-related emissions
# Inputs are city cement production and the cement process emission factor. Statistical yearbook references and access links are provided in Supplementary Table 14; the factor and its reference are described in the Supplementary Methods.
# Cement production is in Mt; the factor is in t CO2/t cement, giving emissions in Mt CO2.
calculate_process_emissions <- function(cement_production_Mt, cement_factor = 0.2906) {
  stopifnot(length(cement_production_Mt) == 1L, is.finite(cement_production_Mt),
            cement_production_Mt >= 0, length(cement_factor) == 1L,
            is.finite(cement_factor), cement_factor >= 0)
  cement_production_Mt * cement_factor
}

# 3. Combine energy-related and process-related emissions
# cement_sector identifies the nonmetal mineral products sector in the input matrix.
assemble_inventory <- function(energy_emissions, process_emissions, cement_sector) {
  stopifnot(cement_sector %in% rownames(energy_emissions))
  process <- setNames(rep(0, nrow(energy_emissions)), rownames(energy_emissions))
  process[cement_sector] <- process_emissions
  inventory <- cbind(energy_emissions, Process = process)
  inventory <- cbind(inventory, Total = rowSums(inventory))
  rbind(inventory, Total = colSums(inventory))
}

# Workflow:
energy <- build_energy_matrix(industry_total, industrial_data, nonindustrial_data)
energy_emissions <- calculate_energy_emissions(energy, transformation_inputs,
                                               nonenergy_use, power_heat_inputs, co2_factors)
process_emissions <- calculate_process_emissions(cement_production_Mt)
inventory <- assemble_inventory(energy_emissions, process_emissions, cement_sector)
