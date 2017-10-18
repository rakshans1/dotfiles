FROM ubuntu:16.04

RUN apt-get update && apt-get install -y git

RUN git clone https://github.com/rakshans1/dotfiles

RUN cd dotfiles && ./setup-new-machine.sh