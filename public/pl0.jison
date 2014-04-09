/* description: Parses end executes mathematical expressions. */

%{
var symbol_table = {};

function fact (n) { 
  return n==0 ? 1 : fact(n-1) * n 
}

%}

%token NUMBER ID E PI ODD EOF IF THEN ELSE WHILE DO CALL BEGIN
/* operator associations and precedence */

%right THEN ELSE
%left '==' '>=' '<=' '<' '>' '#'
%right '='
%left '+' '-'
%left '*' '/'
%left '^'
%right '%'
%left UMINUS
%left '!'

%start prog

%% /* language grammar */
prog
    : block '.' EOF
        { 
          $$ = { type: 'program', block: $1 };
          return $$;
        }
    ;

block
    : consts vars procs statement
        {
          $$ = { type: 'block', consts: $1, vars: $2, procs: $3, st: $4 };
        }
    ;
    
consts
    : /* vac�o */
    | CONST ID '=' NUMBER r_consts ';'
        {
          $$ = [ { type: 'const', id: $2 } ];
          if ($5) $$ = $$.concat($5);
        }
    ;
    
r_consts
    : /* vac�o */
    | ',' ID '=' NUMBER r_consts
        {
          $$ = [ { type: 'const', id: $2 } ];
          if ($5) $$ = $$.concat($5);
        }
    ;
    
vars
    : /* vac�o */
    | VAR ID r_vars ';'
        {
          $$ = [ { type: 'var', id: $2 } ];
          if ($3) $$ = $$.concat($3);
        }
    ;
    
r_vars
    : /* vac�o */
    | ',' ID r_vars
        {
          $$ = [ { type: 'var', id: $2 } ];
          if ($3) $$ = $$.concat($3);
        }
    ;
    
procs
    : /* empty */
    | PROCEDURE ID args ';' block ';' procs
        {
          $$ = [ { type: 'procedure', id: $2, arguments: $3, block: $5 } ];
          if ($7) $$ = $$.concat($7);
        }
    ;

statement
    : ID '=' e
        { $$ = { type: '=', left: { type: 'ID', value: $1 }, right: $3 }; }
    | CALL ID args
        { $$ = { type: 'CALL', id: $2, arguments: $3 }; }
    | BEGIN statement statement_r END
        { 
          var v_sts = [$2];
          if ($3) v_sts = v_sts.concat($3);
          $$ = { type: 'BEGIN', statements: v_sts }; 
        }
    | IF condition THEN statement 
        { $$ = { type: 'IF', condition: $2, statement: $4 }; }
    | IF condition THEN statement ELSE statement
        { $$ = { type: 'IF', condition: $2, true_st: $4, false_st: $6 }; }
    | WHILE condition DO statement
        { $$ = { type: 'WHILE', condition: $2, statement: $4 }; }
    ;
    
statement_r
    : /* vac�o */
    | ';' statement statement_r
        {
          $$ = [$2];
          if ($3) $$ = $$.concat($3);
        }
    ;
    
args
    : /* vac�o */
    | '(' ID args_r ')'
        {
          $$ = [{ type: 'ID', value: $2 }];
          if ($3) $$ = $$.concat($3);
        }
    ;
    
args_r
    : /* vac�o */
    | ',' ID args_r
        {
          $$ = [{ type: 'ID', value: $2 }]
          if ($3) $$ = $$.concat($3);
        }
    ;
    
condition
    : ODD e
        { $$ = { type: 'ODD', e: $2 }; }
    | e COMP e
        { $$ = { type: $2, left: $1, right: $3 }; }
    ;

e
    : ID '=' e
        {$$ = { type: '=', left: { type: 'ID', value: $1 }, right: $3 }; }
    | PI '=' e 
        { throw new Error("Can't assign to constant 'π'"); }
    | E '=' e 
        { throw new Error("Can't assign to math constant 'e'"); }
    | e '+' e
        {$$ = { type: '+', left: $1, right: $3 }; }
    | e '-' e
        {$$ = { type: '-', left: $1, right: $3 }; }
    | e '*' e
        {$$ = { type: '*', left: $1, right: $3 }; }
    | e '/' e
        {$$ = { type: '/', left: $1, right: $3 }; }
    | e '^' e
        {$$ = { type: '^', left: $1, right: $3 }; }
    | e '!'
        {$$ = { type: '!', left: $1 }; }
    | e '%'
        {$$ = { type: '%', left: $1 }; }
    | '-' e %prec UMINUS
        {$$ = { type: '-', right: $2 }; }
    | '(' e ')'
        {$$ = $2;}
    | NUMBER
        {$$ = { type: 'NUM', value: Number(yytext) };}
    | E
        {$$ = Math.E;}
    | PI
        {$$ = Math.PI;}
    | ID 
        { $$ = { type: 'ID', value: $1 }; }
    ;
    