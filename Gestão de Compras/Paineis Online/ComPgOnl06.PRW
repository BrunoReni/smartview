#INCLUDE "Protheus.ch"
#INCLUDE "MSgraphi.ch"
/*                                                                     
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ComPgOnl06�Autor  �Alexandre Inacio Lemes �Data  �06/02/2007���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta array para Painel de Gestao On-line Tipo\Padrao 2.2: ���
���          � Autorizacos de Entrega em Aberto                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ComPgOnl06(nTipo) 1 =Pedido Compras / 2 =Autorizacao Entrega���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {cTypeGraf,{cTitleG,bClickG,aEixoX,aEixoY},        ���
���          � {cTitleT,bClickT,aTabela}}                                 ���
���          � cTypeGraph = Tipo do grafico                       		  ���
���          � cTitleG    = Titulo do grafico                      		  ���
���          � bClickG    = Bloco de codigo executado no click do grafico ���
���          � aEixoX     = Atributos do eixo X                           ���
���          � aEixoY     = Atributos do eixo Y                           ���
���          � cTitleT    = Titulo da tabela                              ���
���          � bClickT    = Bloco de codigo executado no click da tabela  ���
���          � aTabela    = Array multidimensional contendo os array por  ���
���          � filtro, no formato{"filtro",aCabec,aValores}               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGACOM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ComPgOnl06(oObj)

Local aPanel := {}

aPanel := ComPgOnl05(oObj,2)

Return aPanel
