all: build

build:
	ansible-playbook install.yml

clean:
	ansible-playbook delete.yml
