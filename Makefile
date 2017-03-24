.PHONY: build

serve:
	bundle exec middleman

build:
	bundle exec middleman build

deploy: build
	bundle exec middleman deploy

article:
	bundle exec middleman article '${TITLE}' -l id
	# Don't know how to get output from previous line to make its directory
	bundle exec middleman article '${TITLE}' -l en | tail -1 | awk '{print $$NF}' | cut -f 1 -d '.' | xargs mkdir
