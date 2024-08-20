#
#
#

doc_dir	= .

md4_cmd	= $(HOME)/tools/bin/md4 \
		--footer $(doc_dir)/Footer.md

%.md: %.md4
	$(md4_cmd) $< > $@

src	= CacheFile.md4
dst	= $(src:.md4=.md)

all: $(dst)

clean:
	rm -f $(dst)

