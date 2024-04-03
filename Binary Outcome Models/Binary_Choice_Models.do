

tw (function y =exp(x)/(1+exp(x)), range(-5 5)) ///
(function y = normal(x), range(-5 5)) ///
(function y =1-exp(-exp(x)), range(-5 5)), name(g1) xtitle(x) ytitle("g(x)") graphregion(color(white))  legend(row(3) ring(0) position(11) label(1 "Logit") label(2 "Probit") label(3 "log-log"))




*********************************LPM***********************************
* 0<P(y=1)=xb<1 non assuré par MCO
* u_i=y_i-x_i*b peut prendre que deux valeurs possibles, conditionnelement à x_i: absence de normalité
* hetero : v(u_i)=x_i*b*(1-x_i*b) for i=1,2,...,n
********************************************************************************

cd "C:\Users\Yao Thibaut Kpegli\Desktop\Bureau\ENS cours\M2\Seance 2"
clear all
use mus14data.dta , clear

keep ins retire age hstatusg hhincome educyear married hisp       // garder seulement les variables qui nous intéressent

estpost tabstat ins retire age hstatusg hhincome educyear married hisp, /* 
 */  statistics( mean sd min max ) /* 
 */  columns(variables)
*esttab using myfile.tex,  /* 
 */ cells("ins retire age hstatusg hhincome educyear married hisp") /* 
 */  replace nonum noobs

reg ins retire age hstatusg hhincome educyear married hisp                          // LPM
predict yhat, xb                              // fitted value from last regress
predict res, resid                            // residuals from last regress
sum yhat

                      
scatter yhat hhincome , graphregion(color(white)) xtitle("Household income") ytitle("Estimated probability") yline(0) yline(1)                   // nuage de point (valeur prédite, household income)  
scatter res yhat  , name(g2) graphregion(color(white)) xline(0) xline(1) xtitle("Linear prediction (Estimated probability)")                              // Q: Est-ce que l'ampleur des résidus est indépendante de l'observation ? Conclusion ?
rvfplot         , graphregion(color(white))                              // commande rapide pour faire scatter res yhat sans générer vous même res et yhat


eststo: logit ins retire age hstatusg hhincome educyear married hisp  
predict plogit, pr                        // logit
eststo: probit ins retire age hstatusg hhincome educyear married hisp
predict pprobit, pr                           // probit
eststo: reg ins retire age hstatusg hhincome educyear married hisp                          // LPM
predict pols, xb 

sum plogit pprobit pols


***** MEM
eststo clear

logit ins retire age hstatusg hhincome educyear married hisp   // logit
eststo:  margins, dydx(*) atmeans post
                    
probit ins retire age hstatusg hhincome educyear married hisp                          // probit
eststo: margins, dydx(*) atmeans post

reg ins retire age hstatusg hhincome educyear married hisp
eststo: margins, dydx(*) atmeans post

*esttab using result_mem.tex, se wide replace



*** AME
eststo clear

logit ins retire age hstatusg hhincome educyear married hisp   // logit
eststo:  margins, dydx(*)  post
                    
probit ins retire age hstatusg hhincome educyear married hisp                          // probit
eststo: margins, dydx(*)  post

reg ins retire age hstatusg hhincome educyear married hisp
eststo: margins, dydx(*)  post

*esttab using result_ame.tex, se wide replace



******************************** ML routine ************************************
program drop _all

program define mylogit
args lnf xb
qui replace `lnf' = $ML_y1*(`xb'-ln(1+exp(`xb')))  -  (1-$ML_y1)*ln(1+exp(`xb')) 
end
ml model lf mylogit (ins = retire age hstatusg hhincome educyear married hisp)
ml max
logit ins  retire age hstatusg hhincome educyear married hisp 



program define myprobit
args lnf xb
qui replace `lnf' = $ML_y1*ln(normal(`xb'))  +  (1-$ML_y1)*ln(1-normal(`xb')) 
end
ml model lf myprobit (ins = retire age hstatusg hhincome educyear married hisp)
ml max
probit ins  retire age hstatusg hhincome educyear married hisp 
