XSLT_PROCESSOR=export LD_LIBRARY_PATH=/tmp/xml-xalan/c/lib ; /tmp/xml-xalan/c/bin/testXSLT

guide.html:

%.html: %.xml
	($(XSLT_PROCESSOR) $(XSLT_FLAGS) -in $< -out $@ -xsl doc.xsl -param cssURL "'../Rtech.css'")
