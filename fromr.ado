prog fromr
	syntax [, name(string asis) clear]
	if mi(`"`name'"') loc name "StataData"
	qui des
	if `r(changed)' & mi("`clear'") err 4
	if !(`r(changed)') loc clear "clear"
	qui r exists('`name'')
	if strmatch(`"`r(r2)'"',"*FALSE") {
		noi di as err `"'`name'' object does not exist in R."'
		err 675
	}
	qui r is.data.frame(\``name'\`)
	if strmatch(`"`r(r2)'"',"*FALSE") {
		noi di as err `"'`name'' object is not a data.frame!"'
		err 675
	}
	qui r nrow(\``name'\`)
	if strmatch(`"`r(r2)'"',"*0") {
		noi di as err `"'`name'' is empty: it has no observations/rows!"'
		err 675
	}
	qui r ncol(\``name'\`)
	if strmatch(`"`r(r2)'"',"*0") {
		noi di as err `"'`name'' is empty: it has no variables/columns!"'
		err 675
	}
	tempfile d
	loc d = subinstr("`d'","\","/",.)
	di as txt "Exportng " as res `"'`name''"' as txt " from R..."
	cap r write.table(\``name'\`,'`d'', sep='\t', row.names=FALSE, na='.')
	if _rc  {
		r write.table(\``name'\`,'`d'', sep='\t', row.names=FALSE, na='.') // "debugging mode"
	}
	di as txt "Importing data into Stata..."
	insheet using "`d'", tab names `clear'
end

