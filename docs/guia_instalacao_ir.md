# Guia de Instalação do Self-hosted Integration Runtime (IR)  
**Projeto: Processo de Redundância de Arquivos na Azure**

---

## 📌 Objetivo
Este guia descreve o passo a passo para instalar e configurar o **Self-hosted Integration Runtime (IR)**, que permite ao **Azure Data Factory** acessar dados de ambientes **on-premises** (como SQL Server local) e transferi-los para o **Azure Data Lake Storage Gen2**.

---

## 🖥️ Requisitos

### Hardware
- **Sistema Operacional:** Windows 10/11 ou Windows Server 2016+  
- **CPU:** 2 núcleos ou mais  
- **Memória RAM:** mínimo 4 GB (recomendado 8 GB)  
- **Disco:** 2 GB livres para instalação  
- **Rede:** acesso à internet (HTTPS habilitado)

### Software
- Conta Microsoft Azure (plano estudante gratuito)  
- SQL Server instalado e acessível na máquina local  
- Permissões de administrador para instalar o IR  
- Navegador atualizado para acessar o Azure Portal  

---

## 🔑 Preparação no Azure Data Factory

1. Acesse o **Azure Portal** → Crie um recurso **Data Factory**.  
2. No **ADF Studio**, vá em **Manage → Integration Runtimes → New**.  
3. Selecione **Self-hosted**.  
4. Copie a **chave de autenticação** gerada (será usada na instalação local).  

---

## ⚙️ Instalação do IR na máquina local

1. Baixe o instalador oficial:  
   [Download Integration Runtime](https://go.microsoft.com/fwlink/?linkid=2155943)  

2. Execute o instalador:  
   - Clique em **Next** → aceite os termos → escolha o diretório padrão.  
   - Finalize a instalação.  

3. Após instalar, abra o **Integration Runtime Configuration Manager**.  
4. Insira a **chave de autenticação** copiada do Azure Data Factory.  
5. Clique em **Register** → aguarde até o status aparecer como **Online**.  

---

## 🔄 Configuração de Conexão

- **Firewall:** libere portas **443 (HTTPS)**.  
- **Proxy (se houver):** configure no IR Manager.  
- **SQL Server:** confirme que a instância está acessível pela máquina do IR.  

---

## ✅ Teste de Conectividade

1. No **ADF Studio**, crie um **Linked Service** para SQL On-premises.  
2. Configure para usar o **Self-hosted IR**.  
3. Clique em **Test Connection**.  
4. Se o status for **Successful**, a instalação está concluída.  

---

## 🛡️ Boas Práticas

- Instale o IR em uma máquina dedicada ou servidor estável.  
- Mantenha o IR atualizado (verifique patches no portal).  
- Configure **alta disponibilidade** instalando o IR em mais de uma máquina.  
- Monitore logs de execução para identificar falhas de rede ou autenticação.  

---

## 📂 Estrutura do Projeto

Este guia faz parte do repositório:  
`processoRedundanciaArqAzure/docs/guia_instalacao_ir.pdf`

---

## 📸 Prints recomendados para incluir no PDF

- Tela de criação do Integration Runtime no ADF.  
- Tela de instalação do IR local.  
- Tela de configuração com chave de autenticação.  
- Status “Online” no IR Manager.  
- Teste de conexão bem-sucedido no Linked Service.  

---

## 🚀 Conclusão

Com o Self-hosted IR instalado e configurado, o **Azure Data Factory** pode acessar dados locais e transferi-los para o **Azure Data Lake**, garantindo redundância e integração híbrida entre ambientes on-premises e cloud.
