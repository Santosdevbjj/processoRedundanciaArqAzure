# Criando Processos de Redundância de Arquivos na Azure.


![Azure_Databricks01](https://github.com/user-attachments/assets/8ddea732-e045-4694-9207-87aeb9403938)

---

**DESCRIÇÃO:**

Neste projeto prático, o objetivo é criar um processo completo de redundância de arquivos utilizando recursos do Microsoft Azure. 

Através do Azure Data Factory, você aprenderá a configurar uma infraestrutura necessária, incluindo conexões com ambientes on-premises (via Integration Runtime), bancos de dados SQL (Azure e locais) e armazenamento em blob storage. 

Aprenda o passo a passo, como criar linked services, datasets e pipelines para mover dados de uma tabela SQL on-premises para o Azure Data Lake, convertendo as informações em arquivos .TXT organizados por camadas (como raw/bronze). 

O hands-on também aborda validação, publicação e execução dos pipelines, com análise de performance e boas práticas de configuração.



---


**Processo de Redundância de Arquivos na Azure**

Este projeto demonstra como implementar um **processo de redundância de arquivos** utilizando **Azure Data Factory**, **Self-hosted Integration Runtime**, **Azure Data Lake Storage Gen2** e **Databricks**.  

O objetivo é copiar dados de um **SQL Server on-premises** para o **Data Lake**, convertendo-os em arquivos `.txt/.csv` organizados por camadas (`raw` e `bronze`), garantindo redundância, escalabilidade e boas práticas de integração híbrida.

---

 **Objetivos do Projeto**
- Criar pipelines no **Azure Data Factory** para mover dados de SQL on-premises para o Data Lake.
  
- Configurar **Self-hosted Integration Runtime (IR)** para conectar ambientes locais ao Azure.
  
- Organizar dados em camadas (`raw` e `bronze`) para redundância e governança.  
- Documentar e versionar todos os artefatos no GitHub.
  
- Demonstrar boas práticas de segurança, parametrização e monitoramento.  

---

 **Tecnologias Utilizadas**
 
- **Azure Data Factory (ADF)** → Orquestração de pipelines.  
- **Self-hosted Integration Runtime (IR)** → Conexão segura com SQL on-premises.  
- **Azure Data Lake Storage Gen2 (ADLS)** → Armazenamento em camadas.  
- **Azure Key Vault** → Gerenciamento seguro de segredos.  
- **Databricks** → Processamento e promoção de dados da camada `raw` para `bronze`.  
- **SQL Server** → Base de dados on-premises.  
- **GitHub** → Versionamento e documentação.  

---

## 📂 Estrutura de Pastas e Arquivos 


<img width="805" height="1587" alt="Screenshot_20251111-165706" src="https://github.com/user-attachments/assets/e3d4e52f-41ab-41d3-9996-1bd4865d7def" />





---

## 📑 Explicação dos Arquivos

### 📁 docs/
- **imagens/adf_linked_services.png** → Print da configuração dos Linked Services no ADF.  
- **imagens/adf_datasets.png** → Print da configuração dos Datasets no ADF.  
- **arquitetura_azure.png** → Diagrama da arquitetura do projeto (ADF + IR + ADLS + Databricks).  
- **guia_instalacao_ir.md** → Guia detalhado de instalação e configuração do Self-hosted IR.  

### 📁 adf/linkedServices/
- **LS_SQL_OnPrem.json** → Linked Service para conexão com SQL Server on-premises via IR.  
- **LS_ADLS.json** → Linked Service para conexão com o Data Lake Storage Gen2.  
- **LS_KeyVault.json** → Linked Service para acessar segredos armazenados no Azure Key Vault.  

### 📁 adf/datasets/
- **DS_SQL_OnPrem_<Tabela>.json** → Dataset de origem (tabela SQL on-premises).  
- **DS_ADLS_RAW_TXT.json** → Dataset de destino na camada `raw` (arquivos TXT/CSV).  
- **DS_ADLS_BRONZE_TXT.json** → Dataset de destino na camada `bronze`.  

### 📁 adf/pipelines/
- **pl_redundancia_sql_to_datalake.json** → Pipeline principal que copia dados do SQL para o Data Lake (`raw` → `bronze`).  

### 📁 adf/triggers/
- **tr_daily_0200_brt.json** → Trigger de execução diária às 02:00 BRT.  

### 📁 databricks/
- **notebooks/bronze_promote_<tabela>.ipynb** → Notebook Databricks para promover dados da camada `raw` para `bronze`.  
- **configs/cluster_config.json** → Configuração de cluster Databricks (nós, versão Spark, auto-terminação).  

### 📁 scripts/
- **sql/create_sample_table.sql** → Script SQL para criar tabela de exemplo e inserir dados.  
- **powershell/install_self_hosted_ir.ps1** → Script PowerShell para instalar o Self-hosted IR.  

### 📁 logs/
- **samples/run_metadata_example.json** → Exemplo de log de execução de pipeline (metadata: tempo, status, registros copiados).  

---

##  Como Executar o Projeto

1. **Preparação no Azure**
   - Crie um **Resource Group**.  
   - Crie um **Storage Account** com **Data Lake Gen2** habilitado.  
   - Crie um **Data Factory**.  

2. **Instalação do Self-hosted IR**
   - Siga o guia em [`docs/guia_instalacao_ir.md`](docs/guia_instalacao_ir.md).  
   - Instale o IR na máquina local e registre com a chave do ADF.  

3. **Configuração no ADF**
   - Importe os **Linked Services** (`LS_SQL_OnPrem.json`, `LS_ADLS.json`, `LS_KeyVault.json`).  
   - Importe os **Datasets** (`DS_SQL_OnPrem_<Tabela>.json`, `DS_ADLS_RAW_TXT.json`, `DS_ADLS_BRONZE_TXT.json`).  
   - Importe o **Pipeline** (`pl_redundancia_sql_to_datalake.json`).  
   - Configure o **Trigger** (`tr_daily_0200_brt.json`).  

4. **Execução**
   - Execute manualmente o pipeline ou aguarde o trigger diário.  
   - Verifique os arquivos gerados no ADLS (`raw` e `bronze`).  

5. **Processamento com Databricks (opcional)**
   - Configure o cluster com `databricks/configs/cluster_config.json`.  
   - Execute o notebook `bronze_promote_<tabela>.ipynb` para promover dados.  

6. **Validação**
   - Consulte os logs em `logs/samples/run_metadata_example.json`.  
   - Verifique prints em `docs/imagens/` para confirmar configuração.  

---

## Prints do Projeto

- Linked Services → `docs/imagens/adf_linked_services.png`  
- Datasets → `docs/imagens/adf_datasets.png`  
- Arquitetura → `docs/arquitetura_azure.png`  

---

##  Boas Práticas
- **Segurança:** Armazene segredos no Key Vault.  
- **Governança:** Organize dados em camadas (`raw`, `bronze`).  
- **Performance:** Ajuste paralelismo no Copy Activity.  
- **Custos:** Use redundância LRS em conta de estudante.  
- **Logs:** Sempre registre metadata de execução.  

---

## Licença
Este projeto está licenciado sob a licença MIT.  
Sinta-se livre para usar e adaptar em seus próprios projetos.

---

## Conclusão
Este projeto demonstra uma solução prática e didática para **redundância de arquivos na Azure**, integrando ambientes locais e nuvem. 

Com pipelines bem estruturados, camadas de dados e documentação completa, você terá um portfólio sólido para apresentar em entrevistas e projetos reais.

---
**Autor:**
  Sergio Santos 

---
