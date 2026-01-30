* Codes for Konradt and Weder di Mauro - Greenflation 
* produces descriptives in Table 1 and Tables C1 and C2 in the Online Appendix

* Table 1

use "$dir/data/ctax_panel_eu.dta", clear

g enacted = "January 1990" if iso =="FIN"
replace enacted = "January 1990" if iso =="POL"
replace enacted = "January 1991" if iso =="NOR"
replace enacted = "January 1991" if iso =="SWE"
replace enacted = "May 1992" if iso =="DNK"
replace enacted = "January 1996" if iso =="SVN"
replace enacted = "January 2000" if iso =="EST"
replace enacted = "January 2004" if iso =="LVA"
replace enacted = "January 2008" if iso =="CHE"
replace enacted = "January 2010" if iso =="IRL"
replace enacted = "January 2010" if iso =="ISL"
replace enacted = "April 2013" if iso =="GBR"
replace enacted = "January 2014" if iso =="ESP"
replace enacted = "April 2014" if iso =="FRA"
replace enacted = "January 2015" if iso =="PRT"

replace rater_LCU_USD18 = . if rater_LCU_USD18 ==0

keep if !mi(enacted)
collapse (firstnm) enacted rate_start = rater_LCU_USD18 (lastnm) rate_18 = rater_LCU_USD18 share19, by(iso)

list

* Table C1, C2 

use "$dir/data/ctax_panel_eu.dta", clear

tab iso if !mi(infl_head)

tabstat infl_head infl_core infl_energyfood dlrgdp dpolicyrate dtotrade dlemptot dtradebalance, c(s) s(N mean p50 sd) f(%12.2f)
