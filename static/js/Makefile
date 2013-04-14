COFFEE_SOURCES = $(shell find . -name "*.coffee" -print)
JS_SOURCES = $(COFFEE_SOURCES:.coffee=.js)

all: $(JS_SOURCES)
	

$(JS_SOURCES): %.js: %.coffee 
	coffee -cb $<

.PHONY: clean
clean:
	rm *.js
