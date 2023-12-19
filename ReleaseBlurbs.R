## Produce texts at release time
db <- as.list(read.dcf("~/R-release/VERSION-INFO.dcf")[1,])
options(useFancyQuotes = FALSE)
with(db, {
  Oldseries <- paste(sep="",
                     "R-", gsub("[0-9]*$", "x", `Old-release`))
  cat(sep="", 
      "Version ", Release, 
      " (", dQuote(Nickname), ")", 
      " was released on ", Date, ".",
      "\n<p>\n",
      "The wrap-up release of the ", Oldseries, 
      " series was ", `Old-release`,
      " (", dQuote(`Old-nick`), ")", 
      " on ", `Old-date`, ".\n"
  )
  if (`Next-release` == "") ## do something about the else branch later...
    cat(sep="",
        "\n<p>\n",
        "The date for the next release is not yet set.",
        "\n<p>\n"
        )
  ## Markdown blurb for md/index.md in R-project-web
  cat(sep="",
      "-   [**R version ", Release, " (", Nickname, ")**]",
      "(https://cran.r-project.org/src/base/R-4)\n",
      "    has been released on ", Date, ".\n")
}
)
