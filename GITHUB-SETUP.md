# Guia de Setup do GitHub

## Repositório Git criado com sucesso!

O repositório local está pronto. Agora você precisa conectá-lo ao GitHub.

## Opção 1: Criar Repositório no GitHub via Interface Web

### Passo 1: Criar Repositório no GitHub
1. Acesse https://github.com/new
2. Preencha os dados:
   - **Repository name**: `desafio-devops` (ou outro nome de sua preferência)
   - **Description**: `Desafio DevOps - Infraestrutura com Docker, Kubernetes e Terraform`
   - **Visibility**: Public ou Private (sua escolha)
   - **NÃO** marque "Initialize this repository with:"
     - ❌ NÃO adicione README
     - ❌ NÃO adicione .gitignore
     - ❌ NÃO adicione license
3. Clique em "Create repository"

### Passo 2: Conectar Repositório Local ao GitHub

Após criar o repositório, o GitHub mostrará instruções. Use os comandos abaixo:

```bash
# Adicionar o remote (substitua SEU_USUARIO pelo seu username do GitHub)
git remote add origin https://github.com/SEU_USUARIO/desafio-devops.git

# Fazer push do código
git push -u origin main
```

**Exemplo com SSH (se você usa chave SSH):**
```bash
git remote add origin git@github.com:SEU_USUARIO/desafio-devops.git
git push -u origin main
```

### Passo 3: Verificar
Acesse seu repositório no GitHub e verifique se os arquivos foram enviados!

## Opção 2: Criar Repositório via GitHub CLI (gh)

Se você tem o GitHub CLI instalado:

```bash
# Criar repositório público
gh repo create desafio-devops --public --source=. --remote=origin --push

# OU criar repositório privado
gh repo create desafio-devops --private --source=. --remote=origin --push
```

## Opção 3: Comandos Rápidos (após criar no GitHub)

Substitua `SEU_USUARIO` pelo seu username:

```bash
# HTTPS
git remote add origin https://github.com/SEU_USUARIO/desafio-devops.git
git push -u origin main

# SSH
git remote add origin git@github.com:SEU_USUARIO/desafio-devops.git
git push -u origin main
```

## Status Atual do Repositório

```
✅ Git inicializado
✅ Branch main criada
✅ 30 arquivos commitados
✅ Commit inicial criado
⏳ Aguardando conexão com GitHub
```

## Verificar Status

```bash
# Ver commits
git log --oneline

# Ver arquivos commitados
git ls-files

# Ver remotes configurados
git remote -v
```

## Comandos Úteis Após Push

```bash
# Ver repositório no browser
gh repo view --web

# Clonar em outro lugar
git clone https://github.com/SEU_USUARIO/desafio-devops.git

# Verificar branches
git branch -a

# Ver histórico completo
git log
```

## Próximos Passos (Opcional)

### 1. Adicionar Topics no GitHub
Na página do repositório:
- Settings → Topics
- Adicionar: `devops`, `docker`, `kubernetes`, `terraform`, `k3d`, `nodejs`, `infrastructure-as-code`

### 2. Adicionar Description
- Edit repository details
- Description: `Desafio DevOps - Infraestrutura com Docker, Kubernetes e Terraform`
- Website: (deixar em branco ou adicionar URL se houver)

### 3. Criar GitHub Pages (Opcional)
Se quiser hospedar a documentação:
- Settings → Pages
- Source: Deploy from a branch
- Branch: main / root
- Save

### 4. Adicionar Badges ao README
Você pode adicionar badges para deixar o README mais atraente:

```markdown
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
```

## Problemas Comuns

### Erro: "remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/SEU_USUARIO/desafio-devops.git
```

### Erro de autenticação
- HTTPS: Use Personal Access Token ao invés de senha
- SSH: Configure chave SSH (https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

### Erro: "Updates were rejected"
```bash
# Força push (cuidado, use apenas no primeiro push)
git push -u origin main --force
```

## Estrutura do Repositório no GitHub

Após o push, seu repositório terá:

```
desafio-devops/
├── README.md                  ← Aparece automaticamente na página principal
├── QUICKSTART.md
├── ARCHITECTURE.md
├── TESTING.md
├── PROJECT-SUMMARY.md
├── GITHUB-SETUP.md
├── Makefile
├── .gitignore
├── backend/
├── frontend/
├── terraform/
├── k8s/
└── scripts/
```

O GitHub automaticamente renderizará o README.md na página principal do repositório!

## Dicas Finais

1. O README.md será exibido automaticamente na página do repositório
2. Adicione uma licença se quiser (MIT é comum para projetos open source)
3. Configure branch protection rules se quiser (Settings → Branches)
4. Adicione colaboradores se necessário (Settings → Collaborators)

## Pronto!

Depois de seguir estes passos, seu código estará disponível no GitHub e você poderá compartilhar o link do repositório!
