### 🛡️ Redundância de Dados Híbrida: SQL Server On-Premises para Azure Data Lake

**Azure Data Factory • Integração Híbrida • Governança de Dados • DataOps • Continuidade de Negócio (BCP)**


![Azure_Databricks01](https://github.com/user-attachments/assets/8ddea732-e045-4694-9207-87aeb9403938)


**Bootcamp Microsoft AI for Tech - Azure Databricks**

---



📌 **Visão Geral**

Este projeto implementa uma arquitetura de redundância de dados em ambiente híbrido, com foco em Continuidade de Negócio (BCP), governança e conformidade.

A solução realiza a ingestão segura de dados de um SQL Server on-premises para o Azure Data Lake Storage Gen2 (ADLS), utilizando uma arquitetura em camadas (Raw e Bronze).

A orquestração é feita via Azure Data Factory (ADF) com Self-hosted Integration Runtime (SHIR), reproduzindo cenários reais de grandes organizações que operam sistemas legados críticos e precisam integrar dados à nuvem sem expor a infraestrutura interna.


---

🎯 **Problema de Negócio que o Projeto Resolve**

Em ambientes altamente regulados (bancos, seguradoras, setor público), é comum encontrar os seguintes desafios:

• Dependência excessiva de infraestrutura local, sem redundância geográfica

• Risco de indisponibilidade operacional, causado por falhas físicas ou lógicas

• Dificuldade de integrar dados legados à nuvem, devido a firewalls e políticas de segurança

• Exigências regulatórias relacionadas à rastreabilidade, auditoria e recuperação de desastres


Com base na minha trajetória de 15+ anos atuando em sistemas críticos bancários (Bradesco), projetei este fluxo para garantir que os dados sejam:

• Replicados de forma segura

• Armazenados com linhagem preservada

• Prontos para recuperação em cenários de contingência

• Aderentes a boas práticas de governança e compliance



---

🎯 **Objetivos do Projeto**

• Implementar pipelines de redundância híbrida usando Azure Data Factory

• Demonstrar domínio sobre Self-hosted Integration Runtime (SHIR)

• Estruturar dados em camadas Raw e Bronze, preservando o dado original

• Automatizar a promoção de dados utilizando Azure Databricks (PySpark)

• Aplicar práticas de segurança, rastreabilidade e DataOps



---

🛠️ **Decisões Técnicas & Justificativas (Trade-offs)**

🔹 Self-hosted Integration Runtime (SHIR)

Escolhido por ser o padrão corporativo para integração on-premises → cloud, permitindo:

• Tráfego seguro de dentro para fora

• Nenhuma exposição do banco à internet pública

• Aderência a políticas de firewall corporativo


🔹 **Azure Key Vault**

Centraliza credenciais e strings de conexão, evitando:

• Segredos hardcoded

• Risco operacional e falhas de compliance


🔹 **Arquitetura em Camadas (Raw → Bronze)**

• Raw: preserva o dado original, sem transformação (auditoria e replay)

• Bronze: organização mínima para consumo analítico

• Facilita governança, debugging e evolução do pipeline


🔹 **TXT/CSV vs Parquet**

TXT/CSV na camada Raw para **fidelidade ao dado original**


Processamento posterior no Databricks preparando o dado para formatos analíticos



---

🚀 **Tecnologias Utilizadas**

• **Orquestração:** Azure Data Factory (ADF)

• **Integração Híbrida:** Self-hosted Integration Runtime (SHIR)

• **Armazenamento:** Azure Data Lake Storage Gen2

• **Segurança:** Azure Key Vault

• **Processamento:** Azure Databricks (PySpark)

• **Fonte de Dados:** SQL Server (On-Premises)

• **Versionamento:** GitHub



---

🖥️ **Requisitos de Hardware e Software**

**Hardware (On-Premises)**

• Máquina dedicada para o Self-hosted IR

• Mínimo recomendado:

• 8 GB de RAM

• 2 vCPUs



**Software**

• Windows Server ou Windows 10+

• SQL Server (Express ou superior)

• Azure CLI

• Navegador moderno


**Recursos Azure**

• Azure Data Factory

• Azure Data Lake Storage Gen2

• Azure Key Vault

• Azure Databricks



---


## 📂 Estrutura de Pastas e Arquivos 


<img width="805" height="1587" alt="Screenshot_20251111-165706" src="https://github.com/user-attachments/assets/e3d4e52f-41ab-41d3-9996-1bd4865d7def" />



---

### 📁 Descrição das Pastas

• **adf/**  
Artefatos do Azure Data Factory, incluindo pipelines, datasets, linked services e triggers responsáveis pela ingestão e orquestração dos dados.

• **databricks/**  
Notebooks PySpark utilizados para promover dados da camada Raw para Bronze, aplicando organização mínima e preparando os dados para consumo analítico.

• **docs/**  
Diagramas de arquitetura, evidências visuais do Data Factory, prints de configuração e guias de instalação do Self-hosted Integration Runtime (SHIR).

• **scripts/**  
Scripts auxiliares para criação de tabelas SQL de exemplo e automação da instalação do Self-hosted Integration Runtime.

• **logs/**  
Registros e exemplos de metadata de execução dos pipelines, utilizados para auditoria, rastreabilidade, monitoramento operacional e análise de performance.

&nbsp;&nbsp;&nbsp;&nbsp;└── **samples/run_metadata_example.json**  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Exemplo real de metadata de execução de pipeline, contendo informações como status, duração, volume de dados processados e timestamps, fundamentais para ambientes regulados.


---


### 🔍 Observabilidade, Logs e Auditoria

Em ambientes corporativos e regulados, a execução bem-sucedida de um pipeline não é suficiente.
É necessário manter evidências operacionais para auditoria, análise de performance e continuidade de negócio.

A pasta `logs/` contém exemplos de **metadata de execução** dos pipelines do Azure Data Factory.

**Exemplo:** `logs/samples/run_metadata_example.json`

Este arquivo representa o tipo de informação registrada a cada execução:

- Identificação do pipeline executado
- ID único de execução (auditável)
- Janela de início e término
- Status da execução
- Volume de dados processados
- Origem e destino dos dados

Esse modelo de log permite:

- Auditoria técnica e regulatória  
- Validação de SLA e janelas operacionais  
- Investigação de falhas e incidentes  
- Evidência de redundância de dados em cenários de BCP  

A abordagem reflete práticas comuns em ambientes bancários e de missão crítica, onde **rastreabilidade e observabilidade são requisitos obrigatórios**.


---


▶️ **Como Executar o Projeto**

> ⚠️ **Importante:**
Este projeto simula um **ambiente híbrido real.**
Não é um projeto “clone & run” e exige recursos Azure provisionados.



## Passo a passo resumido

**1. Configurar o ambiente on-premises**

• Instalar SQL Server

• Seguir o guia docs/guia_instalacao_ir.md para o SHIR



**2. Provisionar recursos Azure**

• Data Factory

• Data Lake Gen2

• Key Vault

• Databricks



**3. Configurar o Azure Data Factory**

• Importar Linked Services

• Importar Datasets

• Importar Pipelines



**4. Executar o pipeline**

• Execução manual ou via Trigger

• Validar arquivos na camada Raw e Bronze



**5. Processamento com Databricks**
   

• Executar notebooks PySpark para promoção dos dados





---

🧠 **Principais Aprendizados**

• Integração segura entre ambientes híbridos

• Governança e preservação do dado original

• Arquitetura orientada à continuidade de negócio

• Uso do Spark para engenharia de promoção de dados



---

🔮 **Próximos Passos**

• Implementar Incremental Load (Delta)

• Integrar com Microsoft Purview

• Criar CI/CD para Data Factory com Azure DevOps






---

🏁 **Conclusão**

Este projeto demonstra uma solução realista, segura e governada para redundância de dados em ambientes híbridos, refletindo desafios encontrados em grandes corporações e traduzindo experiência em sistemas críticos para práticas modernas de engenharia de dados em cloud.

Mais do que uma prova técnica, este projeto demonstra capacidade de tomada de decisão em ambientes regulados, onde dados, risco e continuidade do negócio caminham juntos.







---
**Autor:**
  Sergio Santos 

---

**Contato:**

[![Portfólio Sérgio Santos](https://img.shields.io/badge/Portfólio-Sérgio_Santos-111827?style=for-the-badge&logo=githubpages&logoColor=00eaff)](https://portfoliosantossergio.vercel.app)

[![LinkedIn Sérgio Santos](https://img.shields.io/badge/LinkedIn-Sérgio_Santos-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/santossergioluiz)


---


