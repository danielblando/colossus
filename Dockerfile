FROM iojs:onbuild

RUN npm install

EXPOSE  5000

CMD ["iojs", "main.js"]