# Redundância de Dados Híbrida: SQL Server On-Premises → Azure Data Lake
### Azure Data Factory • Self-hosted Integration Runtime • DataOps • Continuidade de Negócio

![Azure_Databricks01](https://github.com/user-attachments/assets/8ddea732-e045-4694-9207-87aeb9403938)

**Bootcamp Microsoft AI for Tech — Azure Databricks**

---

## 1. Problema de Negócio

Organizações que operam sistemas legados críticos — bancos, seguradoras, setor público — enfrentam um risco que raramente aparece nos documentos de governança, mas aparece nas falhas de madrugada: **dados armazenados exclusivamente on-premises não têm redundância geográfica**.

Um banco de dados SQL Server local não tem failover automático para a nuvem. Quando o servidor falha, os dados ficam indisponíveis. Quando o storage físico é corrompido, não há replay possível. Quando um auditor solicita o estado dos dados em uma data específica, não há histórico versionado para apresentar.

O problema real não é técnico — é de continuidade de negócio. E em ambientes regulados, a ausência de um plano de redundância documentado é, por si só, uma não-conformidade.

---

## 2. Contexto

Com 15 anos de experiência em sistemas críticos bancários (Bradesco), projetei este fluxo a partir de um cenário que é padrão em grandes corporações: **dados legados precisam chegar à nuvem sem expor a infraestrutura interna**.

Não é possível abrir o SQL Server para a internet. Firewalls corporativos bloqueiam conexões de entrada. Políticas de segurança proíbem credenciais em texto plano. E mesmo assim, os dados precisam chegar ao Azure Data Lake todos os dias, com rastreabilidade completa e sem intervenção humana.

A solução usa Azure Data Factory com Self-hosted Integration Runtime (SHIR) — o padrão corporativo para esse tipo de integração — e estrutura os dados em camadas Raw e Bronze, preservando o dado original para auditoria e preparando uma cópia organizada para consumo analítico.

O pipeline executa diariamente às 02:00 BRT via trigger agendado, é parametrizado por tabela e data de execução, e toda credencial transita exclusivamente pelo Azure Key Vault.

---

## 3. Premissas da Análise

As seguintes premissas foram adotadas para o desenho desta solução:

- O **SHIR é instalado em uma máquina dedicada on-premises** com acesso direto ao SQL Server e saída HTTPS para o Azure — sem abertura de portas de entrada no firewall
- A **camada Raw preserva o dado original sem transformação**, garantindo que qualquer replay ou auditoria possa reconstruir o estado exato dos dados em qualquer data de execução
- A **camada Bronze aplica limpeza mínima** (remoção de nulos via PySpark), suficiente para consumo analítico sem distorcer o dado original
- **Credenciais nunca são hardcoded**: a chave do ADLS é gerenciada exclusivamente pelo Azure Key Vault, referenciada via `LS_KeyVault` nos linked services
- O **formato TXT/CSV na ingestão** é uma escolha deliberada de fidelidade ao dado original; transformações para formatos analíticos (Parquet, Delta) são responsabilidade das camadas posteriores no Databricks
- O pipeline é **parametrizado** (`pTabela`, `pDataExecucao`), permitindo reuso para múltiplas tabelas sem duplicação de artefatos

---

## 4. Estratégia da Solução

A solução foi construída em três camadas que se complementam:

**Camada 1 — Integração Híbrida Segura (ADF + SHIR)**

O Self-hosted Integration Runtime cria um canal de comunicação de dentro para fora: a máquina on-premises se registra no ADF usando uma chave de autenticação, estabelece um túnel HTTPS para o Azure e passa a servir como agente de extração. Nenhuma porta de entrada é aberta no firewall corporativo.

O linked service `LS_SQL_OnPrem` conecta ao SQL Server via SHIR. O linked service `LS_ADLS` conecta ao Data Lake com a chave de conta recuperada dinamicamente do `LS_KeyVault`. As credenciais nunca aparecem nos artefatos versionados.

**Camada 2 — Pipeline Parametrizado com Dupla Ingestão (Raw → Bronze)**

O pipeline `pl_redundancia_sql_to_datalake` executa duas atividades Copy em sequência:

1. `Copy_SQL_to_ADLS_RAW`: extrai a tabela do SQL Server e grava em `raw/sql_onprem/<pTabela>/<pTabela>_<pDataExecucao>.txt` — dado bruto, sem transformação, com header
2. `Copy_RAW_to_BRONZE`: promove o arquivo Raw para `bronze/sql_onprem/<pTabela>/` — mesma estrutura, mesmo formato, garantindo que a camada Bronze seja sempre derivada da Raw

O uso de parâmetros (`pTabela`, `pDataExecucao`) permite que o mesmo pipeline sirva qualquer tabela do banco, sem duplicação de artefatos.

**Camada 3 — Promoção Analítica com PySpark (Databricks)**

O notebook `bronze_promote_<tabela>.ipynb` lê os arquivos CSV da camada Raw via protocolo ABFSS, aplica limpeza básica com `dropna()` e grava o resultado na camada Bronze. O cluster `redundancia-cluster` (Spark 11.3, 2 workers `Standard_DS3_v2`, auto-termination em 30 min) é dimensionado para o volume típico de uma operação de redundância diária.

---

## 5. Insights do Projeto

A implementação evidenciou decisões técnicas que não são óbvias para quem projeta do zero:

**Por que SHIR e não Azure Integration Runtime padrão?**
O IR padrão do Azure só funciona com fontes acessíveis pela internet pública. SQL Server on-premises, protegido por firewall corporativo, exige um agente local que inicie a conexão de dentro para fora. O SHIR é esse agente. Não há alternativa nativa para esse cenário.

**Por que duas atividades Copy no mesmo pipeline em vez de um pipeline Databricks direto?**
Separar a ingestão Raw da promoção Bronze preserva o dado original de forma independente do processamento posterior. Se o notebook Databricks falhar ou introduzir um bug de transformação, o dado Raw permanece íntegro para reprocessamento. Essa separação é um requisito de auditoria em ambientes regulados.

**Por que TXT/CSV e não Parquet direto na ingestão?**
Parquet é o formato ideal para consumo analítico, mas é binário — não auditável diretamente. CSV preserva fidelidade ao dado original e permite inspeção manual em caso de incidente. A conversão para Parquet ou Delta é uma decisão da camada de transformação, não da camada de ingestão.

**Por que parametrizar por `pTabela` e `pDataExecucao`?**
Um pipeline por tabela é inescalável. A parametrização permite que o mesmo artefato sirva toda a base sem duplicação, e garante que o nome do arquivo carregue a data de execução — criando um histórico versionado de snapshots por data no Data Lake.

**O `run_metadata_example.json` como evidência de BCP**
Em ambientes regulados, não basta executar com sucesso — é preciso provar que executou. O metadata de execução registra `executionId`, `startTime`, `endTime`, `status`, `rowsCopied`, `source` e `sink`. Esse registro é a evidência que um auditor ou comitê de riscos solicita em uma revisão de Continuidade de Negócio.

---

## 6. Resultados

Este projeto entrega uma arquitetura de redundância de dados híbrida completamente operacional, com:

- **Ingestão segura** de SQL Server on-premises para Azure Data Lake, sem exposição da infraestrutura interna
- **Dupla camada de armazenamento** (Raw + Bronze) com rastreabilidade completa e capacidade de replay por data de execução
- **Automação diária às 02:00 BRT** via trigger agendado, sem intervenção humana
- **Governança de credenciais** centralizada no Azure Key Vault, com zero segredos em código ou artefatos versionados
- **Evidências operacionais** via metadata de execução, atendendo requisitos de auditoria e BCP em ambientes regulados
- **Base extensível** para Incremental Load (Delta), integração com Microsoft Purview e CI/CD para artefatos ADF

Do ponto de vista de portfólio, o projeto demonstra capacidade de projetar uma solução que resolve um problema corporativo real, com as restrições e requisitos de um ambiente de missão crítica — não apenas usar ferramentas Azure em um cenário simplificado.

---

## 7. Próximos Passos

- Implementar **Incremental Load com Delta Lake**, substituindo a carga full diária por ingestão apenas das alterações (CDC)
- Integrar com **Microsoft Purview** para catalogação automática dos ativos de dados e linhagem visual Raw → Bronze
- Criar **CI/CD para artefatos ADF com Azure DevOps**, versionando e validando automaticamente pipelines, datasets e linked services
- Adicionar **testes de qualidade de dados** na promoção Bronze (contagem de linhas, validação de schema, alertas por limiar)
- Evoluir o cluster Databricks para **processamento em Parquet com particionamento por data**, preparando a camada Bronze para consumo em Synapse Analytics ou Power BI

---

## Estrutura do Repositório

```
processoRedundanciaArqAzure/
│
├── adf/
│   ├── datasets/
│   │   ├── DS_ADLS_RAW_TXT.json          # Dataset de destino — camada Raw no ADLS Gen2
│   │   ├── DS_ADLS_BRONZE_TXT.json       # Dataset de destino — camada Bronze no ADLS Gen2
│   │   └── DS_SQL_OnPrem_<Tabela>.json   # Dataset de origem — tabela SQL Server on-premises
│   │
│   ├── linkedServices/
│   │   ├── LS_SQL_OnPrem.json            # Linked service SQL Server via Self-hosted IR
│   │   ├── LS_ADLS.json                  # Linked service Azure Data Lake (chave via Key Vault)
│   │   └── LS_KeyVault.json              # Linked service Azure Key Vault
│   │
│   ├── pipelines/
│   │   └── pl_redundancia_sql_to_datalake.json  # Pipeline principal: Copy Raw + Copy Bronze
│   │
│   └── triggers/
│       └── tr_daily_0200_brt.json        # Trigger agendado — execução diária às 02:00 BRT
│
├── databricks/
│   ├── configs/
│   │   └── cluster_config.json           # Configuração do cluster Spark (2 workers, DS3_v2)
│   └── notebooks/
│       └── bronze_promote_<tabela>.ipynb # Notebook PySpark: Raw → Bronze com limpeza básica
│
├── docs/
│   └── guia_instalacao_ir.md             # Guia completo de instalação e configuração do SHIR
│
├── scripts/
│   ├── powershell/
│   │   └── install_self_hosted_ir.ps1    # Script PowerShell para instalação automatizada do IR
│   └── sql/
│       └── create_sample_table.sql       # Script DDL/DML para criar e popular tabela de exemplo
│
├── logs/
│   └── samples/
│       └── run_metadata_example.json     # Exemplo real de metadata de execução do pipeline
│
└── README.md
```

---

## Descrição das Pastas e Arquivos

| Arquivo / Pasta | Função |
|---|---|
| `adf/datasets/DS_ADLS_RAW_TXT.json` | Define o destino Raw no ADLS Gen2. O caminho é dinâmico: `raw/sql_onprem/<pTabela>/<pTabela>_<pDataExecucao>.txt`. Formato DelimitedText com header, separador vírgula. Cada execução gera um arquivo datado — histórico versionado de snapshots. |
| `adf/datasets/DS_ADLS_BRONZE_TXT.json` | Define o destino Bronze no ADLS Gen2. Estrutura idêntica ao Raw, mas gravado em `bronze/sql_onprem/<pTabela>/`. A camada Bronze é sempre derivada da Raw — nunca alimentada diretamente pela fonte on-premises. |
| `adf/datasets/DS_SQL_OnPrem_<Tabela>.json` | Dataset de origem. Aponta para o SQL Server on-premises via `LS_SQL_OnPrem`. A tabela-alvo é parametrizada (`@{pipeline().parameters.pTabela}`), permitindo reuso para qualquer tabela do banco sem criar novos datasets. |
| `adf/linkedServices/LS_SQL_OnPrem.json` | Conexão com o SQL Server local. Usa `connectVia: SelfHostedIR` — o tráfego passa pelo agente SHIR instalado on-premises, sem exposição do banco à internet. |
| `adf/linkedServices/LS_ADLS.json` | Conexão com o Azure Data Lake Storage Gen2. A chave de conta é recuperada dinamicamente do Key Vault via `LS_KeyVault` — nunca exposta nos artefatos versionados. |
| `adf/linkedServices/LS_KeyVault.json` | Conexão com o Azure Key Vault. Serve como cofre de credenciais para todos os outros linked services. Centraliza a gestão de segredos e garante conformidade com políticas de segurança corporativas. |
| `adf/pipelines/pl_redundancia_sql_to_datalake.json` | Pipeline principal. Executa duas atividades Copy em sequência: `Copy_SQL_to_ADLS_RAW` (extração) e `Copy_RAW_to_BRONZE` (promoção). Parametrizado por `pTabela` e `pDataExecucao`, reutilizável para qualquer tabela. |
| `adf/triggers/tr_daily_0200_brt.json` | Trigger do tipo `ScheduleTrigger` com recorrência diária. Executa às 02:00 no fuso horário de Brasília (`E. South America Standard Time`). Passa `pDataExecucao: @{utcnow()}` automaticamente para o pipeline. |
| `databricks/configs/cluster_config.json` | Configuração do cluster Spark: versão 11.3.x-scala2.12, 2 workers `Standard_DS3_v2`, auto-termination em 30 minutos. Dimensionado para o volume típico de uma operação de redundância diária, evitando custo de cluster ocioso. |
| `databricks/notebooks/bronze_promote_<tabela>.ipynb` | Notebook PySpark para promoção Raw → Bronze. Lê CSV via protocolo ABFSS, aplica `dropna()` para remover registros nulos e grava o resultado em `bronze/`. Serve como template para qualquer tabela do projeto. |
| `docs/guia_instalacao_ir.md` | Guia passo a passo para instalação e configuração do Self-hosted Integration Runtime: requisitos de hardware/software, download, registro com chave de autenticação, configuração de firewall e teste de conectividade. |
| `scripts/powershell/install_self_hosted_ir.ps1` | Script PowerShell que automatiza o download e instalação silenciosa do IR (`/quiet /qn`). Reduz o tempo de setup em novos ambientes e elimina erros manuais no processo de instalação. |
| `scripts/sql/create_sample_table.sql` | DDL e DML de exemplo: cria a tabela `SampleTable` com colunas `Id`, `Nome`, `Email`, `DataCriacao` e insere 3 registros de teste. Permite reproduzir o ambiente de origem sem dependência de dados reais. |
| `logs/samples/run_metadata_example.json` | Exemplo real de metadata de execução: `pipelineName`, `executionId`, `startTime`, `endTime`, `status`, `rowsCopied`, `source` e `sink`. Evidência operacional para auditoria regulatória e validação de SLA de BCP. |

---

## Requisitos de Hardware e Software

### Hardware — Máquina On-Premises (Host do SHIR)

| Recurso | Mínimo | Recomendado |
|---|---|---|
| Sistema Operacional | Windows 10 / Windows Server 2016+ | Windows Server 2019+ |
| CPU | 2 vCPUs | 4 vCPUs |
| RAM | 4 GB | 8 GB |
| Disco | 2 GB livres (instalação IR) | 10 GB+ (buffer para logs e dados temporários) |
| Rede | HTTPS saída (porta 443) | Conexão estável, baixa latência para o Azure |

> A máquina do SHIR não precisa receber conexões de entrada. Apenas tráfego de saída HTTPS para `*.servicebus.windows.net` e `*.azure.com` é necessário.

### Software — Máquina On-Premises

| Requisito | Versão | Observação |
|---|---|---|
| Self-hosted Integration Runtime | Última estável (download automático via `install_self_hosted_ir.ps1`) | Registrado com chave gerada no ADF |
| SQL Server | Express ou superior | Instância acessível localmente pela máquina do SHIR |
| PowerShell | 5.1+ | Para execução do script de instalação automatizada |
| Navegador moderno | Qualquer | Para acesso ao Azure Portal durante configuração inicial |

### Recursos Azure

| Recurso | Obrigatório | Função no Projeto |
|---|---|---|
| Azure Data Factory (V2) | ✅ | Orquestração do pipeline e hospedagem do SHIR remoto |
| Azure Data Lake Storage Gen2 | ✅ | Armazenamento das camadas Raw e Bronze |
| Azure Key Vault | ✅ | Gestão centralizada de credenciais (chave do ADLS) |
| Azure Databricks | ✅ | Processamento PySpark para promoção Raw → Bronze |
| Azure Subscription (estudante ou trial) | ✅ | Base para todos os recursos acima |

---

## Como Executar o Projeto

> ⚠️ **Este projeto simula um ambiente híbrido real.** Não é um projeto "clone & run" — exige recursos Azure provisionados e uma máquina on-premises com SQL Server. O guia completo para o SHIR está em `docs/guia_instalacao_ir.md`.

**1. Preparar o ambiente on-premises**
```powershell
# Instala o Self-hosted Integration Runtime automaticamente
.\scripts\powershell\install_self_hosted_ir.ps1
# Após instalar, registre o IR com a chave gerada no ADF Studio
```

```sql
-- Cria e popula a tabela de exemplo no SQL Server
-- Execute no SQL Server Management Studio ou Azure Data Studio
scripts/sql/create_sample_table.sql
```

**2. Provisionar recursos Azure**

No Azure Portal, crie na ordem: Key Vault → Storage Account (ADLS Gen2) → Data Factory → Databricks. Adicione a chave do ADLS como secret `adls-account-key` no Key Vault.

**3. Importar artefatos no Azure Data Factory**

No ADF Studio, importe os linked services, datasets, pipeline e trigger da pasta `adf/` nesta ordem: `LS_KeyVault` → `LS_ADLS` → `LS_SQL_OnPrem` → datasets → pipeline → trigger.

**4. Executar o pipeline**
```
No ADF Studio:
- Execução manual: Debug → informe pTabela="SampleTable" e pDataExecucao="2025-01-01"
- Execução automatizada: ative o trigger tr_daily_0200_brt (dispara às 02:00 BRT)
- Valide os arquivos gerados em raw/sql_onprem/SampleTable/ e bronze/sql_onprem/SampleTable/
```

**5. Processar com Databricks**
```python
# Abra o notebook databricks/notebooks/bronze_promote_SampleTable.ipynb
# Ajuste os caminhos raw_path e bronze_path com o nome do seu storage account
# Execute todas as células — o cluster inicializa automaticamente
```

---

## Aprendizados

- Como o Self-hosted Integration Runtime resolve na prática o problema de integração híbrida: o SHIR não é apenas uma configuração de firewall, é uma decisão arquitetural que define toda a topologia de segurança da solução
- A diferença entre versionamento de artefatos ADF (o que o Git armazena) e o estado real do Data Factory em execução — lacuna que motivou o projeto `AzureDevOpsVersiBackup`
- Por que a separação Raw/Bronze não é apenas organização: ela é um contrato de imutabilidade. A camada Raw nunca é alterada após a ingestão, garantindo replay auditável
- Como parametrizar pipelines ADF para torná-los reutilizáveis: a diferença entre um pipeline por tabela (inescalável) e um pipeline parametrizado (produtivo)
- A importância de tratar logs de execução como ativos de dados: o `run_metadata_example.json` não é apenas debug — é a evidência que um processo de BCP exige

---

## Autor

**Sergio Santos**

[![Portfólio Sérgio Santos](https://img.shields.io/badge/Portfólio-Sérgio_Santos-111827?style=for-the-badge&logo=githubpages&logoColor=00eaff)](https://portfoliosantossergio.vercel.app)
[![LinkedIn Sérgio Santos](https://img.shields.io/badge/LinkedIn-Sérgio_Santos-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/santossergioluiz)
