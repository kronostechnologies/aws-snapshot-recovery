all: python_modules

python_modules:
	mkdir python_modules
	pip3 install -r requirements --target="./python_modules" --ignore-installed --system

.PHONY: clean
clean:
	rm -rf python_modules
	sudo rm -f /usr/local/bin/aws-snapshot-recovery

.PHONY: docker
docker:
	docker build . -t kronostechnologies/aws-snapshot-recovery:1.1.2

.PHONY: dev
dev: /usr/local/bin/aws-snapshot-recovery

/usr/local/bin/aws-snapshot-recovery:
	sudo ln -s $(realpath ./bin/dev) /usr/local/bin/aws-snapshot-recovery
