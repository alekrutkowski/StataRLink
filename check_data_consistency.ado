prog check_data_consistency
	args Robj err varlist if in
	preserve
		if !mi(`"`varlist'"') keep `varlist'
		if !mi(`"`if'"') | !mi(`"`in'"') qui keep `if' `in'
		qui des
	restore
	loc direc = cond(`err'==692, "imported", "exported")
	tempvar Nobs Nvars NobsR NvarsR
	sca `Nobs' = r(N)
	sca `Nvars' = r(k)
	qui r nrow(\``Robj'\`)
	sca `NobsR' = real(word(`"`r(r2)'"',2))
	qui r ncol(\``Robj'\`)
	sca `NvarsR' = real(word(`"`r(r2)'"',2))
	if `Nvars'!=`NvarsR' {
		di as err "Something went wrong:" _n /*
			*/ "The `direc' Stata data has {bf:`=`Nvars''} columns/variables," _n /*
			*/ `"R data.frame "`Robj'" has {bf:`=`NvarsR''} columns/variables."'
		err `err'
	}
	if `Nobs'!=`NobsR' {
		di as err "Something went wrong:" _n /*
			*/ "The `direc' Stata data has {bf:`=`Nobs''} rows/observations," _n /*
			*/ `"R data.frame "`Robj'" has {bf:`=`NobsR''} rows/observations."'
		err `err'
	}
end

