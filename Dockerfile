# estágio de compilação
FROM node:14 as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build-pwa

# estágio de produção
FROM nginx:stable-alpine as production-stage
LABEL maintainer "Eduardo Donato <eduardo.donato at eletromarquez.com.br>"
COPY --from=build-stage /app/dist/pwa /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
