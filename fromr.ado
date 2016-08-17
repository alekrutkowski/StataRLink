prog fromr
	syntax [, name(string asis) clear noCHECK]
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
	if `"`r(r2)'"'=="[1] 0" {
		noi di as err `"'`name'' is empty: it has no observations/rows!"'
		err 675
	}
	qui r ncol(\``name'\`)
	if `"`r(r2)'"'=="[1] 0" {
		noi di as err `"'`name'' is empty: it has no variables/columns!"'
		err 675
	}
	tempfile d
	loc d = subinstr("`d'","\","/",.)
	di as txt "Exportng " as res `"'`name''"' as txt " from R..."
	cap r write.table(\``name'\`,'`d'', sep='\t', row.names=FALSE, na="", quote=FALSE)
	if _rc  {
		// "debugging mode":
		r write.table(\``name'\`,'`d'', sep='\t', row.names=FALSE, na="", quote=FALSE)
	}
	di as txt "Importing data into Stata..."
	insheet using "`d'", tab names case `clear'
	if "`check'"!="nocheck" /*
		*/ check_data_consistency `"`name'"' 692
end

