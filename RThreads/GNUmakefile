guide.html:

%.html: %.xml
	($(XSLT_PROCESSOR) $(XSLT_FLAGS) -in $< -out $@ -xsl doc.xsl -param cssURL "'../Rtech.css'")


local.config:
	@echo "# XSLT_PROCESSOR=" > $@
	@echo "# XSLT_FLAGS=" >> $@

include local.config

