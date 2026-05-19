%1. 2 nuevas Reglas
%2. 3 nuevos jugadores
%3. tipos de enemigos (vida)
%4. fuerza de ataque a las armas equipadas
%5. Ejecucion del ataque (1jug, varios jugadores)


% base de conocimiento
personaje('Elara',5,100).
personaje('Kael',6,80).
personaje('Rin',7,120).

%taller
personaje('Cain',6,90).
personaje('Abel',5,110).
personaje('Clarence',6,115).

enemigo('Orca', 50).
enemigo('Ballena', 100).
enemigo('Gran Hermano', 500).

mision(m1,'Bosque de Sombras',2,50).
mision(m2,'Cueva del Dragon',5,120).
mision(m3,'Torre Arcana',7,200).

inventario('Elara',[espada,escudo,pocion]).
inventario('Kael',[arco,flechas]).
inventario('Rin',[varita,grimorio,pocion,amuleto]).
%taller
inventario('Cain',[espada,pocion,amuleto]).
inventario('Abel',[escudo,varita,grimorio]).
inventario('Clarence',[alvin]).


%taller ataque en armas
weaponforce('espada',25).
weaponforce('escudo',5).
weaponforce('pocion',30).
weaponforce('arco',6).
weaponforce('flechas',27).
weaponforce('varita',30).
weaponforce('grimorio',20).
weaponforce('amuleto',15).
weaponforce('alvin',200).
%

requiere(m2,escudo).
requiere(m2,pocion).
requiere(m3,grimorio).
requiere(m4,pocion).

% Reglas aritmeticas y recursivas
%1. Verificacion de nivel (operador relacional >-)
puede_aceptar(Personaje,ID_Mision):-
    personaje(Personaje, Nivel,_),
    mision(ID_Mision,_,Dificultad,_),
    Nivel>=Dificultad.

%2. Cálculo recursivo de XP acumulado (Patrón factorial de 2.1)
%Caso base: 0 misiones = 0xp
xp_acumulada(0,0).
%Paso recursivo: XP(N)-XP(N-1)+(20*N)
xp_acumulada(N,Total):-
    N>0,
    N1 is N-1,
    xp_acumulada(N1,Prev),
    Total is Prev +(30*N).

%3 Verificacion de inventario con member/2
tiene_requerido(Personaje,Objeto):-
    inventario(Personaje, Lista),
    member(Objeto, Lista).

% -- Reglas de unificacion y comparacion--
%1-Detectar personajes del mismo nivel exacto (vs unificacion)
mismo_nivel(P1,P2):-
    personaje(P1,N,_),
    personaje(P2,N,_),
    P1\==P2.

%2. Validar Balance aritemtico estricto
es_balanceado(Personaje):-
    personaje(Personaje,_,Vida),
    Vida =:= 100.

%3. Ejemplo controlado de error


%--Procesamiento de listas y NLP

%1.Fusionar inventarios de dos personajes usando append/3(2.3)
fusionar_equipo(P1,P2,EquipoFusionado):-
    inventario(P1,L1),
    inventario(P2,L2),
    append(L1,L2,EquipoFusionado).

%2. Base de conjugacion (adaptacion directa de conjugar_verbo\5 en 2.3)
tiempo(presente).
tiempo(pasado).
tiempo(futuro).
persona(primera).
persona(segunda).
persona(tercera).
numero(singular).
numero(plural).

ser(presente,tercera,singular,"es").
ser(pasado,tercera,singular,"fue").
ser(futuro,tercera,singular,"será").
ser(presente,primera,singular,"soy").
ser(presente,primera,plural,"somos").

ser(presente,tercera,plural,"son").
ser(pasado,tercera,plural,"fueron").
ser(futuro,tercera,plural,"serán").

%3. Regla de inferencia con estrucura condicional(2.3)
conjugar_accion(Verbo,Tiempo,Persona,Numero,Conjugacion):-
    tiempo(Tiempo),persona(Persona),numero(Numero),
    (Verbo="ser"
    ->  ser(Tiempo,Persona,Numero,R),
        Conjugacion=R
    ;   Conjugacion=Verbo
    ).

%4. Generacion de reporte narrativo

%Actividad. Los 2 personajes pueden aceptar la mision
todos_pueden(P1, P2, MisionID) :-
    puede_aceptar(P1, MisionID),
    puede_aceptar(P2, MisionID).


generar_reporte(P1, P2, MisionID, Mensaje) :-
    todos_pueden(P1, P2, MisionID),
    mision(MisionID, Nombre, _, XP),
    sumar_niveles(P1, P2, NivelTotal),
    conjugar_accion("ser", presente, tercera, plural, FormaVerbal),
    atomic_list_concat([P1, y, P2, FormaVerbal, "capaces de completar", Nombre,
                        "por", XP, "XP (nivel combinado:", NivelTotal, ")"], ' ', Mensaje).


%Consultas Validacion Final


%recibir uno o varios jugadores, conjugacion de primera persona del plural. tercera persona en pluralnode

%entre los 2 llegan a x nivel de xp
sumar_niveles(P1, P2, Total) :-
    personaje(P1, N1, _),
    personaje(P2, N2, _),
    Total is N1 + N2.


%taller
fuerza_total(Personaje, Total) :-
    inventario(Personaje, Lista),
    findall(F, (member(Arma, Lista), weaponforce(Arma, F)), Fuerzas),
    sumlist(Fuerzas, Total).

execute_singleplayer_attack(Personaje, Enemigo, Resultado):-
    fuerza_total(Personaje, Fuerza),
    enemigo(Enemigo, Vida),
    conjugar_accion("ser", presente, tercera, singular, FormaVerbal),
    (Fuerza >= Vida
    ->  atomic_list_concat([Personaje, FormaVerbal, 'victorioso contra', Enemigo,
                            'con', Fuerza, 'de daño vs', Vida, 'de vida - Victoria!'], ' ', Resultado)
    ;   atomic_list_concat([Personaje, FormaVerbal, 'derrotado por', Enemigo,
                            'con', Fuerza, 'de daño vs', Vida, 'de vida - Derrota.'], ' ', Resultado)
    ).

excecute_grupal_attack(P1, P2, Enemigo, Resultado) :-
    fuerza_total(P1, F1),
    fuerza_total(P2, F2),
    FuerzaTotal is F1 + F2,
    enemigo(Enemigo, Vida),
    conjugar_accion("ser", presente, tercera, plural, FormaVerbal),
    (FuerzaTotal >= Vida
    ->  atomic_list_concat([P1, y, P2, FormaVerbal, 'victoriosos contra', Enemigo,
                            'con', FuerzaTotal, 'de daño vs', Vida, 'de vida - Victoria.'], ' ', Resultado)
    ;   atomic_list_concat([P1, y, P2, FormaVerbal, 'derrotados por', Enemigo,
                            'con', FuerzaTotal, 'de daño vs', Vida, 'de vida - Derrota.'], ' ', Resultado)
    ).