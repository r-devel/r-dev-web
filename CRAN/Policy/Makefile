all: pdf html

pdf: CRAN_policies.pdf
html: CRAN_policies.html

CRAN_policies.pdf: CRAN_policies.texi
	texi2pdf $<

CRAN_policies.html: CRAN_policies.texi CRAN_policies.css
	makeinfo --html --no-split --no-headers --css-include=CRAN_policies.css $< -o $@

install: CRAN_policies.html CRAN_policies.pdf
	scp CRAN_policies.html \
	  cran.wu.ac.at:/home/ftp/pub/R/web/packages/policies.html
	scp CRAN_policies.pdf \
	  cran.wu.ac.at:/home/ftp/pub/R/web/packages/policies.pdf

clean:
	-@rm -f *.aux *.cp *.fn *.html *.ky *.log *.pdf *.pg *.toc *.tp *.vr

