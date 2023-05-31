ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2023.1.0.229.0
FROM $IMAGE

USER root

RUN apt-get update && apt-get install -y

# コンテナ内のワークディレクトリを /opt/try　に設定（後でここにデータベースを作成予定）
WORKDIR /opt/try
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/try

USER ${ISC_PACKAGE_MGRUSER}
COPY iris.script .
COPY Setup.cls .
COPY Flask Flask
COPY ISJFoods ISJFoods
COPY entrypoint.sh .

# run iris and initial 
RUN iris start IRIS \
    && iris session IRIS < iris.script \
    && iris stop IRIS quietly

ENV PYTHON_PATH=/usr/irissys/bin/irispython
#ENV PIP_PATH=/usr/irissys/bin/irispip
#ENV IRISUSERNAME "SuperUser"
#ENV IRISPASSWORD "SYS"
#ENV IRISNAMESPACE="USER"

#RUN ${PYTHON_PATH} -m pip install -r requirements.txt
RUN pip install -r /opt/try/Flask/requirements.txt

ENTRYPOINT [ "/tini", "--", "/opt/try/entrypoint.sh" ]