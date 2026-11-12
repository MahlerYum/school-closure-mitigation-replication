# Replication code for Mahler and Yum (2024)

Lukas Mahler and Minchul Yum, “Aggregate and distributional effects of school closure mitigation policies: Public versus private education,” *Economics Letters* 235, 111517. [Paper](https://doi.org/10.1016/j.econlet.2024.111517)

## Run the code

Open the extracted folder in MATLAB and run

```matlab
run_replication
```

This prints the Table 1 estimates and baseline moments in the MATLAB Command Window and opens Figures 1–3 for comparison with the paper. It also writes `table1.csv` and saves the figures as PDF and CSV files in `output_archived/`. The run takes the full-precision parameter estimates in `paper_models.m` as given and uses the original period-0 interpolation and simulated type counts. The code uses base MATLAB functions. For a numbers-only run, use `run_replication('output_archived', false)`.

## Data and outputs

The model generates all figure outcomes. Running the code requires no household microdata or external data files. The calibration targets are the summary statistics in Table 1. The type counts in `paper_models.m` summarize simulated households from the original figure workflow.

In `table1.csv`, the baseline moments appear after the parameter columns. The investment target is the average of expected gross private spending across periods 0 and 1, divided by expected parental income. The model fixes the private-input scale in the CES aggregator at 0.10. In each figure CSV, `mean_h2_ratio` is mean final child human capital divided by that model's own no-closure, no-policy mean. The IGE is the slope from a weighted regression of log final human capital on log parental income with an intercept. The Gini is computed on the distribution of final child human capital.

Figure 1 varies the period-0 public-school input multiplier. Figures 2 and 3 fix it at 0.80 and vary the period-1 public-school input multiplier and the subsidy to low-income households, respectively. Both mitigation exercises start from the same closure-only allocation.

## Source files

| File | Role |
| --- | --- |
| `run_replication.m` | Runs both models, displays the results, and exports Table 1 and Figures 1–3. |
| `paper_models.m` | Stores full-precision parameters, common normalizations, and historical type counts. |
| `solve_model.m` | Solves household choices and calculates weighted moments. |
