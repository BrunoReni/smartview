#INCLUDE "protheus.ch"
#INCLUDE "quicksearch.ch"
#INCLUDE "MATQ150.ch" 

QSSTRUCT MATQ15001 DESCRIPTION STR0001 MODULE 2	//-- Cotações

QSMETHOD INIT QSSTRUCT MATQ15001

//-- Tabelas envolvidas na consulta e seus relacionamentos
QSTABLE "SC8" JOIN "SA2" ON "A2_COD = C8_FORNECE AND A2_LOJA = C8_LOJA"
QSTABLE "SC8" JOIN "SB1" ON "B1_COD = C8_PRODUTO"

//-- Campos/índices utilizados para a pesquisa
QSPARENTFIELD "C8_PRODUTO" INDEX ORDER 9 LABEL STR0002	//-- Código do Produto
QSPARENTFIELD "A2_NOME" INDEX ORDER 2 SET RELATION TO "C8_FORNECE","C8_LOJA" WITH "A2_COD","A2_LOJA" LABEL STR0003	//-- Nome do Fornecedor

//-- Opcoes de filtro
QSFILTER STR0004 WHERE "C8_PRECO > 0 AND C8_EMISSAO >= '" +DToS(Date() - 30) +"'"	//-- Últimos 30 dias
QSFILTER STR0005 WHERE "C8_PRECO > 0 AND C8_EMISSAO >= '" +DToS(Date() - 60) +"'"	//-- Últimos 60 dias
QSFILTER STR0006 WHERE "C8_PRECO > 0 AND C8_EMISSAO >= '" +DToS(Date() - 90) +"'"	//-- Últimos 90 dias
QSFILTER STR0007 WHERE "C8_PRECO > 0 AND C8_EMISSAO >= '" +DToS(Date() - 120) +"'"	//-- Últimos 120 dias
QSFILTER STR0008 WHERE "C8_PRECO > 0 AND C8_EMISSAO >= '" +DToS(Date() - 360) +"'"	//-- Últimos 360 dias
QSFILTER STR0009 WHERE "C8_PRECO > 0"	//-- Todos

//-- Campos da consulta rapida
QSFIELD "C8_FILIAL" LABEL STR0010	//-- Empresa
QSFIELD "C8_NUM" LABEL STR0011		//-- Número da Cotação
QSFIELD "C8_PRODUTO" LABEL STR0002	//-- Código do Produto
QSFIELD "B1_DESC" LABEL STR0012		//-- Descrição do Produto
QSFIELD "A2_NOME" LABEL STR0003		//-- Nome do Fornecedor
QSFIELD "MOEDA" BLOCK {|| SuperGetMV("MV_MOEDA"+AllTrim(Str(C8_MOEDA)),.F.,"")} FIELDS "C8_MOEDA" LABEL STR0013 TYPE "C" SIZE 15	//-- Moeda
QSFIELD "C8_PRECO" LABEL STR0014	//-- Preço Unitário
QSFIELD "C8_VALIDA" LABEL STR0015	//-- Data de Validade

//-- Acoes relacionadas
QSACTION MENUDEF "MATA160" OPERATION 2 LABEL STR0016	//-- Detalhes da Cotação
QSACTION MENUDEF "MATA020" OPERATION 2 LABEL STR0017	//-- Detalhes do Fornecedor
QSACTION MENUDEF "MATA010" OPERATION 2 LABEL STR0018	//-- Detalhes do Produto

Return
