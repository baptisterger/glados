##
## EPITECH PROJECT, 2024
## B-FUN-400-TLS-4-1-wolfram-baptiste.roger
## File description:
## Makefile
##

NAME = glados2

all:
	stack build
	cp $(shell stack path --local-install-root)/bin/$(NAME)-exe	./$(NAME)

clean:
	stack clean

fclean: clean
	rm -f $(NAME)
	rm -rf ./.stack-work

re: fclean all