# Figure

A mini-Heroku inspired by [Dokku](https://github.com/progrium/dokku) and [Fig](https://github.com/docker/fig).

## What is it?

This project started as a fork of [Dokku](https://github.com/progrium/dokku). Instead of just deploying 12-factor apps, with the limitation of one single server, stateful apps should be accepted. Therefore, Figure uses Fig to do all internal work, which means you can have exactly same environments for development and for production.

## Installiation

The current version of Figure only supports Ubuntu. To install it on your server:

1. Install `make` and `git`.
2. Clone the repo by `git clone https://github.com/project-nsmg/figure`.
3. Run `make install` as root.
4. Run `cat ~/.ssh/id_rsa.pub | ssh {YOUR_SERVER_IP} "sudo sshcommand acl-add figure $USER"` in your local server to upload your public key.

That's it!

## License

MIT
