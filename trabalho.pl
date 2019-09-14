%swipl -s trabalho.pl 
%itaú = 1, Santander = 2, Consultor = 3, Caixa = 4
%pessoa(nome, renda, poupado, estabilidade, dependentes)
%banco(nome, renda, poupado, estabilidade, dependentes)
%carteira(banco, tempo, valor)

pessoa(juliano,     500,    250,    estavel,   0).
pessoa(mariana,     9000,   25000,  estavel,    4).
pessoa(louise,      90000,  25000,  estavel,    1).

banco(itau,         7500,   2500,   estavel,    2000).
banco(consultor,    15000,  5000,   estavel,    4000).
banco(santander,    30000, 10000,   estavel,    8000).
banco(caixa,        50,     500,    estavel,    50).

carteira(Banco, Tempo, 1) :- Banco == itau, Tempo < 13,!.
carteira(Banco, Tempo, 3) :- Banco == itau, Tempo >= 13, Tempo < 60,!.
carteira(Banco, Tempo, 5) :- Banco == itau, Tempo >= 60, Tempo < 120,!.
carteira(Banco, Tempo,10) :- Banco == itau, Tempo > 120,!.

carteira(Banco, Tempo, 2) :- Banco == santander, Tempo < 61,!.
carteira(Banco, Tempo, 6) :- Banco == santander, Tempo >= 61, Tempo < 84,!.
carteira(Banco, Tempo, 9) :- Banco == santander, Tempo >= 84, Tempo < 144,!.
carteira(Banco, Tempo,10) :- Banco == santander, Tempo > 144,!.

carteira(Banco, Tempo, 1) :- Banco == consultor, Tempo >= 0,!. 

carteira(Banco, Tempo, 1) :- Banco == caixa, Tempo < 25,!.
carteira(Banco, Tempo, 6) :- Banco == caixa, Tempo >= 25, Tempo < 84,!.
carteira(Banco, Tempo, 9) :- Banco == caixa, Tempo >= 84, Tempo < 240,!.
carteira(Banco, Tempo,14) :- Banco == caixa, Tempo > 240,!.

poupanca_pessoa(Cliente, Valor) :- pessoa(Cliente,_, Valor, _, _).
renda_pessoa(Nome, Valor):- pessoa(Nome, Valor, _, _, _).
estabilidade_pessoa(Nome, Estabilidade) :- pessoa(Nome, _, _, Estabilidade, _).
dependentes_pessoa(Nome, Dependentes) :- pessoa(Nome, _, _, _, Dependentes).

poupanca_banco(Nome, Valor) :- banco(Nome, _, Valor, _, _).
renda_banco(Nome, Renda) :- banco(Nome, Renda, _, _, _).
estabilidade_banco(Nome, Estabilidade) :- banco(Nome, _, _, Estabilidade, _).
dependentes_banco(Nome, Dependentes) :- banco(Nome, _, _, _, Dependentes).


regra_poupanca(Banco, Cliente, adequada):-
    poupanca_pessoa(Cliente,ValorPoupado),
    poupanca_banco(Banco, ValorCadaDependente),
    dependentes_pessoa(Cliente, NumeroDependente),
    ValorPoupado >= ValorCadaDependente * NumeroDependente + ValorCadaDependente.

regra_poupanca(Banco, Cliente, inadequada) :-
    poupanca_pessoa(Cliente,ValorPoupado),
    poupanca_banco(Banco, ValorCadaDependente),
    dependentes_pessoa(Cliente, NumeroDependente),
    ValorPoupado < ValorCadaDependente * NumeroDependente + ValorCadaDependente.

regra_renda(Banco, Nome, adequada) :-
    renda_pessoa(Nome, RendaPessoa),
    renda_banco(Banco, RendaBanco),
    dependentes_pessoa(Nome, NumeroDependente),
    dependentes_banco(Banco, Adicional),
    estabilidade_pessoa(Nome, EstabilidadePessoa),
    estabilidade_banco(Banco, EstabilidadeBanco),
    EstabilidadePessoa == EstabilidadeBanco,
    RendaPessoa >= RendaBanco + NumeroDependente * Adicional.

regra_renda(Banco, Nome, meia_adequada) :-
    renda_pessoa(Nome, RendaPessoa),
    renda_banco(Banco, RendaBanco),
    dependentes_pessoa(Nome, NumeroDependente),
    dependentes_banco(Banco, Adicional),
    estabilidade_pessoa(Nome, EstabilidadePessoa),
    estabilidade_banco(Banco, EstabilidadeBanco),
    EstabilidadePessoa == EstabilidadeBanco,
    RendaPessoa < RendaBanco + NumeroDependente * Adicional + Adicional.

regra_renda(Banco, Nome, inadequada) :-
    renda_pessoa(Nome, RendaPessoa),
    renda_banco(Banco, RendaBanco),
    dependentes_pessoa(Nome, NumeroDependente),
    dependentes_banco(Banco, Adicional),
    estabilidade_pessoa(Nome, EstabilidadePessoa),
    estabilidade_banco(Banco, EstabilidadeBanco),
    EstabilidadePessoa == EstabilidadeBanco,
    RendaPessoa < RendaBanco + NumeroDependente * Adicional + Adicional.

tipo_investimento(Banco,Nome, acao) :-
    regra_poupanca(Banco,Nome,RespostaPoupanca),
    RespostaPoupanca == adequada,
    regra_renda(Banco,Nome,RespostaRenda),
    RespostaRenda == adequada.

tipo_investimento(Banco,Nome, acao_poupanca) :-
    regra_poupanca(Banco,Nome,RespostaPoupanca),
    RespostaPoupanca == adequada.

tipo_investimento(Banco, Nome, poupanca) :-
    regra_poupanca(Banco,Nome, RespostaPoupanca),
    RespostaPoupanca == inadequada.

retorno_investimento(Banco, Nome, Tempo, Retorno) :-
    pessoa(Nome, _, Poupado, _, _),
    carteira(Banco, Tempo, ROI),
    X is Poupado * ROI,
    Retorno is X / 100.

retorno_investimento_por_banco(Nome, Tempo) :-
    banco(BC,_,_,_,_),
    pessoa(Nome, _, Poupado, _, _),
    carteira(BC, Tempo, ROI),
    X is Poupado * ROI,
    Retorno is X / 100,
    write("No banco "), write(BC), write(" o retorno será de RS "), 
    write(Retorno), write(" em "), write(Tempo), write(" meses.").