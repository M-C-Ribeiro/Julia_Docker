FROM ubuntu:latest

RUN apt-get update -y \
    && apt-get install -y sqlite3

CMD ["sqlite3"]
