clear all

*********************************************************************
*************************Ordered Logit*******************************
*********************************************************************

cd "C:\Users\Yao Thibaut Kpegli\Desktop\Bureau\ENS cours\M2"

use ordwarm2 , clear


ologit warm yr89 male white age ed prst

outtex, legend


* MEM
eststo:  margins , dydx(*)  atmeans post


*AME 
ologit warm yr89 male white age ed prst

eststo:  margins , dydx(*)  post

*esttab using result_mem.tex, se wide replace


clear all
set more 1
use "http://fmwww.bc.edu/ec-p/data/mus/mus15data"


*********************************************************************
*******************************MNL***********************************
*********************************************************************

* We estimate a multinomial logit with monthly income as case-specific regressor
* We arbitrarly set "beach fishing" as base category (mode=1)

mlogit mode income, base(1) nolog

* MEM
eststo:  margins , dydx(*)  atmeans post


* AME
mlogit mode income, base(1) nolog

eststo:  margins , dydx(*)  post

*esttab using result_mem.tex, se wide replace

*********************************************************************
****************************CL***************************************
*********************************************************************
* First, we need to reshape the data from wide to long form

generate id=_n

reshape long d p q, i(id) j(fishmode beach pier private charter) string

* Then we implement the Conditional Logit model using as regressors only prices and catch rate (thus estimating alt-invariant coefficients)

asclogit d p q, case(id) alternatives(fishmode) noconst
outtex, legend

estat mfx


*********************************************************************
****************************Mixed***************************************
*********************************************************************

asclogit d p q, case(id) alternatives(fishmode) casevars(income)  basealternative(beach)
outtex, legend


estat mfx



*********************************************************************
****************************Nested Logit*****************************
*********************************************************************
* We now implement a Nested Logit model
* The nature of the estimation requires us to start from the dataset in long form


nlogitgen type=fishmode(shore: pier|beach, boat: private|charter)

nlogittree fishmode type, choice(d)

nlogit d p q || type:, base(shore) || fishmode: income , case(id) notree nolog 
outtex, legend



*********************************************************************
*******************************Poisson*******************************
*********************************************************************


use mus17data.dta , clear 

des docvis private medicaid age age2 educyr actlim totchr

sum docvis private medicaid age age2 educyr actlim totchr

eststo: poisson docvis private medicaid age age2 educyr actlim totchr , nolog

poisson docvis private medicaid age age2 educyr actlim totchr , nolog
eststo:  margins , dydx(*)  atmeans post


poisson docvis private medicaid age age2 educyr actlim totchr , nolog
eststo:  margins , dydx(*)   post

*esttab using result_mem.tex, se wide replace






