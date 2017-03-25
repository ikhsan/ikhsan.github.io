.PHONY: build

serve:
	bundle exec middleman

build:
	bundle exec middleman build

deploy: build
	bundle exec middleman deploy

article:
	bundle exec middleman article '${TITLE}' -l id
	bundle exec middleman article '${TITLE}' -l en

test: build
	bundle exec htmlproofer build/ --check-favicon --check-html --empty-alt-ignore false
