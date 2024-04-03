
clear all 

* Import the data y h s p for the 10 subjects of GW(1999). 
* Note that the "subject 11" is the "median subject"

cd "C:\Users\Yao Thibaut Kpegli\Desktop\ENS Lyon\Econometrics-Discrete-Choice-Models\Maximum Likelihood Estimation" // put the path of the computer where is your database ("ENS_data_GW1999.xlsx") 

import excel ENS_data_GW1999.xlsx, sheet("Feuil1") firstrow

replace p = p/100

program define risk   // give a name for the program, here "risk"
args lnf alph delt gam sig2  // name the argument of the maximization (our theta)

tempvar y h s p w m // provide the names of variables (data: y h s and p) and other intermadiates variables (if necessary, here w and m)
quietly {

generate double `y'  = $ML_y1  // ML_y1 is the way stata name the first variable you will pass in your model
generate double `h'  = $ML_y2  // idem
generate double `s'  = $ML_y3  // idem
generate double `p'  = $ML_y4  // idem

gen double `w'=(`delt'*`p'^`gam')/(`delt'*`p'^`gam'+(1-`p')^`gam')  
gen double `m'=((`h'^`alph'-`s'^`alph')*`w' + `s'^`alph')^(1/`alph')

replace `lnf' = -0.5*(log(`sig2') + log(2*c(pi)) + ((`y' - `m')^2)/`sig2')


}

end


***************************** Estimate subject by subject****************************************
forvalue i=1/11 {

ml model lf risk (alpha: y h s p=) (delta: ) (gamma: )(sigma2: ) if Subject==`i', max
ml di

}



***************************** Have all results of subjects in single step************************

tab Subj, gen(I_)

ml model lf risk (alpha: y h s p= I_* ,nocons) (delta: I_* ,nocons) (gamma: I_* ,nocons)(sigma2: I_* ,nocons) , max
ml di

outtex 

forvalue i=1/10 {
tw (function y=(_b[delta:I_11]*x^_b[gamma:I_`i'])/(_b[delta:I_11]*x^_b[gamma:I_11] + (1-x)^_b[gamma:I_`i']))(function y=x) ///
, title(Weighting function) name(w_`i') graphregion(color(white)) xtitle(p) ytitle("w(p)") legend(row(2) ring(0) position(11) label(1 "w(p)") label(2 "45 ° line"))

}

forvalue i=1/10 {
tw (function y=x^_b[alpha:I_`i'] , range(0 800)) , title(Utility function) name(u_`i') graphregion(color(white)) xtitle("outcome in $ US") ytitle("utility") legend(row(2) ring(0) position(11) label(1 "w(p)") label(2 "45 ° line"))
}


forvalue i=1/10 {
graph combine u_`i' w_`i' , graphregion(color(white)) name(com_`i')
}



tw (function y=x^_b[alpha:I_11] , range(0 800)) , title(Utility function) name(u) graphregion(color(white)) xtitle("outcome in $ US") ytitle("utility") legend(row(2) ring(0) position(11) label(1 "w(p)") label(2 "45 ° line"))


tw (function y=(_b[delta:I_11]*x^_b[gamma:I_11])/(_b[delta:I_11]*x^_b[gamma:I_11] + (1-x)^_b[gamma:I_11]))(function y=x) ///
, title(Weighting function) name(w) graphregion(color(white)) xtitle(p) ytitle("w(p)") legend(row(2) ring(0) position(11) label(1 "w(p)") label(2 "45 ° line"))


graph combine u w , graphregion(color(white))
