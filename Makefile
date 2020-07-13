build:
	gem build popro.gemspec

clean:
	rm popro-*.gem

publish: clean build install
	gem push popro-*.gem

install:
	gem install popro-*.gem

libfiles:
	find lib/

test:
	rspec -fd spec
