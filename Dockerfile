FROM gcr.io/deeplearning-platform-release/r-cpu

# install dependencies
RUN apt-get update && \
    apt-get install -y \
        autoconf \
        automake \
        g++ \
        gcc \
        cmake \
        gfortran \
        make \
        nano \
        liblapack-dev \
        liblapack3 \
        libopenblas-base \
        libopenblas-dev \
        python3 \
        python3-pip \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile 
RUN Rscript -e "install.packages('remotes');"
RUN Rscript -e "remotes::install_github('facebookexperimental/Robyn/R');"
RUN Rscript -e "install.packages('reticulate');"
RUN Rscript -e "library(reticulate)"
RUN Rscript -e "reticulate::use_python('/usr/bin/python3')"
RUN Rscript -e "reticulate::py_config()"
RUN Rscript -e "reticulate::py_install('nevergrad', pip = TRUE)"
RUN Rscript -e "install.packages('bigrquery');"

# install JupyterLab and necessary extensions
RUN pip3 install jupyterlab
RUN jupyter serverextension enable --py jupyterlab --sys-prefix
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter labextension install @jupyterlab/toc

WORKDIR /root
EXPOSE 8888
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--no-browser"]
