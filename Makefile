all: python_modules

python_modules:
	mkdir python_modules
	pip3 install -r requirements.txt --target="./python_modules" --ignore-installed --system

clean:
	rm -rf python_modules
	sudo rm -f /usr/local/bin/aws-snapshot-recovery

dev: /usr/local/bin/aws-snapshot-recovery

/usr/local/bin/aws-snapshot-recovery:
	sudo ln -s $(realpath ./bin/dev) /usr/local/bin/aws-snapshot-recovery
