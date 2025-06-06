FROM croservices/cro-http:0.8.10
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN zef install --deps-only . && perl6 -c -Ilib service.raku
ENV RAKUWA_HOST="0.0.0.0" RAKUWA_PORT="10000"
EXPOSE 10000
CMD perl6 -Ilib service.raku
