alias taghere="find . -not \( -path ./ndk -prune \) -not \( -path ./prebuilts -prune \) -not \( -path ./external -prune \) -name \*.c -o -name \*.h -o -name \*.cc -o -name \*.cpp -o -name \*.hpp > gtags.files; gtags -I -f ./gtags.files"