:- include('KB.pl').

bottle(1).
bottle(2).
bottle(3).

color(r).
color(b).
color(e).

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
    \+ isFull(J, S).   

isTopColor(B,C, S) :-
	bottle(B),
	color(C),
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
	% \+ top(B,C,S),
	\+ isEmpty(I,S),
    isTopColor(I, C, S),  
    top(B, e, S),  
    \+ bottom(B, e, S).

top(B,C, result(pour(B, J), S)) :-
	bottle(B),color(C),
	bottle(J),
	B \= J, 
	C = e,
	% \+ top(B,C,S),
    \+ isFull(J, S),
	\+ top(B,e,S).
	
top(B,C, result(pour(B, J), S)) :-
	bottle(B),color(C),
	bottle(J),
	top(B,C,S),
    (top(B, e, S); 
    isFull(J, S)).	

top(B,C, result(pour(I, B), S)) :-
	bottle(B),color(C),
	bottle(I),
	top(B,C,S),
    (isEmpty(I, S); 
    \+top(B,e,S);isEmpty(B, S)).
	
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
	bottle(B),color(C),
	bottle(I),
    C \= e,
	I\=B,
	% \+ bottom(B,C,S),
	\+ isEmpty(I,S),
    isTopColor(I, C, S),  
    isEmpty(B,S).

bottom(B, C, result(pour(B, J), S)) :-
	bottle(B),color(C),
	bottle(J),
	C = e,
	B\=J,
	% \+ bottom(B,C,S),
    top(B, e, S), 
    \+ isFull(J, S).

bottom(B,C ,result(pour(B, J), S)) :-
	bottle(B),color(C),
	bottle(J),

	bottom(B,C,S),
    (bottom(B, e, S);
	\+ top(B,e,S);
    isFull(J, S)).

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
	
	
isGoal(S) :-
	color(A),color(B),color(C),
	A \= B , A \= C , B \= C,
	situation(S),
    top(1, A, S), bottom(1, A, S),
    top(2, B, S), bottom(2, B, S),
    top(3, C, S), bottom(3, C, S).
	
ids(X,L):-
	(call_with_depth_limit(isGoal(X),L,R), number(R));
	(call_with_depth_limit(isGoal(X),L,R), R=depth_limit_exceeded,
	L1 is L+1, ids(X,L1)).
 
 goal(S):-
	ids(S,1000),!.