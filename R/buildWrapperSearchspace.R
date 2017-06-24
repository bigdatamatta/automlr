
# Take the list of wrappers, a vector named by feature types indicating whether
# they have missings or not, the list of learner names by feature types /
# missings they can handle, and the list of all learners.
# return the set of "shadow" parameters which control wrapper behaviour,
# and the list of psuedoparameter replacements.
buildWrapperSearchSpace = function(wrappers, missings, canHandleX,
    allLearners) {
  outparams = list()
  allTypes = c("factors", "ordered", "numerics")
  
  types.present = names(missings)
  
  converters = bwssConverters(wrappers)
  imputers = bwssImputers(wrappers, missings)
  preprocs = bwssPreprocs(wrappers)
  
  can.convert = as.logical(any(extractSubList(wrappers, "is.converter")))
  can.impute = all(sapply(imputers[missings], length))
  can.convert.before.impute = all(sapply(imputers, length))
  
  imputeparam = "automlr.impute"
  miparam = "automlr.missing.indicators"
  convertanyparam = "automlr.convert"
  cbiparam = "automlr.convert.before.impute"
  
  ppnames = list()
  wanames = list()
  wrapagain = list()
  wimpnames = list()
  convparnames = list()  # type -> parname of automlr.convert.
  convtargetnames = list()  # type -> parname of automlr.convert.X.to
  for (type in allTypes) {
    convparnames[[type]] = sprintf("automlr.convert.%s", type)
    convtargetnames[[type]] = sprintf("automlr.convert.%s.to", type)
    wanames[[type]] = sprintf("automlr.wrapafterconvert.%s", type)
    wrapagain[[type]] = asQuoted(wanames[[type]])
    wimpnames[[type]] = sprintf("automlr.wimputing.%s", type)
    ppnames[[type]] = sprintf("automlr.preproc.%s", type)
    
  }
  
  # return something like quote(selected.learner %in% canHandleX[[type]])
  # but use TRUE of FALSE if this is always TRUE / FALSE.
  learnerCanHandleQuote = function(type) {
    if (setequal(allLearners, canHandleX[[type]])) {
      TRUE
    } else if (!length(canHandleX[[type]])) {
      FALSE
    } else {
      substitute(selected.learner %in% x, list(x = canHandleX[[type]]))
    }
  }
  
  # take a list of truth values indexed by type, giving the state of something
  # (presence, missingness) before conversion. This function generates the
  # expression that gives the respective state *after* conversion.
  transformProposition = function(proplist) {
    sapply(allTypes, function(totype) {
          noconversion = proplist[[totype]] %&&%
              qNot(asQuoted(convparnames[[totype]]))
          conversion = Reduce(`||`, lapply(setdiff(allTypes, totype)),
              function(fromtype) {
                proplist[[fromtype]] %&&%
                    asQuoted(convparnames[[fromtype]]) %&&%
                    substitute(a == b, list(
                            a = asQuoted(convtargetnames[[fromtype]]),
                            b = totype))
              }, FALSE)
          noconversion %||% conversion
        }, simplify = FALSE)
  }
  
  # -------------------------------
  # indicators telling which types are present at each stage
  # -------------------------------

  # e.g. dtPresentAfterConv[[type]] is TRUE whenever 'type' data is present
  #   after conversion.

  # missings does not have all names, only the names of types that are actually
  # present.
  dtMissingBeforeConv = sapply(allTypes,
      function(x) isTRUE(as.list(missings)[[x]]))
  dtPresentBeforeConv = sapply(allTypes, function(x) x %in% types.present,
      simplify = FALSE)
  dtPresentBeforeConv$factors = dtPresentBeforeConv$factors %||%
      asQuoted(miparam)
  
  dtPresentAfterConv = transformProposition(dtPresentBeforeConv)
  dtMissingAfterConv = transformProposition(dtMissingBeforeConv)

  # dtWrap[[type]] is TRUE whenever wrapping is supposed to happen.
  dtWrap = sapply(allTypes, function(type) {
        (qNot(asQuoted(cbiparam)) %&&% dtPresentBeforeConv[[type]]) %||%
            transformProposition(wrapagain)[[type]]
      }, simplify = FALSE)
  
  
  # ----------------------------
  # automlr.impute parameters
  # ----------------------------
  outparams %c=% makeLParam0Req(imputeparam,
      can.impute %&&% qNot(learnerCanHandleQuote("missings")),
      !can.impute)
  
  # ----------------------------
  # automlr.convert.X parameters
  # ----------------------------
  
  # param whether to convert at all
  outparams %c=% makeLParam0Req(convertanyparam, FALSE, !can.convert)
  
  for (type in allTypes) {
    eligible.targets = Filter(function(totype) {
          (totype != type) &&  # no identity conversion
              (length(converters[[type]][[totype]]))  # only if converters exist
        }, allTypes)
    
    convparamname = convparnames[[type]]
    
    req = convertanyparam %&&%
        Reduce(`%||%`, lapply(eligible.targets, learnerCanHandleQuote), FALSE)
    
    if (type == "factors") {
      mayproducefactors = learnerCanHandleQuote(type) %||% req
      outparams %c=% makeLParam0Req(miparam, FALSE,
          !(any(missings) %&&% mayproducefactors))
    }
    
    req = dtPresentBeforeConv[[type]] %&&% req
    
    outparams %c=% makeLParam0Req(convparamname,
        qNot(learnerCanHandleQuote(type)) %&&% req,
        qNot(req))
    
    if (length(eligible.targets) > 1) {
      req = Reduce(`%&&%`, lapply(eligible.targets, learnerCanHandleQuote),
          TRUE) %&&% asQuoted(convparamname)
      outparams %c=% list(makeDiscreteParam(convtargetnames[[type]],
              values = eligible.targets, requires = setReq(req)))
    }
    for (totype in eligible.targets) {
      index = which(totype == eligible.targets)
      other.targets = setdiff(eligible.targets, totype)
      
      # it is possible and easy to handle the case where there are more than
      # three types (and hence more than 2 eligible.targets), but the following
      # would need to change for that.
      assert(length(other.targets) <= 1)
      
      if (length(other.targets)) {
        is.only.conv = qNot(learnerCanHandleQuote(other.targets))
      } else {
        is.only.conv = TRUE
      }
      
      pname = sprintf("automlr.convert.%s.to.AMLRFIX%d", type, index)
      # dropping getReq(convparam) %&&% ..., because (A || B) && B == B.
      req = learnerCanHandleQuote(totype) %&&% is.only.conv %&&%
          asQuoted(convparamname)
      outparams %c=% list(makeDiscreteParam(pname, values = totype,
              requires = setReq(req)))
      
      pname = sprintf("automlr.wconverting.%s.to.%s", type, totype)
      req = learnerCanHandleQuote(totype) %&&% asQuoted(convparamname) %&&%
          substitute(a == b, list(
                  a = asQuoted(convtargetpname),
                  b = totype))
      outparams %c=% list(makeDiscreteParam(pname,
              values = converters[[type]][[totype]], requires = setReq(req)))
    }
  }
  
  # -------------------------------
  # automlr.convert.before.impute
  # -------------------------------
  
  # 'automlr.convert.before.impute is only available if:
  # - can.convert.before.impute
  # - at least one convert param is TRUE
  #   - which means, the convert param's requirements must also be TRUE
  # - imputeparam is TRUE
  cbiReq = can.convert.before.impute %&&% asQuoted(imputeparam) %&&%
      Reduce(`||`, lapply(convparnames, asQuoted))
  outparams %c=% makeLParam0Req(cbiparam, FALSE, qNot(cbiReq))
  
  # -------------------------------
  # automlr.wrapafterconvert.XXX
  # -------------------------------

  for (type in allTypes) {
    wrapagainname = wanames[[type]]
    outparams %c=% makeLParam0Req(wrapagainname,
        asQuoted(cbiparam) %&&% asQuoted(convparnames[[type]]),
        !asQuoted(convparnames[[type]]))
  }

  # -------------------------------
  # automlr.wimputing.XXX
  # -------------------------------
  
  for (type in allTypes) {
    if (!length(imputers[[type]])) {
      next
    }
    wimpreq = (qNot(asQuoted(cbiparam)) %&&% dtMissingBeforeConv[[type]]) %||%
        (asQuoted(cbiparam) %&&% dtMissingAfterConv[[type]])
    outparams %c=% makeDiscreteParam(wimpnames[[type]],
        values = imputers[[type]],
        requires = setReq(asQuoted(imputeparam) %&&% wimpreq))
  }
  
  # -------------------------------
  # automlr.preproc.XXX
  # -------------------------------
  
  for (type in allTypes) {
    ppname = ppnames[[type]]
    outparams %c=% makeDiscreteParam(ppname,
        values = listWrapperCombinations(preprocs[[type]]),
        requires = setReq(dtWrap[[type]]))
    outparams %c=% makeDiscreteParam(paste0(ppname, ".AMLRFIX1"),
        values = "$", requires = setReq(qNot(dtWrap[[type]])))
  }
  
  replacelist = dtPresentAfterConv
  names(replacelist) = paste0("automlr.has.", names(replacelist))
  replacelist$automlr.has.missings = any(missings) %&&%
      qNot(asQuoted(imputeparam))
  
  list(wrapperparams = outparams,
      replaces = replacelist)
}

#################################
# Requirement Helpers           #
#################################

`%&&%` = function(a, b) {
  if (isTRUE(a)) {
    return(b)
  }
  if (isFALSE(a) || isFALSE(b)) {
    return(FALSE)
  }
  if (isTRUE(b)) {
    return(a)
  }
  substitute(((a) && (b)), list(a = a, b = b))
}

`%||%` = function(a, b) {
  if (isFALSE(a)) {
    return(b)
  }
  if (isTRUE(a) || isTRUE(b)) {
    return(TRUE)
  }
  if (isFALSE(b)) {
    return(a)
  }
  substitute(((a) || (b)), list(a = a, b = b))
}

qNot = function(a) {
  if (isFALSE(a)) {
    TRUE
  } else if (isTRUE(a)) {
    FALSE
  } else {
    substitute((!(a)), list(a = a))
  }
}

# call this as in 'makeParam(..., requires = setReq(requirement))`
setReq = function(r) {
  if (isTRUE(r)) {
    NULL
  } else if (class(r) != "call") {
    force(r)
    substitute(identity(r))
  } else {
    r
  }
}

# get a parameter's 'requires' or TRUE if no requires present.
getReq = function(r) {
  req = r$requires
  if (is.null(req)) {
    TRUE
  } else {
    req
  }
}

# make a logical param which only appears when both 'alwaysTrueReq'
# and 'alwaysFalseReq' are FALSE. Otherwise, use AMLRFIX-magic to
# set the parameter to TRUE / FALSE, depending on the requirements.
# assumes alwaysTrueReq and alwaysFalseReq are mutually exclusive.
makeLParam0Req = function(id, alwaysTrueReq, alwaysFalseReq) {
  list(
      makeLogicalParam(id, requires = setReq(
              qNot(alwaysTrueReq) %&&% qNot(alwaysFalseReq))),
      makeDiscreteParam(paste0(id, ".AMLRFIX1"),
          values = list(`TRUE` = TRUE),
          requires = setReq(alwaysTrueReq)),
      makeDiscreteParam(paste0(id, ".AMLRFIX2"),
          values = list(`FALSE` = FALSE),
          requires = setReq(alwaysFalseReq)))
}

#################################
# Wrapper lists                 #
#################################

bwssConverters = function(wrappers) {
  cwrappers = wrappers[extractSubList(wrappers, "is.converter")]
  converters = list()  # a list source -> destination -> converternames
  for (type in types.present) {
    converters[[type]] = list()
  }
  for (cw in cwrappers) {
    converters[[cw$convertfrom]][[cw$datatype]] %c=% cw$name
  }
}

bwssImputers = function(wrappers, missings) {
  imputers = lapply(missings, function(x) character(0))
  iwrappers = wrappers[extractSubList(wrappers, "is.imputer")]
  for (iw in iwrappers) {
    imputers[[iw$datatype]] %c=% iw$name
  }
}

bwssPreprocs = function(wrappers) {
  ppwrappers = wrappers[(!extractSubList(wrappers, "is.imputer")) &
          (!extractSubList(wrappers, "is.converter"))]
  preprocs = list()
  for (pw in ppwrappers) {
    preprocs[[pw$datatype]] %c=% pw$name
  }
}

# get the possible values of preprocessor-wrapper parameters
# these are $-separated lists of names in the order the preprocessors are
# applied.
listWrapperCombinations = function(ids) {
  combineNames = function(x) {
    if (all(!duplicated(x))) {
      paste(x, collapse = "$")
    }
  }
  result = sapply(seq_along(ids), function(l) {
        apply(expand.grid(rep(list(ids), l)), 1, combineNames)
      })
  # add "no wrappers" option. The empty string
  # causes errors, however.
  result = c("$", result)
  unlist(result)
}
