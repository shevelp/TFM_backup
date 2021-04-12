prefix = /usr/local

all:

clean:
	$(RM) -r build dist MANIFEST *.pyc

distclean: clean
	$(RM) doc/*.pdf

doc: doc/mkexp.pdf

check:
	python test.py -v

dist: doc
	python setup.py sdist

install: doc
	python setup.py install --prefix=$(prefix)

.PHONY: all clean distclean doc check dist install

%.pdf: %.fodt
	soffice --headless --convert-to pdf --outdir $(@D) $<
