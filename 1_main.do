/*********************************************************************/
/*  SECTION Main
    Notes: This is the master DO file. It replicates all of the
    estimates and figures for "Probability Discounting and Economic
    Theories of Choice Under Risk: A Translation and Critique" using
    the data from Richards et al. (1999).

    Set the Stata working directory to this folder before running.

    Running this file unzips the data, then calls ml_functions.do,
    analysis.do, and figures.do in turn (each may be skipped via the
    $doMLfunctions, $doAnalysis, and $doFIGURES globals).

    User-written commands estout and mylabels are installed
    automatically via SSC in section 1.1; comment these out after
    the first run.                                                   */
/*********************************************************************/

/*----------------------------------------------------*/
   /* [>   1.0.  Set up log and other defaults   <] */
/*----------------------------------------------------*/

* Log
capture: log close _all
log using "logs/main.log", ///
replace text name(main)

* Drop any labels in memory
capture: label drop _all

* Specify version
version 15.1
set more off

* Start timer
capture: timer clear
timer on 1

* Graphics font - Garamond
graph set window fontface "Garamond"

* Graphics scheme - s1color
global scheme "s1color"
set scheme $scheme

* Document what ran
about


/*----------------------------------------------------*/
   /* [>   1.1.  Install user-written packages    <] */
/*----------------------------------------------------*/

* Comment out after the first run
capture: ssc install estout
capture: ssc install mylabels


/*----------------------------------------------------*/
   /* [>   1.2.  Load the Data   <] */
/*----------------------------------------------------*/

* Unzip the data
unzipfile "data/richards1999analysis.zip", replace

use "Richards1999analysis.dta", clear
describe


/*----------------------------------------------------*/
   /* [>   1.3.  Set $globals   <] */
/*----------------------------------------------------*/

* Global for ML functions
global doMLfunctions   "yes"

* Global for analysis
global doAnalysis      "yes"

* Global for figures
global doFIGURES       "yes"

* Globals for estimation output and model selection tests
global estout          "yes"
global nntest          "yes"


/*----------------------------------------------------*/
   /* [>   1.4.  Conduct the Analyses   <] */
/*----------------------------------------------------*/

* Load ML functions
if "$doMLfunctions" == "yes" {
    do ml_functions.do
}

* Conduct the analysis
if "$doAnalysis" ==    "yes" {
    do analysis.do
}

* Plot the figures
if "$doFIGURES" ==     "yes" {
    do figures.do
}


/*----------------------------------------------------*/
   /* [>   1.5.  Reporting   <] */
/*----------------------------------------------------*/

* Time taken
timer off 1
timer list
local secs = r(t1)
local mins = `secs'/60
local hrs = `mins'/60
local secs_ = string(`secs', "%10.0f")
local mins_ = string(`mins', "%4.1f")
local hrs_ = string(`hrs', "%4.2f")
display "Calculations took `secs_' seconds, `mins_' minutes, or `hrs_' hours."

capture: log close main


/*----------------------- End of SECTION Main -----------------------*/
