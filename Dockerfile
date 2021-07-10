FROM node:alpine
WORKDIR /home/app
COPY ./ ./
RUN npm install
CMD ["npm", "start"]