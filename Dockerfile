# --- Etapa 1: Construir el frontend (React)
# --- Etapa 1: Construir el frontend (React)
FROM node:18 AS frontend
WORKDIR /home/node/app
COPY ./excalidraw-app ./excalidraw-app
WORKDIR /home/node/app/excalidraw-app
RUN npm install
RUN npm run build:app:docker


# --- Etapa 2: Compilar el backend (Go)
FROM golang:alpine AS backend
RUN apk update && apk add --no-cache git
WORKDIR /app
COPY go.mod ./
RUN GOPROXY=direct go mod download
COPY . .

# Copiar el frontend generado al backend
COPY --from=frontend /home/node/app/excalidraw-app/build ./frontend

RUN GOPROXY=direct CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# --- Etapa 3: Imagen final para producción
FROM alpine
WORKDIR /root/
COPY --from=backend /app/main .
COPY --from=backend /app/frontend ./frontend
EXPOSE 8080
CMD ["./main", "--listen=0.0.0.0:8080"]
