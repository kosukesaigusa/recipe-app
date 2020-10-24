FROM ubuntu:latest

WORKDIR /workdir

# apt を最新にして sudo, curl コマンドをインストール
RUN apt-get -y update && apt-get install -y sudo curl

# Java の環境のインストール
RUN apt-get install -y openjdk-8-jdk

# Firebase CLI のインストール
RUN curl -sL "https://firebase.tools" | bash

# Node.js と npm のインストール
RUN apt install -y nodejs npm

# エミュレータの設定
ENV HOST 0.0.0.0
EXPOSE 4000
EXPOSE 5001
EXPOSE 8080

# Firebase ログインに必要なポート
EXPOSE 9005