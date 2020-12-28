FROM python:3.9-slim-buster

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
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /app \
    && chown -R andy /app \
    && mkdir /data \
    && chown -R andy /data

USER andy

ENV PATH="/home/andy/.local/bin::${PATH}"
RUN echo 'EXPORT PS1="$ "' >> /home/andy/.zshrc \
	&& echo 'PATH="/home/andy/.local/bin:${PATH}"' >> /home/andy/.zshrc

WORKDIR /app
COPY . .
RUN git config --global user.email "akmiles@icloud.com" \
	&& git config --global user.name "Andy Miles"

RUN python -m pip install --user --upgrade pip
RUN python -m pip install --user loguru pysnooper pytest pytest-cov pytest-bdd tox mypy pytest-mock pre-commit black

USER root
RUN chown -R andy /app

USER andy
RUN python -m pip install --user -e .
