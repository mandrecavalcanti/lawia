# Start with NVIDIA CUDA base image
FROM nvidia/cuda:12.2.0-base-ubuntu22.04 AS base

# Set environment variables
# ENV PYTHONUNBUFFERED=1 \
#     DEBIAN_FRONTEND=noninteractive



# Definir variáveis de ambiente para evitar prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

# Atualizar pacotes e instalar Python 3.12 com dependências
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    sudo \
    nano \
    ca-certificates \
    libcurl4-openssl-dev \
    libssl-dev \
    libffi-dev \
    build-essential \
    tzdata

RUN apt-get install -y python3-setuptools

# 3. Adicionar o repositório de PPA 'deadsnakes' para versões mais recentes do Python
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update

RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata 

# 4. Instalar o Python 3.12 e outras dependências necessárias
RUN apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3-pip \
    python3-setuptools \
    && apt-get clean

RUN sudo apt-get install -y python3-setuptools

# 3. Adicionar alias ao ~/.bashrc
RUN echo "alias python=python3" >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# 4. Configurar Python 3.12 como a versão padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

RUN wget https://bootstrap.pypa.io/get-pip.py && python3.12 get-pip.py
RUN pip install --upgrade setuptools
RUN pip install wheel
RUN pip install torch torchvision torchaudio
RUN pip install --ignore-installed blinker
RUN pip install "Flask[async]"
RUN pip install numpy faiss-cpu python-docx PyPDF2 transformers accelerate sentence_transformers huggingface_hub  huggingface_hub[cli]

RUN apt-get install -y sudo nano git 
RUN apt-get clean 
RUN rm -rf /var/lib/apt/lists/*
RUN sudo apt-get update

# Define o diretório de trabalho
WORKDIR /app

# Cria um volume para montar o diretório local
# VOLUME /app

# Cria um link simbólico para o diretório
# RUN ln -s /opt/python /python

# Copiar o script de IA e modelo para o container
COPY ./main3.py /app
COPY ./embeddings.faiss /app
COPY ./metadata.pkl /app
COPY ./processos_antigos /app/processos_antigos
# COPY ./models /app/models

# Instalar dependências do projeto, se necessário
COPY ./requirements.txt /app
# RUN pip install -r requirements.txt

# Expor a porta necessária (por exemplo, 8080)
EXPOSE 8000

# Comando para rodar o container
# CMD ["python3", "main3.py"]
