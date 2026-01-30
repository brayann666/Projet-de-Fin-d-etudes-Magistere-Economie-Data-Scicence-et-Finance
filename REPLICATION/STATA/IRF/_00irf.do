* Codes for Konradt and Weder di Mauro - Greenflation 
* largely builds on codes by Metcalf and Stock (2020)
*   Writes excel spreadsheet of IRFs and SEs
*   Input are coefficient-level IRFs, VCV matrix, and X-variable IRFs for innovation
*   Outputs are annual IRFs for $40 carbon tax
*
quietly
local y "$y"
local x "$x"
local controls "$controls"
local smple "$smple"
local p $p
local pp1 = `p'+1
if irfno == 1 {
 cap erase "$fxlsout" 
 putexcel set "$fxlsout", modify
 qui putexcel A1   = "Effect after h years of $40 increase in carbon tax in year 0"
 qui putexcel E2   = "Effects in percent per annum, SEs are below estimates, lag ="
 qui putexcel M2   = "Effects averaged over indicated lags:"
 qui putexcel A3   = "y"
 qui putexcel B3   = "x"
 qui putexcel C3   = "controls"
 qui putexcel D3   = "sample"
 qui putexcel E3   = matrix([0,1,2,3,4,5,6])
 qui putexcel M3   = "Lag 0"
 qui putexcel N3   = "Lag 1-2"
 qui putexcel O3   = "Lag 3-5"
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
* IRF at lag 0, average of 1&2, average of 3,4,&5
mat A = [1  ,0  ,0  ,0  ,0  ,0  ,0\    ///
         0  ,0.5,0.5,0  ,0  ,0  ,0\    ///
	     0  ,0  ,0  ,1/3,1/3,1/3,0]
mat irfavg = A*irf
mat seirfavg = vecdiag(cholesky(diag(vecdiag(A*virf*A'))))'
mat list irfavg
mat list seirfavg

local rn = irfno*2+2
local rnp1 = `rn'+1
 qui putexcel A`rn'   = "`y'"
 qui putexcel B`rn'   = "`x'"
 qui putexcel C`rn'   = "`controls'"
 qui putexcel D`rn'   = "`smple'"
 qui putexcel E`rn'   = matrix(irf'), nformat(###.00)
 qui putexcel E`rnp1' = matrix(seirf'), nformat(###.00)
 qui putexcel M`rn'   = matrix(irfavg'), nformat(###.00)
 qui putexcel M`rnp1' = matrix(seirfavg'), nformat(###.00)
 
noisily


