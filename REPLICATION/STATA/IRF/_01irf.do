* Codes for Konradt and Weder di Mauro - Greenflation 
* largely builds on codes by Metcalf and Stock (2020)
*   Writes excel spreadsheet of IRFs and SEs
*   Input are coefficient-level IRFs, VCV matrix, and X-variable IRFs for innovation
*   Outputs are quarterly IRFs for $40 carbon tax
*
quietly
local y "$y"
local x "$x"
local p $p
local pp1 = `p'+1

if irfno == 1 {
 cap erase "$fxlsout" 
 putexcel set "$fxlsout", modify
 qui putexcel A1   = "Effect after h years of $40 increase in carbon tax in quarter 0"
 qui putexcel C2   = "Effects in percent per annum, SEs are below estimates, lag ="
 qui putexcel A3   = "y"
 qui putexcel B3   = "x"
 qui putexcel C3   = matrix([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]) 
}
* --------- Compute IRF wrt scaled shock and its VCV ------------

 * (i) compute the shocks to x that deliver the desired x path 
 mat B = I(`p'+1)
 forvalues h = 1/`p' {
  forvalues i = 1/`h' {
   mat B[`h'+1,`i'] = theta11[`h'-`i'+2,1]'
  }
 }
 mat epsx = inv(B)*xpath*swfac
 * (ii) compute IRF and its covariance matrix wrt the x shocks
 mat shockmat = I(`pp1')
 forvalues i = 1/`pp1' {
  forvalues j = `i'/`pp1' {
   mat shockmat[`i',`j'] = epsx[`j'-`i'+1,1]
  }
 }
 mat irf = shockmat'*b99
 mat virf = shockmat'*v99*shockmat
 
*
mat seirf = vecdiag(cholesky(diag(vecdiag(virf))))' 

local rn = irfno*2+2
local rnp1 = `rn'+1
 qui putexcel A`rn'   = "`y'"
 qui putexcel B`rn'   = "`x'" 
 qui putexcel C`rn'   = matrix(irf'), nformat(###.00)
 qui putexcel C`rnp1' = matrix(seirf'), nformat(###.00) 
 
noisily


