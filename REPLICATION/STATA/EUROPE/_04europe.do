* Codes for Konradt and Weder di Mauro - Greenflation 
* produces Figures B1, B2 and Table B1 in Online Appendix
* requires ado synth2 (and Stata 16)

cd "$dir"

set scheme s1mono
graph set window fontface "Times New Roman"

use "$dir/data/ctax_panel_eu_mth.dta", clear

* Figure B1

* loop over countries with large tax rate/available data
local j = 1
foreach v in "FIN" "CHE" "FRA" "DNK" "NOR" "SWE" "IRL" "ISL" "ESP" "PRT" "GBR" {
preserve

* define tax economy and month
local iso "`v'"
qui: summarize tax_year if iso =="`v'"
local year = r(mean)
qui: summarize tax_month if iso =="`v'"
local month = r(mean)

* drop economies with missing data
egen go = count(_n) , by(iso)
qui: sum cpi_head if iso =="`v'"
local n_go = r(N)
drop if go < `n_go'

* normalize cpi to 100 in tax month
gen mtreat = 1 if year ==`year' & month ==`month'
bysort id (mtreat): gen cpi2 = 100*(cpi_head/cpi_head[1])
replace cpi_head = cpi2

* extract sample parameters, exclude economies with carbon tax 
quietly: summarize id if iso =="`v'"
local treat = r(mean)
quietly: summarize mdate if mtreat ==1
local event = r(mean)
drop if mdate > `event'+60 | mdate < `event'-60
gen drop = 1 if tax_range == 1 & iso != "`v'"
bys iso: egen mdrop = max(drop)
drop if mdrop ==1
local mseend = `event'-1
quietly: summarize mdate
local start = r(min)
local end = r(max)

* months to be included in scm
foreach c of num 1/58 {
	local start`c' = `start' + `c'
}

*run scm
global var cpi_head
qui synth2 cpi_head $var(`start')   $var(`start1')  $var(`start2')  $var(`start3')  $var(`start4')  $var(`start5')  $var(`start6')  $var(`start7') /// 
                $var(`start8')  $var(`start9')  $var(`start10') $var(`start11') $var(`start12') $var(`start13') $var(`start14') $var(`start15') ///
			    $var(`start16') $var(`start17') $var(`start18') $var(`start19') $var(`start20') $var(`start21') $var(`start22') $var(`start23') ///
			    $var(`start24') $var(`start25') $var(`start26') $var(`start27') $var(`start29') $var(`start30') $var(`start31') $var(`start32') ///
			    $var(`start33') $var(`start34') $var(`start35') $var(`start36') $var(`start37') $var(`start38') $var(`start39') $var(`start40') ///
			    $var(`start41') $var(`start42') $var(`start43') $var(`start44') $var(`start45') $var(`start46') $var(`start47') $var(`start48') ///
			    $var(`start49') $var(`start50') $var(`start51') $var(`start52') $var(`start53') $var(`start54') $var(`start55') $var(`start56') ///
			    $var(`start57') $var(`start58') $var(`mseend') , ///
trunit(`treat') mspeperiod(`start'(1)`mseend') postperiod(`event'(1)`end') trperiod(`event') nofigure

*save weights
mat wgt =  e(U_wt)
local rownames : rownames wgt

g _weight =.
g _id = .
g _treat = iso if id ==`treat'
local c = 1
foreach v of local rownames {
	replace _weight = wgt[`c',1] if _n ==`c'
	replace _id = `v' if _n ==`c'
	local c = `c'+1
}
g j = `j'
tempfile w`j'
save `w`j''

* compute predicted values
g ckeep = 0
local c = 1
foreach v of local rownames {
	replace cpi_head = cpi_head*wgt[`c',1] if id ==`v'
	replace ckeep = 1 if id ==`v'
	
	local c = `c'+1
}
replace ckeep = 1 if id==`treat'
keep if ckeep ==1

g _Y_synthetic = cpi_head if id !=`treat'
g _Y_treated = cpi_head if id ==`treat'

replace iso ="" if id !=`treat'
collapse (sum) _Y_*  (firstnm) iso, by(mdate)
egen time = seq() ,f(-60) t(60) 
drop mdate
tempfile x`j'
save `x`j''
restore
local j = `j'+1
}

* combine and take average over all tax economies and their counterfactuals
clear
forval i=1/11{
append using `x`i''
} 
collapse (mean) _Y_* ,by(time)

tw line _Y_synthetic time, col(gs0) lp("-") lw(medthick) sort || line _Y_treated time, col(gs0) lw(medthick) sort /// 
	xline(0, lp("-") lc(gs6) lw(thin))  xtitle("") ytitle("Headline CPI", size(medlarge)) ylab(80(10)120,nogrid)  ///
	legend(order(2 "Tax Economy Mean" 1 "Counterfactual Economy Mean") r(1) region(color(none))) graphregion(color(white)) ///
	xlab(-60 "-5" -48 "-4" -36 "-3" -24 "-2" -12 "-1" 0 12 "+1" 24 "+2" 36 "+3" 48 "+4" 60 "+5", )
	gr export "$dir/figures/scm_eu_agg.pdf", as(pdf) replace

********************************************************************************	
* Figure B2

* create same figures for individual tax economies
forval i=1/3{
clear
append using `x`i''
local v = iso
tw line _Y_synthetic time, col(gs0) lp("-") lw(medthick) sort || line _Y_treated time, col(gs0) lw(medthick) sort /// 
	xline(0, lp("-") lc(gs6) lw(thin))  xtitle("") ytitle("Headline CPI", size(medlarge)) ylab(80(10)120,nogrid)  ///
	legend(order(2 "Tax Economy" 1 "Counterfactual Economy") r(1) region(color(none))) graphregion(color(white)) ///
	xlab(-60 "-5" -48 "-4" -36 "-3" -24 "-2" -12 "-1" 0 12 "+1" 24 "+2" 36 "+3" 48 "+4" 60 "+5", )
	gr export "$dir/figures/scm_eu_`v'.pdf", as(pdf) replace
}

********************************************************************************
* Table B1

* combine and clean estimated weights 
clear
forval i=1/11{
append using `w`i''
} 

bys j (_treat): replace _treat = _treat[_N]
keep if !mi(_weight)

keep _treat _weight _id j

rename _id id 
merge m:m id using "$dir/data/ctax_panel_eu_mth.dta"
keep if _merge ==3  

collapse (firstnm) _weight, by(iso _treat)
rename iso donor

* use donor economies and respective weights in counterfactual economies
gsort _treat -_weight

*keep and list 3 largest donors for each tax economy
bys _treat: keep if _n <=3
bys _treat: g donor1 = donor if _n ==1
bys _treat: replace donor ="" if _n ==1
collapse (firstnm) donor1 donor2 = donor (lastnm) donor3 = donor, by(_treat)
replace donor3 ="" if donor3 ==donor2
g donorlist = donor1 
replace donorlist = donorlist + ", " + donor2 if !mi(donor2)
replace donorlist = donorlist + ", " + donor3 if !mi(donor3)

list _treat donorlist
