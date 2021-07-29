import os

from pydantic import BaseModel
from fastapi import FastAPI
from typing import Optional, List
import httpx

ENDPOINT = os.environ.get('ENDPOINT')

class Entity(BaseModel):
    name: str
    type: Optional[str]
    value: str

class Recipient(BaseModel):
    email: str
    wechat: str
    fullname: str

class Item(BaseModel):
    name: str
    type: str
    value: Optional[str]
    recipient: Optional[Recipient]
    items: List[Entity]

app = FastAPI()

@app.get("/")
async def info():
    return {'version': 1, 'name': 'wechat broker'}

@app.post("/")
async def index(item: Item):
    message = ''

    message += f"**{item.name}** `{item.type}`\n"
    for i in item.items:
        message += f'><font color="comment">{i.name}</font>: {i.value}\n'

    if item.recipient:
        message += f'\n<@{item.recipient.wechat}>'

    payload = {"msgtype":"markdown","markdown":{"content": message}}

    if ENDPOINT:
        async with httpx.AsyncClient() as client:
            r = await client.post(ENDPOINT, json=payload)
            return r.text
    else:
        return payload


