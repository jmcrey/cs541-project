ifndef VERBOSE
.SILENT:
endif

build:
	docker build \
	 -f docker/torch-gpu.Dockerfile \
	 -t torch-gpu-service:latest \
	 .

help:
	docker-compose -f torch-gpu.yaml run service

run:
	read -p "Which task would you like to compute? [BoolQ|CB|COPA|MultiRC|RTE|ReCoRD|WSC|WiC]: " -r task; \
	echo "Model: albert, Task: $$task"; \
	docker run --rm \
			   -v "$(shell pwd):/src" \
			   --gpus all \
		   	   torch-gpu-service:latest --model albert --task $$task
	# docker-compose -f torch-gpu.yaml run service --model albert --task $$task

run_all:
	docker run --rm \
			   -v "$(shell pwd):/src" \
			   --gpus all \
			   --entrypoint /src/run-all.sh \
		   	   torch-gpu-service:latest

run_it:
	docker run --rm -v "$(shell pwd):/src" --gpus all -it --entrypoint /bin/bash torch-gpu-service:latest
	# docker-compose -f torch-gpu.yaml run --rm -it --entrypoint /bin/bash service
