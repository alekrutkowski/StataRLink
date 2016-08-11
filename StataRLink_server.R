
tor <- function(StataFile) {
    StataData <<- read.delim(StataFile)
    file.remove(StataFile)
}

message('Any old files to be removed?...')
any(file.remove(list.files(path=..server_dir..,
                       pattern=paste0('^script .*\\.R$',
                                     '|^script .*\\.R.done$',
                                     '|^script .*\\.R.output$',
                                     '|.*.server_opened$'),
                       full.names=TRUE)))

cat('', file = paste0(..server_dir.., ..dt.., '.server_opened'))

repeat {
    newfile <- list.files(path=..server_dir..,
                          pattern='^script .*\\.R$',
                          full.names=TRUE)[1]
    if (!is.na(newfile)) {
        message('Executing ', newfile, '...')
        capture.output(tryCatch(source(newfile,
                                       echo=TRUE),
                                error = function(e)
                                    cat(geterrmessage())),
                       file=paste0(newfile, '.output'))
        cat('', file = paste0(newfile,'.done'))
        file.remove(newfile)
        message('Waiting for jobs...')
        Sys.sleep(.01)
    }
}

