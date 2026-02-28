Start a docker with basic desktop environment.

Run like this
```
docker run -it --rm -v $HOME/src:$HOME/src -v $HOME/.cache:$HOME/.cache -p 5900:5900  ghcr.io/chang-ph/ubuntuvnc:main
```

Access it with tigervnc on port 5900.
