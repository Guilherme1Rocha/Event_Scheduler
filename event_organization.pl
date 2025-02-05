:- set_prolog_flag(answer_write_options,[max_depth(0)]).
:- ['dados.pl'], ['keywords.pl'].

%3.1
/*
eventosSemSalas/1,
eventosSemSalas(-EventosSemSala)
-é verdade se EventosSemSala é uma lista ordenada e sem elementos repetidos constituída
por todos os ID's cujos eventos não têm sala.*/
eventosSemSalas(EventosSemSala):-
    setof(ID,X^Y^Z^evento(ID,X,Y,Z,semSala),EventosSemSala).          


/*eventosSemSalasDiaSemana/2,
eventosSemSalasDiaSemana(+DiaSemana,-EventosSemSala_Dia)
-é verdade se EventosSemSala_Dia é uma lista ordenada e sem elementos repetidos
constituída por todos os ID's cujos eventos não têm sala,
num determinado dia da semana(DiaSemana).*/
eventosSemSalasDiaSemana(DiaSemana,EventosSemSalaDia):-
    eventosSemSalas(EventosSemSala),
    findall(ID,(horario(ID,DiaSemana,_,_,_,_),member(ID,EventosSemSala)),EventosSemSalaDia).
/*
semestres/2,
semestres(+ListaPeriodos,-ListaPeriodosSemestres), predicado auxiliar
-é verdade se ListaPeriodosSemestres é uma lista constuída pelos periodos presentes
na ListaPeriodos a que foi adicionado os respetivos semestres.*/
semestres([],[]).
semestres([H|T],Periodos):-semestres(T,Periodos_T),
    append([H,p1_2],Periodos_T,Periodos),(H==p1;H==p2).
semestres([H|T],Periodos):-semestres(T,Periodos_T),
    append([H,p3_4],Periodos_T,Periodos),(H==p3;H==p4).
/*
periodo/2,
periodo(+ListaPeriodos,-EventosPeriodo), predicado auxiliar
-é verdade se EventosPeriodo é uma lista constituida por todos os ID's cujos eventos têm
o seu periodo presente na ListaPeriodos.*/
periodo([],[]).
periodo([H|T],Eventos):-periodo(T,Eventos_T),
    setof(ID,X^Y^Z^W^horario(ID,X,Y,Z,W,H),Eventos_Periodo),
    append(Eventos_Periodo,Eventos_T,Eventos).

/*
EventosNoPeriodo/2,
eventosNoPeriodos(+ListaPeriodosSemestres,EventosPeriodoSemestre), predicado auxiliar
-é verdade se EventosPeriodoSemestre é uma lista constituída por todos os ID's cujos 
eventos têm o seu periodo/semestre presente na ListaPeriodosSemestres*/
eventosNoPeriodo(Lista_Periodos,EventosNoPeriodo):-
    semestres(Lista_Periodos,Lista_Periodos_Semestres),
    periodo(Lista_Periodos_Semestres,EventosNoPeriodo).

/*
eventosSemSalasPeriodo/2,
eventosSemSalasPeriodo(+ListaPeriodos,-EventosSemSala)
-é verdade se os EventosSemSala é uma lista constituída por todos os ID's cujos eventos
não têm sala e decorrem num periodo pertencente à ListaPeriodos.
(a contar com os eventos semestrais).*/
eventosSemSalasPeriodo(ListaPeriodos,EventosSemSalaPeriodolst):-
    eventosSemSalas(Eventos),
    eventosNoPeriodo(ListaPeriodos,EventosPeriodos),
    findall(EventosSemSalaPeriodo,(member(EventosSemSalaPeriodo,Eventos),
    member(EventosSemSalaPeriodo,EventosPeriodos)),EventosSemSalaPeriodolst_aux),
    sort(EventosSemSalaPeriodolst_aux,EventosSemSalaPeriodolst).

%3.2

/*
organizaEventos_aux/3
organizaEventos_aux(+ListaEventos,+ListaPeriodos,-EventosNoPeriodo), predicado auxiliar
-é verdade se EventosNoPeriodo é uma lista constiuída por todos os ID's pertencentes à
ListaEventos cujo período está presente na ListaPeriodos.*/
organizaEventos_aux([],_,[]).
organizaEventos_aux([H|T],[Periodo,Semestre],[H|Temp]):-
    organizaEventos_aux(T,[Periodo,Semestre],Temp),
    horario(H,_,_,_,_,P),(P==Periodo;P==Semestre).
organizaEventos_aux([H|T],[Periodo,Semestre],Eventos):-
    organizaEventos_aux(T,[Periodo,Semestre],Eventos),
    horario(H,_,_,_,_,P),P\==Periodo,P\==Semestre.
/*
organizaEventos/3
organizaEventos(+ListaEventos,+Periodo,-EventosNoPeriodo)
-é verdade se EventosNoPeriodo é uma lista constiuída por todos os ID's pertencentes à ListaEventos cujos eventos ocorrem no Periodo.*/
% organizaEventos(ListaEventos,Periodo,EventosNoPeriodo):-
%     semestres([Periodo],Periodo_Semestre),organizaEventos_aux(ListaEventos,Periodo_Semestre,EventosNoPeriodo_aux),
%     sort(EventosNoPeriodo_aux,EventosNoPeriodo).

% organizaEventos_aux([],_,[]):-!.
% organizaEventos_aux(_,[],[]):-!.
% organizaEventos_aux([H|T],Eventos,[H|Temp]):-member(H,Eventos),!,organizaEventos_aux(T,Eventos,Temp).
% organizaEventos_aux([H|T],Eventos,EventosPeriodo):-
%     \+ member(H,Eventos), organizaEventos_aux(T,Eventos,EventosPeriodo).

intersecao(_,[],[]):- !.
intersecao(L1,[P|L2],I):-
    \+ member(P,L1),!,intersecao(L1,L2,I).
intersecao(L1,[P|L2],[P|I]):-
    intersecao(L1,L2,I).

organizaEventos(ListaEventos,Periodo,EventosNoPeriodo):-
    eventosNoPeriodo([Periodo],Eventos),
    intersecao(ListaEventos,Eventos,EventosNoPeriodo_aux),
    sort(EventosNoPeriodo_aux,EventosNoPeriodo).

% intersecao([],_,[]):-!.
% intersecao(_,[],[]):-!.
% intersecao(L1,[P|L2],I):-
%     \+ member(P,L1),!,
% intersecao(L1,L2,I).
% intersecao(L1,[P|L2],[P|I]):-
%     intersecao(L1,L2,I).
/*
eventosMenoresQue/2
eventosMenoresQue(+Duracao,-ListaEventosMenoresQue)
-é verdade se ListaEventosMenoresQue é uma lista ordenada e sem elementos repetidos
constituída por todos os ID´s cujos eventos têm a duracao menor ou igual à Duracao.*/
eventosMenoresQue(Duracao,ListaEventosMenoresQue):-
    findall(ID,(horario(ID,_,_,_,Duracao_Evento,_),Duracao_Evento=<Duracao),
    ListaEventosMenoresQue_aux),
    sort(ListaEventosMenoresQue_aux,ListaEventosMenoresQue).

/*
eventosMenoresQueBool/2
eventosMenoresQueBool(+ID,+Duracao)
-é verdade se o evento identificado por ID tiver duração igual ou menor a Duracao.*/
eventosMenoresQueBool(ID,Duracao):-eventosMenoresQue(Duracao,ListaEventosMenoresQue),
    member(ID,ListaEventosMenoresQue).

/*
procuraDisciplinas/2
procuraDisciplinas(+Curso,-ListaDisciplinas)
-é verdade se ListaDisciplinas é uma lista ordenada constituída por todas as
disciplinas pertencentes ao Curso.*/
procuraDisciplinas(Curso,ListaDisciplinas):-findall(Disciplina,(evento(ID,Disciplina,_,_,_),
    turno(ID,Curso,_,_)),ListaDisciplinas_aux),
    sort(ListaDisciplinas_aux,ListaDisciplinas).

/*
organizaDiciplinas_aux/4
organizaDisciplinas_aux(ListaDisciplinas,Curso,ListaDisciplinasSemestre1,ListaDisciplinasSemestre2),predicado auxiliar
-é verdade se a ListaDisciplinasSemestre1 e ListaDisciplinasSemestre2 são listas que contenham as diciplinas do 1ºsemestre e
do 2ºsemestre (respetivamente) pertencentes ao Curso e à ListaDisciplinas.*/
organizaDisciplinas_aux([],_,[],[]).
organizaDisciplinas_aux([H|T],Curso,[H|Temp],Disciplinas_S2):-
    organizaDisciplinas_aux(T,Curso,Temp,Disciplinas_S2),
    evento(ID,H,_,_,_),turno(ID,Curso,_,_),
    horario(ID,_,_,_,_,Periodo),(Periodo==p1;Periodo==p2;Periodo==p1_2).
organizaDisciplinas_aux([H|T],Curso,Disciplinas_S1,[H|Temp]):-
    organizaDisciplinas_aux(T,Curso,Disciplinas_S1,Temp),
    evento(ID,H,_,_,_),turno(ID,Curso,_,_),
    horario(ID,_,_,_,_,Periodo),Periodo\==p1,Periodo\==p2,Periodo\==p1_2.

organizaDiciplinas_aux([],_,_,[],[]):-!.
organizaDiciplinas_aux([Head|Tail],Curso,EventosSemestre1,[Head|Temp],Semestre2):-
    organizaDiciplinas_aux(Tail,Curso,EventosSemestre1,Temp,Semestre2),
    evento(ID,H,_,_,_),turno(ID,Curso,_,_),ID


/*
organizaDisciplinas/2
organizaDisciplinas(+ListaDisciplinas,+Curso,-Semestres)
-é verdade se Semestres é uma lista com duas listas,a primeira contêm todas as disciplinas pertencentes à ListaDisciplinas 
e ao Curso do 1ºsemestre,a segunda apresenta o mesmo critério de seleção mas os elementos devem ser as disciplinas do
2ºsemestre (ambas as sublista devem estar ordenadas).*/
organizaDisciplinas(ListaDisciplinas,Curso,Semestres):-
    organizaDisciplinas_aux(ListaDisciplinas,Curso,Disciplinas_S1_aux,Disciplinas_S2_aux),
    sort(Disciplinas_S1_aux,Disciplinas_S1),sort(Disciplinas_S2_aux,Disciplinas_S2),
    append([Disciplinas_S1],[Disciplinas_S2],Semestres).

organizaDisciplinas(ListaDisciplinas,Curso,Semestres):-
    eventosNoPeriodo([p1,p2],EventosSemestre1),eventosNoPeriodo([p3,p4],EventosSemestre2),
    procuraDisciplinas(Curso,DisciplinasCurso)
    intersecao(EventosSemestre1,DisciplinasCurso,Semestre1_aux),
    intersecao(EventosSem),
    
/*
horasCurso_aux/2
horasCurso_aux(+ListaEventos,-TotalHoras), predicado auxiliar
-é verdade se TotalHoras é a soma de todas as durações de eventos presentes na ListaEventos.*/
% horasCurso_aux([],0).
% horasCurso_aux([H|T],Horas):-horasCurso_aux(T,Horas_T),horario(H,_,_,_,Duracao,_),
%     Horas is Duracao + Horas_T.
/*
somaDuracaoEventos/2
somaDuracaoEventos(+ListaDuracoes,-SomaHoras), predicado auxiliar 
-é verdade se SomaHoras é a soma de todas as duracoes presentes na ListaDuracoes.*/
somaDuracaoEventos([],0).
somaDuracaoEventos([H|T],Soma):-somaDuracaoEventos(T,Soma_T),
    Soma is Soma_T + H.

/*
horasCurso/4
horasCurso(+Periodo,+Curso,+Ano,-TotalHoras)
-é verdade se TotalHoras for a duracao total de todos os eventos ocorridos no Curso,Ano e Periodo selecionados.*/
horasCurso(Periodo,Curso,Ano,TotalHoras):-eventosNoPeriodo([Periodo],EventosPeriodo),
    findall(ID,(horario(ID,_,_,_,Duracao,_),turno(ID,Curso,Ano,_),member(ID,EventosPeriodo)),Eventos_aux),sort(Eventos_aux,Eventos),
    findall(Duracao,(horario(ID,_,_,_,Duracao,_),member(ID,Eventos)),ListaDuracoes),
    somaDuracaoEventos(ListaDuracoes,TotalHoras).

/*
evolucaoHorasCurso/2
evolucaoHorasCurso(+Curso,-Evolucao)
-é verdade se Evolucao é uma lista de tuplos an forma:(Ano,Periodo,NumHoras),sendo NumHoras o número total de horas associados ao Ano,
Periodo e ao Curso.*/
evolucaoHorasCurso(Curso,Evolucao):-
    findall((Ano,Periodo,Horas),(member(Periodo,[p1,p2,p3,p4]),member(Ano,[1,2,3]),horasCurso(Periodo,Curso,Ano,Horas)),Evolucao_aux),
    sort(Evolucao_aux,Evolucao).

%3.3
/*
ocupaSlot/5
ocupaSlot(+HoraInicioDada,HoraFimDada,HoraInicioEvento,HoraFimEvento,Horas)
-é verdade se Horas é o número de horas sobrepostas entre o Evento(HoraInicioEvento,HoraFimEvento) e o slot 
que tem início em HoraInicioDada e fim em HoraFimDada,caso não haja sobreposicão o predicado deve falhar.*/
ocupaSlot(HoraInicioD,HoraFimD,HoraInicioE,HoraFimE,Horas):-
    Horas is HoraFimE-HoraInicioE,HoraInicioE>=HoraInicioD,HoraFimE=<HoraFimD.
ocupaSlot(HoraInicioD,HoraFimD,HoraInicioE,HoraFimE,Horas):-
    Horas is HoraFimD-HoraInicioD,HoraInicioE=<HoraInicioD,HoraFimE>=HoraFimD.
ocupaSlot(HoraInicioD,HoraFimD,HoraInicioE,HoraFimE,Horas):-
    Horas is HoraFimD-HoraInicioD,HoraInicioE<HoraInicioD,HoraFimE>HoraFimD.
ocupaSlot(HoraInicioD,HoraFimD,HoraInicioE,HoraFimE,Horas):-
    Horas is HoraFimD-HoraInicioE,HoraInicioD<HoraInicioE,HoraFimD<HoraFimE,HoraFimD>HoraInicioE.
ocupaSlot(HoraInicioD,HoraFimD,HoraInicioE,HoraFimE,Horas):-
    Horas is HoraFimE-HoraInicioD,HoraInicioD>HoraInicioE,HoraFimD>HoraFimE,HoraFimE>HoraInicioD.
/*
numHorasOcupadas/6
numHorasOcupadas(+Periodo,+TipoSala,+DiaSemana,+HoraInicio,+HoraFim,SomaHoras)
-é verdade se SomaHoras for o número de horas ocupadas nas salas do tipo TipoSala, no intervalo de tempo dado (HoraInicio,HoraFim)
no DiaSemana e no Periodo selecionado.*/
numHorasOcupadas(Periodo,TipoSala,DiaSemana,HoraInicio,HoraFim,SomaHoras):-
    salas(TipoSala,Lista_Salas),
    semestres([Periodo],Lista_Periodo_Semestre),
    findall(Horas,(member(Sala,Lista_Salas),evento(ID,_,_,_,Sala),
    horario(ID,DiaSemana,HoraInicioE,HoraFimE,_,P),member(P,Lista_Periodo_Semestre),
    ocupaSlot(HoraInicio,HoraFim,HoraInicioE,HoraFimE,Horas)),Lista_Eventos_Duracao),
    somaDuracaoEventos(Lista_Eventos_Duracao,SomaHoras).
/*
ocupacaoMax/4
ocupacaoMax(+TipoSala,+HoraInicio,+HoraFim,-Max)
-é verdade se Max for o número de horas possíveis de ser ocupadas por salas do tipo TipoSala no intervalo de tempo dado,
(HoraFim-HoraInicio).*/
ocupacaoMax(TipoSala,HoraInicio,HoraFim,Max):-
    salas(TipoSala,ListaSalas),length(ListaSalas,NumeroSalas),
    Max is (HoraFim-HoraInicio) * NumeroSalas.
/*
percentagem/3
percentagem(+SomaHoras,+Max,-Percentagem)
-é verdade Percentagem for a divisão de SomaHoras por Max, multiplicada por 100.*/
percentagem(SomaHoras,Max,Percentagem):-Percentagem is (SomaHoras/Max) * 100.
/*
ocupacaoCritica/4
ocupacaoCritica(+HoraInicio,+HoraFim,+Threshold,-Resultados)
-é verdade se Resultados for uma lista ordenada constituída por tuplos do tipo:
casosCriticos(DiaSemana,TipoSala,Percentagem),formado por um dia da semana, um tipo de sala e a sua percentagem de ocupacão
(respetivamente) num intervalo de tempo dado (HoraFim-HoraInicio), são mostrados os casos onde a Percentagem está acima
do valor Threshold (o tuplo apresenta um valor de Percentagem arrendondado, no entanto em cálculos utiliza-se o valor original).*/
ocupacaoCritica(HoraInicio,HoraFim,Threshold,Resultado):-
    setof(DiaSemana,X^Y^Z^W^M^horario(X,DiaSemana,Y,Z,W,M),DiasSemana),
    setof(Periodo,X^Y^Z^W^M^horario(X,Y,Z,W,M,Periodo),Periodos),
    findall(casosCriticos(DiaSemana,TipoSala,Percentagem),(member(DiaSemana,DiasSemana),member(Periodo,Periodos),
    numHorasOcupadas(Periodo,TipoSala,DiaSemana,HoraInicio,HoraFim,SomaHoras),
    ocupacaoMax(TipoSala,HoraInicio,HoraFim,Max),percentagem(SomaHoras,Max,Percentagem_aux),Percentagem_aux=<100,
    Percentagem_aux>Threshold,ceiling(Percentagem_aux,Percentagem)),OcupacoesCriticas),
    sort(OcupacoesCriticas,Resultado).

restricao(cab1(P),OcupacaoMesa):-OcupacaoMesa = [[_,_,_],[P,_],[_,_,_]].
restricao(cab2(P),OcupacaoMesa):-OcupacaoMesa = [[_,_,_],[_,P],[_,_,_]].

restricao(honra(P1,P2),OcupacaoMesa):-OcupacaoMesa = [[_,_,_],[P1,_],[P2,_,_]];OcupacaoMesa = [[_,_,P2],[_,P1],[_,_,_]].

restricao(lado(P1,P2),OcupacaoMesa):- OcupacaoMesa = [[P1,P2,_],[_,_],[_,_,_]];
    OcupacaoMesa = [[_,P1,P2],[_,_],[_,_,_]]; OcupacaoMesa = [[_,_,_],[_,_],[P1,P2,_]];
    OcupacaoMesa = [[_,_,_],[_,_],[_,P1,P2]]; OcupacaoMesa = [[P2,P1,_],[_,_],[_,_,_]];
    OcupacaoMesa = [[P2,P1,_],[_,_],[_,_,_]]; OcupacaoMesa = [[_,P2,P1],[_,_],[_,_,_]];
    OcupacaoMesa = [[_,_,_],[_,_],[P2,P1,_]]; OcupacaoMesa = [[_,_,_],[_,_],[_,P2,P1]].

restricao(naoLado(P1,P2),OcupacaoMesa):-OcupacaoMesa = [[P1,_,P2],[_,_],[_,_,_]];OcupacaoMesa = [[_,_,_],[_,_],[P1,_,P2]];
    OcupacaoMesa = [[P1,_,_],[_,_],[P2,_,_]];OcupacaoMesa = [[P1,_,_],[_,_],[_,P2,_]];
    OcupacaoMesa = [[P1,_,_],[_,_],[_,_,P2]];OcupacaoMesa = [[_,P1,_],[_,_],[P2,_,_]];
    OcupacaoMesa = [[_,P1,_],[_,_],[_,P2,_]];OcupacaoMesa = [[_,P1,_],[_,_],[_,_,P2]];
    OcupacaoMesa = [[_,_,P1],[_,_],[P2,_,_]];OcupacaoMesa = [[_,_,P1],[_,_],[_,P2,_]];
    OcupacaoMesa = [[_,_,P1],[_,_],[_,_,P2]];OcupacaoMesa = [[P2,_,P1],[_,_],[_,_,_]];
    OcupacaoMesa = [[_,_,_],[_,_],[P2,_,P1]];OcupacaoMesa = [[P2,_,_],[_,_],[P1,_,_]];
    OcupacaoMesa = [[P2,_,_],[_,_],[_,P1,_]];OcupacaoMesa = [[P2,_,_],[_,_],[_,_,P1]];
    OcupacaoMesa = [[_,P2,_],[_,_],[P1,_,_]];OcupacaoMesa = [[_,P2,_],[_,_],[_,P1,_]];
    OcupacaoMesa = [[_,P2,_],[_,_],[_,_,P1]];OcupacaoMesa = [[_,_,P2],[_,_],[P1,_,_]];
    OcupacaoMesa = [[_,_,P2],[_,_],[_,P1,_]];OcupacaoMesa = [[_,_,P2],[_,_],[_,_,P1]];
    OcupacaoMesa = [[_,_,_],[P1,P2],[_,_,_]];OcupacaoMesa = [[P2,_,_],[P1,_],[_,_,_]];
    OcupacaoMesa = [[_,P2,_],[P1,_],[_,_,_]];OcupacaoMesa = [[_,_,P2],[P1,_],[_,_,_]];
    OcupacaoMesa = [[_,_,_],[P1,_],[P2,_,_]];OcupacaoMesa = [[_,_,_],[P1,_],[_,P2,_]];
    OcupacaoMesa = [[_,_,_],[P1,_],[_,_,P2]];OcupacaoMesa = [[_,_,_],[P2,P1],[_,_,_]];
    OcupacaoMesa = [[P1,_,_],[P2,_],[_,_,_]];OcupacaoMesa = [[_,P1,_],[P2,_],[_,_,_]];
    OcupacaoMesa = [[_,_,P1],[P2,_],[_,_,_]];OcupacaoMesa = [[_,_,_],[P2,_],[P1,_,_]];
    OcupacaoMesa = [[_,_,_],[P2,_],[_,P1,_]];OcupacaoMesa = [[_,_,_],[P2,_],[_,_,P1]];
    OcupacaoMesa = [[P2,_,_],[_,P1],[_,_,_]];OcupacaoMesa = [[_,P2,_],[_,P1],[_,_,_]];
    OcupacaoMesa = [[_,_,P2],[_,P1],[_,_,_]];OcupacaoMesa = [[_,_,_],[_,P1],[P2,_,_]];
    OcupacaoMesa = [[_,_,_],[_,P1],[_,P2,_]];OcupacaoMesa = [[_,_,_],[_,P1],[_,_,P2]];
    OcupacaoMesa = [[P1,_,_],[_,P2],[_,_,_]];OcupacaoMesa = [[_,P1,_],[_,P2],[_,_,_]];
    OcupacaoMesa = [[_,_,P1],[_,P2],[_,_,_]];OcupacaoMesa = [[_,_,_],[_,P2],[P1,_,_]];
    OcupacaoMesa = [[_,_,_],[_,P2],[_,P1,_]];OcupacaoMesa = [[_,_,_],[_,P2],[_,_,P1]].

restricao(frente(P1,P2),OcupacaoMesa):-OcupacaoMesa = [[P1,_,_],[_,_],[P2,_,_]]; OcupacaoMesa = [[_,P1,_],[_,_],[_,P2,_]];
    OcupacaoMesa = [[_,_,P1],[_,_],[_,_,P2]];OcupacaoMesa = [[P2,_,_],[_,_],[P1,_,_]];
    OcupacaoMesa = [[_,P2,_],[_,_],[_,P1,_]];OcupacaoMesa = [[_,_,P2],[_,_],[_,_,P1]].

restricao(naoFrente(P1,P2),OcupacaoMesa):-OcupacaoMesa = [[P1,P2,_],[_,_],[_,_,_]];OcupacaoMesa = [[P1,_,P2],[_,_],[_,_,_]];
    OcupacaoMesa = [[P1,_,_],[_,_],[_,P2,_]];OcupacaoMesa = [[P1,_,_],[_,_],[_,_,P2]];
    OcupacaoMesa = [[P2,P1,_],[_,_],[_,_,_]];OcupacaoMesa = [[_,P1,P2],[_,_],[_,_,_]];
    OcupacaoMesa = [[_,P1,_],[_,_],[P2,_,_]];OcupacaoMesa = [[_,P1,_],[_,_],[_,_,P2]];
    OcupacaoMesa = [[P2,_,P1],[_,_],[_,_,_]];OcupacaoMesa = [[_,P2,P1],[_,_],[_,_,_]];
    OcupacaoMesa = [[_,_,P1],[_,_],[P2,_,_]];OcupacaoMesa = [[_,_,P1],[_,_],[_,P2,_]];
    OcupacaoMesa = [[_,P2,_],[_,_],[P1,_,_]];OcupacaoMesa = [[_,_,P2],[_,_],[P1,_,_]];
    OcupacaoMesa = [[_,_,_],[_,_],[P1,P2,_]];OcupacaoMesa = [[_,_,_],[_,_],[P1,_,P2]];
    OcupacaoMesa = [[P2,_,_],[_,_],[_,P1,_]];OcupacaoMesa = [[_,_,P2],[_,_],[_,P1,_]];
    OcupacaoMesa = [[_,_,_],[_,_],[P2,P1,_]];OcupacaoMesa = [[_,_,_],[_,_],[_,P1,P2]];
    OcupacaoMesa = [[P2,_,_],[_,_],[_,_,P1]];OcupacaoMesa = [[_,P2,_],[_,_],[_,_,P1]];
    OcupacaoMesa = [[_,_,_],[_,_],[P2,_,P1]];OcupacaoMesa = [[_,_,_],[_,_],[_,P2,P1]];
    OcupacaoMesa = [[_,_,_],[P1,P2],[_,_,_]];OcupacaoMesa = [[P2,_,_],[P1,_],[_,_,_]];
    OcupacaoMesa = [[_,P2,_],[P1,_],[_,_,_]];OcupacaoMesa = [[_,_,P2],[P1,_],[_,_,_]];
    OcupacaoMesa = [[_,_,_],[P1,_],[P2,_,_]];OcupacaoMesa = [[_,_,_],[P1,_],[_,P2,_]];
    OcupacaoMesa = [[_,_,_],[P1,_],[_,_,P2]];OcupacaoMesa = [[_,_,_],[P2,P1],[_,_,_]];
    OcupacaoMesa = [[P1,_,_],[P2,_],[_,_,_]];OcupacaoMesa = [[_,P1,_],[P2,_],[_,_,_]];
    OcupacaoMesa = [[_,_,P1],[P2,_],[_,_,_]];OcupacaoMesa = [[_,_,_],[P2,_],[P1,_,_]];
    OcupacaoMesa = [[_,_,_],[P2,_],[_,P1,_]];OcupacaoMesa = [[_,_,_],[P2,_],[_,_,P1]];
    OcupacaoMesa = [[P2,_,_],[_,P1],[_,_,_]];OcupacaoMesa = [[_,P2,_],[_,P1],[_,_,_]];
    OcupacaoMesa = [[_,_,P2],[_,P1],[_,_,_]];OcupacaoMesa = [[_,_,_],[_,P1],[P2,_,_]];
    OcupacaoMesa = [[_,_,_],[_,P1],[_,P2,_]];OcupacaoMesa = [[_,_,_],[_,P1],[_,_,P2]];
    OcupacaoMesa = [[P1,_,_],[_,P2],[_,_,_]];OcupacaoMesa = [[_,P1,_],[_,P2],[_,_,_]];
    OcupacaoMesa = [[_,_,P1],[_,P2],[_,_,_]];OcupacaoMesa = [[_,_,_],[_,P2],[P1,_,_]];
    OcupacaoMesa = [[_,_,_],[_,P2],[_,P1,_]];OcupacaoMesa = [[_,_,_],[_,P2],[_,_,P1]].
/*
ocupacaoMesa_aux/2
ocupacaoMesa_aux(+ListaPessoas,+OcupacaoMesa),predicado auxiliar
-é verdade se todas as pessoas pertencentes à ListaPessoas estiver sentado à mesa.*/
ocupacaoMesa_aux([],_).
ocupacaoMesa_aux([Head|Tail],OcupacaoMesa):-ocupacaoMesa_aux(Tail,OcupacaoMesa),
    append(OcupacaoMesa,ListaPessoasMesa), member(Head,ListaPessoasMesa).
/*
ocupacaoMesa/3
ocupacaoMesa(+ListaPessoas,+ListaRestrcoes,OcupacaoMesa)                      
-é verdade se ListaPessoas for uma lista constituída por todas as pessoas a sentar
à mesa, se Lista Restricoes for uma lista formada pelas restricoes a respeitar
e OcupacaoMesa for uma lista com 3 listas,a primeira deve conter as 3 pessoas 
de um lado da mesa,a segunda deve conter as 2 pessoas nas cabeceiras da mesa e a
terceira lista deve conter as pessoas do outro lado da mesa.*/
ocupacaoMesa(_,[],_).
ocupacaoMesa(ListaPessoas,[Head|Tail],Restricao):-
    restricao(Head,OcupacaoMesa),OcupacaoMesa=Restricao,
    ocupacaoMesa(ListaPessoas,Tail,Restricao),ocupacaoMesa_aux(ListaPessoas,Restricao).