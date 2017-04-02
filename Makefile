.PHONY: build test

serve:
	bundle exec middleman

build:
	bundle exec middleman build

deploy: build
ifdef TRAVIS_BUILD_NUMBER
ifdef GH_TOKEN
	@echo Setup config from Travis CI
	git config --global user.name '${CI_COMMIT_AUTHOR}'
	git config --global user.email '${CI_COMMIT_EMAIL}'
	git remote set-url origin https://ikhsan:${GH_TOKEN}@github.com/ikhsan/ikhsan.github.io.git
endif
endif
	bundle exec middleman deploy

article:
	bundle exec middleman article '${TITLE}' -l id
	bundle exec middleman article '${TITLE}' -l en

test: build
	bundle exec htmlproofer build/ --check-favicon --check-html --empty-alt-ignore false
