#'Text summarization of the model results
#'
#'Summarize the model results
#'
#'@param modelReturn censReg model results
#'@param siteINFO dataframe including station name (station_nm) and siteID (site.no) (easiestly retrieved from dataRetrieval package)
#'@param saveOutput logical defaults to FALSE. Set to TRUE if an output file is desired
#'@param fileName string full path and file name to save output
#'@keywords summary text
#'@export
#'@examples
#' DTComplete <- StLouisDT
#' UV <- StLouisUV
#' response <- "Ammonia.N"
#' siteINFO <- StLouisInfo
#' DT <- DTComplete[c(response,getPredictVariables(names(UV)), "decYear","sinDY","cosDY","datetime")]
#' DT <- na.omit(DT)
#' kitchenSink <- createFullFormula(DT,response)
#' modelReturn <- censReg(paste(response," ~ ", kitchenSink, sep=""), dist="lognormal", data=DT)
#' summaryPrintout(modelReturn,siteINFO)
summaryPrintout <- function(modelReturn, siteINFO, saveOutput=FALSE,fileName="output.txt"){
  
  if(saveOutput) sink(fileName)
  
  responseVariable <- rownames(attributes(modelReturn$terms)$factors)[1]
  
  termNames <- names(coef(modelReturn))
  coefficients <- as.numeric(coef(modelReturn))
  
  StCoef <- with(modelReturn, PARAML/STDDEV)
  modelStuff <- with(modelReturn, data.frame(Term=c(names(coef(modelReturn)),"logSigma"),
                                        Coefficient=round(PARAML,digits=3), 
                                        StdError=round(STDDEV,digits=3), 
                                        pValue=round(PVAL,digits=3),
                                        StCoef=round(StCoef,digits=3)
  ))
  
  termNames <- paste(termNames, collapse=" + ")
  printFormula <- paste(responseVariable, " ~ ", termNames, sep="")
  numCensored <- sum(modelReturn$CENSFLAG)
  
  prettyName <- simpleCap(siteINFO$station_nm)
  prettyName <- gsub("Wi", "WI",prettyName) #Consider other states.
  cat(responseVariable, " at ", prettyName, " (", siteINFO$site.no, ")\n")
  cat("Number of observations: ", modelReturn$NOBSC, "\n")
  cat("Distribution: ", modelReturn$dist, "\n")
  cat("Method: ", modelReturn$method, "\n")
  cat("Degrees of freedom: ", modelReturn$DF, "\n")
  cat("RMSE: ", rmse(modelReturn), "\n")
  cat("RSQ: ", modelReturn$RSQ, "\n")
  
  cat("Number of censored values: ", numCensored,"\n")
  cat(printFormula, "\n\n")
  print(modelStuff)
  cat("\n")
  cat("Correlation matrix of coefficients:","\n")
  CORdf <- cov2cor(modelReturn$COV)
  CVdf <- as.data.frame(round(CORdf,digits=4))
  colnames(CVdf) <- c(names(coef(modelReturn)),"logSigma")
  rownames(CVdf) <- c(names(coef(modelReturn)),"logSigma")
  print(CVdf)
#   cat("\nTo clarify:\n")
  
#   cat("LLR: ", modelReturn$LLR, "\n")
#   cat("SCORR: ", modelReturn$SCORR, "\n")
#   cat("LLRAML: ", modelReturn$LLRAML, "\n")
#   cat("PLEVAML: ", modelReturn$PLEVAML, "\n")
#   cat("IERR: ", modelReturn$IERR, "\n")  
  
  if (saveOutput) sink()
}