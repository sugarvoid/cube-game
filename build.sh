#!/bin/bash
zip -9 -r down_mail.love . \
    --exclude '*.git*' \
    '*.vscode*' \
    'gameplay.mp4'\
    'build.sh' \
    'todo.md' \
    'sublime-build.txt' \
    'asset/image/down_mail.png' \
    'asset/image/down_mail.svg'
