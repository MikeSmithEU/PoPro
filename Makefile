build:
	gem build popro.gemspec

install:
	gem install popro-*.gem

libfiles:
	find lib/

test:
	rspec -fd spec
