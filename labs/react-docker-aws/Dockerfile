# # Build stage
# FROM node:20-alpine AS build
# WORKDIR /app
# COPY package.json ./
# RUN npm install
# COPY . .
# RUN npm run build

# # Serve stage
# FROM nginx:alpine
# COPY --from=build /app/dist /usr/share/nginx/html
# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]

# Stage 1 - Building the project
# 1 Selection of base Image - node:latest L-1
FROM node:latest AS build

# 2 Setting up the working directory L-2
WORKDIR /app

# 3 COPY package.json to /app L-3
COPY package.json ./

# 4 Inatallation of dependencies L-4
RUN npm install

# 5 Copying remainng project source code to container L-5
COPY . ./

# 6 Building the react project L-6
RUN npm run build

# Stage 2 - Serving the project to nginx / creation of react project image -> NGINX Container
# Selection of base Image - nginx:latest
FROM alpine:latest

# Copying project build assets to deployment folder in nginx
RUN apk update && apk add nginx

COPY .//nginx-config//default.conf /etc/nginx/http.d

COPY --from=build /app/dist /var/www/localhost/htdocs

# Exposing the app port
EXPOSE 80

# Entry of nginx server
CMD ["nginx", "-g", "daemon off;"]