:- include('KB.pl').

bottle(1).
bottle(2).
bottle(3).

initialize_colors :-
	retractall(color(_)),  % Remove all color facts
    findall(Color, 
            (bottle1(Color, _); bottle1(_, Color); 
             bottle2(Color, _); bottle2(_, Color); 
             bottle3(Color, _); bottle3(_, Color)), 
            Colors),
    sort(Colors, UniqueColors),      % Remove duplicates by sorting
    maplist(assertz_color, UniqueColors).


assertz_color(Color) :-
    assertz(color(Color)).

:- initialization(initialize_colors).


situation(s0).
situation(result(pour(I, J), S)) :-
    situation(S), 
    bottle(I),     
    bottle(J),     
    I \= J,        
    isValidPour(I, J, S).  
situation(result(pour(I, J), S)) :-
    situation(S),  
    bottle(I),     
    bottle(J),!.       

isValidPour(I, J, S) :-
    \+ isEmpty(I, S),  
    \+ isFull(J, S),
	isTopColor(I,C, S),
	(isTopColor(J,C, S); isEmpty(J,S)).   

isTopColor(B,C, S) :-
	bottle(B),
	color(C),
	C\=e,
   	(top(B, C, S);
    (top(B, e, S), bottom(B, C, S))).

isFull(B,S):- 
	bottle(B),
	\+ top(B,e,S) ,
	\+ bottom(B,e,S).

isEmpty(B,S):- 
	bottle(B),
	top(B,e,S) ,
	bottom(B,e,S).


% Clauses for top/3
top(1, T, s0) :- bottle1(T, _).
top(2, T, s0) :- bottle2(T, _).
top(3, T, s0) :- bottle3(T, _).


top(B,C, result(pour(I, B), S)) :-
	bottle(B),
	color(C),
	bottle(I),
	I \= B,
	C \= e,
	\+ isEmpty(I,S),
    isTopColor(I, C, S),  
    top(B, e, S),  
    bottom(B, C, S).

top(B,C, result(pour(B, J), S)) :-
	bottle(B),color(C),
	bottle(J),
	B \= J, 
	C = e,
	\+ isFull(J, S),
	\+ top(B,e,S),
	top(B,C1,S),
	(isTopColor(J,C1, S); isEmpty(J,S)).
	
top(B,C, result(pour(B, J), S)) :-
	bottle(B),color(C),
	bottle(J),
	top(B,C,S),
	(top(B, e, S); 
	isFull(J, S); (\+top(B, e, S),\+ isTopColor(J,C,S), \+isEmpty(J,S))).

top(B,C, result(pour(I, B), S)) :-
	bottle(B),color(C),
	bottle(I),
	top(B,C,S),
	(isEmpty(I, S); 
	\+top(B,e,S);isEmpty(B, S);(bottom(B,C1,S),C1\=e,\+isTopColor(I,C1, S))).
				
	
top(B,C, result(pour(I, J), S)) :-
	bottle(B),color(C),	
	bottle(I),bottle(J),
	(I \= B , J \= B),
	top(B,C,S).


% Clauses for bottom/3
bottom(1, B, s0) :- bottle1(_, B).
bottom(2, B, s0) :- bottle2(_, B).
bottom(3, B, s0) :- bottle3(_, B).
	

bottom(B,C, result(pour(I, B), S)) :-
	bottle(B),
	color(C),
	bottle(I),
    C \= e,
	I\=B,
	\+ isEmpty(I,S),
    isTopColor(I, C, S),  
    isEmpty(B,S).

bottom(B, C, result(pour(B, J), S)) :-
	bottle(B),
	color(C),
	bottle(J),
	C = e,
	B\=J,
	top(B, e, S), 
	\+ isFull(J, S),	
	bottom(B,C1,S),
	(isTopColor(J,C1, S); isEmpty(J,S)).

bottom(B,C ,result(pour(B, J), S)) :-
	bottle(B),
	color(C),
	bottle(J),
	bottom(B,C,S),
	(bottom(B, e, S);
	\+ top(B,e,S);
	isFull(J, S) ;
	(top(B,e,S),C\=e,\+ isTopColor(J,C,S), \+isEmpty(J,S))).	

bottom(B,C, result(pour(I, B), S)) :-
	bottle(B),color(C),
	bottle(I),
	bottom(B,C,S),
    (isEmpty(I, S); 
    \+bottom(B,e, S)).
	
bottom(B,C, result(pour(I, J), S)) :-
	bottle(B),color(C),
	bottle(I),bottle(J),
	(I \= B , J \= B),
	bottom(B,C,S).
	
	
is_goal(S) :-
	situation(S),
    top(1, A, S), bottom(1, A, S),
    top(2, B, S), bottom(2, B, S),
    top(3, C, S), bottom(3, C, S).
	
ids(X,L):-
	(call_with_depth_limit(is_goal(X),L,R), number(R));
	(call_with_depth_limit(is_goal(X),L,R), R=depth_limit_exceeded,
	L1 is L+1, ids(X,L1)).
 
 goal(S):-
	ids(S,1000).