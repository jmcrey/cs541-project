# PET: Achieving Big Results with Small Language Models

This repository will host all the code for the CS541 Project, where I will mimic the results of the paper [It’s Not Just Size That Matters: Small Language Models Are Also Few-Shot Learners](https://aclanthology.org/2021.naacl-main.185/) by using the paper's [official repository](https://github.com/timoschick/pet). The goal of the paper is to show that smaller, more practical language models can achieve state-of-the-art (SOTA) results on text-classification tasks using few-shot learning. In this case, they introduce and expand their novel framework "Pattern-Exploiting Training" (PET) to achieve SOTA results on various text classification tasks using the smaller `albert-xxlarge-v2` model.

## Steps to Reproduce

1. Clone this repository: `git clone https://github.com/jmcrey/cs541-project.git`
2. Download the SuperGLUE evaluation and test datasets
    1. Visit the following site: https://super.gluebenchmark.com/tasks
    2. Click the "Download" button for each task
    3. Extract the files `test.jsonl` and `val.jsonl`
    4. Place those files in the corresponding data folder
        - For example, for CommitmentBank (CB), extract `val.jsonl` and `test.jsonl` and place it in the `data/cb/` folder.
3. Clean out the `output/albert/{task}` folder
    - The folders for each task have to be empty for the script to run properly. Simply delete the contents of each task's folder so that it is empty. For example, delete the contents of `output/albert/boolq/`
    - If you do not clear a folder, the script will fail and output an error suggesting to clear its contents.
4. Download docker and ensure that it is running: https://docs.docker.com/get-docker/
    - You must also ensure that GPU support in Docker is enabled. Please consult the appropriate documentation for how to configure this in your environment. You can try following [this article](https://towardsdatascience.com/how-to-properly-use-the-gpu-within-a-docker-container-4c699c78c6d1) for some help.
5. Build the docker image: `make build`
6. Run the tasks
    1. `make run` and follow the prompt
    2. Do this for all of the 8 tasks and wait for the output to complete

### Notes

#### Run All

There is a `make run_all` command that should run all the tasks in one go, but this is largely untested so it may not work as expected. Specifically, I was enountering an issue where the first task would use the GPU but none of the subsequent tasks would.

#### GPT-3

There is an option to run the script using GPT-3 and priming, but I was not able to test this due to time constraints. Note that the GPT-3 image referenced in this repository **is not the official image**. It is an image posted on [HuggingFace](https://huggingface.co/Nicki/gpt3-base) and results should be interpreted with skepticism. 

In order to run using GPT-3 with priming, run the following command:

```
docker run --rm \
    -v "$(shell pwd):/src" \
    --gpus all \
    torch-gpu-service:latest --model gpt3 --task {task-name}
```
