utils::globalVariables(c("measurementEstimate","transitionEstimate", "C",
                         "persistenceEstimate","obsAll","obsInsample","multisteps","ot","obsNonzero","ICs","cfObjective",
                         "yForecast","yLower","yUpper","normalizer","yForecastStart"));

#' Generalised Univariate Model
#'
#' Function constructs Generalised Univariate Model, estimating matrices F, w,
#' vector g and initial parameters.
#'
#' The function estimates the Single Source of Error state space model of the
#' following type:
#'
#' \deqn{y_{t} = o_{t} (w' v_{t-l} + x_t a_{t-1} + \epsilon_{t})}
#'
#' \deqn{v_{t} = F v_{t-l} + g \epsilon_{t}}
#'
#' \deqn{a_{t} = F_{X} a_{t-1} + g_{X} \epsilon_{t} / x_{t}}
#'
#' Where \eqn{o_{t}} is the Bernoulli distributed random variable (in case of
#' normal data equal to 1), \eqn{v_{t}} is the state vector (defined using
#' \code{orders}) and \eqn{l} is the vector of \code{lags}, \eqn{x_t} is the
#' vector of exogenous parameters. \eqn{w} is the \code{measurement} vector,
#' \eqn{F} is the \code{transition} matrix, \eqn{g} is the \code{persistence}
#' vector, \eqn{a_t} is the vector of parameters for exogenous variables,
#' \eqn{F_{X}} is the \code{transitionX} matrix and \eqn{g_{X}} is the
#' \code{persistenceX} matrix. Finally, \eqn{\epsilon_{t}} is the error term.
#'
#'
#' @template ssBasicParam
#' @template ssAdvancedParam
#' @template ssInitialParam
#' @template ssPersistenceParam
#' @template ssAuthor
#' @template ssKeywords
#'
#' @template smoothRef
#' @template ssIntervalsRef
#'
#' @param orders Order of the model. Specified as vector of number of states
#' with different lags. For example, \code{orders=c(1,1)} means that there are
#' two states: one of the first lag type, the second of the second type.
#' @param lags Defines lags for the corresponding orders. If, for example,
#' \code{orders=c(1,1)} and lags are defined as \code{lags=c(1,12)}, then the
#' model will have two states: the first will have lag 1 and the second will
#' have lag 12. The length of \code{lags} must correspond to the length of
#' \code{orders}.
#' @param type Type of model. Can either be \code{"A"} - additive - or
#' \code{"M"} - multiplicative. The latter means that the GUM is fitted on
#' log-transformed data.
#' @param transition Transition matrix \eqn{F}. Can be provided as a vector.
#' Matrix will be formed using the default \code{matrix(transition,nc,nc)},
#' where \code{nc} is the number of components in state vector. If \code{NULL},
#' then estimated.
#' @param measurement Measurement vector \eqn{w}. If \code{NULL}, then
#' estimated.
#' @param ...  Other non-documented parameters.  For example parameter
#' \code{model} can accept a previously estimated GUM model and use all its
#' parameters.  \code{FI=TRUE} will make the function produce Fisher
#' Information matrix, which then can be used to calculated variances of
#' parameters of the model.
#' You can also pass two parameters to the optimiser: 1. \code{maxeval} - maximum
#' number of evaluations to carry on; 2. \code{xtol_rel} - the precision of the
#' optimiser. The default values used in es() are \code{maxeval=5000} and
#' \code{xtol_rel=1e-8}. You can read more about these parameters in the
#' documentation of \link[nloptr]{nloptr} function.
#' @return Object of class "smooth" is returned. It contains:
#'
#' \itemize{
#' \item \code{model} - name of the estimated model.
#' \item \code{timeElapsed} - time elapsed for the construction of the model.
#' \item \code{states} - matrix of fuzzy components of GUM, where \code{rows}
#' correspond to time and \code{cols} to states.
#' \item \code{initialType} - Type of the initial values used.
#' \item \code{initial} - initial values of state vector (extracted from
#' \code{states}).
#' \item \code{nParam} - table with the number of estimated / provided parameters.
#' If a previous model was reused, then its initials are reused and the number of
#' provided parameters will take this into account.
#' \item \code{measurement} - matrix w.
#' \item \code{transition} - matrix F.
#' \item \code{persistence} - persistence vector. This is the place, where
#' smoothing parameters live.
#' \item \code{fitted} - fitted values.
#' \item \code{forecast} - point forecast.
#' \item \code{lower} - lower bound of prediction interval. When
#' \code{intervals="none"} then NA is returned.
#' \item \code{upper} - higher bound of prediction interval. When
#' \code{intervals="none"} then NA is returned.
#' \item \code{residuals} - the residuals of the estimated model.
#' \item \code{errors} - matrix of 1 to h steps ahead errors.
#' \item \code{s2} - variance of the residuals (taking degrees of freedom
#' into account).
#' \item \code{intervals} - type of intervals asked by user.
#' \item \code{level} - confidence level for intervals.
#' \item \code{cumulative} - whether the produced forecast was cumulative or not.
#' \item \code{actuals} - original data.
#' \item \code{holdout} - holdout part of the original data.
#' \item \code{imodel} - model of the class "iss" if intermittent model was estimated.
#' If the model is non-intermittent, then imodel is \code{NULL}.
#' \item \code{xreg} - provided vector or matrix of exogenous variables. If
#' \code{xregDo="s"}, then this value will contain only selected exogenous variables.
#' \item \code{updateX} - boolean, defining, if the states of exogenous variables
#' were estimated as well.
#' \item \code{initialX} - initial values for parameters of exogenous variables.
#' \item \code{persistenceX} - persistence vector g for exogenous variables.
#' \item \code{transitionX} - transition matrix F for exogenous variables.
#' \item \code{ICs} - values of information criteria of the model. Includes
#' AIC, AICc, BIC and BICc.
#' \item \code{logLik} - log-likelihood of the function.
#' \item \code{cf} - Cost function value.
#' \item \code{cfType} - Type of cost function used in the estimation.
#' \item \code{FI} - Fisher Information. Equal to NULL if \code{FI=FALSE} or
#' when \code{FI} variable is not provided at all.
#' \item \code{accuracy} - vector of accuracy measures for the holdout sample.
#' In case of non-intermittent data includes: MPE, MAPE, SMAPE, MASE, sMAE,
#' RelMAE, sMSE and Bias coefficient (based on complex numbers). In case of
#' intermittent data the set of errors will be: sMSE, sPIS, sCE (scaled
#' cumulative error) and Bias coefficient. This is available only when
#' \code{holdout=TRUE}.
#' }
#' @seealso \code{\link[forecast]{ets}, \link[smooth]{es}, \link[smooth]{ces},
#' \link[smooth]{sim.es}}
#'
#' @examples
#'
#' # Something simple:
#' gum(rnorm(118,100,3),orders=c(1),lags=c(1),h=18,holdout=TRUE,bounds="a",intervals="p")
#'
#' # A more complicated model with seasonality
#' \dontrun{ourModel <- gum(rnorm(118,100,3),orders=c(2,1),lags=c(1,4),h=18,holdout=TRUE)}
#'
#' # Redo previous model on a new data and produce prediction intervals
#' \dontrun{gum(rnorm(118,100,3),model=ourModel,h=18,intervals="sp")}
#'
#' # Produce something crazy with optimal initials (not recommended)
#' \dontrun{gum(rnorm(118,100,3),orders=c(1,1,1),lags=c(1,3,5),h=18,holdout=TRUE,initial="o")}
#'
#' # Simpler model estiamted using trace forecast error cost function and its analytical analogue
#' \dontrun{gum(rnorm(118,100,3),orders=c(1),lags=c(1),h=18,holdout=TRUE,bounds="n",cfType="TMSE")
#' gum(rnorm(118,100,3),orders=c(1),lags=c(1),h=18,holdout=TRUE,bounds="n",cfType="aTMSE")}
#'
#' # Introduce exogenous variables
#' \dontrun{gum(rnorm(118,100,3),orders=c(1),lags=c(1),h=18,holdout=TRUE,xreg=c(1:118))}
#'
#' # Ask for their update
#' \dontrun{gum(rnorm(118,100,3),orders=c(1),lags=c(1),h=18,holdout=TRUE,xreg=c(1:118),updateX=TRUE)}
#'
#' # Do the same but now let's shrink parameters...
#' \dontrun{gum(rnorm(118,100,3),orders=c(1),lags=c(1),h=18,xreg=c(1:118),updateX=TRUE,cfType="TMSE")
#' ourModel <- gum(rnorm(118,100,3),orders=c(1),lags=c(1),h=18,holdout=TRUE,cfType="aTMSE")}
#'
#' # Or select the most appropriate one
#' \dontrun{gum(rnorm(118,100,3),orders=c(1),lags=c(1),h=18,holdout=TRUE,xreg=c(1:118),xregDo="s")
#'
#' summary(ourModel)
#' forecast(ourModel)
#' plot(forecast(ourModel))}
#'
#' @rdname gum
#' @export gum
gum <- function(data, orders=c(1,1), lags=c(1,frequency(data)), type=c("A","M"),
                persistence=NULL, transition=NULL, measurement=NULL,
                initial=c("optimal","backcasting"), ic=c("AICc","AIC","BIC","BICc"),
                cfType=c("MSE","MAE","HAM","MSEh","TMSE","GTMSE","MSCE"),
                h=10, holdout=FALSE, cumulative=FALSE,
                intervals=c("none","parametric","semiparametric","nonparametric"), level=0.95,
                intermittent=c("none","auto","fixed","interval","probability","sba","logistic"),
                imodel="MNN",
                bounds=c("restricted","admissible","none"),
                silent=c("all","graph","legend","output","none"),
                xreg=NULL, xregDo=c("use","select"), initialX=NULL,
                updateX=FALSE, persistenceX=NULL, transitionX=NULL, ...){
# General Univariate Model function. Crazy thing...
#
#    Copyright (C) 2016 - Inf Ivan Svetunkov

# Start measuring the time of calculations
    startTime <- Sys.time();

# Add all the variables in ellipsis to current environment
    list2env(list(...),environment());

    # If a previous model provided as a model, write down the variables
    if(exists("model",inherits=FALSE)){
        if(is.null(model$model)){
            stop("The provided model is not GUM.",call.=FALSE);
        }
        else if(smoothType(model)!="GUM"){
            stop("The provided model is not GUM.",call.=FALSE);
        }

        type <- errorType(model);

        if(!is.null(model$imodel)){
            imodel <- model$imodel;
        }
        initial <- model$initial;
        persistence <- model$persistence;
        transition <- model$transition;
        measurement <- model$measurement;
        if(is.null(xreg)){
            xreg <- model$xreg;
        }
        else{
            if(is.null(model$xreg)){
                xreg <- NULL;
            }
            else{
                if(ncol(xreg)!=ncol(model$xreg)){
                    xreg <- xreg[,colnames(model$xreg)];
                }
            }
        }
        initialX <- model$initialX;
        persistenceX <- model$persistenceX;
        transitionX <- model$transitionX;
        if(any(c(persistenceX)!=0) | any((transitionX!=0)&(transitionX!=1))){
            updateX <- TRUE;
        }
        model <- model$model;
        orders <- as.numeric(substring(model,unlist(gregexpr("\\[",model))-1,unlist(gregexpr("\\[",model))-1));
        lags <- as.numeric(substring(model,unlist(gregexpr("\\[",model))+1,unlist(gregexpr("\\]",model))-1));
    }

    orders <- orders[order(lags)];
    lags <- sort(lags);

##### Set environment for ssInput and make all the checks #####
    environment(ssInput) <- environment();
    ssInput("gum",ParentEnvironment=environment());

##### Initialise gum #####
ElementsGUM <- function(C){
    n.coef <- 0;
    if(measurementEstimate){
        matw <- matrix(C[n.coef+(1:nComponents)],1,nComponents);
        n.coef <- n.coef + nComponents;
    }
    else{
        matw <- matrix(measurement,1,nComponents);
    }

    if(transitionEstimate){
        matF <- matrix(C[n.coef+(1:(nComponents^2))],nComponents,nComponents);
        n.coef <- n.coef + nComponents^2;
    }
    else{
        matF <- matrix(transition,nComponents,nComponents);
    }

    if(persistenceEstimate){
        vecg <- matrix(C[n.coef+(1:nComponents)],nComponents,1);
        n.coef <- n.coef + nComponents;
    }
    else{
        vecg <- matrix(persistence,nComponents,1);
    }

    vt <- matrix(NA,maxlag,nComponents);
    if(initialType!="b"){
        if(initialType=="o"){
            vtvalues <- C[n.coef+(1:(orders %*% lags))];
            n.coef <- n.coef + c(orders %*% lags);

            for(i in 1:nComponents){
                vt[(maxlag - modellags + 1)[i]:maxlag,i] <- vtvalues[((cumsum(c(0,modellags))[i]+1):cumsum(c(0,modellags))[i+1])];
                vt[is.na(vt[1:maxlag,i]),i] <- rep(vt[(maxlag - modellags + 1)[i]:maxlag,i],
                                                   ceiling((maxlag - modellags + 1) / modellags)[i])[is.na(vt[1:maxlag,i])];
            }
        }
        else if(initialType=="p"){
            vt[,] <- initialValue;
        }
    }
    else{
        vt[,] <- matvt[1:maxlag,nComponents];
    }

# If exogenous are included
    if(xregEstimate){
        at <- matrix(NA,maxlag,nExovars);
        if(initialXEstimate){
            at[,] <- rep(C[n.coef+(1:nExovars)],each=maxlag);
            n.coef <- n.coef + nExovars;
        }
        else{
            at <- matat[1:maxlag,];
        }
        if(FXEstimate){
            matFX <- matrix(C[n.coef+(1:(nExovars^2))],nExovars,nExovars);
            n.coef <- n.coef + nExovars^2;
        }

        if(gXEstimate){
            vecgX <- matrix(C[n.coef+(1:nExovars)],nExovars,1);
            n.coef <- n.coef + nExovars;
        }
    }
    else{
        at <- matrix(matat[1:maxlag,],maxlag,nExovars);
    }

    return(list(matw=matw,matF=matF,vecg=vecg,vt=vt,at=at,matFX=matFX,vecgX=vecgX));
}

##### Cost Function for GUM #####
CF <- function(C){
    elements <- ElementsGUM(C);
    matw <- elements$matw;
    matF <- elements$matF;
    vecg <- elements$vecg;
    matvt[1:maxlag,] <- elements$vt;
    matat[1:maxlag,] <- elements$at;
    matFX <- elements$matFX;
    vecgX <- elements$vecgX;

    cfRes <- costfunc(matvt, matF, matw, y, vecg,
                       h, modellags, Etype, Ttype, Stype,
                       multisteps, cfType, normalizer, initialType,
                       matxt, matat, matFX, vecgX, ot,
                       bounds);

    if(is.nan(cfRes) | is.na(cfRes)){
        cfRes <- 1e100;
    }
    return(cfRes);
}

##### Estimate gum or just use the provided values #####
CreatorGUM <- function(silentText=FALSE,...){
    environment(likelihoodFunction) <- environment();
    environment(ICFunction) <- environment();

# If there is something to optimise, let's do it.
    if(any((initialType=="o"),(measurementEstimate),(transitionEstimate),(persistenceEstimate),
       (initialXEstimate),(FXEstimate),(gXEstimate))){

        if(is.null(providedC)){
            Cub <- Clb <- C <- NULL;
# matw, matF, vecg, vt
            if(measurementEstimate){
                C <- c(C,rep(1,nComponents));
                if(bounds=="r"){
                    Clb <- c(Clb,rep(0,nComponents));
                    Cub <- c(Cub,rep(1,nComponents));
                }
                else{
                    Clb <- c(Clb,rep(-Inf,nComponents));
                    Cub <- c(Cub,rep(Inf,nComponents));
                }
            }
            if(transitionEstimate){
                C <- c(C,rep(1,nComponents^2));
                if(bounds=="r"){
                    Clb <- c(Clb,rep(0,nComponents^2));
                    Cub <- c(Cub,rep(1,nComponents^2));
                }
                else{
                    Clb <- c(Clb,rep(-Inf,nComponents^2));
                    Cub <- c(Cub,rep(Inf,nComponents^2));
                }
            }
            if(persistenceEstimate){
                C <- c(C,rep(0.1,nComponents));
                Clb <- c(Clb,rep(-Inf,nComponents));
                Cub <- c(Cub,rep(Inf,nComponents));
            }
            if(initialType=="o"){
                C <- c(C,intercept);
                Clb <- c(Clb,-Inf);
                Cub <- c(Cub,Inf);
                if((orders %*% lags)>1){
                    C <- c(C,slope);
                    Clb <- c(Clb,-Inf);
                    Cub <- c(Cub,Inf);
                }
                if((orders %*% lags)>2){
                    C <- c(C,yot[1:(orders %*% lags-2),]);
                    Clb <- c(Clb,rep(-Inf,(orders %*% lags-2)));
                    Cub <- c(Cub,rep(Inf,(orders %*% lags-2)));
                }
            }

# initials, transition matrix and persistence vector
            if(xregEstimate){
                if(initialXEstimate){
                    C <- c(C,matat[maxlag,]);
                    Clb <- c(Clb,rep(-Inf,nExovars));
                    Cub <- c(Cub,rep(Inf,nExovars));
                }
                if(updateX){
                    if(FXEstimate){
                        C <- c(C,c(diag(nExovars)));
                        Clb <- c(Clb,rep(0,nExovars^2));
                        Cub <- c(Cub,rep(1,nExovars^2));
                    }
                    if(gXEstimate){
                        C <- c(C,rep(0,nExovars));
                        Clb <- c(Clb,rep(-Inf,nExovars));
                        Cub <- c(Cub,rep(Inf,nExovars));
                    }
                }
            }
        }

# Optimise model. First run
        res <- nloptr(C, CF, opts=list("algorithm"="NLOPT_LN_BOBYQA", "xtol_rel"=xtol_rel, "maxeval"=maxeval),
                      lb=Clb, ub=Cub);
        C <- res$solution;

# Optimise model. Second run
        res2 <- nloptr(C, CF, opts=list("algorithm"="NLOPT_LN_NELDERMEAD", "xtol_rel"=xtol_rel/100, "maxeval"=maxeval/5),
                       lb=Clb, ub=Cub);
        # This condition is needed in order to make sure that we did not make the solution worse
        if(res2$objective <= res$objective){
            res <- res2;
        }

        C <- res$solution;
        cfObjective <- res$objective;

        # Parameters estimated + variance
        nParam <- length(C) + 1;
    }
    else{
# matw, matF, vecg, vt
        C <- c(measurement,
               c(transition),
               c(persistence),
               c(initialValue));

        C <- c(C,matat[maxlag,],
               c(transitionX),
               c(persistenceX));

        cfObjective <- CF(C);

        # Only variance is estimated
        nParam <- 1;
    }

    ICValues <- ICFunction(nParam=nParam,nParamIntermittent=nParamIntermittent,
                           C=C,Etype=Etype);
    ICs <- ICValues$ICs;
    logLik <- ICValues$llikelihood;

    icBest <- ICs[ic];

    return(list(cfObjective=cfObjective,C=C,ICs=ICs,icBest=icBest,nParam=nParam,logLik=logLik));
}

##### Preset yFitted, yForecast, errors and basic parameters #####
    matvt <- matrix(NA,nrow=obsStates,ncol=nComponents);
    yFitted <- rep(NA,obsInsample);
    yForecast <- rep(NA,h);
    errors <- rep(NA,obsInsample);

##### Prepare exogenous variables #####
    xregdata <- ssXreg(data=data, xreg=xreg, updateX=updateX, ot=ot,
                       persistenceX=persistenceX, transitionX=transitionX, initialX=initialX,
                       obsInsample=obsInsample, obsAll=obsAll, obsStates=obsStates,
                       maxlag=maxlag, h=h, xregDo=xregDo, silent=silentText);

    if(xregDo=="u"){
        nExovars <- xregdata$nExovars;
        matxt <- xregdata$matxt;
        matat <- xregdata$matat;
        xregEstimate <- xregdata$xregEstimate;
        matFX <- xregdata$matFX;
        vecgX <- xregdata$vecgX;
        xregNames <- colnames(matxt);
    }
    else{
        nExovars <- 1;
        nExovarsOriginal <- xregdata$nExovars;
        matxtOriginal <- xregdata$matxt;
        matatOriginal <- xregdata$matat;
        xregEstimateOriginal <- xregdata$xregEstimate;
        matFXOriginal <- xregdata$matFX;
        vecgXOriginal <- xregdata$vecgX;

        matxt <- matrix(1,nrow(matxtOriginal),1);
        matat <- matrix(0,nrow(matatOriginal),1);
        xregEstimate <- FALSE;
        matFX <- matrix(1,1,1);
        vecgX <- matrix(0,1,1);
        xregNames <- NULL;
    }
    xreg <- xregdata$xreg;
    FXEstimate <- xregdata$FXEstimate;
    gXEstimate <- xregdata$gXEstimate;
    initialXEstimate <- xregdata$initialXEstimate;
    if(is.null(xreg)){
        xregDo <- "u";
    }

    # These three are needed in order to use ssgeneralfun.cpp functions
    Etype <- "A";
    Ttype <- "N";
    Stype <- "N";

# Check number of parameters vs data
    nParamExo <- FXEstimate*length(matFX) + gXEstimate*nrow(vecgX) + initialXEstimate*ncol(matat);
    nParamIntermittent <- all(intermittent!=c("n","provided"))*1;
    nParamMax <- nParamMax + nParamExo + nParamIntermittent;

    if(xregDo=="u"){
        parametersNumber[1,2] <- nParamExo;
        # If transition is provided and not identity, and other things are provided, write them as "provided"
        parametersNumber[2,2] <- (length(matFX)*(!is.null(transitionX) & !all(matFX==diag(ncol(matat)))) +
                                      nrow(vecgX)*(!is.null(persistenceX)) +
                                      ncol(matat)*(!is.null(initialX)));
    }

##### Check number of observations vs number of max parameters #####
    if(obsNonzero <= nParamMax){
        if(xregDo=="select"){
            if(obsNonzero <= (nParamMax - nParamExo)){
                warning(paste0("Not enough observations for the reasonable fit. Number of parameters is ",
                               nParamMax + nParamExo," while the number of observations is ",obsNonzero,"!"),call.=FALSE);
                tinySample <- TRUE;
            }
            else{
                warning(paste0("The potential number of exogenous variables is higher than the number of observations. ",
                               "This may cause problems in the estimation."),call.=FALSE);
            }
        }
        else{
            warning(paste0("Not enough observations for the reasonable fit. Number of parameters is ",
                           nParamMax," while the number of observations is ",obsNonzero,"!"),call.=FALSE);
            tinySample <- TRUE;
        }
    }
    else{
        tinySample <- FALSE;
    }

# If this is tiny sample, use SES instead
    if(tinySample){
        warning("Not enough observations to fit GUM Switching to ETS(A,N,N).",call.=FALSE);
        return(es(data,"ANN",initial=initial,cfType=cfType,
                  h=h,holdout=holdout,cumulative=cumulative,
                  intervals=intervals,level=level,
                  intermittent=intermittent,
                  imodel=imodel,
                  bounds="u",
                  silent=silent,
                  xreg=xreg,xregDo=xregDo,initialX=initialX,
                  updateX=updateX,persistenceX=persistenceX,transitionX=transitionX));
    }

##### Preset values of matvt ######
    slope <- cov(yot[1:min(max(12,dataFreq),obsNonzero),],c(1:min(max(12,dataFreq),obsNonzero)))/var(c(1:min(max(12,dataFreq),obsNonzero)));
    intercept <- sum(yot[1:min(max(12,dataFreq),obsNonzero),])/min(max(12,dataFreq),obsNonzero) - slope * (sum(c(1:min(max(12,dataFreq),obsNonzero)))/min(max(12,dataFreq),obsNonzero) - 1);

    vtvalues <- intercept;
    if((orders %*% lags)>1){
        vtvalues <- c(vtvalues,slope);
    }
    if((orders %*% lags)>2){
        if(orders %*% lags-2 > obsNonzero){
            vtTail <- orders %*% lags-2 - obsNonzero;
            vtvalues <- c(vtvalues,yot[1:obsNonzero,]);
            vtvalues <- c(vtvalues,rep(yot[obsNonzero],vtTail));
        }
        else{
            vtvalues <- c(vtvalues,yot[1:(orders %*% lags-2),]);
        }
    }

    vt <- matrix(NA,maxlag,nComponents);
    for(i in 1:nComponents){
        vt[(maxlag - modellags + 1)[i]:maxlag,i] <- vtvalues[((cumsum(c(0,modellags))[i]+1):cumsum(c(0,modellags))[i+1])];
        vt[is.na(vt[1:maxlag,i]),i] <- rep(rev(vt[(maxlag - modellags + 1)[i]:maxlag,i]),
                                           ceiling((maxlag - modellags + 1) / modellags)[i])[is.na(vt[1:maxlag,i])];
    }
    matvt[1:maxlag,] <- vt;

#### Deal with provided C ####
    ellipsis <- list(...);
    if(any(names(ellipsis)=="C")){
        providedC <- ellipsis$C;
    }
    else{
        providedC <- NULL;
    }

    if(!is.null(providedC)){
        nParamToEstimate <- (nComponents*measurementEstimate + nComponents*persistenceEstimate +
                                 (nComponents^2)*transitionEstimate);
        if(initialType=="o"){
            nParamToEstimate <- nParamToEstimate + orders %*% lags;
        }

        if(length(providedC)!=nParamToEstimate){
            warning(paste0("Number of parameters to optimise differes from the length of C: ",nParamToEstimate," vs ",length(providedC),".\n",
                           "We will have to drop parameter C."),call.=FALSE);
            providedC <- NULL;
        }
        C <- providedC;
    }

    if(any(names(ellipsis)=="maxeval")){
        maxeval <- ellipsis$maxeval;
    }
    else{
        maxeval <- 5000;
    }
    if(any(names(ellipsis)=="xtol_rel")){
        xtol_rel <- ellipsis$xtol_rel;
    }
    else{
        xtol_rel <- 1e-8;
    }

##### Start the calculations #####
    environment(intermittentParametersSetter) <- environment();
    environment(intermittentMaker) <- environment();
    environment(ssForecaster) <- environment();
    environment(ssFitter) <- environment();

    # If auto intermittent, then estimate model with intermittent="n" first
    if(any(intermittent==c("a","n"))){
        intermittentParametersSetter(intermittent="n",ParentEnvironment=environment());
    }
    else{
        intermittentParametersSetter(intermittent=intermittent,ParentEnvironment=environment());
        intermittentMaker(intermittent=intermittent,ParentEnvironment=environment());
    }

    gumValues <- CreatorGUM(silentText=silentText);

##### If intermittent=="a", run a loop and select the best one #####
    if(intermittent=="a"){
        if(!any(cfType==c("MSE","MAE","HAM","MSEh","MAEh","HAMh","MSCE","MACE","CHAM",
                          "TFL","aTFL","Rounded","TSB","LogisticD","LogisticL"))){
            warning(paste0("'",cfType,"' is used as cost function instead of 'MSE'. A wrong intermittent model may be selected"),call.=FALSE);
        }
        if(!silentText){
            cat("Selecting appropriate type of intermittency... ");
        }
# Prepare stuff for intermittency selection
        intermittentModelsPool <- c("n","f","i","p","s","l");
        intermittentCFs <- intermittentICs <- rep(NA,length(intermittentModelsPool));
        intermittentModelsList <- list(NA);
        intermittentICs[1] <- gumValues$icBest;
        intermittentCFs[1] <- gumValues$cfObjective;

        for(i in 2:length(intermittentModelsPool)){
            intermittentParametersSetter(intermittent=intermittentModelsPool[i],ParentEnvironment=environment());
            intermittentMaker(intermittent=intermittentModelsPool[i],ParentEnvironment=environment());
            intermittentModelsList[[i]] <- CreatorGUM(silentText=TRUE);
            intermittentICs[i] <- intermittentModelsList[[i]]$icBest[ic];
            intermittentCFs[i] <- intermittentModelsList[[i]]$cfObjective;
        }
        intermittentICs[is.nan(intermittentICs) | is.na(intermittentICs)] <- 1e+100;
        intermittentCFs[is.nan(intermittentCFs) | is.na(intermittentCFs)] <- 1e+100;
        # In cases when the data is binary, choose between intermittent models only
        if(any(intermittentCFs==0)){
            if(all(intermittentCFs[2:length(intermittentModelsPool)]==0)){
                intermittentICs[1] <- Inf;
            }
        }
        iBest <- which(intermittentICs==min(intermittentICs))[1];

        if(!silentText){
            cat("Done!\n");
        }
        if(iBest!=1){
            intermittent <- intermittentModelsPool[iBest];
            gumValues <- intermittentModelsList[[iBest]];
        }
        else{
            intermittent <- "n"
        }

        intermittentParametersSetter(intermittent=intermittent,ParentEnvironment=environment());
        intermittentMaker(intermittent=intermittent,ParentEnvironment=environment());
    }

    list2env(gumValues,environment());

    if(xregDo!="u"){
# Prepare for fitting
        elements <- ElementsGUM(C);
        matw <- elements$matw;
        matF <- elements$matF;
        vecg <- elements$vecg;
        matvt[1:maxlag,] <- elements$vt;
        matat[1:maxlag,] <- elements$at;
        matFX <- elements$matFX;
        vecgX <- elements$vecgX;

        ssFitter(ParentEnvironment=environment());

        xregNames <- colnames(matxtOriginal);
        xregNew <- cbind(errors,xreg[1:nrow(errors),]);
        colnames(xregNew)[1] <- "errors";
        colnames(xregNew)[-1] <- xregNames;
        xregNew <- as.data.frame(xregNew);
        xregResults <- stepwise(xregNew, ic=ic, silent=TRUE, df=nParam+nParamIntermittent-1);
        xregNames <- names(coef(xregResults))[-1];
        nExovars <- length(xregNames);
        if(nExovars>0){
            xregEstimate <- TRUE;
            matxt <- as.data.frame(matxtOriginal)[,xregNames];
            matat <- as.data.frame(matatOriginal)[,xregNames];
            matFX <- diag(nExovars);
            vecgX <- matrix(0,nExovars,1);

            if(nExovars==1){
                matxt <- matrix(matxt,ncol=1);
                matat <- matrix(matat,ncol=1);
                colnames(matxt) <- colnames(matat) <- xregNames;
            }
            else{
                matxt <- as.matrix(matxt);
                matat <- as.matrix(matat);
            }
        }
        else{
            nExovars <- 1;
            xreg <- NULL;
        }

        if(!is.null(xreg)){
            gumValues <- CreatorGUM(silentText=TRUE);
            list2env(gumValues,environment());
        }
    }

    if(!is.null(xreg)){
        if(ncol(matat)==1){
            colnames(matxt) <- colnames(matat) <- xregNames;
        }
        xreg <- matxt;
        if(xregDo=="s"){
            nParamExo <- FXEstimate*length(matFX) + gXEstimate*nrow(vecgX) + initialXEstimate*ncol(matat);
            parametersNumber[1,2] <- nParamExo;
        }
    }
# Prepare for fitting
    elements <- ElementsGUM(C);
    matw <- elements$matw;
    matF <- elements$matF;
    vecg <- elements$vecg;
    matvt[1:maxlag,] <- elements$vt;
    matat[1:maxlag,] <- elements$at;
    matFX <- elements$matFX;
    vecgX <- elements$vecgX;

##### Fit simple model and produce forecast #####
    ssFitter(ParentEnvironment=environment());
    ssForecaster(ParentEnvironment=environment());

    if(modelIsMultiplicative){
        y <- exp(y);
        yFitted <- exp(yFitted);
        yForecast <- exp(yForecast);
        yLower <- exp(yLower);
        yUpper <- exp(yUpper);

        environment(likelihoodFunction) <- environment();
        environment(ICFunction) <- environment();

        ICValues <- ICFunction(nParam=nParam,nParamIntermittent=nParamIntermittent,
                               C=C,Etype="M");
        ICs <- ICValues$ICs;
        logLik <- ICValues$llikelihood;
    }

##### Do final check and make some preparations for output #####

# Write down initials of states vector and exogenous
    parametersNumber[1,1] <- (nComponents*measurementEstimate + nComponents*persistenceEstimate +
        (nComponents^2)*transitionEstimate);
    # parametersNumber[2,1] <- (nComponents*(!measurementEstimate) + nComponents*(!persistenceEstimate) +
    #                               (nComponents^2)*(!transitionEstimate));

    if(initialType!="p"){
        initialValue <- matrix(matvt[1:maxlag,],maxlag);
        if(initialType!="b"){
            parametersNumber[1,1] <- parametersNumber[1,1] + orders %*% lags;
        }
    }

    if(initialXEstimate){
        initialX <- matat[1,];
        names(initialX) <- colnames(matat);
    }

    # Make initialX NULL if all xreg were dropped
    if(length(initialX)==1){
        if(initialX==0){
            initialX <- NULL;
        }
    }

    if(gXEstimate){
        persistenceX <- vecgX;
    }

    if(FXEstimate){
        transitionX <- matFX;
    }

    # Add variance estimation
    parametersNumber[1,1] <- parametersNumber[1,1] + 1;

    # Write down the probabilities from intermittent models
    pt <- ts(c(as.vector(pt),as.vector(pForecast)),start=dataStart,frequency=dataFreq);
    # Write down the number of parameters of imodel
    if(all(intermittent!=c("n","provided")) & !imodelProvided){
        parametersNumber[1,3] <- imodel$nParam;
    }
    # Make nice names for intermittent
    if(intermittent=="f"){
        intermittent <- "fixed";
    }
    else if(intermittent=="i"){
        intermittent <- "interval";
    }
    else if(intermittent=="p"){
        intermittent <- "probability";
    }
    else if(intermittent=="l"){
        intermittent <- "logistic";
    }
    else if(intermittent=="n"){
        intermittent <- "none";
    }

# Make some preparations
    matvt <- ts(matvt,start=(time(data)[1] - deltat(data)*maxlag),frequency=frequency(data));
    if(!is.null(xreg)){
        matvt <- cbind(matvt,matat);
        colnames(matvt) <- c(paste0("Component ",c(1:nComponents)),colnames(matat));
        if(updateX){
            rownames(vecgX) <- xregNames;
            dimnames(matFX) <- list(xregNames,xregNames);
        }
    }
    else{
        colnames(matvt) <- paste0("Component ",c(1:nComponents));
    }

    parametersNumber[1,4] <- sum(parametersNumber[1,1:3]);
    parametersNumber[2,4] <- sum(parametersNumber[2,1:3]);

    # Write down Fisher Information if needed
    if(FI & parametersNumber[1,4]>1){
        environment(likelihoodFunction) <- environment();
        FI <- -numDeriv::hessian(likelihoodFunction,C);
    }
    else{
        FI <- NA;
    }

##### Deal with the holdout sample #####
    if(holdout){
        yHoldout <- ts(data[(obsInsample+1):obsAll],start=yForecastStart,frequency=frequency(data));
        if(cumulative){
            errormeasures <- Accuracy(sum(yHoldout),yForecast,h*y);
        }
        else{
            errormeasures <- Accuracy(yHoldout,yForecast,y);
        }

        if(cumulative){
            yHoldout <- ts(sum(yHoldout),start=yForecastStart,frequency=dataFreq);
        }
    }
    else{
        yHoldout <- NA;
        errormeasures <- NA;
    }

    if(!is.null(xreg)){
        modelname <- "GUMX";
    }
    else{
        modelname <- "GUM";
    }
    modelname <- paste0(modelname,"(",paste(orders,"[",lags,"]",collapse=",",sep=""),")");
    if(all(intermittent!=c("n","none"))){
        modelname <- paste0("i",modelname);
    }

    if(modelIsMultiplicative){
        modelname <- paste0("M",modelname);
    }

##### Print output #####
    if(!silentText){
        if(any(abs(eigen(matF - vecg %*% matw)$values)>(1 + 1E-10))){
            if(bounds=="n"){
                warning("Unstable model was estimated! Use bounds='admissible' to address this issue!",
                        call.=FALSE);
            }
            else{
                warning("Something went wrong in optimiser - unstable model was estimated! Please report this error to the maintainer.",
                        call.=FALSE);
            }
        }
    }

##### Make a plot #####
    if(!silentGraph){
        yForecastNew <- yForecast;
        yUpperNew <- yUpper;
        yLowerNew <- yLower;
        if(cumulative){
            yForecastNew <- ts(rep(yForecast/h,h),start=yForecastStart,frequency=dataFreq)
            if(intervals){
                yUpperNew <- ts(rep(yUpper/h,h),start=yForecastStart,frequency=dataFreq)
                yLowerNew <- ts(rep(yLower/h,h),start=yForecastStart,frequency=dataFreq)
            }
        }

        if(intervals){
            graphmaker(actuals=data,forecast=yForecastNew,fitted=yFitted, lower=yLowerNew,upper=yUpperNew,
                       level=level,legend=!silentLegend,main=modelname,cumulative=cumulative);
        }
        else{
            graphmaker(actuals=data,forecast=yForecastNew,fitted=yFitted,
                       legend=!silentLegend,main=modelname,cumulative=cumulative);
        }
    }

##### Return values #####
    model <- list(model=modelname,timeElapsed=Sys.time()-startTime,
                  states=matvt,measurement=matw,transition=matF,persistence=vecg,
                  initialType=initialType,initial=initialValue,
                  nParam=parametersNumber,
                  fitted=yFitted,forecast=yForecast,lower=yLower,upper=yUpper,residuals=errors,
                  errors=errors.mat,s2=s2,intervals=intervalsType,level=level,cumulative=cumulative,
                  actuals=data,holdout=yHoldout,imodel=imodel,
                  xreg=xreg,updateX=updateX,initialX=initialX,persistenceX=persistenceX,transitionX=transitionX,
                  ICs=ICs,logLik=logLik,cf=cfObjective,cfType=cfType,FI=FI,accuracy=errormeasures);
    return(structure(model,class="smooth"));
}

#' @rdname gum
#' @export
ges <- function(...){
    warning("You are using the old name of the function. Please, use 'gum' instead.", call.=FALSE);
    return(gum(...));
}
