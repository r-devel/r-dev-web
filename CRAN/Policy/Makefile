all: pdf html

pdf: CRAN_policies.pdf
html: CRAN_policies.html

CRAN_policies.pdf: CRAN_policies.texi
	texi2pdf $<

CRAN_policies.html: CRAN_policies.texi CRAN_policies.css
	makeinfo --html --no-split --no-headers --css-include=CRAN_policies.css $< -o $@
