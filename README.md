
# IaCSafePrompt - Em desenvolvimento

> Avaliação de vulnerabilidades em Infraestrutura como Código (IaC) gerada por Large Language Models, por meio de um ciclo iterativo de crítica e refinamento (RCI) aplicado em três fases sequenciais.
![status](https://img.shields.io/badge/status-pesquisa%20em%20andamento-yellow)

Repositório de apoio à tese de doutorado *"Uma Abordagem de Avaliação de Segurança de Código IaC Gerado por LLMs"* (PUCPR — Curitiba).

---

## Sobre o projeto

Este repositório reúne o código, os *prompts*, os artefatos experimentais e os dados de execução do estudo que avalia a postura de segurança de código IaC (Terraform, Ansible, Docker Compose) gerado por LLMs de propósito geral e especializadas.


## Método

O pipeline é organizado em três fases sequenciais, cada uma aplicando o ciclo RCI com um propósito distinto:

```
 Fase 1                     Fase 2                          Fase 3
 Geração          ────▶     Refinamento de Segurança  ────▶  Validação Ofensiva
 (Grupo A)                  (Grupo A × Grupo B)              (Grupo C)
    │                             │                               │
 Avaliação                   Avaliação Humana                Ataques mapeados
 Funcional                   (Trivy + Checkov + humano)       ao MITRE ATT&CK
    │                             │                               │
    ▼                             ▼                               ▼
 código aprovado             IAZT (Índice de Aderência        TMR (Taxa de
                              Zero Trust)                      Mitigação de Riscos)
```

## Controles operacionais

Os cinco controles avaliados, mapeados ao CISA Zero Trust Maturity Model (ZTMM), ao modelo de ameaças STRIDE e ao MITRE ATT&CK:

| Controle | CISA ZTMM | Mitigação STRIDE | Táticas MITRE ATT&CK |
|---|---|---|---|
| 1. Gestão de Segredos | Dados; Cargas de Trabalho | Information Disclosure; Spoofing | T1552 |
| 2. Security Smells | Cargas de Trabalho | Tampering; DoS; Information Disclosure | T1190, T1083 |
| 3. Imagens Seguras | Cargas de Trabalho | Tampering | T1525 |
| 4. Privilégio Mínimo | Identidade; Cargas de Trabalho | Elevation of Privilege | T1078.004, T1611, T1083 |
| 5. Microsegmentação | Redes / Ambiente | Spoofing; Information Disclosure | mitiga impacto de T1190 |

## Grupos experimentais

| Grupo | LLMs representativas | Função | Fase de atuação |
|---|---|---|---|
| A | ChatGPT, DeepSeek | Geração + refinamento homogêneo (autocrítica, grupo de controle) | 1 e 2 |
| B | White Rabbit Neo, Blue Team AI | Refinamento especializado (Crítico e Refinador) | 2 |
| C | PentestGPT (modo `legacy`, interativo), VulnBot (Modo Manual) | Validação ofensiva | 3 |

> O Grupo C opera sob o paradigma *human-in-the-loop*: o PentestGPT é utilizado em seu modo interativo (`pentestgpt-legacy`), e o VulnBot em Modo Manual — ambos exigindo que o operador humano execute os comandos sugeridos e devolva os resultados ao sistema.

## Métricas

- **IAZT — Índice de Aderência Zero Trust** (estática). Por controle, é a razão entre as regras de segurança efetivamente atendidas (`S_i = 1`) e o total de regras aplicáveis àquele controle (`n_k`), expressa em percentual:

  ```
  IAZT(controle) = ( Σ S_i , i=1..n_k ) / n_k  × 100
  ```

  O **IAZT Global** é a média aritmética dos cinco índices por controle.

- **TMR — Taxa de Mitigação de Riscos** (dinâmica). Proporção de vetores de ataque que a arquitetura conseguiu neutralizar ou bloquear, em relação ao total de vetores executados na Fase 3:

  ```
  TMR = ( V_neutralizados / V_totais ) × 100
  ```

# Requisitos

> Versões:

- Python 3.x
- Terraform, Ansible
- [Trivy](https://github.com/aquasecurity/trivy) e [Checkov](https://github.com/bridgecrewio/checkov)
- Acesso às APIs/interfaces dos modelos de cada grupo (A, B e C)
- Docker / Docker Compose (ambiente de laboratório)

## Autor 

**Fellipe Medeiros Veiga** 
- Pontifícia Universidade Católica do Paraná
- Orientador: Altair Olivo Santin
- Co-orientador: Eduardo Kugler Viegas
