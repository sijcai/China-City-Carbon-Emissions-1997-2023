% Monte Carlo uncertainty analysis of city-level energy-related CO2 emissions.
% Each run processes one city-year. Cement process emissions are excluded.


%% 1. Input data and settings
% Inputs include sector-by-fuel energy-related emissions, emission factors and the CVs of activity data and emission factors.
% CV sources and assignments follow the Methods section, "Uncertainty analysis".
input_file = 'Monte_Carlo_Input.xlsx';
output_file = 'Monte_Carlo_Results.xlsx';
city_year = 'City_Year';
n = 20000;
rng(2026, 'twister'); % Fixed seed for repeatable runs of this script.

inventory_emissions = readmatrix(input_file, 'Sheet', 'Emissions');
EF = readmatrix(input_file, 'Sheet', 'EF');
CV_AD = readmatrix(input_file, 'Sheet', 'CV_AD');
CV_EF = readmatrix(input_file, 'Sheet', 'CV_EF');

EF = EF(:);
CV_AD = CV_AD(:);
CV_EF = CV_EF(:);

%% 2. Preprocessing
% Reconstruct activity data by dividing sector-by-fuel emissions by the corresponding EF.
AD = inventory_emissions ./ EF';
sumVal = sum(inventory_emissions(:));

%% 3. Monte Carlo simulation
% Each fuel's sampled EF is shared across sectors; AD is sampled for each sector-fuel entry.
AD_sd = AD .* repmat(CV_AD, 1, 26);
EF_sd = EF .* CV_EF;
emission = zeros(n, 1);

for i = 1:n
    sampled_EF = max(normrnd(EF, EF_sd), 0);
    sampled_AD = max(normrnd(AD, AD_sd), 0);
    emission(i) = sum(sampled_AD * sampled_EF);
end

%% 4. Uncertainty metrics
Low_total = quantile(emission, 0.025);
Up_total = quantile(emission, 0.975);
P95_total = quantile(emission, 0.95);
mean_emission = mean(emission);

Low = (Low_total - sumVal) / sumVal;
Up = (Up_total - sumVal) / sumVal;
relative_UN = (Up_total - Low_total) / (2 * mean_emission) * 100;

% Low and Up are fractional deviations from the baseline; relative_UN is in percent.
% P95_total is the 95th percentile, not the upper bound of the central 95% interval.
results = table(string(city_year), sumVal, Up_total, Low_total, Up, Low, ...
    relative_UN, P95_total, 'VariableNames', ...
    {'City', 'SumVal', 'Up_total', 'Low_total', 'Up', 'Low', 'relative_UN', 'P95_total'});
writetable(results, output_file, 'Sheet', 'Results');
disp(results);

