# --- Etapa 1: Construir frontend
FROM node:20-alpine as frontend
WORKDIR /app
COPY ./excalidraw ./excalidraw
WORKDIR /app/excalidraw
RUN yarn install && yarn build

# --- Etapa 2: backend
FROM golang:1.21-alpine as backend
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
# Copiar el frontend generado
COPY --from=frontend /app/excalidraw/build ./static
RUN go build -o server .

# --- Etapa final
FROM alpine
WORKDIR /root/
COPY --from=backend /app/server .
COPY --from=backend /app/static ./static
EXPOSE 8080
CMD ["./server", "--listen=0.0.0.0:8080"]
