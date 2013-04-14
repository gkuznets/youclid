COFFEE_SOURCES=$(shell find static/js -name "*.coffee")
COFFEE_SOURCES+=app.js
JS_SOURCES=$(patsubst %.coffee,%.js,$(COFFEE_SOURCES))

%.js : %.coffee
	coffee -cb $< > $@

# compile all js files
js: $(JS_SOURCES)

doc: $(COFFEE_SOURCES)
	codo -n youclid --title "youclid documentation" $(COFFEE_SOURCES)

run: $(JS_SOURCES)
	node app

clean:
	echo $(COFFEE_SOURCES)
	rm -rf $(JS_SOURCES)
	rm -rf doc
