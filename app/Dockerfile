FROM alpine:latest

RUN apk update && apk upgrade
RUN apk add nodejs yarn

WORKDIR /app

COPY . .

# CMD ["node", "src/index.js"]
