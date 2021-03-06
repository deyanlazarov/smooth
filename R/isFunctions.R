#' Smooth classes checkers
#'
#' Functions to check if an object is of the specified class
#'
#' The list of functions includes:
#' \itemize{
#' \item \code{is.smooth()} tests if the object was produced by a smooth function
#' (e.g. \link[smooth]{es} / \link[smooth]{ces} / \link[smooth]{ssarima} /
#' \link[smooth]{gum} / \link[smooth]{sma} / \link[smooth]{msarima});
#' \item \code{is.msarima()} tests if the object was produced by the
#' \link[smooth]{msarima} function;
#' \item \code{is.smoothC()} tests if the object was produced by a combination
#' function (currently applies only to \link[smooth]{smoothCombine});
#' \item \code{is.vsmooth()} tests if the object was produced by a vector model (e.g.
#' \link[smooth]{ves} / \link[smooth]{gsi});
#' \item \code{is.iss()} tests if the object was produced by \link[smooth]{iss}
#' function;
#' \item \code{is.viss()} tests if the object was produced by \link[smooth]{viss}
#' function;
#' \item \code{is.smooth.sim()} tests if the object was produced by simulate functions
#' (e.g. \link[smooth]{sim.es} / \link[smooth]{sim.ces} / \link[smooth]{sim.ssarima}
#' / \link[smooth]{sim.sma} / \link[smooth]{sim.gum});
#' \item \code{is.vsmooth.sim()} tests if the object was produced by the functions
#' \link[smooth]{sim.ves};
#' \item \code{is.smooth.forecast()} checks if the forecast was produced from a smooth
#' function using forecast() function.
#' }
#'
#' @param x The object to check.
#' @return \code{TRUE} if this is the specified class and \code{FALSE} otherwise.
#'
#' @template ssAuthor
#' @keywords ts univar
#' @examples
#'
#' ourModel <- msarima(rnorm(100,100,10))
#'
#' is.smooth(ourModel)
#' is.iss(ourModel)
#' is.msarima(ourModel)
#' is.vsmooth(ourModel)
#'
#' @rdname isFunctions
#' @export
is.smooth <- function(x){
    return(inherits(x,"smooth"))
}

#' @rdname isFunctions
#' @export
is.vsmooth <- function(x){
    return(inherits(x,"vsmooth"))
}

#' @rdname isFunctions
#' @export
is.smoothC <- function(x){
    return(inherits(x,"smoothC"))
}

#' @rdname isFunctions
#' @export
is.msarima <- function(x){
    return(inherits(x,"msarima"))
}

#' @rdname isFunctions
#' @export
is.iss <- function(x){
    return(inherits(x,"iss"))
}

#' @rdname isFunctions
#' @export
is.viss <- function(x){
    return(inherits(x,"viss"))
}

#' @rdname isFunctions
#' @export
is.smooth.sim <- function(x){
    return(inherits(x,"smooth.sim"))
}

#' @rdname isFunctions
#' @export
is.vsmooth.sim <- function(x){
    return(inherits(x,"vsmooth.sim"))
}

#' @rdname isFunctions
#' @export
is.smooth.forecast <- function(x){
    return(inherits(x,"smooth.forecast"))
}
