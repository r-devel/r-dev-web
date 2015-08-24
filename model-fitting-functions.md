---
title: Model Fitting Functions in R
author: Brian Ripley, Nov. 2003; R Core Team
---
How To Write Model-Fitting Functions in R
=========================================

This page documents some of the features that are available to
model-fitting functions in R, and especially the safety features that
can (and should) be enabled.

By model-fitting functions we mean functions like lm() which take a
formula, create a model frame and perhaps a model matrix, and have
methods (or use the default methods) for many of the standard accessor
functions such as coef(), residuals() and predict().

A fairly complete list of such functions in the standard and
recommended packages is

- stats: aov (via lm), lm, glm, ppr

- MASS: glm.nb, glmmPQL, lda, lm.gls, lqs, polr, qda, rlm
- mgcv: mgcv
- nlme: gls, lme
- nnet: multinom, nnet
- survival: coxph, survreg

and those not using a model matrix or not intended to handle
categorical predictors

- stats: factanal, loess, nls, prcomp, princomp

- MASS: loglm
- nlme: gnls, nlme
- rpart: rpart


Standard behaviour for a fitting function
-----------------------------------------

The annotations in the following simplified version of `lm` (its current
source is in <https::/svn.r-project.org/R/trunk/src/library/stats/R/lm.R>) indicate
what is standard for a model-fitting function.

```{r}
lm <- function (formula, data, subset, weights, na.action,
		method = "qr", model = TRUE, contrasts = NULL, offset, ...)
{
    cl <- match.call()

    ## keep only the arguments which should go into the model frame
    mf <- match.call(expand.dots = FALSE)
    m <- match(c("formula", "data", "subset", "weights", "na.action",
                 "offset"), names(mf), 0)
    mf <- mf[c(1, m)]
    mf$drop.unused.levels <- TRUE
    mf[[1]] <- quote(stats::model.frame) # was as.name("model.frame"), but
                          ##    need "stats:: ..." for non-standard evaluation
    mf <- eval.parent(mf)
    if (method == "model.frame") return(mf)

    ## 1) allow model.frame to update the terms object before saving it.
    mt <- attr(mf, "terms")
    y <- model.response(mf, "numeric")

    ## 2) retrieve the weights and offset from the model frame so
    ## they can be functions of columns in arg data.
    w <- model.weights(mf)
    offset <- model.offset(mf)
    x <- model.matrix(mt, mf, contrasts)
    ## if any subsetting is done, retrieve the "contrasts" attribute here.

    z <- lm.fit(x, y, offset = offset, ...)
    class(z) <- c(if(is.matrix(y)) "mlm", "lm")

    ## 3) return the na.action info
    z$na.action <- attr(mf, "na.action")
    z$offset <- offset

    ## 4) return the contrasts used in fitting: possibly as saved earlier.
    z$contrasts <- attr(x, "contrasts")

    ## 5) return the levelsets for factors in the formula
    z$xlevels <- .getXlevels(mt, mf)
    z$call <- cl
    z$terms <- mt
    if (model)	z$model <- mf
    z
}
```

Note that if this approach is taken, any defaults for arguments
handled by model.frame are never invoked (the defaults in
model.frame.default are used) so it is good practice not to supply
any.  (This behaviour can be overruled, and is by e.g. rpart.)

If this is done, the following pieces of information are stored with
the model object:

* The model frame (unless argument model=FALSE).  This is useful to
  avoid scoping problems if the model frame is needed later (most
  often by predict methods).

* What contrasts and levels were used when coding factors to form the
  model matrix, and these plus the model frame allow the re-creation
  of the model matrix.  (The real lm() allows the model matrix to be
  saved, but that is provided for S compatibility, and is normally a
  waste of space.)

* The na.action results are recorded for use in forming residuals and
  fitted values/prediction from the original data set.

* The terms component records
  - environment(formula) as its environment,
  - details of the classes supplied for each column of the model frame
    as attribute "dataClasses",
  - in the "predvars" attribute, calls to functions such as bs() and
    poly() which should be used for prediction from a new dataset.
    (See ?makepredictcall for the details.)

Some of these are used automatically but most require code in
class-specific methods.


residuals/fitted/weights methods
--------------------------------

To make use of na.action options like na.exclude, the fitted() method
needs to be along the lines of
```
fitted.default <- function(object, ...)
    napredict(object$na.action, object$fitted.values)
```
For the residuals() method, replace napredict by naresid (although for
all current na.action's they are the same, this need not be the case
in future).

Similar code with a call to naresid is needed in a weights() method.


predict() methods
-----------------

Prediction from the original data used in fitting will often be
covered by the `fitted()` method, unless s.e.'s or confidence/prediction
intervals are required.

In a `newdata` argument is supplied, most methods will need to create
a model matrix as if the newdata had originally been used (but with
na.action as set on the predict method, defaulting to na.pass).
A typical piece of code is

```
    m <- model.frame(Terms, newdata, na.action = na.action,
		     xlev = object$xlevels)
    if(!is.null(cl <- attr(Terms, "dataClasses"))) .checkMFClasses(cl, m)
    X <- model.matrix(Terms, m, contrasts = object$contrasts)
```

Note the use of the saved levels and saved contrasts, and the safety
check on the classes of the variables found by model.frame (which of
course need not be found in `newdata`).  Safe prediction from terms
involving poly(), bs() and so on will happen without needing any code
in the predict() method as this is handled in model.frame.default().

If your code is like rpart() and handles ordered and unordered factors
differently use `.checkMFClasses(cl, m, TRUE)` --- this is not needed
for code like lm() as both the set of levels of the factors and the
contrasts used at fit time are recorded in the fit object and
retrieved by the predict() method.


model.frame() methods
---------------------

model.frame() methods are most often used to retrieve or recreate the
model frame from the fitted object, with no other arguments.  For
fitting functions following the standard pattern outlined in this
document no method is needed: as from R 1.9.0 model.frame.default()
will work.

One reason that a special method might be needed is to retrieve
columns of the data frame that correspond to arguments of the orginal
call other than `formula`, `subset` and `weights`: for example the glm
method handles `offset`, `etastart` and `mustart`.

If you have a `model.frame()` method it should

* return the `model` component of the fit (and there are no other arguments).

* establish a suitable environment within which to look for variables.
  The standard recipe is

```
    fcall <- formula$call
    ## drop unneeded args
    fcall[[1]] <- as.name("model.frame")
	if (is.null(env <- environment(formula$terms))) env <- parent.frame()
        eval(fcall, env)
```

* allow `...` to specify at least `data`, `na.action` or `subset`.
