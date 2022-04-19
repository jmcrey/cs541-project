FROM pytorch/pytorch:1.5-cuda10.1-cudnn7-runtime

# Install the requirements
RUN pip install transformers==3.0.2 && \
    conda install -c conda-forge numpy==1.19 jsonpickle==1.1 scikit-learn==0.23.1 tqdm==4.48.1


# Set workdir and expose port
WORKDIR /src

# Run the training
ENTRYPOINT [ "/src/run.sh" ]
CMD [ "-h" ]
