ANATOLY YAKOVENKO
-----------------

aeyakovenko@gmail.com   |   [GitHub](https://github.com/aeyakovenko)   |   [LinkedIn](https://www.linkedin.com/in/anatoly-yakovenko/) | [resume](http://aeyakovenko.github.io/resume.html)

[HOFs in CPP](#hofs-in-cpp)
---------------------------

Might as well do scheme next :).

```C
//compile assert macro
#define C_ASSERT(test) \
    switch(0) {\
      case 0:\
      case test:;\
    }
// ... means any number of arguments a1 -> a2 -> a3 ... -> an
// so (...) is (a1 -> a2 -> a3 ... -> an) or a list
// but i will use haskells [a] types to express lists
// where lists are expected explicitly

//count arguments
//COUNT_ARGS :: ... -> Int
#define COUNT_ARGS(...) COUNT_ARGS_(,##__VA_ARGS__,6,5,4,3,2,1,0)
#define COUNT_ARGS_(z,a,b,c,d,e,f,cnt,...) cnt

//call an object
//CALL :: (... -> a) -> (...) -> a
#define CALL(x,y) x y

//HEAD :: [a] -> a
#define HEAD(args) CALL(HEAD_,args)
#define HEAD_(a,...) a

//TAIL :: [a] -> [a]
#define TAIL(args) (CALL(TAIL_,args))
#define TAIL_(a,...) __VA_ARGS__

//UNPACK :: (...) -> ...
#define UNPACK(args) CALL(UNPACK_,args)
#define UNPACK_(...) __VA_ARGS__

#define ISEMPTY(ls) PASTE(ISEMPTY_,CALL_(COUNT_ARGS,PASTE(ISEMPTY_,CALL(COUNT_ARGS,ls))))
#define CALL_(f,a) f(a) 
#define ISEMPTY_0 a,b
#define ISEMPTY_2 1
#define ISEMPTY_1 0

//JOIN :: (...) -> (...) -> (...)
#define JOIN(l1,l2) PASTE(JOIN_,PASTE(ISEMPTY(l1),ISEMPTY(l2)))(l1,l2)
#define JOIN_00(l1,l2) (UNPACK(l1),UNPACK(l2))
#define JOIN_10(l1,l2) l2
#define JOIN_01(l1,l2) l1
#define JOIN_11(l1,l2) ()

//curry a function to it arguments
#define CURRY(f,args) JOIN(f,args)

//evaluate a function object
#define EVAL(f) EVAL_ f 
#define EVAL_(f,...) f(__VA_ARGS__)


//PASTE :: a -> b -> c
//this is really in the preprocessor domain, so hard to type
#define PASTE(aa,bb) PASTE_(aa,bb)
#define PASTE_(aa,bb) aa ## bb


//FOLDR :: (a -> b -> b) -> b -> [a] -> b
#define FOLDR(func,accum,lst)       PASTE(FOLDR_,CALL(COUNT_ARGS,lst))(func,accum,lst)
#define FOLDR_1(func,accum,lst)     EVAL_FR(CURRY(func,(HEAD(lst), accum)))
#define FOLDR_2(func,accum,lst)     EVAL_FR(CURRY(func,(HEAD(lst),FOLDR_1(func,accum,TAIL(lst)))))
#define FOLDR_3(func,accum,lst)     EVAL_FR(CURRY(func,(HEAD(lst),FOLDR_2(func,accum,TAIL(lst)))))
#define FOLDR_4(func,accum,lst)     EVAL_FR(CURRY(func,(HEAD(lst),FOLDR_3(func,accum,TAIL(lst)))))

//the map needs a different eval then the foldr
//i dont fully grok this part yet
#define EVAL_FR(f) EVAL_FR_ f 
#define EVAL_FR_(f,...) f(__VA_ARGS__)

//MAP :: (a -> b) -> [a] -> b
#define MAP(func,lst)  FOLDR((MAP_,func),(),lst)
#define MAP_(func,aa,acc)  JOIN((EVAL_MP(CURRY(func,(aa)))), acc)
#define EVAL_MP(f) EVAL_MP_ f 
#define EVAL_MP_(f,...) f(__VA_ARGS__)

int main(void) {
   C_ASSERT(0 == COUNT_ARGS());
   C_ASSERT(1 == COUNT_ARGS(1));
   C_ASSERT(2 == COUNT_ARGS(1,2));
   C_ASSERT(3 == COUNT_ARGS(1,2,3));

   C_ASSERT(12 == PASTE(1,2));

   C_ASSERT(1 == HEAD((1,2,3)));
   C_ASSERT(2 == HEAD(TAIL((1,2,3))));
   C_ASSERT(3 == HEAD(TAIL(TAIL((1,2,3,4)))))

   C_ASSERT(1 == ISEMPTY(()))
   C_ASSERT(0 == ISEMPTY((1)))
   C_ASSERT(0 == ISEMPTY((1,2)))
   C_ASSERT(0 == ISEMPTY((1,2,3)))
   C_ASSERT(1 == ISEMPTY(JOIN((),())))

   C_ASSERT(1 == HEAD(JOIN((),(1))))
   C_ASSERT(1 == HEAD(JOIN((1),())))
   C_ASSERT(1 == HEAD(JOIN((1,2),())))
   C_ASSERT(1 == HEAD(JOIN((1),(2))))
   C_ASSERT(2 == HEAD(JOIN((2),(1))))
   C_ASSERT(1 == HEAD(JOIN((1,2),(3,4))))
   C_ASSERT(2 == HEAD(TAIL(JOIN((1,2),(3,4)))))
   C_ASSERT(3 == HEAD(TAIL(TAIL(JOIN((1,2),(3,4))))))
   C_ASSERT(4 == HEAD(TAIL(TAIL(TAIL(JOIN((1,2),(3,4)))))))

   C_ASSERT(1 == EVAL(CURRY((HEAD),((1,2)))))
   C_ASSERT(12 == EVAL(CURRY((PASTE),(1,2))))
   C_ASSERT(12 == EVAL(CURRY((PASTE,1),(2))))

   C_ASSERT(123 == FOLDR((PASTE),,(1,2,3)))

   #define ID(x) x
   C_ASSERT(1 == HEAD(MAP((ID),(1,2,3))))
   C_ASSERT(1 == HEAD(MAP((ID),MAP((ID),(1,2,3)))))
   C_ASSERT(1 == HEAD(MAP((ID),MAP((ID),MAP((ID),(1,2,3))))))


   return 0;
}
```

[wtf C](#wtf-c)
---------------

```C
#include <stdio.h>
#include <string.h>

#define C_ASSERT(test) \
    switch(0) {\
      case 0:\
      case test:;\
    }

int main() {
   void (wtf)(void);
   C_ASSERT(sizeof(wtf) == 1);
   //wtf = 0;              //unasignable type error
   printf("%p\n", &wtf);   //linker error
   return 0;
}
```

So the reason a function has a size even though its unasignable is so we can do arithmetic on function pointers.

```C
   assert(main+1 == ((char*)main)+1);
```


[counting args in CPP](#count-args-in-cpp)
------------------------------------------

```C
/**
 * we need a comma at the start for ##_VA_ARGS__ to consume then
 * the arguments are pushed out in such a way that 'cnt' ends up with
 * the right count.  
 */
#define COUNT_ARGS(...) COUNT_ARGS_(,##__VA_ARGS__,6,5,4,3,2,1,0)
#define COUNT_ARGS_(z,a,b,c,d,e,f,cnt,...) cnt

#define C_ASSERT(test) \
    switch(0) {\
      case 0:\
      case test:;\
    }

int main() {
   C_ASSERT(0 ==  COUNT_ARGS());
   C_ASSERT(1 ==  COUNT_ARGS(a));
   C_ASSERT(2 ==  COUNT_ARGS(a,b));
   C_ASSERT(3 ==  COUNT_ARGS(a,b,c));
   C_ASSERT(4 ==  COUNT_ARGS(a,b,c,d));
   C_ASSERT(5 ==  COUNT_ARGS(a,b,c,d,e));
   C_ASSERT(6 ==  COUNT_ARGS(a,b,c,d,e,f));
   return 0;
}
```

[compile time assert](compile time assert)
------------------------------------------

```C
#define C_ASSERT(test) \
    switch(0) {\
      case 0:\
      case test:;\
    }
```

[make repl](#make-repl)
-----------------------

```Makefile
#run make '$(expression)' to see what make thinks the expression evaluates to from your rules
$$%:;@$(call true)$(info $(call or,$$$*))
```

[make cabal](#make-cabal)
-------------------------

```Makefile
#list of haskell sources
hs_files=RBM/List.hs
#list of cabal files
cabal_files=rbm.cabal

all:dist/cabal.test.ok dist/cabal.perf.ok dist/cabal.build.ok

dist/cabal.perf.ok:$(hs_files) dist/setup-config
	cabal bench 2>&1
	@touch $@

dist/cabal.test.ok:$(hs_files) dist/setup-config
	cabal test 2>&1
	@touch $@

dist/cabal.build.ok:$(hs_files) dist/setup-config
	cabal build 2>&1
	@touch $@

clean:
	cabal clean

dist/setup-config:$(cabal_files) Makefile
	cabal install --only-dependencies
	cabal configure --enable-tests --enable-coverage --enable-library-profiling
	@touch $@

$$%:;@$(call true)$(info $(call or,$$$*))
```

[cgdb highlight current line](#cgdb-hi-cul)
--------------------------------------------

```VimL
:hi SelectedLineNr cterm=reverse
```

[printing all the gcc defines](#printing-all-the-gcc-defines)
--------------------------------------------------------

```bash
gcc -dM -E - < /dev/null
```


[disable warnings in gcc](#disable-warnings-in-gcc)
-----------------------

```C
#pragma GCC system_header
```

works great for generated code.

[git-add-p4-opened](#git-add-p4-opened)
----------------------------------

```bash
alias git-add-p4-opened="p4 opened | cut -f 1 -d '#' | xargs p4 where | cut -f 3 -d ' ' | xargs git add"
```

[map capslock to leftctrl in windows](#win-capslock)
----------------------------------------------------
create a file with the following registery script, then run it
```
REGEDIT4
[HKEY_CURRENT_USER\Keyboard Layout]
"Scancode Map"=hex:00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00
```

[.vimrc](#vimrc)
----------------
```VimL
"remembering cursor position between sessions
:set viminfo='10,\"100,:20,%,n~/.viminfo
      
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction
      
augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

:syntax on
:set nowrapscan
:set autoindent
:set expandtab
:set tabstop=4
:set ruler
:set shiftwidth=4
:set ignorecase
:set smartcase
:set tags=./tags;
:set noswapfile
:map <tab> <C-w><C-w>
:set wildmode=longest,list,full
:set wildmenu
"underline spell check
:hi clear SpellBad
:hi SpellBad cterm=underline
"sane highlights for vimdiff
highlight DiffAdd term=reverse cterm=bold ctermbg=green ctermfg=white
highlight DiffChange term=reverse cterm=bold ctermbg=cyan ctermfg=black
highlight DiffText term=reverse cterm=bold ctermbg=gray ctermfg=black
highlight DiffDelete term=reverse cterm=bold ctermbg=red ctermfg=black

"use tabs in linux kernel code
:au BufNewFile,BufRead /*kernel* set tabstop=8
:au BufNewFile,BufRead /*kernel* set shiftwidth=8
:au BufNewFile,BufRead /*kernel* set noexpandtab
```
