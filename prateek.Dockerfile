FROM python:3.9.1-slim-buster

RUN apt update && apt install -y \
		git \
		curl \
		sudo \
		zsh

SHELL ["/bin/zsh", "-c"]

RUN if ! getent passwd andy; then groupadd -g 1000 andy && useradd -u 1000 -g 1000 -d /home/andy -m -s /bin/bash andy; fi \
    && echo andy:andy | chpasswd \
    && echo 'andy ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /etc/sudoers.d \
    && echo 'andy ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/andy \
    && chmod 0440 /etc/sudoers.d/andy \
	&& apt-get autoremove \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

USER andy

RUN mkdir -p /home/andy/app \
    && mkdir -p /home/andy/data

ENV PATH="/home/andy/.local/bin:${PATH}"
RUN echo 'export PS1="$ "' >> /home/andy/.zshrc \
	&& echo 'PATH="/home/andy/.local/bin:${PATH}"' >> /home/andy/.zshrc

WORKDIR /home/andy/app
COPY . .

RUN pip install --user --upgrade pip \
    && pip install --user loguru pysnooper pytest pytest-cov pytest-bdd tox mypy pytest-mock pre-commit black

USER root
RUN pip install -e .

USER andy
RUN git config --global user.email "akmiles@icloud.com" \
	&& git config --global user.name "Andy Miles"
