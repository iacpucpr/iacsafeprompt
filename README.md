
# IaCSafePrompt - Em desenvolvimento

> Avaliação e mitigação de vulnerabilidades em Infraestrutura como Código (IaC) gerada por Large Language Models, por meio de um ciclo iterativo de crítica e refinamento (RCI) aplicado em três fases sequenciais.
![status](https://img.shields.io/badge/status-pesquisa%20em%20andamento-yellow)

Repositório de apoio à tese de doutorado *"Avaliação da Resiliência de Segurança de Código IaC Gerado por LLMs sob os Princípios de Zero Trust"* (PUCPR — Curitiba).

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

**Fase 1 — Geração.** LLMs de propósito geral (Grupo A) geram o código IaC a partir de um *prompt* estruturado, aplicando o RCI de forma homogênea — o próprio modelo atua sequencialmente como Gerador, Crítico e Refinador sobre sua própria saída. O resultado passa pela Avaliação Funcional (Sim / Parcialmente / Não), com limite de 3 iterações; esgotado o limite sem sucesso, a amostra é documentada como falha de geração e não avança.

**Fase 2 — Refinamento de Segurança.** O RCI é reaplicado sobre o conjunto dos cinco controles operacionais como um único artefato (não controle a controle), respeitando o mesmo limite de 3 iterações. Dois braços são comparados sobre o mesmo artefato gerado pelo Grupo A: o próprio Grupo A realizando autocrítica homogênea (grupo de controle) e o Grupo B, especializado em segurança defensiva, atuando exclusivamente como Crítico e Refinador. A saída passa pela Avaliação Humana de Segurança, que combina análise automatizada (Trivy, Checkov) com revisão manual sobre os cinco controles em conjunto — o que dispensa uma verificação de regressão dedicada, já que qualquer regressão introduzida por uma correção pontual é capturada na rodada seguinte. A complexidade da correção determina o encaminhamento: correções de baixa complexidade retornam diretamente à Avaliação Humana; correções de alta complexidade reencaminham o artefato ao ciclo RCI.

**Fase 3 — Validação Ofensiva.** O Grupo C, especializado em segurança ofensiva, gera vetores de ataque por controle sob o mesmo método RCI (agora orientado à quebra de cada controle), mapeados ao MITRE ATT&CK. A execução adota o paradigma *human-in-the-loop*: um operador humano conduz os passos sugeridos pela LLM, preservando controle e auditabilidade sobre o ambiente de teste. O ciclo encerra-se quando o vetor é executado com sucesso (controle quebrado) ou ao atingir-se o limite de 3 iterações (controle resistente).

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

## Instalação

```bash
git clone https://github.com/iacpucpr/iacsafeprompt.git
cd iacsafeprompt
pip install -r requirements.txt
```

## Uso

> Ajuste os comandos abaixo para os scripts reais do pipeline.

```bash
# Fase 1 — geração do baseline
python -m src.rci.fase1 --grupo A --controle all

# Fase 2 — refinamento de segurança (autocrítica do Grupo A ou crítica especializada do Grupo B)
python -m src.rci.fase2 --grupo B --max-iter 3

# Fase 3 — validação ofensiva (human-in-the-loop)
python -m src.rci.fase3 --grupo C --modo legacy
```

## Reprodutibilidade e versionamento

Cada execução é versionada individualmente, em um diretório próprio no padrão `amostras<id>`, registrando:

- identificador único da amostra;
- modelo utilizado e sua versão (fixada na data de acesso, dada a volatilidade das versões);
- parâmetros de inferência aplicados;
- código IaC extraído da resposta;
- valor de `S_i` atribuído a cada regra, com justificativa quando houver desempate humano;
- IAZT por controle e IAZT global;
- TMR calculada por controle.

## Autor

**Fellipe Medeiros Veiga**
