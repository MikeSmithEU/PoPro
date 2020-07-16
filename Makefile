build:
	gem build popro.gemspec

clean:
	rm popro-*.gem

publish: clean build install
	gem push popro-*.gem
	gem push --key github --host https://rubygems.pkg.github.com/MikeSmithEU popro-*.gem

install:
	gem install popro-*.gem

libfiles:
	find lib/

test:
	rspec -fd spec
