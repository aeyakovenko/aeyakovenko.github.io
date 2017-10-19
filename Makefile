# 'Makefile'
#apt-get install texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended
MARKDOWN = pandoc --from markdown_github --standalone -c github.css #--to $(subst .,,$(suffix $@))
MARKDOWN2 = pandoc --from markdown_github --standalone -c pandoc.css #--to $(subst .,,$(suffix $@))
all: $(patsubst %.md,%.html,$(wildcard *.md))
all: $(filter-out index.pdf,$(patsubst %.md,%.pdf,$(wildcard *.md)))

clean:
	 rm -f $(patsubst %.md,%.html,$(wildcard *.md))
	 rm -f *.bak *~

%.html: %.md *.css Makefile
	$(MARKDOWN) $< --output $@


%.pdf: %.html *.css Makefile
	export PATH=${PATH}:/Applications/wkhtmltopdf.app/Contents/MacOS && wkhtmltopdf $< $@

