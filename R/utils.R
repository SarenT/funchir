# Specific wrapper of cut to create a factor of quantiles of a vector
create_quantiles <- function(x, num, right = FALSE, na.rm = FALSE,
                             include.lowest = TRUE, labels = 1:num){
  uniq_Qs = unique(quantile(x, probs = 0:num/num, na.rm = na.rm))
  if (length(uniq_Qs) - 1L != length(labels) && !is.null(labels))
    stop('Overlapping quantiles. Please provide ', length(uniq_Qs) - 1L, ' labels.')
  cut(x, breaks = uniq_Qs, labels = labels, right = right,
      include.lowest = include.lowest)
}

# Inline conversion to percentage
to.pct <- function(x, dig = Inf) round(100 * x, digits = dig)

# Get the nearest multiple of n weakly larger than x
nx.mlt <- function(x, n) n * ceiling(x / n)

# Create a linear progression along the range of x with n points
divide = function(x, n, na.rm = FALSE) {
  r = range(x, na.rm = na.rm)
  seq(r[1L], r[2L], length.out = n)
}

# Convert numbers for printing to dollar format
dol.form <- function(x, dig = 0L, suff = "", tex = FALSE){
  neg <- rep("", length(x))
  neg[x < 0] <- "-"
  div <- c(1, "k"=1e3, "m"=1e6, "b"=1e9)
  idx <- which(names(div) == suff)
  paste0(neg, if (tex) "\\", "$",
         prettyNum(round(abs(x)/div[idx], digits = dig),
                   big.mark = ",", scientific = FALSE), suff)
}

# Convert numbers to strings OF SPECIFIED LENGTH
#   Convenient for getting c("99","00") from 99:100
ntostr <- function(n, dig = 2L){
  sprintf(sprintf("%%0%dd", dig), n %% 10L^dig)
}

# Condensed cleaning of work space at
#   outset of R script
# **has some errors when applied to more general setups**
# clean_slate = function(detach.packages = TRUE, gc = TRUE,
#                        all = TRUE, envir = .GlobalEnv) {
#   rm(list = ls(envir = envir, all.names = all), envir = envir)
#   if (gc) gc(verbose = FALSE)
#   if (detach.packages) {
#     base.pkg = "package:" %+% c("stats", "graphics", "grDevices",
#                                 "utils", "datasets", "methods", "base")
#     invisible(lapply(setdiff(grep("^package:",
#                                   search(), value = TRUE), base.pkg),
#                      detach, character.only = TRUE, unload = TRUE))
#   }
# }

# Write the output of sessionInfo() & the date to a file
#   (for tracking package versions over time)
write.packages <- function(con = stdout()) {
  si = sessionInfo()
  desc_fields = c('Version', 'Depends', 'Imports', 'Suggests',
                  'License', 'URL', 'Packaged', 'Built')
  desc_pad = function(desc) `names<-`(desc[desc_fields], desc_fields)
  locale_list = function() {
    # query these individually given proviso in ?Sys.getlocale:
    # > For portability, it is best to query categories individually...
    # this list of categories taken from the output of my Linux Mint machine
    lc_names = c('LC_CTYPE', 'LC_NUMERIC', 'LC_TIME', 'LC_COLLATE',
                 'LC_MONETARY', 'LC_MESSAGES', 'LC_PAPER',
                 'LC_NAME', 'LC_ADDRESS', 'LC_TELEPHONE',
                 'LC_MEASUREMENT', 'LC_IDENTIFICATION')
    as.list(
      sapply(lc_names, function(x) {
        tryCatch(Sys.getlocale(x), error = function(e) {
          if (e$message == "invalid 'category' argument") '' else stop(e$message)
        })
      })
    )
  }
  out = list(
    r_version = list(platform = si$platform,
                     version.string = si$R.version$version.string),
    locale = locale_list(),
    running = si$running,
    linear_algebra = list(matrix_products = si$matprod,
                          blas = si$BLAS, lapack= si$LAPACK),
    base_packages = si$basePkgs,
    other_packages = lapply(si$otherPkgs, desc_pad),
    loaded_via_namespace = lapply(si$loadedOnly, desc_pad),
    write_package_time = format(Sys.time(), tz = 'UTC', usetz = TRUE)
  )
  writeLines(toJSON(out, pretty = TRUE, auto_unbox = TRUE), con = con)
  return(invisible(out))
}

# Embed the matrix mat in a larger matrix by
#   placing the top-left element of mat at the supplied
#   position (m,n).
embed.mat <- function(mat, M = nrow(mat), N = ncol(mat),
                      m = 1L, n = 1L, fill = 0L) {
  if (m > M || n > N)
    stop("Supplied starting position outside supplied enclosing matrix bounds")
  if ((end1 <- m + nrow(mat) - 1L) > M ||
      (end2 <- n + ncol(mat) - 1L) > N){
    stop("Supplied matrix too large for supplied enclosing matrix")
  }
  out <- matrix(fill, nrow = M, ncol = N)
  out[m:end1, n:end2] <- mat
  out
}

# Quick scan of code for whether the
#   packages loaded are actually used
stale_package_check = function(con) {
  code = readLines(con = con)
  #should fix this to match require calls too...
  #remove comments
  code = gsub("#.*","",code)
  #remove empty lines and tabs
  code = gsub("\t","",code)
  code[code != ""]
  
  pkg_used =
    #also misses lines with multiple package calls
    gsub('.*library\\(["]?([^)]*)["]?\\).*', '\\1',
         grep('library', code, value = TRUE, fixed = TRUE))
  for (pkg in unique(pkg_used)) {
    fns = getNamespaceExports(pkg)
    # issue: short function names like D are likely
    #   to be matched even if unused as a function --
    #   this check could be more sophisticated
    used = names(which(sapply(fns, function(x)
      any(grepl(x, code, fixed = TRUE)))))
    if (length(used)) cat('\nFunctions matched from package ', pkg, ': ',
                          paste(used, collapse = ', '), sep = '')
    else cat('\n**No exported functions matched from ', pkg, '**', sep = '')
  }
}

# Accurately calculate fractional age, quickly
## R CMD check appeasement
cycle_type = extra = rem = int_yrs = i.start = start = end = NULL

get_age <- function(birthdays, ref_dates){
  `:=` = function(...) NULL
  .BY = NULL
  x <- data.table(bday <- unclass(birthdays),
                  rem = ((ref <- unclass(ref_dates)) - bday) %% 1461)
  x[ , cycle_type :=
       foverlaps(data.table(start = bdr <- bday %% 1461, end = bdr),
                 data.table(start = c(0, 59, 424, 790, 1155),
                            end = c(58, 423, 789, 1154, 1460),
                            val = c(3L, 2L, 1L, 4L, 3L),
                            key = "start,end"))$val]
  I4 <- diag(4L)[ , -4L]
  x[ , extra :=
       foverlaps(data.table(start = rem, end = rem),
                 data.table(start = st <- cumsum(c(0, rep(365, 3L) +
                                                     I4[.BY[[1L]], ])),
                            end = c(st[-1L] - 1L, 1461),
                            int_yrs = c(0, 1, 2, 3), key = "start,end")
       )[ , int_yrs + (i.start - start) / (end + 1L - start)], by = cycle_type]
  4 * ((ref - bday) %/% 1461) + x$extra
}

# Quickly get the year of a date
quick_year = function(dates) {
  quadrennia = as.integer(unclass(dates) %/% 1461L)
  rr = unclass(dates) %% 1461L
  rem_yrs = (rr > 365L) + (rr > 730L) + (rr > 1096L)
  1970L + 4L * quadrennia + rem_yrs
}

quick_yday = function(dates)
  ((((unclass(dates) %% 1461L) %% 1096L) %% 730L) %% 365L) +
  365L * (unclass(dates) == 1095L) + 1L

#Month days in the quadrennial cycle
.mday1461__ = c(1L:31L, 1L:28L, 1L:31L, 1L:30L, 1L:31L, 1L:30L,
                1L:31L, 1L:31L, 1L:30L, 1L:31L, 1L:30L, 1L:31L,
                1L:31L, 1L:28L, 1L:31L, 1L:30L, 1L:31L, 1L:30L,
                1L:31L, 1L:31L, 1L:30L, 1L:31L, 1L:30L, 1L:31L,
                1L:31L, 1L:29L, 1L:31L, 1L:30L, 1L:31L, 1L:30L,
                1L:31L, 1L:31L, 1L:30L, 1L:31L, 1L:30L, 1L:31L,
                1L:31L, 1L:28L, 1L:31L, 1L:30L, 1L:31L, 1L:30L,
                1L:31L, 1L:31L, 1L:30L, 1L:31L, 1L:30L, 1L:31L)

quick_mday = function(dates)
  .mday1461__[1L + unclass(dates) %% 1461L]

# Tired of over-using as.Date everywhere...
D <- function(...){
  if (is.null(names(dl <- list(...))))
    return(do.call("as.Date", list(do.call("c", dl))))
  do.call("as.Date", c(list(do.call("c", dl[nm <- names(dl) == ""])), dl[!nm]))
}

