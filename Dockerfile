FROM rakudo-star:latest

# Instala bibliotecas del sistema, ¡incluyendo las herramientas de compilación!
RUN apt-get update && apt-get install -y \
    libssl-dev \
    default-libmysqlclient-dev \
    build-essential \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Crea y establece directorio de trabajo
WORKDIR /app

# Copia tu aplicación
COPY . /app

# Instala módulos Raku uno por uno
# Esto ayuda a aislar cualquier fallo en la instalación
RUN zef install --/test Cro
RUN zef install --/test Cro::HTTP
RUN zef install --/test Cro::HTTP::Log::File
RUN zef install --/test Cro::HTTP::Server
RUN zef install --/test Cro::HTTP::Router
RUN zef install --/test 'Template6:ver<0.16.0>:auth<zef:davidromero55>'
RUN zef install --/test DB::MySQL
RUN zef install --/test Cro::HTTP::Auth
RUN zef install --/test JSON::Class
RUN zef install --/test Cro::HTTP::Session::MySQL
RUN zef install --/test HTML::Escape
RUN zef install --/test Digest::SHA256::Native
RUN zef install --/test DB::SQLite
RUN zef install --/test Cro::HTTP::Session::SQLite

# Instala las dependencias de prueba
RUN zef install --deps-only --/test Test::More Test::Harness

ENV RAKUWA_HOST="0.0.0.0" RAKUWA_PORT="5555"
EXPOSE 5555

ENV RAKULIB=/app/lib
CMD ["raku", "service.raku"]


