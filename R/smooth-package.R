#' Smooth package
#'
#' Package contains functions implementing Single Source of Error state space models for
#' purposes of time series analysis and forecasting.
#'
#' \tabular{ll}{ Package: \tab smooth\cr Type: \tab Package\cr Date: \tab
#' 2016-01-27 - Inf\cr License: \tab GPL-2 \cr } The following functions are
#' included in the package:
#' \itemize{
#' \item \link[smooth]{es} - Exponential Smoothing in Single Source of Errors State Space form.
#' \item \link[smooth]{ces} - Complex Exponential Smoothing.
#' \item \link[smooth]{gum} - Generalised Exponential Smoothing.
#' \item \link[smooth]{ssarima} - SARIMA in state space framework.
#' % \item \link[smooth]{nus} - Non-Uniform Smoothing.
#' \item \link[smooth]{auto.ces} - Automatic selection between seasonal and non-seasonal CES.
#' \item \link[smooth]{auto.ssarima} - Automatic selection of ARIMA orders.
#' \item \link[smooth]{sma} - Simple Moving Average in state space form.
#' \item \link[smooth]{smoothCombine} - the function that combines forecasts from es(),
#' ces(), gum(), ssarima() and sma() functions.
#' \item \link[smooth]{cma} - Centered Moving Average. This is for smoothing time series,
#' not for forecasting.
#' \item \link[smooth]{ves} - Vector Exponential Smoothing.
#' \item \link[smooth]{sim.es} - simulate time series using ETS as a model.
#' \item \link[smooth]{sim.ces} - simulate time series using CES as a model.
#' \item \link[smooth]{sim.ssarima} - simulate time series using SARIMA as a model.
#' \item \link[smooth]{sim.gum} - simulate time series using GUM as a model.
#' \item \link[smooth]{sim.sma} - simulate time series using SMA.
#' \item \link[smooth]{iss} - intermittent data state space model. This
#' function models the part with data occurrences using one of three methods.
#' \item \link[smooth]{viss} - Does the same as iss, but for the multivariate models.
#' }
#' There are also several methods implemented in the package for the classes
#' "smooth" and "smooth.sim":
#' \itemize{
#' \item \link[smooth]{orders} - extracts orders of the fitted model.
#' \item \link[smooth]{lags} - extracts lags of the fitted model.
#' \item \link[smooth]{modelType} - extracts type of the fitted model.
#' \item \link[smooth]{forecast} - produces forecast using provided model.
#' \item \link[smooth]{covar} - returns covariance matrix of multiple steps ahead forecast errors.
#' \item \link[smooth]{pls} - returns Prediction Likelihood Score.
#' \item \link[greybox]{nParam} - returns number of the estimated parameters.
#' \item \link[smooth]{Accuracy} - returns vector of error measures for the provided forecasts
#' and holdout.
#' \item fitted - extracts fitted values from provided model.
#' \item getResponse - returns actual values from the provided model.
#' \item residuals - extracts residuals of provided model.
#' \item plot - plots either states of the model or produced forecast (depending on what object
#' is passed).
#' \item simulate - uses sim functions in order to simulate data using the provided object.
#' \item summary - provides summary of the object.
#' \item AICc, BICc - return, guess what...
#' }
#'
#' @name smooth
#' @docType package
#' @author Ivan Svetunkov
#'
#' Maintainer: Ivan Svetunkov <ivan@svetunkov.ru>
#' @seealso \code{\link[forecast:forecast]{forecast}, \link[smooth]{es},
#' \link[smooth]{ssarima}, \link[smooth]{ces}, \link[smooth]{gum}}
#'
#' @template ssGeneralRef
#' @template ssIntermittentRef
#' @template ssCESRef
#' @template smoothRef
#' @template ssETSRef
#' @template ssIntervalsRef
#' @template ssKeywords
#'
#' @examples
#'
#' \dontrun{y <- ts(rnorm(100,10,3),frequency=12)
#'
#' es(y,h=20,holdout=TRUE)
#' gum(y,h=20,holdout=TRUE)
#' auto.ces(y,h=20,holdout=TRUE)
#' auto.ssarima(y,h=20,holdout=TRUE)}
#'
#' @import zoo Rcpp
#' @importFrom nloptr nloptr
#' @importFrom graphics abline layout legend lines par points polygon
#' @importFrom stats AIC BIC cov dbeta decompose deltat end frequency is.ts median coef optimize nlminb cor qnorm qt qlnorm quantile rbinom rlnorm rnorm rt runif start time ts var simulate lm as.formula residuals plnorm pnorm
#' @importFrom utils packageVersion
#' @importFrom greybox xregExpander stepwise qs qlaplace ps plaplace ds dlaplace graphmaker
#' @importFrom forecast is.ets
#' @useDynLib smooth
NULL



