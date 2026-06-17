/*********************************************************************/
/*  SECTION ML Functions
    Notes: This DO file defines the ML evaluator programs for the
    probability weighting function (PWF) models estimated in
    analysis.do. Programs must be loaded before calling ml model.

    Programs defined:
      pd_model_pwf  - PD model PWF (single parameter)
      tk_pwf        - Tversky-Kahneman PWF (single parameter)
      prelec2_pwf   - Prelec two-parameter PWF
      pwf_mix_tk    - Finite mixture of PD and TK PWFs             */
/*********************************************************************/


/*----------------------------------------------------*/
   /* [>   1.0.  Drop existing programs             <] */
/*----------------------------------------------------*/

capture program drop pd_model_pwf
capture program drop tk_pwf
capture program drop prelec2_pwf
capture program drop pwf_mix_tk


/*----------------------------------------------------*/
   /* [>   1.1.  PD Model PWF                      <] */
/*----------------------------------------------------*/

program define pd_model_pwf

* Specify the arguments of this program
args lnf gamma sigma

* Declare the temporary variables to be used
tempvar lhs rhs omega p

quietly {

* Read in the data
generate double `omega' = $ML_y1
generate double `p' = $ML_y2

* Construct LHS
generate double `lhs' = `omega'

* Construct RHS (i.e., PD model PWF)
generate double `rhs' = `p'/(`p' + (1-`p')*`gamma')

* Evaluate the log-likelihood
replace `lnf' = ln(normalden(`lhs',`rhs',`sigma'))

}

end


/*----------------------------------------------------*/
   /* [>   1.2.  TK PWF                            <] */
/*----------------------------------------------------*/

program define tk_pwf

* Specify the arguments of this program
args lnf gamma sigma

* Declare the temporary variables to be used
tempvar lhs rhs omega p

quietly {

* Read in the data
generate double `omega' = $ML_y1
generate double `p' = $ML_y2

* Construct LHS
generate double `lhs' = `omega'

* Construct RHS (i.e., TK PWF)
generate double `rhs' = (`p'^`gamma')/(`p'^`gamma' + (1-`p')^`gamma')^(1/`gamma')

* Evaluate the log-likelihood
replace `lnf' = ln(normalden(`lhs',`rhs',`sigma'))

}

end


/*----------------------------------------------------*/
   /* [>   1.3.  Prelec 2-Parameter PWF            <] */
/*----------------------------------------------------*/

program define prelec2_pwf

* Specify the arguments of this program
args lnf gamma eta sigma

* Declare the temporary variables to be used
tempvar lhs rhs omega p

quietly {

* Read in the data
generate double `omega' = $ML_y1
generate double `p' = $ML_y2

* Construct LHS
generate double `lhs' = `omega'

* Construct RHS (i.e., Prelec PWF)
generate double `rhs' = exp((-`eta')*(-ln(`p'))^`gamma') if `p' > 0 & `p' < 1
replace `rhs' = 1 if `p' == 1

* Evaluate the log-likelihood
replace `lnf' = ln(normalden(`lhs',`rhs',`sigma'))

}

end


/*----------------------------------------------------*/
   /* [>   1.4.  Mixture Model PWF (PD and TK)    <] */
/*----------------------------------------------------*/

program define pwf_mix_tk

* Specify the arguments of this program
args lnf gammaPD gammaTK sigma kappa

* Declare the temporary variables to be used
tempvar lnfPD lnfTK lhs rhs omega p f1 f2 p1 p2

quietly {

* Read in the data
generate double `omega' = $ML_y1
generate double `p' = $ML_y2

* Construct the likelihood for the PD model PWF
generate double `lhs' = `omega'
generate double `rhs' = `p'/(`p' + (1-`p')*`gammaPD')
generate double `lnfPD' = ln(normalden(`lhs',`rhs',`sigma'))

* Construct the likelihood for the TK PWF
replace `lhs' = `omega'
replace `rhs' = (`p'^`gammaTK')/(`p'^`gammaTK' + (1-`p')^`gammaTK')^(1/`gammaTK')
generate double `lnfTK' = ln(normalden(`lhs',`rhs',`sigma'))

* Calculate the grand likelihood for the mixture model
generate double `f1' = exp(`lnfPD')
generate double `f2' = exp(`lnfTK')
generate double `p1' = 1/(1+exp(`kappa'))
generate double `p2' = exp(`kappa')/(1+exp(`kappa'))
replace	`lnf' = ln((`p1'*`f1') + (`p2'*`f2'))

}

end


/*------------------- End of SECTION ML Functions -------------------*/
