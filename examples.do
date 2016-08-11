set line 140
cls
startr  // start R "server"
r options(width=140)
sysuse auto, clear  // open example datasets available in Stata (built-in)
tor  // i.e. "to R" -- export data to R; as a convention the dataset is put into R object called `StataData`
r StataData <- within(StataData, new <- price/100)  // `r` command allows to execute R functions interactively
fromr  // import modified data (`StataData` object) back into Stata
list in 1/5, clean  // have a look at the top of the data
r StataData <- within(StataData, new2 <- rep78/100)  // do some manipulations again in R
fromr, clear  // import the latest version of the `StataData` object
list in 1/5, clean  // have a look at the top of the data
tor in 1/3  // you can export observation subsets with `if` and `in`
r StataData  // see how the data now looks inside R
tor m* in 1/3  // you can also export column (variable) subsets
r StataData  // again, see how the data now looks inside R
stopr  // close the R "server"

