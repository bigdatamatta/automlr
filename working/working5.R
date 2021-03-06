


#install.packages("Rmpi", configure.args = c("--with-Rmpi-include=/usr/include/openmpi-x86_64/", "--with-Rmpi-libpath=/usr/lib64/openmpi/lib/",
#                   "--with-Rmpi-type=OPENMPI"))

upstart()
roxygenise('..')

devtools::load_all("..")

devtools::test("..", filter = "aux")
devtools::test("..", filter = "errors", reporter = "debug")  # makes warnings
devtools::test("..", filter = "paramhandling")
devtools::test("..", filter = "searchspacedefs")
devtools::test("..", filter = "coltypes")
devtools::test("..", filter = "requirements")
devtools::test("..", filter = "wrappers")
devtools::test("..", filter = "taskbuilding")
devtools::test("..", filter = "trafos")

smalltests = c("aux", "errors", "paramhandling", "searchspacedefs", "coltypes",
  "requirements", "wrappers", "trafos")

sapply(smalltests, devtools::test, pkg = "..")

devtools::test("..", filter = "automlr_random")
devtools::test("..", filter = "automlr_mbo")

devtools::test("..", filter = "automlr_irace")

system.time(devtools::test("..", filter = "timeout"), FALSE)


# TODO:
# test_automlr_irace, _mbo, _random
# using helper_automlrhelpers

sp("type.multinomial", "cat", c("grouped", "ungrouped"), req = quote(automlr.targettype == "multiclass"))

mlrLearnersNoWrap

mlrWrappers$ampreproc$learner

mlrLearners
str(mlrLearners$ampreproc$searchspace[1])

sapply(mlrLearners$ampreproc$searchspace[[1]]$trafo, function(x) x)

mlrLearners
mlrLearners$ampreproc$searchspace[[1]]

pp

mlrLearners$classif.JRip$searchspace
catf
capture.output(cat('x'))
capture.output
deparse(quote(a + b))
x <- "a"
x <- 'b'
deparse(x)

##
pid.task

lrn <- buildLearners(list(mlrLearners$classif.linDA), pid.task, verbosity=6)

##

## TODO: try to just set currentBudget to a large number

debugonce(amoptimize.ammbo)

resRand <- automlr(pid.task, budget=c(evals=300), backend="mbo", verbosity=3,
                   searchspace=list(mlrLearners$classif.ctree, mlrLearners$classif.rknn))

debugger()
q

plot(as.data.frame(amfinish(resRand)$opt.path)$y)


resRand <- automlr(pid.task, budget=c(evals=1), backend="random", verbosity=3,
                   max.walltime.overrun=10, max.learner.time=10,
                   searchspace=list(mlrLearners$classif.ctree, mlrLearners$classif.rknn))


configureMlr(on.error.dump = TRUE)

configureMlr(show.info=TRUE, on.error.dump = TRUE)
resRand <- automlr(pid.task, budget=c(walltime=20), backend="random", verbosity=3,
                   max.walltime.overrun=10, max.learner.time=10,
                   searchspace=list(mlrLearners$classif.ctree, mlrLearners$classif.rknn, mlrLearners$ampreproc))

names(mlrLearners)

str(mlrLearners$classif.randomForest)


as.data.frame(amfinish(resRand)$opt.path)

debugger(getOptPathEl(amfinish(resRand)$opt.path, 1)$extra$.dump[[1]][[1]])

automlr:::runWithTimeout

as.data.frame(amfinish(resRand)$opt.path)


tl <- makeRLearnerClassif('testlearner', par.set=makeParamSet(makeIntegerLearnerParam('testparam')), package=character(0))
tl$fix.factors.prediction=TRUE

trainLearner.testlearner = function(.learner, .task, .subset, .weights = NULL, testparam, ...) {
  print(colnames(getTaskData(.task)))
  testparam
}

predictLearner.testlearner = function(.learner, .model, .newdata, ...) {
  print(.model$learner.model)
  factor(rep(.model$task.desc$class.levels[1], nrow(.newdata)),
         levels=.model$task.desc$class.levels)
}

configureMlr(show.info=TRUE, on.error.dump = TRUE)

data = getTaskData(pid.task)
data[1, 1] = NA
pid.task2 = makeClassifTask(data=data, target=getTaskTargetNames(pid.task))


m <- train(setHyperPars(tl, testparam=2), pid.task)
predict(m, newdata=getTaskData(pid.task2))

tlw <- makePreprocWrapperAm(tl, ppa.nzv.cutoff.numeric=10, ppa.impute.numeric="remove.na", ppa.multivariate.trafo="ica")
mw <- train(setHyperPars(tlw, testparam=2), pid.task2)
predict(mw, newdata=getTaskData(pid.task2))


tlw2 <- makeFailImputationWrapper(tl)
mw2 <- train(setHyperPars(tlw2), pid.task2)
predict(mw2, newdata=getTaskData(pid.task2))


debugger(m$dump)
sapply(getTaskData(pid.task), var)


automlr:::trainLearner.PreprocWrapperAm()
debugonce(predictLearner.PreprocWrapperAm)

debugonce(trainLearner.PreprocWrapperAm)



##
configureMlr(show.info=TRUE, on.error.dump = TRUE)
resRand <- automlr(pid.task, budget=c(evals=3), backend="mbo", verbosity=3,
                   searchspace=mlrLightweight)

debug(makePreprocWrapperAm)


adf <- as.data.frame(amfinish(resRand)$opt.path)

names(adf)
adf[, c(1, 298:304)]

resRand2 <- automlr(resRand, budget=c(evals=1190), verbosity=5)

resRand$spent




resRand3 <- automlr(pid.task, budget=c(evals=3), backend="mbo", verbosity=3,
                   searchspace=mlrLightweight)



resRand3 <- automlr(pid.task, budget=c(evals=3), backend="mbo", verbosity=3,
                   searchspace=list(mlrLearners$classif.ctree, mlrLearners$classif.rknn))

debugonce(mlrMBO:::evalMBODesign.OptState)


##

getNativeSymbolInfo("lhs")
getNativeSymbolInfo("maximinLHS_C")

str(getCallingDLLe(getNamespace("lhs")))
getCallingDLLe(getNamespace("lhs"))$info
getCallingDLLe(getNamespace("lhs"))[[5]]



debugonce(lhs::maximinLHS)
.dynLibs(.dynLibs()[1:16!=8])

dyn.unload
devtools:::unload_dll
devtools:::load_dll
devtools:::loaded_dlls

##

recurseObj <- function(obj) {
  visitedList = list()
  visitedList[[capture.output(str(.GlobalEnv))]] = 1
  recurse <- function(obj, lvl) {

    indent = collapse(c("", rep("|", length(lvl))), sep="")
#    if (length(obj) < 10) {
#      out = capture.output(print(obj))
#      out = c(paste0(indent, out[out != ""]), "")
#      cat(collapse(out, sep="\n"))
#    }
    if (is.recursive(obj) && !is.atomic(obj)) {
      if (typeof(obj) == "...") {
        obj = evalq(list(...), list(`...`=obj))
      } else if (typeof(obj) == "closure") {
        obj = environment(obj)
      }
      if (typeof(obj) == "environment") {
        objRem <- obj
        attributes(objRem) <- NULL
        enname = capture.output(str(objRem))
        if (isNamespace(obj)) {
          position = collapse(lvl, sep=" -> ")
          catf("NAMESPACE %s%s", enname, position)
          return(NULL)
        }
        if (!is.null(visitedList[[enname]])) {
          return(NULL)
        }
        visitedList[enname] <<- 1
      }
      if (is.null(names(obj)) || any(names(obj) == "")) {
        for (i in seq_along(obj)) {
#          catf("%sentering: %i", indent, i)
          Recall(obj[[i]], lvl = c(lvl, i))
        }
      } else {
        for (i in names(obj)) {
#          catf("%sentering: %s", indent, i)
          Recall(obj[[i]], lvl = c(lvl, i))
        }
      }
    }
    for (an in names(attributes(obj))) {
      a = attr(obj, an)
      if (!is.atomic(a)) {
        Recall(a, lvl = c(lvl,an) )
      }
    }
  }
  recurse(obj, character(0))
}

recurseObj(lapply(objects(), get))
isNamespace(environment(lhs::maximinLHS))



simplifyEval = function(lang) {
  if (!is.recursive(lang)) {
    if (is.symbol(lang)) {
      return(NULL)
    } else {
      return(list(eval(lang, baseenv())))
    }
  }
  asCond = function(x) {
    x && TRUE
  }
  logOrNull = function(x) {
    if (is.null(x)) {
      NULL
    } else {
      list(asCond(x[[1]]))
    }
  }
  if (identical(lang[[1]], quote(`if`))) {
    # emulate 'if': if conditional is unknown,
    # we may still rescue the situation if both
    # cases give same result.
    cond = simplifyEval(lang[[2]])
    if (is.null(cond)) {
      ca = simplifyEval(lang[[3]])
      cb = simplifyEval(lang[[4]])
      if (identical(ca, cb)) {
        return(ca)
      } else {
        return(NULL)
      }
    } else if (cond[[1]]) {
      return(simplifyEval(lang[[3]]))
    } else {
      return(simplifyEval(lang[[4]]))
    }
  } else if (identical(lang[[1]], quote(`&&`))) {
    ca = simplifyEval(lang[[2]])
    if (is.null(ca) || asCond(ca[[1]])) {
      cb = simplifyEval(lang[[3]])
      if (is.null(cb) || !asCond(cb[[1]])) {
        return(logOrNull(cb))
      }
      return(logOrNull(ca))
    } else {
      return(list(FALSE))
    }
  } else if (identical(lang[[1]], quote(`||`))) {
    ca = simplifyEval(lang[[2]])
    if (is.null(ca) || !asCond(ca[[1]])) {
      cb = simplifyEval(lang[[3]])
      if (is.null(cb) || asCond(cb[[1]])) {
        return(logOrNull(cb))
      }
      return(logOrNull(ca))
    } else {
      return(list(TRUE))
    }
  }
  if (length(lang) == 2) {
    allowedunary = list(quote(`(`), quote(isTRUE), quote(isFALSE),
      quote(identity), quote(as.null), quote(`!`), quote(`+`), quote(`-`))
    for (f in allowedunary) {
      if (!identical(lang[[1]], f)) {
        next
      }
      ca = simplifyEval(lang[[2]])
      if (is.null(ca)) {
        return(NULL)
      }
      return(list(get(as.character(f))(ca[[1]])))
    }
  } else if (length(lang) == 3) {
    allowedbinary = list(quote(`==`), quote(`+`),
      quote(`-`), quote(`*`), quote(`/`))
    for (f in allowedbinary) {
      if (!identical(lang[[1]], f)) {
        next
      }
      ca = simplifyEval(lang[[2]])
      if (is.null(ca)) {
        return(NULL)
      }
      cb = simplifyEval(lang[[3]])
      if (is.null(cb)) {
        return(NULL)
      }
      return(list(get(as.character(f))(ca[[1]], cb[[1]])))
    }
  }
  NULL
}

l <- buildLearners(list(
      NumericsLearner,
      pWW(nimp1), pWW(nimp2), pWW(fimp1), pWW(fimp2), pWW(oimp1), pWW(oimp2),
      pWW(fnconv1), pWW(onconv1), pWW(onconv2),
      pWW(nfconv1), pWW(nfconv2), pWW(ofconv1), pWW(ofconv2),
      pWW(noconv1), pWW(noconv2), pWW(foconv1), pWW(foconv2)), MissingsNumericsTask, verbosity = 6)

pvs = list(automlr.missing.indicators = FALSE,
    automlr.wimputing.numerics = "numimputer2", multiplier = 1,
    NumericsLearner.int1 = 9)

predict(train(setHyperPars(l, par.vals=pvs), MissingsNumericsTask), MissingsNumericsTask)

  pvx = namedList(getParamIds(getParamSet(l)), NA)
  x = isFeasible(getParamSet(l), insert(pvx, pvs))
  substr(attr(x, "warning"), 1, 200)

m = train(setHyperPars(l, par.vals = pvs), MissingsNumericsOrderedTask)

head(m$learner.model$learner.model$next.model$learner.model$next.model$learner.model$data)

getpars(l)$automlr.convert$requires


eval(getpars(l)$reference.cat$requires[[2]], pvs)

eval(getpars(l)$reference.cat$requires[[2]][[2]][[2]], pvs)


getpars(l)$reference.cat$requires[[2]][[2]][[2]][[2]][[2]][[2]][[1]]

getpars(l)$reference.cat$requires[[2]][[2]][[2]][[2]][[2]][[2]][[2]]

eval(l$staticParams[[8]]$requires[[2]], pvs)


l$staticParams[[9]]

which(extractSubList(l$staticParams, "id") == "automlr.wconverting.factors.to.numerics")

which(extractSubList(l$staticParams, "id") == "automlr.convert.factors")

eval(l$staticParams[[4]]$requires, pvs)

pvs$automlr.missing.indicators

l$staticParams[[9]]


library(lineprof)

#tmp <- "profiling"
#Rprof(tmp, interval = 0.1)
#Rprof(NULL)

lprof <- lineprof(automlr(theTask, searchspace = searchSpaceToTest, backend = "random",
  budget = c(evals = 100), verbosity = 0))

ll = buildLearners(searchSpaceToTest, theTask)

lprof <- lineprof(tuneParams(ll, theTask, cv5, par.set = ll$searchspace,
  control = makeTuneControlRandom(maxit = 500)))

save(lprof, file = "lprof_profiling.Rsv")

shine(lprof)




bd = body(devtools:::process_imports)
pidash = devtools:::process_imports
body(pidash)[[7]][[4]] = bd[[7]][[4]][[3]]

pidash

assignIn
assignInNamespace("process_imports", pidash, ns = "devtools")
