
# GymAPP

Sistema de gestão para academias, com controle de clientes, planos, pagamentos, avaliações físicas e relatórios.

---

## Como era antes

- Layout simples, pouco responsivo e sem padronização visual
- Formulários sem design, sem agrupamento de campos e sem feedback visual
- Botões de exclusão e ações importantes sem confirmação ou feedback
- Toasts pouco visíveis e sem animação
- Navegação redundante (logout e usuário em vários lugares)
- Gráficos só funcionavam com refresh manual
- Listagens sem ordenação clara
- Falta de interatividade e visualização dos dados corporais

## Como está agora

- Layout moderno com Tailwind CSS, responsivo e com identidade visual consistente
- Formulários redesenhados, agrupados por seções, com ícones, placeholders e feedback visual
- Toasts de sucesso/erro visíveis, animados e com cores distintas
- Botões de exclusão e logout com confirmação Turbo e feedback imediato
- Navegação lateral única, com perfil e logout integrados
- Gráficos (Chart.js) funcionam perfeitamente com navegação Turbo (SPA)
- Listagens ordenadas por data de adição/atualização
- Visualização interativa de dobras cutâneas (SVG proporcional)
- UX aprimorada em todas as telas principais
- Código preparado para Hotwire/Turbo

## Como rodar o projeto

1. Instale as dependências:
   ```bash
   bundle install
   yarn install # se usar JS/CSS moderno
   ```
2. Configure o banco:
   ```bash
   rails db:setup
   ```
3. Rode o servidor:
   ```bash
   rails server
   ```
4. Acesse em http://localhost:3000

## Próximos passos

- Migrar todas as interações para Hotwire (Turbo Frames/Streams, Stimulus)
- Cobertura de testes automatizados (modelos, controllers, sistema)
- Melhorar feedback em tempo real (ex: pagamentos, avaliações)
- Refino de acessibilidade e responsividade
- Adicionar gateway de pagamento para gerenciar assinaturas (visando modelo SAAS)

---

Para dúvidas ou sugestões, abra uma issue ou entre em contato!
