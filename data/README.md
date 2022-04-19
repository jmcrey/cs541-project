# FewGLUE
FewGLUE was developed by Timo Schick and Hinrich Schütze in the paper [It's Not Just Size That Matters: Small Language Models Are Also Few-Shot Learners](https://arxiv.org/abs/2009.07118). In their work, it is used to measure the effictiveness of the PET training procedure against GPT-3 priming on all the [SuperGLUE tasks](https://super.gluebenchmark.com/tasks/). The official repository of FewGlue can be found [here](https://github.com/timoschick/fewglue). All credit for development goes to the authors.

### Project
This project uses this dataset to replicate the results in the paper mentioned above. The structure is the same as the SuperGLUE data, but it is much smaller at 32 samples per task. The `train.jsonl` file contains all the training samples, while the `unlabeled.jsonl` contains all the unlabeled examples used for evaluation.

### Citation

FewGLUE was made public and used in the following paper:

    @article{schick2020small,
      title={It's Not Just Size That Matters: Small Language Models Are Also Few-Shot Learners},
      author={Timo Schick and Hinrich Schütze},
      journal={Computing Research Repository},
      volume={arXiv:2009.07118},
      url={http://arxiv.org/abs/2009.07118},
      year={2020}
    }
