* Codes for Konradt and Weder di Mauro - Greenflation 
* largely builds on codes by Metcalf and Stock (2020)
* produces Table A1, Table A3 and Table A5 of Online Appendix

* Table A1  

use "$dir/data/ctax_panel_eu.dta", clear

************************************************************
* lag parameters and globals
************************************************************
global p = 6  // number of horizons, also number of lags in DL specifications
global lplags = 4  // number of lags in LP and XTVAR specifications
global q = 1 // recursiveness assumption
global fxlsout "$dir/tables/europe_lp_rob1.xlsx"
************************************************************
*
* housekeeping
local p $p
local lplags $lplags
local q $q
local pp1 = `p'+1

*set of controls
bys iso (year): g t = _n
g t2 = t^2
global ctrl1 "L(`q'/`lplags').dpolicyrate L(`q'/`lplags').dlrgdp i.year"
global ctrl2 "L(`q'/`lplags').dpolicyrate L(`q'/`lplags').dlrgdp t"
global ctrl3 "L(`q'/`lplags').dpolicyrate L(`q'/`lplags').dlrgdp t2"

*carbon tax variable
local x "rater_LCU_USD18sw" 

*run LPs
sca irfno = 0
foreach y in  "infl_head" "infl_core" "infl_energyfood" { //LHS variable loop
 forval smpl = 1/1 { //subsample loop
  preserve
  
  * set panel
  cap drop cdum
  cap drop cnum
  egen cnum = group(iso)
  xtset cnum year
  tab year, gen(ydum)
  tab iso, gen(cdum)
  local nc = r(r)
  
  * carbon tax path
  sca rateinit = 40
   if strmatch("`x'","*sw") sca swfac = 0.3
  mat xpath = J(`pp1',1,rateinit) // real carbon tax path
	
  global y "`y'"
  global x "`x'"
  global smple "`smpl'" 
  forval j = 1/3 { //controls loop
  global controls "`j'"
  
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
* Table A3

use "$dir/data/ctax_panel_eu.dta", clear

************************************************************
* lag parameters and globals
************************************************************
global p = 6  // number of horizons, also number of lags in DL specifications
global svlags = 4  // number of lags in VAR
global q = 1 // recursiveness assumption
global fxlsout "$dir/tables/europe_var_rob.xlsx"
************************************************************
*
* housekeeping
local p $p
local svlags $svlags
local q $q
local pp1 = `p'+1

*set of controls
global ctrl1 "i.year"
global ctrl2 "L(`q'/`svlags').dpolicyrate L(`q'/`svlags').dlrgdp i.year"

*carbon tax variable
local x "rater_LCU_USD18sw" 

*set panel
cap drop cdum
cap drop cnum
egen cnum = group(iso)
xtset cnum year
tab year, gen(ydum)
tab iso, gen(cdum)
local nc = r(r)

*run VARs
sca irfno = 0
foreach y in  "infl_head" "infl_core" "infl_energyfood" { //LHS variable loop
  * lags of x and y for VARs
  global xylags ""
    forvalues i = 1/`svlags' {
	 global xylagsi "L`i'.`x' L`i'.`y'"
     global xylags $xylags $xylagsi
	}
	
  * carbon tax path
  sca rateinit = 40
   if strmatch("`x'","*sw") sca swfac = 0.3
  mat xpath = J(`pp1',1,rateinit) // real carbon tax path
	
 forval smpl = 1/1 { //subsample loop
  global y "`y'"
  global x "`x'"
  global smple "`smpl'" 
  
  forval j = 1/2 { //controls loop
  preserve
  
  global controls "`j'"
   global svlags `svlags'
   sca irfno = irfno+1
   local svlags $svlags

    qui sureg (`x' = $xylags cdum* ${ctrl`j'}) (`y' = L0.`x' $xylags cdum* ${ctrl`j'})
    mat b98 = e(b)
    mat v98 = e(V)
    ...
   * compute and save irfs 
   do "$dir/codes/_02irf.do"   
   
 	restore
	} //controls loop
 } // smple loop
} // y loop

********************************************************************************
* Table A5

use "$dir/data/ctax_panel_eu.dta", clear

************************************************************
* lag parameters and globals
************************************************************
global p = 6
global lplags = 4
global q = 1
global fxlsout "$dir/tables/europe_lp_rob2.xlsx"
************************************************************

...

    *compute and save irfs
    do "$dir/codes/_00irf.do"
