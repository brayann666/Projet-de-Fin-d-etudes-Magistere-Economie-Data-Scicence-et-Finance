* Codes for Konradt and Weder di Mauro - Greenflation 
* largely builds on codes by Metcalf and Stock (2020)
* produces Figure 3


use "$dir/data/ctax_panel_can_qtl.dta", clear

************************************************************
* lag parameters and globals
************************************************************
global p = 24  // number of horizons
global lplags = 8  // number of lags in LP  
global q = 1 // recursiveness assumption
global fxlsout "$dir/tables/canada_qtl.xlsx"
************************************************************
*
* housekeeping
local p $p
local q $q
local lplags $lplags
local pp1 = `p'+1

*carbon tax variable
local x "rater_LCU_USD18sw"

***** create y vars for cumulative irfs
egen id = group(prov)
xtset id qdate
foreach v in "head" "core" "energyfood" {
forv h = 0/24 {
gen infl_`v'`h' = 100*(f`h'.cpi_`v' - l.cpi_`v')/l.cpi_`v' 		
}
} 

* run LP
sca irfno = 0
foreach y in  "infl_head" "infl_core" "infl_energyfood" { //LHS variable loop

  preserve

  *
  * set panel
  cap drop cdum
  cap drop cnum
  egen cnum = group(prov)
  xtset cnum qdate
  qui tab qdate, gen(ydum)
  qui tab prov, gen(cdum)
  local nc = r(r)
  
  * carbon tax path
  sca rateinit = 40
   if strmatch("`x'","*sw") sca swfac = 0.3
  mat xpath = J(`pp1',1,rateinit) // real carbon tax path
	
  global y "`y'"
  global x "`x'"

   mat theta11 = J(`pp1',1,1)
   sca irfno = irfno+1
    mat b99 = J(`pp1',1,0)
    mat s99 = b99
    cap drop e99*
    forvalues h = 0/`p' {
     local hp1 = `h'+1
	 * effect on y h-periods hence of unit innovation in x
     qui reg `y'`h' L(0/`lplags').`x' L(1/`lplags').`y' L(`q'/`lplags').dlemptot ydum* cdum*, r
     mat b98 = e(b)
     mat b99[`hp1',1] = b98[1,1]
     * create product of X projected off of controls * resids for computing HR VCV matrix
     local k = e(df_m)
     cap drop smpl`h' e`h' etax`h' zz`h'
	 qui gen smpl`h' = e(sample)
	 qui predict e`h', resid
     qui reg `x' L(1/`lplags').`x' L(1/`lplags').`y' ydum* cdum* if smpl`h', r
	 qui predict etax`h', resid
	 qui su etax`h' if smpl`h'
     gen zz`h' = (r(N)/(r(N)-1))*(e`h'*etax`h'/r(Var))/sqrt(r(N)-`k') if smpl`h'
     * IRF from rate shock to rate - for inverting rate path to shocks
     if `h'>0 {
      qui areg F`h'.`x' L(0/`lplags').`x' L(1/`lplags').`y' ydum*, absorb(cnum) vce(r)
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
    do "$dir/codes/_01irf.do"
 
	restore
} // y loop



********************************************************************************
********************* Figures based on cumulative IRFs  ************************
 
set scheme s1mono
graph set window fontface "Times New Roman"

*import irf estimates
import excel using "$dir/tables/canada_qtl.xlsx", first clear

*prepare data
drop if _n <3
destring C, replace

drop B 
rename (C-AA) (b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 b17 b18 b19 b20 b21 b22 b23 b24)
rename Effectafterhyearsof40incr est0
replace est0 = "beta" if _n ==1 | _n ==3 | _n ==5
replace est0 = "se" if _n ==2 | _n ==4 | _n ==6

g y = "infl_head"
replace y = "infl_core" if _n >2
replace y = "infl_energyfood" if _n >4

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

rename horizon Years
drop if Years >20
twoway ///
		(rarea u_2 d_2  Years,  ///
		fcolor(gs15) lcolor(gs15) lw(none) lpattern(solid)) ///
		(rarea u_1 d_1  Years,  ///
		fcolor(gs10) lcolor(gs10) lw(none) lpattern(solid)) ///
		(line b Years, lcolor(gs0) ///
		lpattern(solid) lwidth(medthick)), /// 
		yline(0, lp("-") lc(gs6)) legend(off) ///
		title("", color(black) size(medsmall)) ///
		ytitle("Percentage points", size(medlarge)) xtitle("Quarters", size(medlarge)) ///
		ylab(-8(2)8,) xlab(0(4)20,)	
		gr export "$dir/figures/lp_can_qtl_`v'.pdf", as(pdf) replace
restore
}
