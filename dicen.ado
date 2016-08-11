program dicen
	loc len = strlen(`0')
	loc col = int((c(linesize) - `len')/2) - 2
	di as txt "{hline `col'} " `0' " {hline}" _c
end
