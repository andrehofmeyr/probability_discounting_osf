/*********************************************************************/
/*  SECTION Figures
    Notes: This DO file produces all figures for the probability
    discounting analysis. Globals for estimated parameters must be
    set by analysis.do before this file is run.

    Figures produced:
      Figure 2 - Probability Weighting Function of the PD Model
      Figure 3 - Estimated PWFs (homogeneous preferences)
      Figure 4 - Estimated PWFs (mixture model)                    */
/*********************************************************************/


/*----------------------------------------------------*/
   /* [>   1.0.  Figure 2: PD Model PWF            <] */
/*----------------------------------------------------*/

* Set labels for graph
mylabels 0(0.25)1, myscale(@) format(%4.2f) clean local(xylabelspwf)

twoway function y = x / (x + 0.5*(1-x)), ///
    clpattern(solid) clwidth(0.6) lcolor("196 30 58"%30) ///
|| function y=x, clpattern(solid) clwidth(0.6) lcolor("0 153 153"%30) ///
|| function y = x / (x + 2*(1-x)), ///
    clpattern(solid) clwidth(0.6) lcolor("255 153 51"%30) ///
legend(off) ///
ytitle("{&pi}({it:p)}", orient(horizontal) size(medium)) ///
xtitle("{it: p}", size(medium)) ///
ylabel(`xylabelspwf', nogrid angle(horizontal) labsize(small)) ///
xlabel(`xylabelspwf', nogrid angle(horizontal) labsize(small)) ///
xline(0.5, lwidth(thin) lpattern(shortdash) lcolor(gs12)) ///
yline(0.5, lwidth(thin) lpattern(shortdash) lcolor(gs12)) ///
text(0.35 0.268 "{&gamma} = 1") ///
text(0.55 0.28 "{&gamma} = 0.5") ///
text(0.11 0.268 "{&gamma} = 2") ///
title("{bf:Figure 2}" ///
    "Probability Weighting Function of the PD Model", size(medium)) ///
xsize(2) ysize(2)
graph export "figures/figure2.pdf", replace


/*----------------------------------------------------*/
   /* [>   1.1.  Figure 3: Estimated PWFs          <] */
/*----------------------------------------------------*/

local gamma:    display %4.3f $gamma_prelec_hom
local eta:      display %4.3f $eta_prelec_hom
local gamma_tk: display %4.3f $gamma_tk_hom
local gamma_pd: display %4.3f $gamma_pd_hom
twoway function y = exp((-`eta')*((-ln(x))^`gamma'))  ///
, clpattern(solid) lcolor(red%85) clwidth(medium) ///
|| function y=x, clpattern(shortdash) clwidth(medium) lcolor(black) ///
|| function y = (x^`gamma_tk')/(x^`gamma_tk' + ///
    ((1-x)^`gamma_tk'))^(1/`gamma_tk')  ///
, clpattern(solid) lcolor(gold%85) clwidth(medium) ///
|| function y = x / (x + `gamma_pd'*(1-x))  ///
, clpattern(solid) lcolor(emerald%90) clwidth(medthick) ///
legend(order( 4 "PD" 3 "TK" 1 "Prelec") size(medium) cols(1) ring(0) ///
    pos(11) nobox symxsize(*.4)) ///
ytitle("{&pi}({it:p}) ", orient(horizontal) size(medium)) ///
xtitle("{it:p}", size(medium)) ///
ylabel(`xylabelspwf', nogrid angle(horizontal) labsize(small)) ///
xlabel(`xylabelspwf', nogrid angle(horizontal) labsize(small)) ///
xline(0.5, lwidth(thin) lpattern(shortdash) lcolor(gs12)) ///
yline(0.5, lwidth(thin) lpattern(shortdash) lcolor(gs12)) ///
text(1 0.1 "{&gamma} = `gamma'") ///
text(0.90 0.1 "{&eta} = `eta'") ///
title("{bf:Figure 3}" ///
    "Estimated Probability Weighting Functions", size(medium)) ///
xsize(2) ysize(2)
graph export "figures/figure3.pdf", replace


/*----------------------------------------------------*/
   /* [>   1.2.  Figure 4: Mixture Model PWFs      <] */
/*----------------------------------------------------*/

local gamma_pd_mix: display %4.3f $gamma_pd_mix
local gamma_tk_mix: display %4.3f $gamma_tk_mix
twoway function y=x, clpattern(shortdash) clwidth(medium) lcolor(black) ///
|| function y = (x^`gamma_tk_mix')/(x^`gamma_tk_mix' + ///
    ((1-x)^`gamma_tk_mix'))^(1/`gamma_tk_mix')  ///
, clpattern(solid) lcolor(gold%85) clwidth(medium) ///
|| function y = x / (x + `gamma_pd_mix'*(1-x))  ///
, clpattern(solid) lcolor(emerald%90) clwidth(medthick) ///
legend(order( 3 "PD" 2 "TK") size(medium) cols(1) ring(0) ///
    pos(11) nobox symxsize(*.4)) ///
ytitle("{&pi}({it:p}) ", orient(horizontal) size(medium)) ///
xtitle("{it:p}", size(medium)) ///
ylabel(`xylabelspwf', nogrid angle(horizontal) labsize(small)) ///
xlabel(`xylabelspwf', nogrid angle(horizontal) labsize(small)) ///
xline(0.5, lwidth(thin) lpattern(shortdash) lcolor(gs12)) ///
yline(0.5, lwidth(thin) lpattern(shortdash) lcolor(gs12)) ///
text(1 0.1 "{&gamma}{sub:PD} = `gamma_pd_mix'") ///
text(0.90 0.1 "{&gamma}{sub:TK} = `gamma_tk_mix'") ///
title("{bf:Figure 4}" ///
    "Estimated Probability Weighting Functions" ///
    "(Mixture Model)", size(medium)) ///
xsize(2) ysize(2)
graph export "figures/figure4.pdf", replace


/*--------------------- End of SECTION Figures ----------------------*/
