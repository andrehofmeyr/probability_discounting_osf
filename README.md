# Probability Discounting

Replicates the estimates and figures for "Probability Discounting and Economic Theories of Choice Under Risk: A Translation and Critique," using data from Richards et al. (1999), "Delay or Probability Discounting in a Model of Impulsive Behavior: Effect of Alcohol."

## Structure

```
1_main.do        — entry point; run this to replicate all results
analysis.do      — ML estimation of probability weighting functions
figures.do       — figures
ml_functions.do  — ML likelihood programs (PD, TK, Prelec)
data/            — source data
figures/         — figure output
output/          — estimation output (CSV tables)
logs/            — log output
```

## Requirements

Stata with the user-written commands `estout` and `mylabels` (both available via SSC). `1_main.do` installs them automatically on the first run; the install lines can be commented out afterwards. Figures use the Garamond font — if it is not installed, Stata will fall back to a system default.

## Usage

Set the Stata working directory to the repo folder, then open and run `1_main.do`. It unzips the data, then calls `ml_functions.do`, `analysis.do`, and `figures.do` in turn. Toggle the `$doMLfunctions`, `$doAnalysis`, and `$doFIGURES` globals at the top to control which parts execute.
