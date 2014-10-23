# 'Makefile'
#apt-get install texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended
MARKDOWN = pandoc --from markdown_github --standalone -c github.css #--to $(subst .,,$(suffix $@))
all: $(patsubst %.md,%.html,$(wildcard *.md))
all: $(patsubst %.md,%.pdf,$(wildcard *.md))

clean:
	 rm -f $(patsubst %.md,%.html,$(wildcard *.md))
	 rm -f *.bak *~

%.html: %.md *.css Makefile
	$(MARKDOWN) $< --output $@

%.pdf: %.md *.css Makefile
	$(MARKDOWN) $< --output $@

