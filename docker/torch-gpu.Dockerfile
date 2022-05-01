FROM pytorch/pytorch:1.8.0-cuda11.1-cudnn8-runtime

# Install the requirements
RUN pip install transformers==3.0.2 scikit-learn==0.23.1 jsonpickle==1.1


# Set workdir and expose port
WORKDIR /src

# Run the training
ENTRYPOINT [ "/src/run.sh" ]
CMD [ "-h" ]
