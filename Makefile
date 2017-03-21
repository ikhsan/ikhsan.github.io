.PHONY: build

serve:
	bundle exec middleman

build:
	bundle exec middleman build

deploy: build
	bundle exec middleman deploy
