FROM node:alpine

ARG full

RUN apk update && apk upgrade && \
    apk add bash tmux zsh git neovim && \
    rm -rf /var/cache/apk/*

RUN test "$full" && \
    apk add gcc python3 python3-dev py3-pip musl-dev && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    rm -rf /var/cache/apk/* || true

RUN test "$full" && \
    git clone https://github.com/ranger/ranger && \
    cd ranger && \
    python setup.py install --optimize=1 --record=install_log.txt && \
    cd / && rm -r ranger || true

RUN test "$full" && \
    apk add gcc && \
    pip install neovim && \
    apk del gcc && \
    rm -rf /var/cache/apk/* || true

RUN sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

RUN git clone https://github.com/cviejo/dotfiles && \
    mv /dotfiles/.git $HOME/ && \
    rm -r dotfiles

RUN cd $HOME && git reset --hard

RUN nvim -E -c PlugInstall -c qa &>/dev/null || \
    find $HOME/.vim/plugged -name .git | xargs rm -r || true

RUN sed -i -e "s/bin\/ash/bin\/zsh/" /etc/passwd

# COPY $HOME/.config/yarn/global/package.json /home/

ENV SHELL /bin/zsh

ENTRYPOINT /bin/zsh

# RUN test "$full" && \
	 # apk add gcc python3 python3-dev py3-pip musl-dev && \
	 # ln -sf /usr/bin/python3 /usr/bin/python && \
	 # ln -sf /usr/bin/pip3 /usr/bin/pip && \
	 # pip install neovim && \
	 # git clone https://github.com/ranger/ranger && \
	 # cd ranger && \
	 # python setup.py install --optimize=1 --record=install_log.txt && \
	 # cd / && rm -r ranger && \
	 # apk del gcc && \
	 # rm -rf /var/cache/apk/* || true

