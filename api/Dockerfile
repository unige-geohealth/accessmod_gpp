FROM fredmoser/accessmod:5.8.3-alpha.1

RUN apk add --no-cache nodejs npm

# context = parent !
COPY helpers /helpers
COPY 04_travel_time /run
COPY api /api


WORKDIR /api
RUN npm install


VOLUME /data

EXPOSE 3000

CMD ["node", "app.js"]
