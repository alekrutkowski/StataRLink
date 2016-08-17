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
	tempfile d
	loc d = subinstr("`d'","\","/",.)
	di as txt "Exportng " as res `"'`name''"' as txt " from R..."
	qui r write.table(\``name'\`,'`d'', sep='\t', row.names=FALSE, na='.')
	di as txt "Importing data into Stata..."
	insheet using "`d'", tab names `clear'
end

