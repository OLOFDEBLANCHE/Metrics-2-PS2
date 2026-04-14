cd "C:\Users\24693\OneDrive - Handelshögskolan i Stockholm\Documents\Plugg\Metrics 2\PS\2"
clear all
**# Question 2


set obs 120

set seed 56

gen tau = rnormal(1,1)
gen eps = rnormal(0,1)
gen X = _n <= 60


gen Y_1 = tau + 5*X + eps
gen Y_0 = 5*X + eps 

gen IT = Y_1 - Y_0

sum IT

local ATE = r(mean)

frame create measures
frame change measures 

set obs 1000

forvalues j = 1/3{
	g est`j' = 0
	g se`j' = 0
	g p`j' = 0
	
	
}


frame change default 



forvalues j = 1/3{
	
	
	forvalues i = 1/1000{
		
		gen random = runiform(0,1)
		
		
		if `j'<3{
			sort random 
			g D = _n<= 120*0.25*`j'
			
		}
		
		if `j' == 3{
			sort X random
			by X: g D = _n <= _N*0.25 
			
		}
	
		g Y = Y_1*D + Y_0*(1-D)
	
		quietly reg Y D 
	
		frame change measures 
	
		quietly{
		replace est`j' = r(table)[1,1] if _n == `i'
		replace se`j' = r(table)[2,1] if _n == `i'
		
 	
		}
		quietly lincom D - `ATE'
		quietly replace p`j' = r(p) if _n == `i'
	
		frame change default 
	
		drop random Y D 
	
}


}


frame change measures

twoway (kdensity est1, ytitle("Density") xtitle("Estimated ATE") legend(label(1 "%Treated = 25%") label(2 "%Treated = 50%") label(3 "%Treated = 25%, Stratified") position(6) cols(3))) (kdensity est2) (kdensity est3) 

graph export "pictures\densities2.png", replace

sum est1 est2 est3

sum se1 se2 se3 

forvalues i = 1/3{
	g count = p`i' < 0.05
	
	count if count == 1
	drop count
}


**# Question 3 
clear all
set obs 1000

set seed 5

gen tau = rnormal(1,1)
gen eps = rnormal(0,1)
gen X_1 = eps > 1
gen X_0 = eps > -1


gen Y_1 = tau + 5*X_1 + eps
gen Y_0 = 5*X_0 + eps 

gen IT = Y_1 - Y_0

sum IT

sum tau

frame create measures
frame change measures 

set obs 1000

forvalues j = 1/3{
	g est`j' = 0

}

frame change default 


forvalues i = 1/1000{
	g random = runiform(0,1)
	sort random 
	g D = _n <= 500
	
	g Y = Y_1*D + Y_0*(1-D)
	
	g X = X_1*D + X_0*(1-D)
	
	quietly reg Y D
	
	frame change measures 
	
	quietly replace est1 = r(table)[1,1] if _n == `i'
	
	frame change default
		
	quietly reg Y D if X == 0
	
	frame change measures
	
	quietly replace est2 = r(table)[1,1] if _n == `i'
	
	frame change default
	quietly reg Y D if X == 1
	
	frame change measures
	quietly replace est3 = r(table)[1,1] if _n == `i'
	
	frame change default
	drop random Y X D
}
	
frame change measures 

sum est1 est2 est3
	
	
	
**# Question 5

clear all
set obs 10000

set seed 7

gen tau = rnormal(1,1)
gen eps = rnormal(0,1)
g X = _n <= 4000


gen Y_1 = tau + 5*X + eps
gen Y_0 = 5*X + eps 

gen IT = Y_1 - Y_0

gen random = runiform(0,1)

g D = (random <= 0.8)*(X == 1) + (random<= 0.5)*(X == 0)

g Y = Y_1*D + Y_0*(1-D)

reg Y D if X == 0
eststo m1

reg Y D if X == 1
eststo m2

reg Y D X
eststo m3 


reg Y D 
eststo m4

esttab m1 m2 m3 m4 using "data\Q5.tex", replace









