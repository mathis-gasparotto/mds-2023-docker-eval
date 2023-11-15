FROM alpine:latest

RUN apk update && apk upgrade
RUN apk add nodejs yarn
RUN apk add sqlite

WORKDIR /app

COPY . .

CMD ["yarn", "install", "&&", "yarn", "run", "dev"]