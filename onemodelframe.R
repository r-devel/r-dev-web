formulasFrame<-function(formulas, 
                        data=parent.frame(),
                        na.action=getOption("na.action"),subset=NULL,
                        check.env=FALSE, one.frame=TRUE){
  
  pf<-parent.frame()
  
  ## Doug wants formulas to be objects with formula methods
  formulas<-lapply(formulas,formula)
   
  if(check.env){
    envs<-lapply(formulas, environment)
    hasenv<-which(sapply(envs,is.null))
    if (length(hasenv)>1){
      for(i in 2:length(hasenv))
        if (!identical(envs[[hasenv[1]]],envs[[hasenv[i]]]))
          warning("Different environments on formulas")
    }
  }
  

  mfs<-eval(substitute(lapply(formulas,model.frame,data=data,
                              na.action="na.pass",subset=subset),
                       list(subset=subset,formulas=formulas,data=data)),pf)
  
  if (one.frame){
    mf<-do.call("cbind",mfs)
    rm(mfs)
    mf<-mf[,!duplicated(names(mf)),drop=FALSE]
    return(get(na.action)(mf))
  } else {
    naa<-lapply(mfs,function(x) attr(get(na.action)(x),"na.action"))
    drop<-unique(do.call("c",naa))
   	class(drop)<-class(naa[[min(which(sapply(naa,is.null)))]])
    
    if (length(drop)){
	   mfs<-lapply(mfs, function(x) {x<-x[-drop,,drop=FALSE]; attr(x,"na.action")<-drop; x})
         }
    return(mfs)
    
  }
  
}
