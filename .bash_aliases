alias taghere="find . -type d \( -path ./build -o -path ./system \) -prune -o -name \*.c -o -name \*.h -o -name \*.hh -o -name \*.cc -o -name \*.cpp -o -name \*.hpp > gtags.files; gtags -I -f ./gtags.files"
alias ..="cd .."
alias ps="ps auxf"
