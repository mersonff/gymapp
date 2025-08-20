# CI/CD Workflows

Este diretório contém os workflows de CI/CD para o projeto GymApp.

## Workflows Disponíveis

### 1. 🔍 Lint and Test (`lint-and-test.yml`)

**Triggers:**
- Push para branches `main` e `develop`
- Pull Requests para branches `main` e `develop`

**Jobs:**

#### Lint (RuboCop)
- 📝 Análise de estilo e qualidade de código
- ℹ️ **Informativo apenas** (não falha o build)
- 📊 Relatórios em JSON e HTML

#### Test (RSpec + Coverage)
- ✅ Executa todos os testes RSpec
- 📊 Gera relatório de cobertura de código
- 🎯 Verifica threshold mínimo de cobertura (80%)
- 📈 Comenta PRs com relatório de cobertura
- 📁 Upload de artifacts com relatórios

**Critérios de Falha:**
- Testes falhando
- Cobertura abaixo de 80%
- ℹ️ RuboCop não falha o build (informativo)

### 2. 🛡️ Security Scan (`security-scan.yml`)

**Triggers:**
- Push para branches `main` e `develop`
- Pull Requests para branches `main` e `develop`
- Scheduled: Diariamente às 2h UTC

**Jobs:**

#### Brakeman (Segurança)
- 🔍 Análise de segurança com Brakeman
- ⚠️ **Falha APENAS para issues críticos** (high confidence)
- 📊 Relatórios em JSON e HTML
- 💬 Comentários em PRs com resumo de segurança

**Critérios de Falha:**
- ❌ Apenas vulnerabilidades de segurança críticas (Brakeman)

## Configurações

### Cobertura de Código
- **Threshold mínimo:** 80%
- **Ferramenta:** SimpleCov
- **Formato:** HTML + JSON

### Segurança
- **Ferramenta:** Brakeman 6.1+
- **Nível crítico:** High confidence (confidence: 0)
- **Formatos:** JSON + HTML

### Qualidade de Código
- **Ferramenta:** RuboCop 1.60+
- **Configuração:** `.rubocop.yml`
- **Modo:** Informativo (não-bloqueante)

## Artifacts Gerados

Cada workflow gera artifacts que podem ser baixados:

### Lint and Test
- `rubocop-reports`: Relatórios JSON e HTML do RuboCop
- `test-results`: Resultados em formato JUnit XML
- `coverage-report`: Relatório HTML de cobertura

### Security Scan
- `brakeman-reports`: Relatórios JSON e HTML do Brakeman

## Como Usar

### 1. Push/PR Normal
Os workflows executam automaticamente em push ou PR.

### 2. Visualizar Relatórios
1. Vá para Actions tab no GitHub
2. Clique no workflow run
3. Baixe os artifacts
4. Abra os arquivos HTML para visualização

### 3. Corrigir Falhas

#### Falha de Teste
```bash
bundle exec rspec
# Corrija os testes falhando
```

#### Baixa Cobertura
```bash
COVERAGE=true bundle exec rspec
# Adicione mais testes para áreas não cobertas
```

#### Vulnerabilidades Críticas
```bash
bundle exec brakeman
# Corrija apenas issues de alta confiança
```

#### Issues de Estilo (RuboCop)
```bash
bundle exec rubocop -A  # Auto-corrige quando possível
bundle exec rubocop     # Lista issues restantes
```

## Dependências

### Ruby Version
- Ruby 3.3.6

### Gems Necessárias
```ruby
# Test group
gem 'rspec_junit_formatter', '~> 0.6', require: false
gem 'simplecov', require: false

# Development group  
gem 'rubocop', '~> 1.60', require: false
gem 'brakeman', '~> 6.1', require: false
```

### Sistema
- PostgreSQL 16
- jq (para parsing JSON)
- bc (para cálculos matemáticos)

## Troubleshooting

### Workflow não executa
- Verifique se o arquivo YAML está bem formatado
- Confirme que os triggers estão corretos

### Falha de dependências
- Verifique se todas as gems estão no Gemfile
- Confirme se bundle install está funcionando

### Database issues
- Verifique configuração do PostgreSQL no workflow
- Confirme se as migrações estão funcionando

### Timeout issues
- Workflows têm timeout padrão de 60 minutos
- Para testes longos, considere paralelização

## Melhorias Futuras

- [ ] Cache de dependências mais agressivo  
- [ ] Paralelização de testes
- [ ] Integração com ferramentas de análise externa
- [ ] Notificações Slack/Discord
- [ ] Deploy automático em staging