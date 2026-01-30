* Codes for Konradt and Weder di Mauro - Greenflation 
* produces Figures and Tables in the main text and online appendix

clear all

*set directory
global dir "/Users/sims7/Desktop/FAC/M2/S1/PFE/replication"

*set = 1 to reproduce SCM results in Appendix C. Note this requires ado synth 2 (and Stata 16) 
global scm = 0 

****
**** European estimates
* summary stats
do "$dir/codes/_01europe.do"

* tables and figures
forval i = 2/3 {
	do "$dir/codes/_0`i'europe.do"
}

****
**** Canadian estimates
* summary stats
do "$dir/codes/_01canada.do"

* tables and figures
forval i = 2/4 {
	do "$dir/codes/_0`i'canada.do"
}

****
**** SCM (Europe and Canada)
if $scm ==1 {
	*ssc install synth2
	
	do "$dir/codes/_04europe.do"
	do "$dir/codes/_05canada.do"
}
