all: pdf html

pdf: CRAN_policies.pdf
html: CRAN_policies.html
txt: CRAN_policies.txt

CRAN_policies.pdf: CRAN_policies.texi
	texi2pdf $<

CRAN_policies.html: CRAN_policies.texi CRAN_policies.css
	makeinfo --html --no-split --no-headers --css-include=CRAN_policies.css $< -o $@

CRAN_policies.txt: CRAN_policies.texi
	makeinfo --fill-column=76 --no-split --no-headers --number-sections $< -o $@

## Careful: you need to svn commit before installing as the files
## contain the SVN revision.
install: CRAN_policies.html CRAN_policies.pdf
	scp CRAN_policies.html \
	  cran.wu.ac.at:/home/ftp/pub/R/web/packages/policies.html
	scp CRAN_policies.pdf \
	  cran.wu.ac.at:/home/ftp/pub/R/web/packages/policies.pdf

clean:
	-@rm -f *.aux *.cp *.fn *.html *.ky *.log *.pdf *.pg *.toc *.tp *.vr
