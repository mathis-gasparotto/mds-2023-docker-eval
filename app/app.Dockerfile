FROM alpine:latest

RUN apk update && apk upgrade
RUN apk add nodejs yarn

WORKDIR /app

COPY . .

HEALTHCHECK --interval=1s --timeout=3s --retries=10 \
  CMD ping -c 1 127.0.0.1:3001

CMD ["yarn", "install", "&&", "yarn", "run", "dev"]