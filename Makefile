
HTML_FILES := model-fitting-functions.html

all: $(HTML_FILES)

$(HTML_FILES): %.html: %.md
	pandoc '$<' -o '$@' --standalone --smart

.PHONY: clean
clean:
	$(RM) $(HTML_FILES)

