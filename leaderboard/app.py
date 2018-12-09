import logging
import os

import asyncio
import aioredis
import uvicorn
from starlette.applications import Starlette
from starlette.middleware.gzip import GZipMiddleware
from starlette.responses import HTMLResponse, PlainTextResponse, RedirectResponse, UJSONResponse
from starlette.schemas import SchemaGenerator, OpenAPIResponse
from starlette.staticfiles import StaticFiles

logger = logging.getLogger()
logger.setLevel(logging.INFO)

loop = asyncio.get_event_loop()

editors = [
  'emacs',
  'vim',
  'vscode',
  'sublimetext',
]

app = Starlette(debug=('DEV' in os.environ), template_directory='templates')

app.schema_generator = SchemaGenerator(
    {"openapi": "3.0.0", "info": {"title": "Leaderboard", "version": "1.0"}}
)

app.template_env.auto_reload = 'DEV' in os.environ

app.mount('/static', StaticFiles(directory="static"))

redis = None

@app.on_event('startup')
async def create_pool():
  global redis

  redis = await aioredis.create_redis_pool(
    'redis://redis:3306',
    minsize=5,
    maxsize=10,
    loop=loop,
    encoding='utf-8')

@app.on_event('shutdown')
async def close_pool():
  redis.close()
  await redis.wait_closed()

@app.route('/')
async def index(request):
  return HTMLResponse(app.get_template('index.html').render(
    request=request,
    editors=editors,
    votes=await redis.hgetall('editors')))

@app.route('/vote')
async def get_board(request):
  return UJSONResponse({
    'status': 'ok',
    'users': await redis.hgetall('editors'),
  })

@app.route('/vote/{editor}/minus')
async def down_vote(request):
  editor = request.path_params.get('editor')
  val = await redis.hincrby('editors', editor, -1)
  if val < 0:
    await redis.hset('editors', editor, 0)
  return RedirectResponse(url='/')

@app.route('/vote/{editor}/plus')
async def up_vote(request):
  await redis.hincrby(
    'editors', request.path_params.get('editor'))
  return RedirectResponse(url='/')

# Swagger spec

@app.route("/schema", methods=["GET"], include_in_schema=False)
def schema(request):
    return OpenAPIResponse(app.schema)
