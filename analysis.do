/*********************************************************************/
/*  SECTION Analysis
    Notes: This DO file conducts the analyses for "Probability
    Discounting and Economic Theories of Choice Under Risk:
    A Translation and Critique" using the data from Richards et al.
    (1999).

    Set globals $estout, $doFIGURES, and $nntest to "yes" to post
    output, produce graphs, and conduct non-nested model selection
    tests.

    The variable omega is V_i/x in equation (16): a subject's
    certainty-equivalent (V_i) divided by the amount x = 10.                              */
/*********************************************************************/


/*----------------------------------------------------*/
   /* [>   1.0.  Set up log                        <] */
/*----------------------------------------------------*/

capture log close
log using "logs/pd_estimates.log", replace


/*----------------------------------------------------*/
   /* [>   1.1.  PD PWF                            <] */
/*----------------------------------------------------*/

* ML
set more off
estimates clear
global maxtech "nr"
ml model lf pd_model_pwf (gamma: omega prob = ) (sigma: ), ///
cluster(subjectid) technique($maxtech) init(1 1, copy)
ml search
ml maximize, difficult

test [gamma]_cons == 1

estimates store m1, title(Model 1 - PD)
global gamma_pd_hom = [gamma]_cons

* Recover individual log-likelihood contributions
global lhs "omega"
global rhs "prob/(prob + (1-prob)*_b[_cons])"
capture drop llPD lPD
generate double llPD = ln(normalden($lhs,$rhs,[sigma]_cons))
quietly summarize llPD
global llPD = r(sum)
di $llPD
generate double lPD = exp(llPD)


/*----------------------------------------------------*/
   /* [>   1.2.  TK PWF                            <] */
/*----------------------------------------------------*/

ml model lf tk_pwf (gamma: omega prob = ) (sigma: ), ///
cluster(subjectid) technique($maxtech) init(1 1, copy)
ml search
ml maximize, difficult

test [gamma]_cons == 1

estimates store m2, title(Model 2 - TK)
global gamma_tk_hom = [gamma]_cons

* Recover individual log-likelihood contributions
global rhs "(prob^(_b[_cons]))/(prob^(_b[_cons])+(1-prob)^(_b[_cons]))^(1/(_b[_cons]))"
capture drop llTK lTK
generate double llTK = ln(normalden($lhs,$rhs,[sigma]_cons))
quietly summarize llTK
global llTK = r(sum)
di $llTK
generate double lTK = exp(llTK)


/*----------------------------------------------------*/
   /* [>   1.3.  Prelec 2-Parameter PWF            <] */
/*----------------------------------------------------*/

ml model lf prelec2_pwf (gamma: omega prob = ) (eta: ) (sigma: ), ///
cluster(subjectid) technique($maxtech) init(1 1 1, copy)
ml search
ml maximize, difficult

estimates store m3, title(Model 3 - Prelec)
global gamma_prelec_hom = [gamma]_cons
global eta_prelec_hom   = [eta]_cons

test [gamma]_cons == 1
test [eta]_cons == 1

* Recover individual log-likelihood contributions
global rhs "exp((-[eta]_cons)*(-ln(prob))^[gamma]_cons)"
capture drop llPrelec lPrelec
generate double llPrelec = ln(normalden($lhs,$rhs,[sigma]_cons))
quietly summarize llPrelec
global llPrelec = r(sum)
di $llPrelec
generate double lPrelec = exp(llPrelec)


/*----------------------------------------------------*/
   /* [>   1.4.  Export estimates                  <] */
/*----------------------------------------------------*/

if "$estout" == "yes" {
   estout * using "output/pwf_estimates.csv" ///
   , replace delimiter(",") starlevels(* 0.10 ** 0.05 *** 0.01) ///
   cells( b(star label("Estimate") fmt(3)) ///
   se(label("Std error") par(`"="("' `")""') fmt(3))  ) ///
   stats(N ll, fmt(%5.0f %12.3f) labels(N "log-likelihood")) ///
   varlabels(gamma:_cons "PWF parameter (gamma)" ///
   eta:_cons "PWF parameter (eta)" sigma:_cons "Sigma") ///
   prehead("Table 1" "Probability Weighting Function ML Estimates" @title) ///
   title("(Homogenous Preferences)") ///
   legend eqlabels(none) mlabels(,titles)  ///
   postfoot("Results account for clustering at the individual level" ///
   "Standard errors in parentheses")
}


/*----------------------------------------------------*/
   /* [>   1.5.  Model selection tests             <] */
/*----------------------------------------------------*/

if "$doFIGURES" == "yes" {

   * ln of the ratio of likelihoods: PD vs TK
   capture drop lnratiolPDTK
   generate double lnratiolPDTK = ln(lPD) - ln(lTK)
   summarize lnratiolPDTK, detail
   histogram lnratiolPDTK, normal ylabel(, angle(horizontal)) ///
   fcolor(dkorange%80) lcolor(dkorange) ///
   title("PD and TK", bcolor(gs14) lcolor(black) ///
   	position(11) ring(0) justification(center) box size(medium)) ///
   xtitle("") ///
   ylabel(, noticks nolabels) ///
   xlabel(, noticks nolabels) ///
   saving(figures/ll_ratio_distrib_histogram_pd_tk.gph, replace)

   * ln of the ratio of likelihoods: PD vs Prelec
   capture drop lnratiolPDPrelec
   generate double lnratiolPDPrelec = ln(lPD) - ln(lPrelec)
   summarize lnratiolPDPrelec, detail
   histogram lnratiolPDPrelec, normal ylabel(, angle(horizontal)) ///
   fcolor(dkorange%80) lcolor(dkorange) ///
   title("PD and Prelec", bcolor(gs14) lcolor(black) ///
   	position(11) ring(0) justification(center) box size(medium)) ///
   xtitle("") ///
   ylabel(, noticks nolabels) ///
   xlabel(, noticks nolabels) ///
   saving(figures/ll_ratio_distrib_histogram_pd_prelec.gph, replace)

   * ln of the ratio of likelihoods: Prelec vs TK
   capture drop lnratiolPrelecTK
   generate double lnratiolPrelecTK = ln(lPrelec) - ln(lTK)
   summarize lnratiolPrelecTK, detail
   histogram lnratiolPrelecTK, normal ylabel(, angle(horizontal)) ///
   fcolor(dkorange%80) lcolor(dkorange) ///
   title("Prelec and TK", bcolor(gs14) lcolor(black) ///
   	position(11) ring(0) justification(center) box size(medium)) ///
   xtitle("") ///
   ylabel(, noticks nolabels) ///
   xlabel(, noticks nolabels) ///
   saving(figures/ll_ratio_distrib_histogram_prelec_tk.gph, replace)

   graph combine ///
   "figures/ll_ratio_distrib_histogram_pd_tk.gph" ///
   "figures/ll_ratio_distrib_histogram_pd_prelec.gph" ///
   "figures/ll_ratio_distrib_histogram_prelec_tk.gph", ///
   cols(1) imargin(tiny) ///
   title("{bf:Figure D1}" ///
   "Log-Likelihood Ratio Distributions", size(medium)) ///
   saving(figures/ll_ratio_distrib_histogram_all, replace)
   graph export figures/ll_ratio_distrib_histogram_all.png, replace

}

* Construct the Clarke test statistics for the models
   if "$nntest" == "yes" {
      quietly {
         foreach m1 in PD TK Prelec {
            * `ferest()' stores the items in the list that have not been executed
            foreach m2 in `ferest()' {

            noisily display as input "`m1' `m2'"

            * Construct the Clarke (2007) test statistic
            capture drop Cd
            generate double Cd = ll`m1' - ll`m2'
            capture drop Cdsign
            generate double Cdsign = .
            replace Cdsign = 1 if Cd > 0
            replace Cdsign = 0 if Cd < 0
            quietly summarize Cdsign
            local b = r(sum)
            local n = r(N)
            local half = r(N)/2
            local p = binomialtail(`n', `b', 0.5)

            * Display the results
            noisily display as input "The log-likelihood for model `m1' is ${ll`m1'} and for model `m2' is ${ll`m2'}"
            noisily display as result "The Clarke (2007) statistic for the test of model `m1' and `m2' is `b' and favours `m1' over `m2' if greater than `half' (p-value = `p' of `m1'" as error " not " as result "being the better model)"

            * Clean up
            drop Cd Cdsign

            noisily display _newline(2)


            }
      }
   }
}


/*----------------------------------------------------*/
   /* [>   1.6.  Heterogeneous preferences         <] */
/*----------------------------------------------------*/

estimates clear
global demog "i.male i.highdose i.task"

ml model lf pd_model_pwf (gamma: omega prob = ) (sigma: ), ///
cluster(subjectid) technique($maxtech) init(1 1, copy) maximize
ml model lf pd_model_pwf (gamma: omega prob = $demog) (sigma: ), ///
cluster(subjectid) technique($maxtech) continue
ml search
ml maximize, difficult

estimates store m1, title(Model 1 - PD)

* Test the task estimates
test 2.task == 3.task
test 2.task == 4.task
test 3.task == 4.task

ml model lf tk_pwf (gamma: omega prob = ) (sigma: ), ///
cluster(subjectid) technique($maxtech) init(1 1, copy) maximize
ml model lf tk_pwf (gamma: omega prob = $demog) (sigma: ), ///
cluster(subjectid) technique($maxtech) continue
ml search
ml maximize, difficult

estimates store m2, title(Model 2 - TK)

* Test the task estimates
test 2.task == 3.task
test 2.task == 4.task
test 3.task == 4.task

ml model lf prelec2_pwf (gamma: omega prob = ) (eta: ) (sigma: ), ///
cluster(subjectid) technique($maxtech) init(1 1 1, copy) maximize
ml model lf prelec2_pwf (gamma: omega prob = $demog) (eta: $demog) ///
(sigma: ), cluster(subjectid) technique($maxtech) continue
ml search
ml maximize, difficult

estimates store m3, title(Model 3 - Prelec)

* Test the task estimates
test [gamma]2.task == [gamma]3.task
test [gamma]2.task == [gamma]4.task
test [gamma]3.task == [gamma]4.task

test [eta]2.task == [eta]3.task
test [eta]2.task == [eta]4.task
test [eta]3.task == [eta]4.task

if "$estout" == "yes" {
   estout * using "output/pwf_estimates_het.csv" ///
   , replace delimiter(",") starlevels(* 0.10 ** 0.05 *** 0.01) ///
   keep(gamma:_cons gamma:1.male gamma:1.highdose ///
   gamma:2.task gamma:3.task gamma:4.task ///
   eta:_cons eta:1.male eta:1.highdose ///
   eta:2.task eta:3.task eta:4.task sigma:_cons) ///
   cells( b(star label("Estimate") fmt(3)) ///
   se(label("Std error") par(`"="("' `")""') fmt(3))  ) ///
   stats(N ll, fmt(%5.0f %12.3f) labels(N "log-likelihood")) ///
   varlabels(gamma:_cons "Constant" eta:_cons "Constant" ///
   sigma:_cons "Constant" ///
   gamma:1.male "Male" gamma:1.highdose "Ethanol - high dose" ///
   gamma:2.task "Post-placebo session" ///
   gamma:3.task "Pre-ethanol session" gamma:4.task "Post-ethanol session" ///
   eta:1.male "Male" eta:1.highdose "Ethanol - high dose" ///
   eta:2.task "Post-placebo session" ///
   eta:3.task "Pre-ethanol session" eta:4.task "Post-ethanol session") ///
   prehead("Table C1" "Probability Weighting Function ML Estimates" @title) ///
   title("(Heterogenous Preferences)") ///
   legend eqlabels("PWF parameter (gamma)" "Sigma" ///
   "PWF parameter (eta)") mlabels(,titles)  ///
   postfoot("Results account for clustering at the individual level" ///
   "Standard errors in parentheses")
}


/*----------------------------------------------------*/
   /* [>   1.7.  PWF Mixture                       <] */
/*----------------------------------------------------*/

* PD and TK
estimates clear
ml model lf pwf_mix_tk (gammaPD: omega prob = ) (gammaTK: ) (sigma: ) (kappa: ) ///
, cluster(subjectid) technique($maxtech) init(1 1 1 -3, copy)
ml search
ml maximize, difficult

estimates store m1, title(Mixture Model - PD and TK)
global gamma_pd_mix = [gammaPD]_b[_cons]
global gamma_tk_mix = [gammaTK]_b[_cons]

* Evaluate the mixture probabilities
nlcom (pPD: 1/(1+exp([kappa]_b[_cons]))) ///
(pTK: exp([kappa]_b[_cons])/(1+exp([kappa]_b[_cons])))

* Test if p(TK) == 1
testnl exp([kappa]_b[_cons])/(1+exp([kappa]_b[_cons])) = 1

* Test if gammaTK == 1
test [gammaTK]_cons == 1

if "$estout" == "yes" {
   local ll_mix = e(ll)
   nlcom ///
      (gammaPD_cons: [gammaPD]_b[_cons]) ///
      (pPD: 1/(1+exp([kappa]_b[_cons]))) ///
      (gammaTK_cons: [gammaTK]_b[_cons]) ///
      (pTK: exp([kappa]_b[_cons])/(1+exp([kappa]_b[_cons]))) ///
      (sigma_cons: [sigma]_b[_cons]), post
   estadd scalar ll = `ll_mix'
   estimates store m1_mix
   estout m1_mix using "output/pwf_mix_estimates.csv" ///
   , replace delimiter(",") starlevels(* 0.10 ** 0.05 *** 0.01) ///
   cells( b(star label("Estimate") fmt(3)) ///
   se(label("Std error") par(`"="("' `")""') fmt(3))  ) ///
   stats(N ll, fmt(%5.0f %12.3f) labels(N "log-likelihood")) ///
   varlabels(gammaPD_cons "PWF parameter (gamma PD)" ///
   pPD "Mixture probability (pi PD)" ///
   gammaTK_cons "PWF parameter (gamma TK)" ///
   pTK "Mixture probability (pi TK)" ///
   sigma_cons "Constant (sigma)") ///
   prehead("Table 2" "Mixture Model ML Estimates" @title) ///
   title("(PD and TK Functions)") ///
   postfoot("Results account for clustering at the individual level" ///
   "Standard errors in parentheses")
}


/*----------------------------------------------------*/
   /* [>   1.8.  Clean up                          <] */
/*----------------------------------------------------*/

capture log close


/*--------------------- End of SECTION Analysis ---------------------*/
