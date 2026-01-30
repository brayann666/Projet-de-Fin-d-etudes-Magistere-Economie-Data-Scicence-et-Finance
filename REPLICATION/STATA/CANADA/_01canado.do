* Codes for Konradt and Weder di Mauro - Greenflation 
* produces descriptives in Table 1 and Tables C1 and C2 in the Online Appendix

* Table 1

use "$dir/data/ctax_panel_can.dta", clear

g enacted = "July 2008" if prov =="Quebec"
replace enacted = "January 2013" if prov =="British Columbia"
replace enacted = "January 2017" if prov =="Alberta" 

replace rater_LCU_USD18 = . if rater_LCU_USD18 ==0

keep if !mi(enacted)
collapse (firstnm) enacted rate_start = rater_LCU_USD18 (lastnm) rate_18 = rater_LCU_USD18 share19, by(prov)

list


* Table C1, C2 

use "$dir/data/ctax_panel_can.dta", clear

tab prov if !mi(infl_head)

tabstat infl* dlgdp dpolicyrate demp dtradebalance, c(s) s(N mean p50 sd) f(%12.2f)

