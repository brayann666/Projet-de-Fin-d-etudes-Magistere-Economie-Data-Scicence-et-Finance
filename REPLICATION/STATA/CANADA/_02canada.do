* Codes for Konradt and Weder di Mauro - Greenflation 
* largely builds on codes by Metcalf and Stock (2020)
* produces Table 3 and Figure 2, Table 5 and Table 7

use "$dir/data/ctax_panel_can.dta", clear

************************************************************
* lag parameters and globals
************************************************************
global p = 6  // number of horizons, also number of lags in DL specifications
global lplags = 4  // number of lags in LP and XTVAR specifications
global q = 1 // recursiveness assumption
global fxlsout "$dir/tables/canada_lp.xlsx"
************************************************************
*
* housekeeping
local p $p
local lplags $lplags
local q $q
local pp1 = `p'+1

*set of controls
global ctrl1 "i.year"
global ctrl2 "i.year L(`q'/`lplags').dpolicyrate L(`q'/`lplags').dlgdp"
global ctrl3 "i.year L(`q'/`lplags').dpolicyrate L(`q'/`lplags').dlgdp L(`q'/`lplags').demp L(`q'/`lplags').dtradebalance"
global ctrl4 "i.year L(`q'/`lplags').dpolicyrate L(`q'/`lplags').dlgdp"

*carbon tax rate 
local x "rater_LCU_USD18sw"

*clean control condition for LP DID estimator
egen id = group(prov)
xtset id year 
foreach v in "rater_LCU_USD18sw" {
forv h = 0/8 {
gen treat`h' = 0
replace treat`h' = 1 if f`h'.`v' >0 & !mi(f`h'.`v')			
}
}  

*run LP
sca irfno = 0
foreach y in  "infl_head" "infl_core" "infl_energyfood" { //LHS variable loop

 forval smpl = 1/2 { //subsample loop
  preserve
  
  if `smpl' ==2 {
	drop if BC==0
  }
  *
  * set panel
  cap drop cdum
  cap drop cnum
  egen cnum = group(prov)
  xtset cnum year
  tab year, gen(ydum)
  tab prov, gen(cdum)
  local nc = r(r)
  
  * carbon tax path
  sca rateinit = 40
   if strmatch("`x'","*sw") sca swfac = 0.3
  mat xpath = J(`pp1',1,rateinit) // real carbon tax path
	
  global y "`y'"
  global x "`x'"
  global smple "`smpl'" 
  forval j = 1/4 { //controls loop
  global controls "`j'"
 *-------------------------------------------------------------------------------------------
 *             LP estimation II
 *  Via individual regs with dummy variables 
 *  Notes on SE computation:
 *    1. HAC SEs not needed, these are HR (Montiel Olea- Plagborg Moller (2019))
 *    2. SEs computed for full covariance matrix of IRFs across regressions using
 *       x's*resids for different horizon regressions. The messiness below is because
 *       the different horizon regressions are computed over different samples, so VCV matrix
 *       must be computed for the overlapping data in each covariance matrix pair.
 *-------------------------------------------------------------------------------------------
 *
   mat theta11 = J(`pp1',1,1)
   sca irfno = irfno+1
    mat b99 = J(`pp1',1,0)
    mat s99 = b99
    cap drop e99*
    forvalues h = 0/`p' {
     local hp1 = `h'+1
     * effect on y h-periods hence of unit innovation in x, for TWFE and LP-DID estimators
	 if `j' <4 {
     qui reg F`h'.`y' L(0/`lplags').`x' L(1/`lplags').`y' ${ctrl`j'} cdum*, r
	 }
	 else if `j'==4 {
	 qui reg F`h'.`y' L(0/`lplags').`x' L(1/`lplags').`y' ${ctrl`j'} cdum* if ((`x'>0)|(treat0==0 & treat`h'==0)), r
	 }
     mat b98 = e(b)
     mat b99[`hp1',1] = b98[1,1]
     * create product of X projected off of controls * resids for computing HR VCV matrix
     local k = e(df_m)
     cap drop smpl`h' e`h' etax`h' zz`h'
	 qui gen smpl`h' = e(sample)
	 qui predict e`h', resid
     qui reg `x' L(1/`lplags').`x' L(1/`lplags').`y' ${ctrl`j'} cdum* if smpl`h', r
	 qui predict etax`h', resid
	 qui su etax`h' if smpl`h'
     gen zz`h' = (r(N)/(r(N)-1))*(e`h'*etax`h'/r(Var))/sqrt(r(N)-`k') if smpl`h'
     * IRF from rate shock to rate - for inverting rate path to shocks
     if `h'>0 {
	 if `j' <4 {
      qui areg F`h'.`x' L(0/`lplags').`x' L(1/`lplags').`y' ${ctrl`j'}, absorb(cnum) vce(r)
	  }
	 else if `j' ==4 {
	  qui areg F`h'.`x' L(0/`lplags').`x' L(1/`lplags').`y' ${ctrl`j'} if ((`x'>0)|(treat0==0 & treat`h'==0)), absorb(cnum) vce(r)
	  }
      mat b97 = e(b)
      mat theta11[`h'+1,1] = b97[1,1]
     }
    } // end of loop over horizon
	* Compute covariance matrix over different subsamples for different horizon LP estimation
	mat v99 = I(`p'+1)
	forvalues i = 0/`p' {
	 qui su zz`i'
	 mat v99[`i'+1,`i'+1] = r(Var)
	 dis `i' "   " b99[`i'+1,1] "   " sqrt(v99[`i'+1,`i'+1])
	 local ip1 = `i'+1
	 forvalues j = `ip1'/`p' {
	  qui corr zz`i' zz`j', cov
	  mat v99[`i'+1,`j'+1] = r(cov_12)
	  mat v99[`j'+1,`i'+1] = r(cov_12)
	 }
    }
	
	*compute and save irfs
    do "$dir/codes/_00irf.do"
 
	} //controls loop
	restore
 } // smple loop
} // y loop


********************************************************************************
************************* cumulative IRF ***************************************

use "$dir/data/ctax_panel_can.dta", clear

************************************************************
* lag parameters and globals
************************************************************
global p = 6  // number of horizons 
global lplags = 4  // number of lags in LP  
global q = 1 // recursiveness assumption
global fxlsout "$dir/tables/canada_clp.xlsx"
************************************************************
*
* housekeeping
local p $p
local lplags $lplags
local q $q
local pp1 = `p'+1

* set of controls
global ctrl1 "i.year L(`q'/`lplags').dpolicyrate L(`q'/`lplags').dlgdp"

*carbon tax variable
local x "rater_LCU_USD18sw"

***** create y vars for cumulative irfs
egen id = group(prov)
xtset id year
foreach v in "head" "core" "energyfood" {
forv h = 0/6 {
gen infl_`v'`h' = 100*(f`h'.cpi_`v' - l.cpi_`v')/l.cpi_`v' 		
}
} 

* estimate LPs
sca irfno = 0
foreach y in  "infl_head" "infl_core" "infl_energyfood" { //LHS variable loop

 forval smpl = 1/1 { //subsample loop
  preserve
  *
  * set panel
  cap drop cdum
  cap drop cnum
  egen cnum = group(prov)
  xtset cnum year
  tab year, gen(ydum)
  tab prov, gen(cdum)
  local nc = r(r)
  
  * carbon tax path
  sca rateinit = 40
   if strmatch("`x'","*sw") sca swfac = 0.3
  mat xpath = J(`pp1',1,rateinit) // real carbon tax path
	
  global y "`y'"
  global x "`x'"
  global smple "`smpl'" 
  forval j = 1/1 { //controls loop
  global controls "`j'"
  
     mat theta11 = J(`pp1',1,1)
   sca irfno = irfno+1
    mat b99 = J(`pp1',1,0)
    mat s99 = b99
    cap drop e99*
    forvalues h = 0/`p' {
     local hp1 = `h'+1
     * effect on y h-periods hence of unit innovation in x, for TWFE and LP-DID estimators
     qui reg `y'`h' L(0/`lplags').`x' L(1/`lplags').`y' ${ctrl`j'} cdum*, r
     mat b98 = e(b)
     mat b99[`hp1',1] = b98[1,1]
     * create product of X projected off of controls * resids for computing HR VCV matrix
     local k = e(df_m)
     cap drop smpl`h' e`h' etax`h' zz`h'
	 qui gen smpl`h' = e(sample)
	 qui predict e`h', resid
     qui reg `x' L(1/`lplags').`x' L(1/`lplags').`y' ${ctrl`j'} cdum* if smpl`h', r
	 qui predict etax`h', resid
	 qui su etax`h' if smpl`h'
     gen zz`h' = (r(N)/(r(N)-1))*(e`h'*etax`h'/r(Var))/sqrt(r(N)-`k') if smpl`h'
     * IRF from rate shock to rate - for inverting rate path to shocks
     if `h'>0 {
      qui areg F`h'.`x' L(0/`lplags').`x' L(1/`lplags').`y' ${ctrl`j'}, absorb(cnum) vce(r)
      mat b97 = e(b)
      mat theta11[`h'+1,1] = b97[1,1]
     }
    } // end of loop over horizon
	* Compute covariance matrix over different subsamples for different horizon LP estimation
	mat v99 = I(`p'+1)
	forvalues i = 0/`p' {
	 qui su zz`i'
	 mat v99[`i'+1,`i'+1] = r(Var)
	 dis `i' "   " b99[`i'+1,1] "   " sqrt(v99[`i'+1,`i'+1])
	 local ip1 = `i'+1
	 forvalues j = `ip1'/`p' {
	  qui corr zz`i' zz`j', cov
	  mat v99[`i'+1,`j'+1] = r(cov_12)
	  mat v99[`j'+1,`i'+1] = r(cov_12)
	 }
    }
	*estimate and save irf
    do "$dir/codes/_00irf.do"
 
	} //controls loop
	restore
 } // smple loop
} // y loop

********************************************************************************
********************* Figures based on cumulative IRFs  ************************
 
set scheme s1mono
graph set window fontface "Times New Roman"

*import irf estimates
import excel using "$dir/tables/canada_clp.xlsx", first clear

*prepare data
drop if _n <3
destring E, replace

drop L-O B-D

rename (E-K) (b0 b1 b2 b3 b4 b5 b6)
rename Effectafterhyearsof40incr est0
replace est0 = "beta" if _n ==1 | _n ==3 | _n ==5
replace est0 = "se" if _n ==2 | _n ==4 | _n ==6

g y = "infl_head"
replace y = "infl_core" if _n >2
replace y = "infl_energyfood" if _n >4

*loop over y variables
foreach v in "infl_head" "infl_core" "infl_energyfood" {

preserve
keep if y =="`v'"

reshape long b, i(est0) j(horizon)

reshape wide b, j(est0) i(horizon) string

rename bbeta b
gen u_2 = b + 2*bse
gen u_1 = b + bse
gen d_2 = b - 2*bse
gen d_1 = b - bse

drop if horizon >5

twoway ///
		(rarea u_2 d_2  horizon,  ///
		fcolor(gs15) lcolor(gs15) lw(none) lpattern(solid)) ///
		(rarea u_1 d_1  horizon,  ///
		fcolor(gs10) lcolor(gs10) lw(none) lpattern(solid)) ///
		(line b horizon, lcolor(gs0) ///
		lpattern(solid) lwidth(medthick)), /// 
		yline(0, lp("-") lc(gs6)) legend(off) ///
		title("", color(black) size(medsmall)) ///
		ytitle("Percentage points", size(medlarge)) xtitle("Years", size(medlarge)) ///
		ylab(-8(2)8,) xlab(0(1)5)	
		gr export "$dir/figures/lp_can_`v'.pdf", as(pdf) replace
restore
}

*********************************************
* Table 7

use "$dir/data/ctax_panel_can.dta", clear

************************************************************
* lag parameters and globals
************************************************************
global p = 6  // number of horizons, also number of lags in DL specifications
global lplags = 4  // number of lags in LP and XTVAR specifications
global q = 1 // recursiveness assumption
global fxlsout "$dir/tables/canada_lp_rob0.xlsx"
************************************************************
*
* housekeeping
local p $p
local lplags $lplags
local q $q
local pp1 = `p'+1

*set of controls
global ctrl1 "i.year"
global ctrl2 "i.year L(`q'/`lplags').dpolicyrate L(`q'/`lplags').dlgdp"
global ctrl3 "i.year L(`q'/`lplags').dpolicyrate L(`q'/`lplags').dlgdp L(`q'/`lplags').demp L(`q'/`lplags').dtradebalance"
global ctrl4 "i.year L(`q'/`lplags').dpolicyrate L(`q'/`lplags').dlgdp"

*carbon tax rate (based on Dolphin et al 2019)
local x "rater_LCU_USD18sw"

*clean control condition for LP DID estimator
egen id
