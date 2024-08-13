FROM --platform=arm64 crystallang/crystal:latest as builder

WORKDIR /build
RUN apt update && apt upgrade -y
RUN apt install -y libsqlite3-dev
COPY . .
RUN shards install
RUN shards build api --static

FROM --platform=arm64 crystallang/crystal:latest

WORKDIR /app
COPY --from=builder /build/bin/api /app/api 
COPY --from=builder /build/database.db /app/database.db
CMD [ "/app/api" ]