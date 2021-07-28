import os
import json
import yaml
import datetime
from json import JSONEncoder

from pydantic import BaseModel
from fastapi import Request, FastAPI, responses
from typing import Optional, List
import httpx

ENDPOINT = os.environ.get('NOTIFY_GATEWAY')
CLUSTER = os.environ.get('CLUSTER')

class ManagedFields(BaseModel):
    manager: str
    operation: str
    apiVersion: str
    time: str

class MetaData(BaseModel):
    name: str
    namespace: str
    uid: str
    resourceVersion: str
    creationTimestamp: str
    ManagedFields: List[ManagedFields]

class Source(BaseModel):
    component: str
    host: Optional[str]

class InvolvedObject(BaseModel):
    kind: str
    namespace: str
    name: str
    uid: str
    apiVersion: str
    resourceVersion: str
    fieldPath: Optional[str]
    labels: Optional[dict]

class Item(BaseModel):
    metadata: MetaData
    reason: str
    message: str
    source: Source
    firstTimestamp: datetime.datetime
    lastTimestamp: datetime.datetime
    count: int
    type: str
    eventTime: Optional[str]
    reportingComponent: str
    reportingInstance: str
    involvedObject: InvolvedObject


app = FastAPI()


@app.get("/")
async def info():
    return {'version': 1, 'name': 'watch aggregator'}

@app.post('/dump')
async def dump(req: Request):
    r = await req.json()
    print(r)
    return r

@app.post("/")
async def index(item: Request):
    body = await item.json()
    reason = body.get('reason')
    ob = body.get('involvedObject')
    name = ob.get('name')
    namespace = ob.get('namespace')

    if not (reason and reason == 'Started') :
        return responses.JSONResponse(status_code=404, content={"message": "event is not started"})

    kind = ob.get('kind')
    if not (kind and kind == 'Pod') :
        return responses.JSONResponse(status_code=404, content={"message": "event is not pod"})

    labels = ob.get('labels')

    if not (labels and labels.get('ci.argo/kubectl')):
        return responses.JSONResponse(status_code=404, content={"message": "pod is not ci govern"})

    msg = {
      'type': "ci",
      'name': "容器已启动",
      'recipient': None,
      'items': [
            {'name': "集群", 'value': CLUSTER},
            {'name': "名称空间", 'value': namespace},
            {'name': "容器", 'value': name},
      ]
    }

    print(labels)
    for i in ['component', 'instance', 'name', 'stage']:
        v = labels.get(f'app.kubernetes.io/{i}')
        if v:
            msg['items'].append({'name': i, 'value': v})

    if ENDPOINT:
        async with httpx.AsyncClient() as client:
            r = await client.post(ENDPOINT, json=msg)
            return r.text
    else:
        return msg

