# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Comandos de Build

### Configuração Inicial
```bash
# Configurar o ambiente de desenvolvimento
bin/setup
```

### Desenvolvimento
```bash
# Iniciar o servidor de desenvolvimento (Rails + Tailwind CSS watch)
bin/dev

# Iniciar apenas o servidor Rails
bin/rails server

# Observar mudanças no Tailwind CSS
bin/rails tailwindcss:watch
```

### Assets
```bash
# Compilar assets para produção
bin/rails assets:precompile

# Compilar Tailwind CSS
bin/rails tailwindcss:build

# Limpar assets compilados
bin/rails assets:clean
bin/rails assets:clobber

# Limpar arquivos CSS do Tailwind
bin/rails tailwindcss:clobber
```

### Database
```bash
# Preparar o banco de dados
bin/rails db:prepare

# Executar migrações
bin/rails db:migrate

# Criar o banco de dados
bin/rails db:create

# Resetar o banco de dados
bin/rails db:reset
```

### Testes
```bash
# Executar todos os testes
bin/rails test

# Executar testes específicos
bin/rails test test/models/
bin/rails test test/controllers/
```

### Outras Ferramentas
```bash
# Análise de código com RuboCop
bin/rubocop

# Análise de segurança com Brakeman
bin/brakeman

# Importar mapas de importação
bin/importmap
```
