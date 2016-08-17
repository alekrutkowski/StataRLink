prog tor
	syntax [varlist] [if] [in] [, name(string asis) replace]
	qui des
	if r(N)==0 | r(k)==0 {
		di as err "The dataset in Stata memory is empty!" _n /*
			*/ "(`r(k)' variables/columns, `r(N)' observations/rows)"
		err 3
	}
	if mi(`"`name'"') loc name "StataData"
	if mi("`replace'") {
		qui r exists('`name'')
		if strmatch(`"`r(r2)'"',"*TRUE") {
			noi di as err `"Object "`name'" already exists in R!"' _n /*
				*/ "Specify option {bf:replace} if you want to replace it or" _n /*
				*/ "specify a new object name inside option {bf:name()}."
			err 675
		}
	}
	tempfile d
	loc d "`d'.tor"
	di as txt "Exporting data from Stata..."
	qui outsheet `varlist' using "`d'" `if' `in', replace
	loc d = subinstr("`d'","\","/",.)
	di as txt "Importng data into R object " as res `"'`name''"' as txt "..."
	cap r \``name'\` <- read.delim('`d''); file.remove('`d'')
	if _rc {
		r \``name'\` <- read.delim('`d''); file.remove('`d'') // "debugging mode"
	}
	r str(\``name'\`)
end

