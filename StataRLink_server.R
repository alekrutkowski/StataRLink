
message('Any old files to be removed?...')
any(file.remove(setdiff(list.files(path=..server_dir..,
                                   pattern=paste0('^script .*\\.R$',
                                                  '|^script .*\\.R.done$',
                                                  '|^script .*\\.R.output$',
                                                  '|.*.server_opened$',
                                                  '|^server.*\\.R$'),
                                   full.names=TRUE),
                        paste0(..server_dir..,'server ',..dt.., '.R'))))

..tor.. <- function(StataFile) {
    StataData <<- read.delim(StataFile)
    file.remove(StataFile)
}

cat('', file = paste0(..server_dir.., ..dt.., '.server_opened'))
message('Waiting for jobs...')
repeat {
    ..newfile.. <- list.files(path=..server_dir..,
                              pattern='^script .*\\.R$',
                              full.names=TRUE)[1]
    if (!is.na(..newfile..)) {
        message('Executing ', ..newfile.., '...')
        capture.output(tryCatch(source(..newfile..,
                                       echo=TRUE),
                                error = function(e)
                                    cat(sub(paste0(..newfile..,':2:0:'),
                                            "",
                                            paste0('Error:\n ',
                                                   geterrmessage()),
                                            fixed=TRUE),
                                        sep='\n')),
                       file=paste0(..newfile.., '.output'))
        cat('', file = paste0(..newfile..,'.done'))
        file.remove(..newfile..)
        message('Waiting for jobs...')
        Sys.sleep(.01)
    }
}

